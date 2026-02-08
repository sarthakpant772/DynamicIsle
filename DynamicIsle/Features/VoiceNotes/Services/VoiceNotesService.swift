import Foundation
import Speech
import AVFoundation
import AppKit

/// A saved voice note
struct SavedNote: Identifiable, Codable {
    let id: UUID
    let originalText: String
    let conciseText: String
    let createdAt: Date

    init(original: String, concise: String) {
        self.id = UUID()
        self.originalText = original
        self.conciseText = concise
        self.createdAt = Date()
    }
}

/// Service for speech recognition and LLM summarization via Ollama
class VoiceNotesService: ObservableObject {
    static let shared = VoiceNotesService()

    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var conciseText = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var hasPermission = false
    @Published var savedNotes: [SavedNote] = []

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // Ollama settings
    private let ollamaBaseURL = "http://localhost:11434"
    private let ollamaModel = "llama3.2" // Change to your installed model

    // Storage
    private let notesFileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent("DynamicIsle", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("voice_notes.json")
    }()

    private init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        requestPermissions()
        loadNotes()
    }

    // MARK: - Permissions

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.hasPermission = true
                case .denied, .restricted, .notDetermined:
                    self?.hasPermission = false
                    self?.errorMessage = "Speech recognition not authorized"
                @unknown default:
                    self?.hasPermission = false
                }
            }
        }
    }

    // MARK: - Recording

    func startRecording() {
        guard hasPermission else {
            errorMessage = "Speech recognition not authorized. Check System Settings > Privacy."
            return
        }

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition not available"
            return
        }

        // Reset state
        transcribedText = ""
        conciseText = ""
        errorMessage = nil

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true

        // Configure audio session
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.transcribedText = result.bestTranscription.formattedString
                }
            }

            if error != nil {
                self?.stopRecording()
            }
        }

        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Could not start audio engine: \(error.localizedDescription)"
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
    }

    // MARK: - Ollama Integration

    func makeConcise() {
        guard !transcribedText.isEmpty else {
            errorMessage = "No text to summarize"
            return
        }

        isProcessing = true
        errorMessage = nil

        let prompt = """
        Make the following text concise and clear. Keep the key points but remove filler words and redundancy. Return only the concise version, nothing else:

        \(transcribedText)
        """

        callOllama(prompt: prompt) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                switch result {
                case .success(let response):
                    self?.conciseText = response.trimmingCharacters(in: .whitespacesAndNewlines)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func callOllama(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(ollamaBaseURL)/api/generate") else {
            completion(.failure(NSError(domain: "VoiceNotes", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": ollamaModel,
            "prompt": prompt,
            "stream": false
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NSError(domain: "VoiceNotes", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ollama not running. Start with: ollama serve"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "VoiceNotes", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let response = json["response"] as? String {
                    completion(.success(response))
                } else {
                    completion(.failure(NSError(domain: "VoiceNotes", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from Ollama"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Utility

    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    func clear() {
        transcribedText = ""
        conciseText = ""
        errorMessage = nil
    }

    // MARK: - Persistence

    func saveCurrentNote() {
        guard !conciseText.isEmpty else {
            errorMessage = "Nothing to save - make text concise first"
            return
        }

        let note = SavedNote(original: transcribedText, concise: conciseText)
        savedNotes.insert(note, at: 0) // Add to beginning
        saveNotes()
        clear()
    }

    func deleteNote(_ note: SavedNote) {
        savedNotes.removeAll { $0.id == note.id }
        saveNotes()
    }

    func deleteNote(at index: Int) {
        guard index < savedNotes.count else { return }
        savedNotes.remove(at: index)
        saveNotes()
    }

    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(savedNotes)
            try data.write(to: notesFileURL)
        } catch {
            errorMessage = "Failed to save notes: \(error.localizedDescription)"
        }
    }

    private func loadNotes() {
        guard FileManager.default.fileExists(atPath: notesFileURL.path) else { return }
        do {
            let data = try Data(contentsOf: notesFileURL)
            savedNotes = try JSONDecoder().decode([SavedNote].self, from: data)
        } catch {
            print("Failed to load notes: \(error)")
        }
    }
}
