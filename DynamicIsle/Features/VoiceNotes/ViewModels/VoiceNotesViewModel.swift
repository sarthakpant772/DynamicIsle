import SwiftUI
import Combine

class VoiceNotesViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var conciseText = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var hasPermission = false
    @Published var savedNotes: [SavedNote] = []
    @Published var showHistory = false

    private let service = VoiceNotesService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        service.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: &$isRecording)

        service.$transcribedText
            .receive(on: DispatchQueue.main)
            .assign(to: &$transcribedText)

        service.$conciseText
            .receive(on: DispatchQueue.main)
            .assign(to: &$conciseText)

        service.$isProcessing
            .receive(on: DispatchQueue.main)
            .assign(to: &$isProcessing)

        service.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)

        service.$hasPermission
            .receive(on: DispatchQueue.main)
            .assign(to: &$hasPermission)

        service.$savedNotes
            .receive(on: DispatchQueue.main)
            .assign(to: &$savedNotes)
    }

    // MARK: - Actions

    func toggleRecording() {
        if isRecording {
            service.stopRecording()
        } else {
            service.startRecording()
        }
    }

    func makeConcise() {
        service.makeConcise()
    }

    func copyOriginal() {
        service.copyToClipboard(transcribedText)
    }

    func copyConcise() {
        service.copyToClipboard(conciseText)
    }

    func clear() {
        service.clear()
    }

    func requestPermissions() {
        service.requestPermissions()
    }

    func saveNote() {
        service.saveCurrentNote()
    }

    func deleteNote(_ note: SavedNote) {
        service.deleteNote(note)
    }

    func toggleHistory() {
        showHistory.toggle()
    }

    // MARK: - Computed

    var canMakeConcise: Bool {
        !transcribedText.isEmpty && !isProcessing && !isRecording
    }

    var statusText: String {
        if isRecording {
            return "Listening..."
        } else if isProcessing {
            return "Making concise..."
        } else if !conciseText.isEmpty {
            return "Done! Tap to copy"
        } else if !transcribedText.isEmpty {
            return "Tap 'Make Concise' to summarize"
        } else {
            return "Tap mic to start speaking"
        }
    }
}
