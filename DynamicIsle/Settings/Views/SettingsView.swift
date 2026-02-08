import SwiftUI

struct SettingsView: View {
    @AppStorage("showNowPlaying") private var showNowPlaying = true
    @AppStorage("showTimer") private var showTimer = true
    @AppStorage("showCalendar") private var showCalendar = true
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("autoCollapse") private var autoCollapse = true
    @AppStorage("autoCollapseDelay") private var autoCollapseDelay = 5.0

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            featuresTab
                .tabItem {
                    Label("Features", systemImage: "square.grid.2x2")
                }

            permissionsTab
                .tabItem {
                    Label("Permissions", systemImage: "lock.shield")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 350)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $launchAtLogin)

                Toggle("Auto-collapse island", isOn: $autoCollapse)

                if autoCollapse {
                    HStack {
                        Text("Collapse after")
                        Slider(value: $autoCollapseDelay, in: 2...15, step: 1)
                        Text("\(Int(autoCollapseDelay))s")
                            .frame(width: 30)
                    }
                }
            } header: {
                Text("Behavior")
            }

            Section {
                Text("The Dynamic Island appears at the top center of your screen, integrating with the notch on supported MacBooks.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Info")
            }
        }
        .padding()
    }

    // MARK: - Features Tab

    private var featuresTab: some View {
        Form {
            Section {
                Toggle("Now Playing", isOn: $showNowPlaying)
                Text("Show currently playing music from Spotify, Apple Music, etc.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Toggle("Timer", isOn: $showTimer)
                Text("Display countdown timers in the island.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Toggle("Calendar", isOn: $showCalendar)
                Text("Show upcoming calendar events.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Toggle("Notifications", isOn: $showNotifications)
                Text("Display app notifications in the island.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    // MARK: - Permissions Tab

    private var permissionsTab: some View {
        Form {
            Section {
                PermissionRow(
                    title: "Calendar",
                    description: "Required to show upcoming events",
                    icon: "calendar",
                    status: CalendarService.shared.authorizationStatus == .authorized ? .granted : .notGranted,
                    action: {
                        Task {
                            await CalendarService.shared.requestAccess()
                        }
                    }
                )

                PermissionRow(
                    title: "Notifications",
                    description: "Required to send timer alerts",
                    icon: "bell",
                    status: .granted,
                    action: {}
                )

                PermissionRow(
                    title: "Media (System)",
                    description: "Uses system framework for Now Playing",
                    icon: "music.note",
                    status: .granted,
                    action: {}
                )
            } header: {
                Text("Required Permissions")
            }
        }
        .padding()
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "capsule.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("Dynamic Isle")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("A Dynamic Island experience for macOS")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Text("Made with SwiftUI")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Permission Row

enum PermissionStatus {
    case granted
    case notGranted
    case denied

    var color: Color {
        switch self {
        case .granted: return .green
        case .notGranted: return .orange
        case .denied: return .red
        }
    }

    var icon: String {
        switch self {
        case .granted: return "checkmark.circle.fill"
        case .notGranted: return "questionmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        }
    }
}

struct PermissionRow: View {
    let title: String
    let description: String
    let icon: String
    let status: PermissionStatus
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if status == .granted {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
            } else {
                Button("Grant") {
                    action()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
}
