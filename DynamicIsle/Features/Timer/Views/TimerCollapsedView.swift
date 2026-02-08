import SwiftUI

struct TimerCollapsedView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        HStack(spacing: 10) {
            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 20, height: 20)

                Circle()
                    .trim(from: 0, to: viewModel.progressPercentage)
                    .stroke(
                        timerColor,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "timer")
                    .font(.system(size: 8))
                    .foregroundColor(.white)
            }

            // Timer info
            VStack(alignment: .leading, spacing: 1) {
                Text(viewModel.label)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)

                Text(viewModel.shortFormattedTime)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }

            Spacer()

            // Play/Pause indicator
            Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))
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

#Preview {
    TimerCollapsedView(viewModel: TimerViewModel())
        .frame(width: 176, height: 20)
        .padding()
        .background(Color.black)
}
