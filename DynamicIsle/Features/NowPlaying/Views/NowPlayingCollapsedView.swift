import SwiftUI

struct NowPlayingCollapsedView: View {
    @ObservedObject var viewModel: NowPlayingViewModel

    var body: some View {
        HStack(spacing: 8) {
            // Album art or music icon
            if let artwork = viewModel.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 22, height: 22)

                    Image(systemName: "music.note")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            // Song info
            VStack(alignment: .leading, spacing: 1) {
                Text(viewModel.displayTitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(viewModel.displayArtist)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Animated waveform indicator
            if viewModel.isPlaying {
                AudioWaveformView()
                    .frame(width: 16, height: 14)
            } else {
                Image(systemName: "pause.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

/// Animated audio waveform visualization
struct AudioWaveformView: View {
    @State private var animating = false

    let barCount = 3
    let barWidth: CGFloat = 3
    let spacing: CGFloat = 2

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(delay: Double(index) * 0.15, animating: animating)
            }
        }
        .onAppear {
            animating = true
        }
    }
}

struct WaveformBar: View {
    let delay: Double
    let animating: Bool

    @State private var height: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.green)
            .frame(width: 3, height: height)
            .onAppear {
                guard animating else { return }
                withAnimation(
                    Animation
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    height = CGFloat.random(in: 6...14)
                }
            }
    }
}

#Preview {
    NowPlayingCollapsedView(viewModel: NowPlayingViewModel())
        .frame(width: 176, height: 20)
        .padding()
        .background(Color.black)
}
