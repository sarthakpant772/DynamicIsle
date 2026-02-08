import Foundation
import AppKit
import Combine
import UserNotifications

/// Service for Pomodoro focus sessions with app blocking
class FocusService: ObservableObject {
    static let shared = FocusService()

    // Session state
    @Published var isActive = false
    @Published var currentPhase: FocusPhase = .work
    @Published var remainingTime: TimeInterval = 0
    @Published var progress: Double = 0
    @Published var completedPomodoros = 0

    // Settings
    @Published var workDuration: TimeInterval = 25 * 60  // 25 minutes
    @Published var shortBreakDuration: TimeInterval = 5 * 60  // 5 minutes
    @Published var longBreakDuration: TimeInterval = 15 * 60  // 15 minutes
    @Published var pomodorosUntilLongBreak = 4

    // App blocking
    @Published var blockedApps: [String] = [
        "com.apple.Safari",
        "com.google.Chrome",
        "org.mozilla.firefox",
        "com.tinyspeck.slackmacgap",
        "com.twitter.twitter-mac",
        "com.facebook.Facebook",
        "com.reddit.Reddit"
    ]
    @Published var isBlockingEnabled = true

    private var timer: Timer?
    private var sessionStartTime: Date?
    private var blockedAppObserver: Any?

    private init() {
        loadSettings()
    }

    // MARK: - Settings Persistence

    private func loadSettings() {
        if let apps = UserDefaults.standard.array(forKey: "blockedApps") as? [String] {
            blockedApps = apps
        }
        isBlockingEnabled = UserDefaults.standard.bool(forKey: "isBlockingEnabled")
    }

    func saveBlockedApps() {
        UserDefaults.standard.set(blockedApps, forKey: "blockedApps")
        UserDefaults.standard.set(isBlockingEnabled, forKey: "isBlockingEnabled")
    }

    // MARK: - Session Control

    func startSession() {
        currentPhase = .work
        remainingTime = workDuration
        progress = 0
        isActive = true
        sessionStartTime = Date()

        startTimer()
        startAppBlocking()
    }

    func pauseSession() {
        timer?.invalidate()
        timer = nil
        stopAppBlocking()
    }

    func resumeSession() {
        startTimer()
        if currentPhase == .work {
            startAppBlocking()
        }
    }

    func stopSession() {
        timer?.invalidate()
        timer = nil
        isActive = false
        remainingTime = 0
        progress = 0
        currentPhase = .work
        stopAppBlocking()
    }

    func skipPhase() {
        completePhase()
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        timer?.tolerance = 0.1
    }

    private func tick() {
        guard remainingTime > 0 else {
            completePhase()
            return
        }

        remainingTime -= 1

        let totalDuration = currentPhase == .work ? workDuration :
                           (shouldTakeLongBreak ? longBreakDuration : shortBreakDuration)
        progress = 1 - (remainingTime / totalDuration)
    }

    private func completePhase() {
        timer?.invalidate()

        sendPhaseCompletionNotification()

        switch currentPhase {
        case .work:
            completedPomodoros += 1
            if shouldTakeLongBreak {
                currentPhase = .longBreak
                remainingTime = longBreakDuration
            } else {
                currentPhase = .shortBreak
                remainingTime = shortBreakDuration
            }
            stopAppBlocking()

        case .shortBreak, .longBreak:
            currentPhase = .work
            remainingTime = workDuration
            startAppBlocking()
        }

        progress = 0
        startTimer()
    }

    private var shouldTakeLongBreak: Bool {
        completedPomodoros > 0 && completedPomodoros % pomodorosUntilLongBreak == 0
    }

    // MARK: - App Blocking

    private func startAppBlocking() {
        guard isBlockingEnabled else { return }

        // Monitor for blocked apps launching
        blockedAppObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppLaunch(notification)
        }

        // Check currently running apps
        checkRunningApps()
    }

    private func stopAppBlocking() {
        if let observer = blockedAppObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            blockedAppObserver = nil
        }
    }

    private func handleAppLaunch(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleId = app.bundleIdentifier,
              blockedApps.contains(bundleId) else { return }

        // Hide or terminate the blocked app
        app.hide()

        // Show notification
        showBlockedAppNotification(appName: app.localizedName ?? "App")
    }

    private func checkRunningApps() {
        for app in NSWorkspace.shared.runningApplications {
            if let bundleId = app.bundleIdentifier,
               blockedApps.contains(bundleId) {
                app.hide()
            }
        }
    }

    private func showBlockedAppNotification(appName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Mode Active"
        content.body = "\(appName) is blocked during focus time"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Notifications

    private func sendPhaseCompletionNotification() {
        let content = UNMutableNotificationContent()

        switch currentPhase {
        case .work:
            content.title = "Focus Session Complete!"
            content.body = "Great work! Time for a break."
        case .shortBreak:
            content.title = "Break Over"
            content.body = "Ready for another focus session?"
        case .longBreak:
            content.title = "Long Break Over"
            content.body = "Feeling refreshed? Let's get back to work!"
        }

        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - App Management

    func addBlockedApp(_ bundleId: String) {
        if !blockedApps.contains(bundleId) {
            blockedApps.append(bundleId)
            saveBlockedApps()
        }
    }

    func removeBlockedApp(_ bundleId: String) {
        blockedApps.removeAll { $0 == bundleId }
        saveBlockedApps()
    }

    func getRunningApps() -> [AppInfo] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app in
                guard let bundleId = app.bundleIdentifier,
                      let name = app.localizedName else { return nil }
                return AppInfo(bundleId: bundleId, name: name, icon: app.icon)
            }
    }

    deinit {
        stopAppBlocking()
    }
}

// MARK: - Models

enum FocusPhase: String {
    case work = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var color: String {
        switch self {
        case .work: return "red"
        case .shortBreak: return "green"
        case .longBreak: return "blue"
        }
    }

    var icon: String {
        switch self {
        case .work: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "figure.walk"
        }
    }
}

struct AppInfo: Identifiable {
    let id = UUID()
    let bundleId: String
    let name: String
    let icon: NSImage?
}
