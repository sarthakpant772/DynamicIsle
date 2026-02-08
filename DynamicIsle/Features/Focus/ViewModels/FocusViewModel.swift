import SwiftUI
import Combine

class FocusViewModel: ObservableObject {
    @Published var isActive = false
    @Published var currentPhase: FocusPhase = .work
    @Published var remainingTime: TimeInterval = 0
    @Published var progress: Double = 0
    @Published var completedPomodoros = 0
    @Published var isBlockingEnabled = true
    @Published var blockedApps: [String] = []

    // Settings
    @Published var workMinutes: Double = 25
    @Published var shortBreakMinutes: Double = 5
    @Published var longBreakMinutes: Double = 15

    private let focusService = FocusService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        focusService.$isActive
            .receive(on: DispatchQueue.main)
            .assign(to: &$isActive)

        focusService.$currentPhase
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentPhase)

        focusService.$remainingTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$remainingTime)

        focusService.$progress
            .receive(on: DispatchQueue.main)
            .assign(to: &$progress)

        focusService.$completedPomodoros
            .receive(on: DispatchQueue.main)
            .assign(to: &$completedPomodoros)

        focusService.$isBlockingEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: &$isBlockingEnabled)

        focusService.$blockedApps
            .receive(on: DispatchQueue.main)
            .assign(to: &$blockedApps)
    }

    // MARK: - Computed

    var formattedTime: String {
        remainingTime.formatted
    }

    var shortFormattedTime: String {
        remainingTime.shortFormatted
    }

    var progressPercentage: Double {
        1.0 - progress
    }

    var phaseName: String {
        currentPhase.rawValue
    }

    var phaseColor: Color {
        switch currentPhase {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }

    var phaseIcon: String {
        currentPhase.icon
    }

    var pomodoroText: String {
        completedPomodoros == 1 ? "1 pomodoro" : "\(completedPomodoros) pomodoros"
    }

    // MARK: - Actions

    func start() {
        // Apply settings
        focusService.workDuration = workMinutes * 60
        focusService.shortBreakDuration = shortBreakMinutes * 60
        focusService.longBreakDuration = longBreakMinutes * 60
        focusService.isBlockingEnabled = isBlockingEnabled

        focusService.startSession()
    }

    func pause() {
        focusService.pauseSession()
    }

    func resume() {
        focusService.resumeSession()
    }

    func stop() {
        focusService.stopSession()
    }

    func skip() {
        focusService.skipPhase()
    }

    func toggleBlocking() {
        isBlockingEnabled.toggle()
        focusService.isBlockingEnabled = isBlockingEnabled
        focusService.saveBlockedApps()
    }

    func getRunningApps() -> [AppInfo] {
        focusService.getRunningApps()
    }

    func addBlockedApp(_ bundleId: String) {
        focusService.addBlockedApp(bundleId)
    }

    func removeBlockedApp(_ bundleId: String) {
        focusService.removeBlockedApp(bundleId)
    }

    func isAppBlocked(_ bundleId: String) -> Bool {
        blockedApps.contains(bundleId)
    }
}
