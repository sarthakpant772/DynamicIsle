import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var remainingTime: TimeInterval = 0
    @Published var progress: Double = 0
    @Published var label: String = "Timer"
    @Published var showQuickTimerSheet: Bool = false

    // Quick timer presets (in seconds)
    let presets: [(String, TimeInterval)] = [
        ("1 min", 60),
        ("3 min", 180),
        ("5 min", 300),
        ("10 min", 600),
        ("15 min", 900),
        ("30 min", 1800)
    ]

    private let timerService = TimerService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        timerService.$isRunning
            .receive(on: DispatchQueue.main)
            .assign(to: &$isRunning)

        timerService.$remainingTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$remainingTime)

        timerService.$progress
            .receive(on: DispatchQueue.main)
            .assign(to: &$progress)

        timerService.$activeTimer
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.label }
            .assign(to: &$label)
    }

    // MARK: - Actions

    func startTimer(duration: TimeInterval, label: String = "Timer") {
        timerService.startTimer(duration: duration, label: label)
    }

    func pauseResume() {
        if isRunning {
            timerService.pauseTimer()
        } else {
            timerService.resumeTimer()
        }
    }

    func stop() {
        timerService.stopTimer()
    }

    func addMinute() {
        timerService.addTime(60)
    }

    func showQuickTimer() {
        showQuickTimerSheet = true
    }

    // MARK: - Computed Properties

    var formattedTime: String {
        remainingTime.formatted
    }

    var shortFormattedTime: String {
        remainingTime.shortFormatted
    }

    var progressPercentage: Double {
        min(1.0, max(0.0, 1.0 - progress))
    }

    var hasActiveTimer: Bool {
        timerService.activeTimer != nil
    }
}
