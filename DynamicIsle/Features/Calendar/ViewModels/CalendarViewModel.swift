import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    @Published var upcomingEvents: [CalendarEvent] = []
    @Published var nextEvent: CalendarEvent?
    @Published var hasUpcomingEvent: Bool = false
    @Published var isAuthorized: Bool = false

    private let calendarService = CalendarService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        calendarService.$upcomingEvents
            .receive(on: DispatchQueue.main)
            .assign(to: &$upcomingEvents)

        calendarService.$nextEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.nextEvent = event
                self?.hasUpcomingEvent = event?.isHappeningSoon ?? false
            }
            .store(in: &cancellables)

        calendarService.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .map { $0 == .authorized }
            .assign(to: &$isAuthorized)
    }

    // MARK: - Actions

    func refresh() {
        calendarService.fetchEvents()
    }

    func requestAccess() {
        Task {
            await calendarService.requestAccess()
        }
    }

    // MARK: - Computed Properties

    var hasEvents: Bool {
        !upcomingEvents.isEmpty
    }

    var nextEventTitle: String {
        nextEvent?.title ?? "No upcoming events"
    }

    var nextEventTime: String {
        nextEvent?.formattedStartTime ?? ""
    }

    var nextEventRelativeTime: String {
        nextEvent?.relativeTimeString ?? ""
    }
}
