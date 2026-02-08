import Foundation
import Combine
import UserNotifications

/// Service for managing countdown timers
class TimerService: ObservableObject {
    static let shared = TimerService()

    @Published var activeTimer: CountdownTimer?
    @Published var isRunning: Bool = false
    @Published var remainingTime: TimeInterval = 0
    @Published var progress: Double = 0

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        requestNotificationPermission()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    // MARK: - Timer Controls

    func startTimer(duration: TimeInterval, label: String = "Timer") {
        stopTimer()

        let newTimer = CountdownTimer(
            duration: duration,
            label: label,
            startTime: Date()
        )

        activeTimer = newTimer
        remainingTime = duration
        progress = 0
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        timer?.tolerance = 0.05
    }

    func pauseTimer() {
        guard isRunning, let active = activeTimer else { return }

        timer?.invalidate()
        timer = nil
        isRunning = false

        // Store remaining time
        let elapsed = Date().timeIntervalSince(active.startTime)
        remainingTime = max(0, active.duration - elapsed)
    }

    func resumeTimer() {
        guard let active = activeTimer, !isRunning else { return }

        // Adjust start time to account for pause
        let newStartTime = Date().addingTimeInterval(-active.duration + remainingTime)
        activeTimer = CountdownTimer(
            duration: active.duration,
            label: active.label,
            startTime: newStartTime
        )

        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        activeTimer = nil
        isRunning = false
        remainingTime = 0
        progress = 0
    }

    func addTime(_ seconds: TimeInterval) {
        guard let active = activeTimer else { return }

        let newDuration = active.duration + seconds
        activeTimer = CountdownTimer(
            duration: newDuration,
            label: active.label,
            startTime: active.startTime
        )
    }

    // MARK: - Tick

    private func tick() {
        guard let active = activeTimer else { return }

        let elapsed = Date().timeIntervalSince(active.startTime)
        remainingTime = max(0, active.duration - elapsed)
        progress = elapsed / active.duration

        if remainingTime <= 0 {
            timerCompleted()
        }
    }

    private func timerCompleted() {
        let label = activeTimer?.label ?? "Timer"
        stopTimer()

        // Send notification
        sendCompletionNotification(label: label)

        // Post notification for UI update
        NotificationCenter.default.post(
            name: .timerCompleted,
            object: nil,
            userInfo: ["label": label]
        )
    }

    private func sendCompletionNotification(label: String) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "\(label) has finished"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Models

struct CountdownTimer: Identifiable, Equatable {
    let id = UUID()
    let duration: TimeInterval
    let label: String
    let startTime: Date

    var endTime: Date {
        startTime.addingTimeInterval(duration)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
}

// MARK: - Time Formatting

extension TimeInterval {
    var formatted: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var shortFormatted: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
