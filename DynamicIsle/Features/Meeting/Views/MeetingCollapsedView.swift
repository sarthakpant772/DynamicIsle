import SwiftUI

struct MeetingCollapsedView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 8) {
            // Meeting icon with pulse animation when starting soon
            ZStack {
                if viewModel.isMeetingSoon {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .opacity(isPulsing ? 0 : 0.5)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: isPulsing)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(viewModel.isMeetingSoon ? Color.green : Color.blue)
                        .frame(width: 22, height: 22)

                    Image(systemName: viewModel.platformIcon)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                if viewModel.isMeetingSoon {
                    isPulsing = true
                }
            }

            // Meeting info
            VStack(alignment: .leading, spacing: 1) {
                Text(viewModel.meetingTitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(viewModel.relativeTime)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(viewModel.isMeetingSoon ? .green : .white.opacity(0.6))

                    if !viewModel.platformName.isEmpty {
                        Text("•")
                            .foregroundColor(.white.opacity(0.4))
                        Text(viewModel.platformName)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }

            Spacer()

            // Quick join button when meeting is soon
            if viewModel.isMeetingSoon {
                Button(action: viewModel.joinMeeting) {
                    Text("Join")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    MeetingCollapsedView(viewModel: MeetingViewModel())
        .frame(width: 200, height: 36)
        .padding()
        .background(Color.black)
}
