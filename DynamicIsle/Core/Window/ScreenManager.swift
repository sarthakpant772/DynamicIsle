import AppKit
import Combine

/// Manages screen detection and notch awareness
class ScreenManager: ObservableObject {
    static let shared = ScreenManager()

    @Published var currentScreen: NSScreen?
    @Published var screens: [NSScreen] = []

    private var cancellables = Set<AnyCancellable>()

    private init() {
        updateScreens()
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                self?.updateScreens()
            }
            .store(in: &cancellables)
    }

    private func updateScreens() {
        screens = NSScreen.screens
        currentScreen = NSScreen.main
    }

    /// Check if a screen has a notch (MacBook Pro 14"/16" 2021+)
    func hasNotch(screen: NSScreen? = nil) -> Bool {
        let targetScreen = screen ?? NSScreen.main

        guard let safeAreaInsets = targetScreen?.safeAreaInsets else {
            return false
        }

        // If there's a top safe area inset, the screen has a notch
        return safeAreaInsets.top > 0
    }

    /// Get the notch height if present
    func notchHeight(screen: NSScreen? = nil) -> CGFloat {
        let targetScreen = screen ?? NSScreen.main
        return targetScreen?.safeAreaInsets.top ?? 0
    }

    /// Get the ideal island position for a screen
    func islandFrame(for screen: NSScreen, expanded: Bool) -> NSRect {
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame

        let windowWidth: CGFloat = expanded ? 360 : 200
        let windowHeight: CGFloat = expanded ? 180 : 36

        let xPosition = screenFrame.midX - (windowWidth / 2)

        let yPosition: CGFloat
        if hasNotch(screen: screen) {
            // For notched screens, calculate position relative to notch
            let menuBarHeight = screenFrame.height - visibleFrame.height - visibleFrame.minY + screenFrame.minY
            yPosition = screenFrame.maxY - menuBarHeight - windowHeight - 4
        } else {
            // For regular screens, position below menu bar
            yPosition = visibleFrame.maxY - windowHeight - 8
        }

        return NSRect(x: xPosition, y: yPosition, width: windowWidth, height: windowHeight)
    }

    /// Get all screens with notches
    var notchedScreens: [NSScreen] {
        screens.filter { hasNotch(screen: $0) }
    }

    /// Primary screen for displaying island
    var primaryScreen: NSScreen? {
        // Prefer the main screen (with menu bar), fall back to first screen
        NSScreen.main ?? screens.first
    }
}
