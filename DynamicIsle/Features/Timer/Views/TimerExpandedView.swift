import SwiftUI

struct TimerExpandedView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.hasActiveTimer {
                activeTimerView
            } else {
                quickTimerView
            }
        }
    }

    // MARK: - Active Timer View

    private var activeTimerView: some View {
        VStack(spacing: 16) {
            // Label
            Text(viewModel.label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))

            // Large progress ring with time
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 8)
                    .frame(width: 80, height: 80)

                // Progress ring
                Circle()
                    .trim(from: 0, to: viewModel.progressPercentage)
                    .stroke(
                        timerColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: viewModel.progressPercentage)

                // Time display
                Text(viewModel.formattedTime)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            // Controls
            HStack(spacing: 24) {
                // Stop button
                Button(action: viewModel.stop) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Play/Pause button
                Button(action: viewModel.pauseResume) {
                    ZStack {
                        Circle()
                            .fill(timerColor)
                            .frame(width: 48, height: 48)

                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .offset(x: viewModel.isRunning ? 0 : 1)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Add minute button
                Button(action: viewModel.addMinute) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Text("+1")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - Quick Timer View

    private var quickTimerView: some View {
        VStack(spacing: 12) {
            Text("Quick Timer")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            // Timer presets in a grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(viewModel.presets, id: \.1) { preset in
                    Button(action: {
                        viewModel.startTimer(duration: preset.1, label: preset.0)
                    }) {
                        Text(preset.0)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var timerColor: Color {
        if viewModel.remainingTime < 10 {
            return .red
        } else if viewModel.remainingTime < 60 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview("Active Timer") {
    let vm = TimerViewModel()
    return TimerExpandedView(viewModel: vm)
        .frame(width: 328, height: 156)
        .padding(16)
        .background(Color.black)
        .cornerRadius(24)
        .onAppear {
            vm.startTimer(duration: 300, label: "Focus Time")
        }
}

#Preview("Quick Timer") {
    TimerExpandedView(viewModel: TimerViewModel())
        .frame(width: 328, height: 156)
        .padding(16)
        .background(Color.black)
        .cornerRadius(24)
}
