import SwiftUI

struct MenuBarView: View {
    @AppStorage("showNowPlaying") private var showNowPlaying = true
    @AppStorage("showTimer") private var showTimer = true
    @AppStorage("showCalendar") private var showCalendar = true

    @StateObject private var timerViewModel = TimerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "capsule.fill")
                    .foregroundColor(.accentColor)
                Text("Dynamic Isle")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Quick Timer Section
            if showTimer {
                timerSection
                Divider()
            }

            // Feature Toggles
            togglesSection

            Divider()

            // Footer Actions
            footerSection
        }
        .frame(width: 280)
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Timer")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            if timerViewModel.hasActiveTimer {
                // Active timer display
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(timerViewModel.label)
                            .font(.caption)
                        Text(timerViewModel.formattedTime)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                    }

                    Spacer()

                    Button(action: timerViewModel.pauseResume) {
                        Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                    }
                    .buttonStyle(.borderless)

                    Button(action: timerViewModel.stop) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            } else {
                // Timer presets
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 6) {
                    ForEach(timerViewModel.presets.prefix(6), id: \.1) { preset in
                        Button(preset.0) {
                            timerViewModel.startTimer(duration: preset.1, label: preset.0)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Toggles Section

    private var togglesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Features")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            Toggle("Now Playing", isOn: $showNowPlaying)
                .padding(.horizontal, 12)
                .padding(.vertical, 2)

            Toggle("Timer", isOn: $showTimer)
                .padding(.horizontal, 12)
                .padding(.vertical, 2)

            Toggle("Calendar", isOn: $showCalendar)
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 0) {
            Button(action: openSettings) {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings...")
                    Spacer()
                    Text("⌘,")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())

            Divider()

            Button(action: quitApp) {
                HStack {
                    Image(systemName: "power")
                    Text("Quit Dynamic Isle")
                    Spacer()
                    Text("⌘Q")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
    }

    // MARK: - Actions

    private func openSettings() {
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

#Preview {
    MenuBarView()
}
