import AppKit
import SwiftUI
import Combine

class IslandWindowController: NSWindowController {
    private var islandViewModel: IslandViewModel
    private var cancellables = Set<AnyCancellable>()
    private var mouseMonitor: Any?
    private var hideTimer: Timer?

    // Trigger zone at top-center of screen
    private let triggerZoneWidth: CGFloat = 400
    private let triggerZoneHeight: CGFloat = 25

    init() {
        self.islandViewModel = IslandViewModel()

        // Create the island window with fixed size
        let initialRect = NSRect(
            x: 0, y: 0,
            width: IslandWindow.windowWidth,
            height: IslandWindow.windowHeight
        )
        let islandWindow = IslandWindow(
            contentRect: initialRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        super.init(window: islandWindow)

        setupContentView()
        setupScreenObserver()
        setupMouseTracking()
        setupNotificationObserver()
        updateWindowPosition()

        // Start hidden
        window?.alphaValue = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupContentView() {
        guard let islandWindow = window as? IslandWindow else { return }

        let contentView = IslandContainerView(viewModel: islandViewModel)
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSRect(
            x: 0, y: 0,
            width: IslandWindow.windowWidth,
            height: IslandWindow.windowHeight
        )
        hostingView.autoresizingMask = [.width, .height]

        islandWindow.contentView = hostingView
    }

    private func setupScreenObserver() {
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                self?.updateWindowPosition()
            }
            .store(in: &cancellables)
    }

    private func setupMouseTracking() {
        // Monitor mouse movement globally
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleMouseMove(event)
        }

        // Also monitor locally when app is active
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleMouseMove(event)
            return event
        }
    }

    private func setupNotificationObserver() {
        // Listen for notifications to show island
        islandViewModel.notificationViewModel.$currentNotification
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.showIslandForNotification()
            }
            .store(in: &cancellables)

        // Listen for timer completion
        NotificationCenter.default.publisher(for: .timerCompleted)
            .sink { [weak self] _ in
                self?.showIslandForNotification()
            }
            .store(in: &cancellables)

        // Listen for meeting alerts
        islandViewModel.meetingViewModel.$isMeetingSoon
            .sink { [weak self] isSoon in
                if isSoon {
                    self?.showIslandForNotification()
                }
            }
            .store(in: &cancellables)
    }

    private func handleMouseMove(_ event: NSEvent) {
        guard let screen = NSScreen.main else { return }

        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = screen.frame

        // Check if mouse is in the trigger zone (top-center of screen)
        let triggerZone = NSRect(
            x: screenFrame.midX - triggerZoneWidth / 2,
            y: screenFrame.maxY - triggerZoneHeight,
            width: triggerZoneWidth,
            height: triggerZoneHeight
        )

        if triggerZone.contains(mouseLocation) {
            showIsland()
        } else if let windowFrame = window?.frame {
            // Check if mouse is inside the island window
            if windowFrame.contains(mouseLocation) {
                // Keep visible and cancel any hide timer
                hideTimer?.invalidate()
                hideTimer = nil
            } else {
                // Mouse is outside both trigger zone and window
                scheduleHide()
            }
        }
    }

    // MARK: - Show/Hide

    func showIsland() {
        hideTimer?.invalidate()
        hideTimer = nil

        guard let islandWindow = window else { return }

        // Only animate if currently hidden
        if islandWindow.alphaValue < 1.0 {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                islandWindow.animator().alphaValue = 1.0
            }
        }

        islandWindow.orderFrontRegardless()
    }

    func hideIsland() {
        guard let islandWindow = window else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            islandWindow.animator().alphaValue = 0.0
        }

        // Reset to idle mode when hiding
        islandViewModel.goBack()
    }

    private func scheduleHide() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            // Double-check mouse isn't over window before hiding
            if let window = self?.window {
                let mouseLocation = NSEvent.mouseLocation
                if !window.frame.contains(mouseLocation) {
                    self?.hideIsland()
                }
            }
        }
    }

    func showIslandForNotification() {
        showIsland()

        // Hide after 5 seconds
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.hideIsland()
        }
    }

    private func updateWindowPosition() {
        guard let islandWindow = window as? IslandWindow,
              let screen = NSScreen.main else { return }

        islandWindow.updatePosition(for: screen)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        updateWindowPosition()
        window?.alphaValue = 0 // Start hidden
    }

    deinit {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
        }
        hideTimer?.invalidate()
    }
}
