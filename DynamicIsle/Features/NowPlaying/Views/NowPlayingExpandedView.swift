import SwiftUI

struct NowPlayingExpandedView: View {
    @ObservedObject var viewModel: NowPlayingViewModel

    var body: some View {
        HStack(spacing: 16) {
            // Album artwork
            albumArtwork

            // Track info and controls
            VStack(alignment: .leading, spacing: 8) {
                // Track info
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.displayTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(viewModel.displayArtist)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)

                    if !viewModel.album.isEmpty {
                        Text(viewModel.album)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Progress bar
                progressBar

                // Playback controls
                playbackControls
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(4)
    }

    private var albumArtwork: some View {
        Group {
            if let artwork = viewModel.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "music.note")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }

    private var progressBar: some View {
        VStack(spacing: 4) {
            // Progress track
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)

                    // Progress
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .frame(width: geometry.size.width * viewModel.progress, height: 4)
                }
            }
            .frame(height: 4)

            // Time labels
            HStack {
                Text(viewModel.elapsedTime)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                Text(viewModel.duration)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 24) {
            Spacer()

            // Previous
            Button(action: viewModel.previousTrack) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())

            // Play/Pause
            Button(action: viewModel.togglePlayPause) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 36, height: 36)

                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .offset(x: viewModel.isPlaying ? 0 : 1)
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Next
            Button(action: viewModel.nextTrack) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
    }
}

#Preview {
    NowPlayingExpandedView(viewModel: NowPlayingViewModel())
        .frame(width: 328, height: 156)
        .padding(16)
        .background(Color.black)
        .cornerRadius(24)
}
