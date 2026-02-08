import SwiftUI
import Combine

/// The current mode/content being displayed in the island
enum IslandMode: Equatable {
    case idle
    case nowPlaying
    case timer
    case calendar
    case notification(String)
    case ai
    case meeting
    case clipboard
    case focus
}

/// Main view model for the Dynamic Island
class IslandViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentMode: IslandMode = .idle

    // Feature view models
    @Published var nowPlayingViewModel: NowPlayingViewModel
    @Published var timerViewModel: TimerViewModel
    @Published var calendarViewModel: CalendarViewModel
    @Published var notificationViewModel: NotificationViewModel
    @Published var aiViewModel: AIViewModel
    @Published var meetingViewModel: MeetingViewModel
    @Published var clipboardViewModel: ClipboardViewModel
    @Published var focusViewModel: FocusViewModel

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        self.nowPlayingViewModel = NowPlayingViewModel()
        self.timerViewModel = TimerViewModel()
        self.calendarViewModel = CalendarViewModel()
        self.notificationViewModel = NotificationViewModel()
        self.aiViewModel = AIViewModel()
        self.meetingViewModel = MeetingViewModel()
        self.clipboardViewModel = ClipboardViewModel()
        self.focusViewModel = FocusViewModel()

        setupModeObservers()
        setupGlobalHotkeys()
    }

    // MARK: - Mode Management

    private func setupModeObservers() {
        // Priority: Focus > Meeting > Now Playing > Timer > Calendar > Idle

        // Observe focus mode (highest priority when active)
        focusViewModel.$isActive
            .sink { [weak self] isActive in
                if isActive {
                    self?.setMode(.focus)
                } else if self?.currentMode == .focus {
                    self?.determineIdleMode()
                }
            }
            .store(in: &cancellables)

        // Observe meeting alerts (high priority)
        meetingViewModel.$isMeetingSoon
            .sink { [weak self] isSoon in
                guard let self = self else { return }
                if isSoon && self.currentMode != .focus {
                    self.setMode(.meeting)
                } else if !isSoon && self.currentMode == .meeting {
                    self.determineIdleMode()
                }
            }
            .store(in: &cancellables)

        // Observe now playing state
        nowPlayingViewModel.$isPlaying
            .sink { [weak self] isPlaying in
                guard let self = self else { return }
                if isPlaying && !self.isHighPriorityMode {
                    self.setMode(.nowPlaying)
                } else if !isPlaying && self.currentMode == .nowPlaying {
                    self.determineIdleMode()
                }
            }
            .store(in: &cancellables)

        // Observe active timer
        timerViewModel.$isRunning
            .sink { [weak self] isRunning in
                guard let self = self else { return }
                if isRunning && !self.isHighPriorityMode && self.currentMode != .nowPlaying {
                    self.setMode(.timer)
                } else if !isRunning && self.currentMode == .timer {
                    self.determineIdleMode()
                }
            }
            .store(in: &cancellables)

        // Observe calendar events
        calendarViewModel.$hasUpcomingEvent
            .sink { [weak self] hasEvent in
                guard let self = self else { return }
                if hasEvent && self.currentMode == .idle {
                    self.setMode(.calendar)
                }
            }
            .store(in: &cancellables)

        // Observe notifications
        notificationViewModel.$currentNotification
            .compactMap { $0 }
            .sink { [weak self] notification in
                self?.showNotification(notification)
            }
            .store(in: &cancellables)
    }

    private var isHighPriorityMode: Bool {
        currentMode == .focus || currentMode == .meeting
    }

    private func setMode(_ mode: IslandMode) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentMode = mode
        }
    }

    private func determineIdleMode() {
        // Priority: Focus > Meeting > Now Playing > Timer > Calendar > Idle
        if focusViewModel.isActive {
            setMode(.focus)
        } else if meetingViewModel.isMeetingSoon {
            setMode(.meeting)
        } else if nowPlayingViewModel.isPlaying {
            setMode(.nowPlaying)
        } else if timerViewModel.isRunning {
            setMode(.timer)
        } else if calendarViewModel.hasUpcomingEvent {
            setMode(.calendar)
        } else {
            setMode(.idle)
        }
    }

    // MARK: - Manual Mode Switching

    func switchToMode(_ mode: IslandMode) {
        setMode(mode)
    }

    func goBack() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentMode = .idle
        }
    }

    // MARK: - Global Hotkeys

    private func setupGlobalHotkeys() {
        // Register Cmd+J for AI quick access
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "j" {
                self?.switchToMode(.ai)
                return nil
            }
            return event
        }
    }

    // MARK: - Notifications

    private func showNotification(_ message: String) {
        setMode(.notification(message))

        // Auto-dismiss after showing (island visibility is handled by IslandWindowController)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.notificationViewModel.dismissCurrent()
            self?.determineIdleMode()
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        cancellables.removeAll()
    }
}
