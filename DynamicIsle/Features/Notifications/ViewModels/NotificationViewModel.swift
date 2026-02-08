import SwiftUI
import Combine

class NotificationViewModel: ObservableObject {
    @Published var currentNotification: String?
    @Published var notifications: [IslandNotification] = []

    private let notificationService = NotificationService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        notificationService.$currentNotification
            .receive(on: DispatchQueue.main)
            .map { $0?.message }
            .assign(to: &$currentNotification)

        notificationService.$notifications
            .receive(on: DispatchQueue.main)
            .assign(to: &$notifications)
    }

    // MARK: - Actions

    func dismissCurrent() {
        notificationService.dismissCurrent()
    }

    func dismissAll() {
        notificationService.dismissAll()
    }

    func showTestNotification() {
        notificationService.showNotification(
            title: "Test Notification",
            message: "This is a test notification from Dynamic Isle",
            icon: "bell.fill",
            type: .info
        )
    }

    // MARK: - Current Notification Info

    var currentIcon: String {
        notificationService.currentNotification?.icon ?? "bell.fill"
    }

    var currentTitle: String {
        notificationService.currentNotification?.title ?? ""
    }

    var currentMessage: String {
        notificationService.currentNotification?.message ?? ""
    }

    var currentType: NotificationType {
        notificationService.currentNotification?.type ?? .info
    }
}
