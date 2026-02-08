import SwiftUI

@main
struct DynamicIsleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar extra for app control
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "capsule.fill")
        }
        .menuBarExtraStyle(.window)

        // Settings window
        Settings {
            SettingsView()
        }
    }
}
