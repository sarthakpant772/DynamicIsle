import Foundation
import Combine
import AppKit

/// Service for accessing Now Playing information
/// Uses AppleScript for Spotify/Apple Music (reliable) with MediaRemote as fallback
class MediaRemoteService: ObservableObject {
    static let shared = MediaRemoteService()

    @Published var nowPlayingInfo: NowPlayingInfo?
    @Published var isPlaying: Bool = false

    private var timer: Timer?
    private var useAppleScript = true // Prefer AppleScript for reliability

    private init() {
        startPolling()
    }

    private func startPolling() {
        // Poll for now playing info every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.fetchNowPlayingInfo()
        }
        timer?.tolerance = 0.5

        // Initial fetch
        fetchNowPlayingInfo()
    }

    func fetchNowPlayingInfo() {
        // Try Spotify first, then Apple Music
        if let spotifyInfo = getSpotifyInfo() {
            DispatchQueue.main.async {
                self.nowPlayingInfo = spotifyInfo
                self.isPlaying = spotifyInfo.isCurrentlyPlaying
            }
        } else if let musicInfo = getAppleMusicInfo() {
            DispatchQueue.main.async {
                self.nowPlayingInfo = musicInfo
                self.isPlaying = musicInfo.isCurrentlyPlaying
            }
        } else {
            DispatchQueue.main.async {
                self.nowPlayingInfo = nil
                self.isPlaying = false
            }
        }
    }

    // MARK: - Spotify AppleScript

    private func getSpotifyInfo() -> NowPlayingInfo? {
        guard isSpotifyRunning() else { return nil }

        let script = """
        tell application "Spotify"
            if player state is playing or player state is paused then
                set trackName to name of current track
                set artistName to artist of current track
                set albumName to album of current track
                set trackDuration to duration of current track
                set trackPosition to player position
                set playerState to player state as string
                return trackName & "|||" & artistName & "|||" & albumName & "|||" & (trackDuration / 1000) & "|||" & trackPosition & "|||" & playerState
            end if
        end tell
        """

        guard let result = runAppleScript(script) else { return nil }
        let parts = result.components(separatedBy: "|||")
        guard parts.count >= 6 else { return nil }

        let duration = Double(parts[3]) ?? 0
        let elapsed = Double(parts[4]) ?? 0
        let isPlaying = parts[5] == "playing"

        return NowPlayingInfo(
            title: parts[0],
            artist: parts[1],
            album: parts[2],
            duration: duration,
            elapsedTime: elapsed,
            artwork: getSpotifyArtwork(),
            appBundleIdentifier: "com.spotify.client",
            isCurrentlyPlaying: isPlaying
        )
    }

    private func getSpotifyArtwork() -> NSImage? {
        let script = """
        tell application "Spotify"
            return artwork url of current track
        end tell
        """

        guard let urlString = runAppleScript(script),
              let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let image = NSImage(data: data) else {
            return nil
        }
        return image
    }

    private func isSpotifyRunning() -> Bool {
        NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == "com.spotify.client" }
    }

    // MARK: - Apple Music AppleScript

    private func getAppleMusicInfo() -> NowPlayingInfo? {
        guard isAppleMusicRunning() else { return nil }

        let script = """
        tell application "Music"
            if player state is playing or player state is paused then
                set trackName to name of current track
                set artistName to artist of current track
                set albumName to album of current track
                set trackDuration to duration of current track
                set trackPosition to player position
                set playerState to player state as string
                return trackName & "|||" & artistName & "|||" & albumName & "|||" & trackDuration & "|||" & trackPosition & "|||" & playerState
            end if
        end tell
        """

        guard let result = runAppleScript(script) else { return nil }
        let parts = result.components(separatedBy: "|||")
        guard parts.count >= 6 else { return nil }

        let duration = Double(parts[3]) ?? 0
        let elapsed = Double(parts[4]) ?? 0
        let isPlaying = parts[5] == "playing"

        return NowPlayingInfo(
            title: parts[0],
            artist: parts[1],
            album: parts[2],
            duration: duration,
            elapsedTime: elapsed,
            artwork: nil, // Apple Music artwork is harder to get
            appBundleIdentifier: "com.apple.Music",
            isCurrentlyPlaying: isPlaying
        )
    }

    private func isAppleMusicRunning() -> Bool {
        NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == "com.apple.Music" }
    }

    // MARK: - AppleScript Helper

    private func runAppleScript(_ source: String) -> String? {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }
        let result = script.executeAndReturnError(&error)
        if error != nil { return nil }
        return result.stringValue
    }

    // MARK: - Playback Controls

    func play() {
        if isSpotifyRunning() {
            _ = runAppleScript("tell application \"Spotify\" to play")
        } else if isAppleMusicRunning() {
            _ = runAppleScript("tell application \"Music\" to play")
        }
    }

    func pause() {
        if isSpotifyRunning() {
            _ = runAppleScript("tell application \"Spotify\" to pause")
        } else if isAppleMusicRunning() {
            _ = runAppleScript("tell application \"Music\" to pause")
        }
    }

    func togglePlayPause() {
        if isSpotifyRunning() {
            _ = runAppleScript("tell application \"Spotify\" to playpause")
        } else if isAppleMusicRunning() {
            _ = runAppleScript("tell application \"Music\" to playpause")
        }
    }

    func nextTrack() {
        if isSpotifyRunning() {
            _ = runAppleScript("tell application \"Spotify\" to next track")
        } else if isAppleMusicRunning() {
            _ = runAppleScript("tell application \"Music\" to next track")
        }
    }

    func previousTrack() {
        if isSpotifyRunning() {
            _ = runAppleScript("tell application \"Spotify\" to previous track")
        } else if isAppleMusicRunning() {
            _ = runAppleScript("tell application \"Music\" to previous track")
        }
    }

    deinit {
        timer?.invalidate()
    }
}

/// Model for now playing information
struct NowPlayingInfo: Equatable {
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval
    let elapsedTime: TimeInterval
    let artwork: NSImage?
    let appBundleIdentifier: String?
    var isCurrentlyPlaying: Bool = false

    var progress: Double {
        guard duration > 0 else { return 0 }
        return elapsedTime / duration
    }

    var formattedElapsed: String {
        formatTime(elapsedTime)
    }

    var formattedDuration: String {
        formatTime(duration)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    static func == (lhs: NowPlayingInfo, rhs: NowPlayingInfo) -> Bool {
        lhs.title == rhs.title &&
        lhs.artist == rhs.artist &&
        lhs.album == rhs.album
    }
}
