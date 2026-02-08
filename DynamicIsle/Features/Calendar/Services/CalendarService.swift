import Foundation
import EventKit
import Combine

/// Service for accessing calendar events via EventKit
class CalendarService: ObservableObject {
    static let shared = CalendarService()

    @Published var upcomingEvents: [CalendarEvent] = []
    @Published var nextEvent: CalendarEvent?
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined

    private let eventStore = EKEventStore()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        checkAuthorization()
        setupRefreshTimer()

        // Listen for calendar changes
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .sink { [weak self] _ in
                self?.fetchEvents()
            }
            .store(in: &cancellables)
    }

    // MARK: - Authorization

    func checkAuthorization() {
        if #available(macOS 14.0, *) {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        } else {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }

        if authorizationStatus == .authorized {
            fetchEvents()
        }
    }

    func requestAccess() async -> Bool {
        do {
            if #available(macOS 14.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                await MainActor.run {
                    authorizationStatus = granted ? .authorized : .denied
                    if granted { fetchEvents() }
                }
                return granted
            } else {
                let granted = try await eventStore.requestAccess(to: .event)
                await MainActor.run {
                    authorizationStatus = granted ? .authorized : .denied
                    if granted { fetchEvents() }
                }
                return granted
            }
        } catch {
            print("Calendar access error: \(error)")
            return false
        }
    }

    // MARK: - Fetching Events

    private func setupRefreshTimer() {
        // Refresh events every minute
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.fetchEvents()
        }
    }

    func fetchEvents() {
        guard authorizationStatus == .authorized else { return }

        let now = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now

        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: endDate,
            calendars: nil
        )

        let ekEvents = eventStore.events(matching: predicate)
            .filter { !$0.isAllDay } // Skip all-day events
            .sorted { $0.startDate < $1.startDate }

        DispatchQueue.main.async {
            self.upcomingEvents = ekEvents.prefix(5).map { CalendarEvent(from: $0) }
            self.nextEvent = self.upcomingEvents.first
        }
    }

    deinit {
        timer?.invalidate()
    }
}

// MARK: - Calendar Event Model

struct CalendarEvent: Identifiable, Equatable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let calendarColor: CGColor?
    let isAllDay: Bool

    init(from ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier
        self.title = ekEvent.title ?? "Untitled Event"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.location = ekEvent.location
        self.calendarColor = ekEvent.calendar?.cgColor
        self.isAllDay = ekEvent.isAllDay
    }

    // MARK: - Computed Properties

    var isHappeningSoon: Bool {
        let now = Date()
        let timeUntilStart = startDate.timeIntervalSince(now)
        return timeUntilStart > 0 && timeUntilStart < 900 // 15 minutes
    }

    var isHappeningNow: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    var timeUntilStart: TimeInterval {
        startDate.timeIntervalSince(Date())
    }

    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }

    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var relativeTimeString: String {
        let now = Date()
        let timeUntil = startDate.timeIntervalSince(now)

        if timeUntil < 0 {
            return "Now"
        } else if timeUntil < 60 {
            return "Starting"
        } else if timeUntil < 3600 {
            let minutes = Int(timeUntil / 60)
            return "in \(minutes) min"
        } else {
            let hours = Int(timeUntil / 3600)
            return "in \(hours) hr"
        }
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}
