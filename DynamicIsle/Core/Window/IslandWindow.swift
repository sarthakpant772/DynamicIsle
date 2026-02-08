import AppKit

/// Custom NSWindow subclass for the floating Dynamic Island
class IslandWindow: NSPanel {

    // Fixed size for the island
    static let windowWidth: CGFloat = 380
    static let windowHeight: CGFloat = 200

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless, .nonactivatingPanel], backing: backingStoreType, defer: flag)
        configureWindow()
    }

    private func configureWindow() {
        // Window level - float above other windows
        self.level = .floating

        // Transparent background
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false // We use SwiftUI shadow instead

        // Non-activating - don't steal focus from other apps
        self.isMovable = false
        self.isMovableByWindowBackground = false

        // Behavior flags
        self.collectionBehavior = [
            .canJoinAllSpaces,      // Show on all desktops/spaces
            .stationary,            // Stay in place during space transitions
            .ignoresCycle,          // Don't appear in Cmd+Tab
            .fullScreenAuxiliary    // Can appear over fullscreen apps
        ]

        // Allow mouse events even when app is not active
        self.acceptsMouseMovedEvents = true
        self.ignoresMouseEvents = false

        // Appearance
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    /// Update window position to top-center of screen
    func updatePosition(for screen: NSScreen) {
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame

        let xPosition = screenFrame.midX - (IslandWindow.windowWidth / 2)

        // Position at top of screen, below menu bar
        let menuBarHeight = screenFrame.height - visibleFrame.height - (visibleFrame.minY - screenFrame.minY)
        let yPosition = screenFrame.maxY - menuBarHeight - IslandWindow.windowHeight - 8

        let newFrame = NSRect(
            x: xPosition,
            y: yPosition,
            width: IslandWindow.windowWidth,
            height: IslandWindow.windowHeight
        )

        self.setFrame(newFrame, display: true, animate: false)
    }
}
