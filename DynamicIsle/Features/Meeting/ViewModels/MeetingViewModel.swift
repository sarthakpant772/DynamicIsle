import SwiftUI
import Combine

class MeetingViewModel: ObservableObject {
    @Published var meeting: Meeting?
    @Published var isMeetingSoon = false
    @Published var showJoinButton = false

    private let meetingService = MeetingService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        meetingService.$upcomingMeeting
            .receive(on: DispatchQueue.main)
            .assign(to: &$meeting)

        meetingService.$isMeetingSoon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] soon in
                self?.isMeetingSoon = soon
                self?.showJoinButton = soon
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties

    var hasMeeting: Bool {
        meeting != nil
    }

    var meetingTitle: String {
        meeting?.title ?? "No upcoming meetings"
    }

    var meetingTime: String {
        meeting?.formattedStartTime ?? ""
    }

    var relativeTime: String {
        meeting?.relativeTimeString ?? ""
    }

    var platformName: String {
        meeting?.platform.rawValue ?? ""
    }

    var platformIcon: String {
        meeting?.platform.icon ?? "calendar"
    }

    var isHappeningNow: Bool {
        meeting?.isHappeningNow ?? false
    }

    // MARK: - Actions

    func joinMeeting() {
        meetingService.joinMeeting()
    }

    func dismiss() {
        meetingService.dismissMeeting()
    }
}
