import SwiftUI

struct FocusExpandedView: View {
    @ObservedObject var viewModel: FocusViewModel
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.isActive {
                activeSessionView
            } else if showSettings {
                settingsView
            } else {
                startView
            }
        }
    }

    // MARK: - Start View

    private var startView: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.red)
                Text("Pomodoro Focus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Quick info
            HStack(spacing: 16) {
                InfoPill(label: "Focus", value: "\(Int(viewModel.workMinutes))m", color: .red)
                InfoPill(label: "Break", value: "\(Int(viewModel.shortBreakMinutes))m", color: .green)

                Toggle("", isOn: $viewModel.isBlockingEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .red))
                    .scaleEffect(0.7)
                    .labelsHidden()

                Text("Block apps")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Start button
            Button(action: viewModel.start) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Start Focus Session")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.red, .red.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Active Session View

    private var activeSessionView: some View {
        VStack(spacing: 12) {
            // Phase indicator
            HStack {
                Text(viewModel.phaseName.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(viewModel.phaseColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(viewModel.phaseColor.opacity(0.2))
                    .cornerRadius(6)

                Spacer()

                Text(viewModel.pomodoroText)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }

            // Large progress ring
            ZStack {
                Circle()
                    .stroke(viewModel.phaseColor.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: viewModel.progressPercentage)
                    .stroke(viewModel.phaseColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: viewModel.progressPercentage)

                VStack(spacing: 0) {
                    Text(viewModel.formattedTime)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Image(systemName: viewModel.phaseIcon)
                        .font(.system(size: 10))
                        .foregroundColor(viewModel.phaseColor)
                }
            }

            // Controls
            HStack(spacing: 20) {
                // Stop
                Button(action: viewModel.stop) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Pause/Resume
                Button(action: {
                    if viewModel.isActive && viewModel.remainingTime > 0 {
                        viewModel.pause()
                    } else {
                        viewModel.resume()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.phaseColor)
                            .frame(width: 48, height: 48)

                        Image(systemName: "pause.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Skip
                Button(action: viewModel.skip) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: "forward.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - Settings View

    private var settingsView: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { showSettings = false }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())

                Text("Focus Settings")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()
            }

            // Duration settings
            VStack(spacing: 8) {
                SettingSlider(label: "Focus", value: $viewModel.workMinutes, range: 5...60, unit: "min", color: .red)
                SettingSlider(label: "Short Break", value: $viewModel.shortBreakMinutes, range: 1...15, unit: "min", color: .green)
                SettingSlider(label: "Long Break", value: $viewModel.longBreakMinutes, range: 5...30, unit: "min", color: .blue)
            }

            // App blocking toggle
            HStack {
                Toggle("Block distracting apps", isOn: $viewModel.isBlockingEnabled)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .toggleStyle(SwitchToggleStyle(tint: .red))
            }
        }
    }
}

// MARK: - Helper Views

struct InfoPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SettingSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 70, alignment: .leading)

            Slider(value: $value, in: range, step: 1)
                .tint(color)

            Text("\(Int(value))\(unit)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(color)
                .frame(width: 40)
        }
    }
}

#Preview {
    FocusExpandedView(viewModel: FocusViewModel())
        .frame(width: 328, height: 180)
        .padding(16)
        .background(Color.black)
        .cornerRadius(24)
}
