import SwiftUI
import Combine
import AppKit

class NowPlayingViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var album: String = ""
    @Published var artwork: NSImage?
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0
    @Published var elapsedTime: String = "0:00"
    @Published var duration: String = "0:00"

    private let mediaService = MediaRemoteService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        // Observe now playing info changes
        mediaService.$nowPlayingInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                guard let self = self, let info = info else {
                    self?.clearInfo()
                    return
                }

                self.title = info.title
                self.artist = info.artist
                self.album = info.album ?? ""
                self.artwork = info.artwork
                self.progress = info.progress
                self.elapsedTime = info.formattedElapsed
                self.duration = info.formattedDuration
            }
            .store(in: &cancellables)

        // Observe playing state
        mediaService.$isPlaying
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPlaying)
    }

    private func clearInfo() {
        title = ""
        artist = ""
        album = ""
        artwork = nil
        progress = 0
        elapsedTime = "0:00"
        duration = "0:00"
    }

    // MARK: - Actions

    func togglePlayPause() {
        mediaService.togglePlayPause()
    }

    func nextTrack() {
        mediaService.nextTrack()
    }

    func previousTrack() {
        mediaService.previousTrack()
    }

    func refresh() {
        mediaService.fetchNowPlayingInfo()
    }

    // MARK: - Computed Properties

    var hasContent: Bool {
        !title.isEmpty
    }

    var displayTitle: String {
        title.isEmpty ? "Not Playing" : title
    }

    var displayArtist: String {
        artist.isEmpty ? "—" : artist
    }
}
