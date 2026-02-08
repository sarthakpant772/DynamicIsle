import SwiftUI

struct FocusCollapsedView: View {
    @ObservedObject var viewModel: FocusViewModel

    var body: some View {
        HStack(spacing: 8) {
            // Phase indicator with progress ring
            ZStack {
                Circle()
                    .stroke(viewModel.phaseColor.opacity(0.2), lineWidth: 2)
                    .frame(width: 22, height: 22)

                Circle()
                    .trim(from: 0, to: viewModel.progressPercentage)
                    .stroke(viewModel.phaseColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 22, height: 22)
                    .rotationEffect(.degrees(-90))

                Image(systemName: viewModel.phaseIcon)
                    .font(.system(size: 8))
                    .foregroundColor(viewModel.phaseColor)
            }

            // Session info
            VStack(alignment: .leading, spacing: 1) {
                Text(viewModel.phaseName)
                    .font(.system(size: 9))
                    .foregroundColor(viewModel.phaseColor)

                Text(viewModel.shortFormattedTime)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            Spacer()

            // Pomodoro count
            HStack(spacing: 4) {
                ForEach(0..<min(viewModel.completedPomodoros, 4), id: \.self) { _ in
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                }
                ForEach(0..<max(0, 4 - viewModel.completedPomodoros), id: \.self) { _ in
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

#Preview {
    FocusCollapsedView(viewModel: FocusViewModel())
        .frame(width: 200, height: 36)
        .padding()
        .background(Color.black)
}
