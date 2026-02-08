import Foundation
import UserNotifications
import Combine

/// Service for managing app notifications displayed in the island
/// Note: macOS doesn't allow intercepting other apps' notifications,
/// so this handles only our own app's notifications (timers, reminders, etc.)
class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var notifications: [IslandNotification] = []
    @Published var currentNotification: IslandNotification?

    private var notificationQueue: [IslandNotification] = []
    private var displayTimer: Timer?

    private init() {
        setupNotificationObservers()
    }

    private func setupNotificationObservers() {
        // Listen for timer completions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTimerCompleted(_:)),
            name: .timerCompleted,
            object: nil
        )
    }

    @objc private func handleTimerCompleted(_ notification: Notification) {
        let label = notification.userInfo?["label"] as? String ?? "Timer"
        showNotification(
            title: "Timer Complete",
            message: "\(label) has finished",
            icon: "timer",
            type: .timer
        )
    }

    // MARK: - Public API

    func showNotification(
        title: String,
        message: String,
        icon: String = "bell.fill",
        type: NotificationType = .info,
        duration: TimeInterval = 3.0
    ) {
        let notification = IslandNotification(
            title: title,
            message: message,
            icon: icon,
            type: type,
            duration: duration
        )

        DispatchQueue.main.async {
            self.notificationQueue.append(notification)
            self.notifications.append(notification)
            self.processQueue()
        }
    }

    func dismissCurrent() {
        DispatchQueue.main.async {
            self.currentNotification = nil
            self.displayTimer?.invalidate()
            self.processQueue()
        }
    }

    func dismissAll() {
        DispatchQueue.main.async {
            self.notificationQueue.removeAll()
            self.notifications.removeAll()
            self.currentNotification = nil
            self.displayTimer?.invalidate()
        }
    }

    // MARK: - Queue Management

    private func processQueue() {
        guard currentNotification == nil, !notificationQueue.isEmpty else { return }

        let notification = notificationQueue.removeFirst()
        currentNotification = notification

        // Auto-dismiss after duration
        displayTimer = Timer.scheduledTimer(withTimeInterval: notification.duration, repeats: false) { [weak self] _ in
            self?.dismissCurrent()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Models

struct IslandNotification: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
    let type: NotificationType
    let duration: TimeInterval
    let timestamp: Date = Date()

    static func == (lhs: IslandNotification, rhs: IslandNotification) -> Bool {
        lhs.id == rhs.id
    }
}

enum NotificationType {
    case info
    case success
    case warning
    case error
    case timer
    case calendar

    var color: String {
        switch self {
        case .info: return "blue"
        case .success: return "green"
        case .warning: return "orange"
        case .error: return "red"
        case .timer: return "purple"
        case .calendar: return "blue"
        }
    }
}
