import Foundation
import AppKit
import EventKit
import UserNotifications
import Combine

/// Manages app permissions for various features
class PermissionsManager: ObservableObject {
    static let shared = PermissionsManager()

    @Published var calendarAuthorized = false
    @Published var notificationsAuthorized = false

    private var cancellables = Set<AnyCancellable>()

    private init() {
        checkCurrentStatus()
    }

    // MARK: - Check Status

    func checkCurrentStatus() {
        checkCalendarStatus()
        checkNotificationStatus()
    }

    private func checkCalendarStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        DispatchQueue.main.async {
            self.calendarAuthorized = status == .authorized
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Request Permissions

    func requestAllPermissions() {
        requestCalendarPermission()
        requestNotificationPermission()
    }

    func requestCalendarPermission() {
        Task {
            await CalendarService.shared.requestAccess()
            await MainActor.run {
                checkCalendarStatus()
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            DispatchQueue.main.async {
                self.notificationsAuthorized = granted
            }
        }
    }

    // MARK: - Open System Preferences

    func openCalendarSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
            NSWorkspace.shared.open(url)
        }
    }

    func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
}
