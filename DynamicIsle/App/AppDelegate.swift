import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var islandWindowController: IslandWindowController?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - this is a menu bar app
        NSApp.setActivationPolicy(.accessory)

        // Create and show the island window
        setupIslandWindow()

        // Request necessary permissions
        PermissionsManager.shared.requestAllPermissions()
    }

    private func setupIslandWindow() {
        islandWindowController = IslandWindowController()
        islandWindowController?.showWindow(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        islandWindowController?.close()
    }
}
