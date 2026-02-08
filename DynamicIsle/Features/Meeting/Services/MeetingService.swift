import Foundation
import EventKit
import Combine
import AppKit

/// Service for detecting and managing upcoming meetings with join links
class MeetingService: ObservableObject {
    static let shared = MeetingService()

    @Published var upcomingMeeting: Meeting?
    @Published var isMeetingSoon = false // Within 5 minutes

    private let calendarService = CalendarService.shared
    private var cancellables = Set<AnyCancellable>()
    private var checkTimer: Timer?

    private init() {
        setupBindings()
        startChecking()
    }

    private func setupBindings() {
        calendarService.$upcomingEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                self?.findNextMeeting(from: events)
            }
            .store(in: &cancellables)
    }

    private func startChecking() {
        // Check every 30 seconds for meeting timing
        checkTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updateMeetingStatus()
        }
    }

    private func findNextMeeting(from events: [CalendarEvent]) {
        // Find the first event with a meeting link
        for event in events {
            if let meeting = extractMeeting(from: event) {
                upcomingMeeting = meeting
                updateMeetingStatus()
                return
            }
        }
        upcomingMeeting = nil
        isMeetingSoon = false
    }

    private func extractMeeting(from event: CalendarEvent) -> Meeting? {
        // Check event location and notes for meeting links
        let searchText = (event.location ?? "") + " " + (event.title)

        if let link = extractMeetingLink(from: searchText) {
            return Meeting(
                title: event.title,
                startTime: event.startDate,
                endTime: event.endDate,
                link: link,
                platform: detectPlatform(from: link)
            )
        }
        return nil
    }

    private func extractMeetingLink(from text: String) -> URL? {
        // Patterns for common meeting platforms
        let patterns = [
            // Zoom
            "https?://[\\w.-]*zoom\\.us/j/[\\d]+(?:\\?pwd=[\\w]+)?",
            // Google Meet
            "https?://meet\\.google\\.com/[a-z-]+",
            // Microsoft Teams
            "https?://teams\\.microsoft\\.com/l/meetup-join/[\\w%-]+",
            // Webex
            "https?://[\\w.-]*webex\\.com/[\\w/.-]+",
            // Generic video call links
            "https?://[\\w.-]+/(?:join|meeting|call)/[\\w-]+"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range, in: text) {
                return URL(string: String(text[range]))
            }
        }
        return nil
    }

    private func detectPlatform(from url: URL) -> MeetingPlatform {
        let host = url.host?.lowercased() ?? ""

        if host.contains("zoom") {
            return .zoom
        } else if host.contains("meet.google") {
            return .googleMeet
        } else if host.contains("teams.microsoft") {
            return .teams
        } else if host.contains("webex") {
            return .webex
        } else {
            return .other
        }
    }

    private func updateMeetingStatus() {
        guard let meeting = upcomingMeeting else {
            isMeetingSoon = false
            return
        }

        let timeUntil = meeting.startTime.timeIntervalSinceNow
        isMeetingSoon = timeUntil > 0 && timeUntil < 300 // 5 minutes
    }

    // MARK: - Actions

    func joinMeeting() {
        guard let meeting = upcomingMeeting else { return }
        NSWorkspace.shared.open(meeting.link)
    }

    func dismissMeeting() {
        upcomingMeeting = nil
        isMeetingSoon = false
    }

    deinit {
        checkTimer?.invalidate()
    }
}

// MARK: - Models

struct Meeting: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let startTime: Date
    let endTime: Date
    let link: URL
    let platform: MeetingPlatform

    var timeUntilStart: TimeInterval {
        startTime.timeIntervalSinceNow
    }

    var isStartingSoon: Bool {
        timeUntilStart > 0 && timeUntilStart < 300
    }

    var isHappeningNow: Bool {
        let now = Date()
        return now >= startTime && now <= endTime
    }

    var relativeTimeString: String {
        let time = timeUntilStart

        if time < 0 {
            return "Now"
        } else if time < 60 {
            return "Starting"
        } else if time < 3600 {
            return "in \(Int(time / 60)) min"
        } else {
            let hours = Int(time / 3600)
            return "in \(hours) hr"
        }
    }

    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }

    static func == (lhs: Meeting, rhs: Meeting) -> Bool {
        lhs.id == rhs.id
    }
}

enum MeetingPlatform: String {
    case zoom = "Zoom"
    case googleMeet = "Google Meet"
    case teams = "Teams"
    case webex = "Webex"
    case other = "Meeting"

    var icon: String {
        switch self {
        case .zoom: return "video.fill"
        case .googleMeet: return "video.fill"
        case .teams: return "person.3.fill"
        case .webex: return "video.fill"
        case .other: return "link"
        }
    }

    var color: String {
        switch self {
        case .zoom: return "blue"
        case .googleMeet: return "green"
        case .teams: return "purple"
        case .webex: return "green"
        case .other: return "gray"
        }
    }
}
