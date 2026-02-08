import SwiftUI
import Combine

class AIViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var response: String = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var isConfigured = false
    @Published var showAPIKeyInput = false

    // API Key configuration
    @Published var apiKeyInput: String = ""
    @Published var selectedProvider: AIService.AIProvider = .claude

    private let aiService = AIService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        aiService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        aiService.$lastResponse
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .assign(to: &$response)

        aiService.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)

        aiService.$apiKey
            .receive(on: DispatchQueue.main)
            .map { !$0.isEmpty }
            .assign(to: &$isConfigured)

        aiService.$apiProvider
            .receive(on: DispatchQueue.main)
            .assign(to: &$selectedProvider)
    }

    // MARK: - Actions

    func submit() {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let query = prompt
        prompt = "" // Clear input

        Task {
            await aiService.sendPrompt(query)
        }
    }

    func cancel() {
        aiService.cancel()
    }

    func clear() {
        response = ""
        error = nil
    }

    func saveAPIKey() {
        aiService.saveAPIKey(apiKeyInput, provider: selectedProvider)
        showAPIKeyInput = false
        apiKeyInput = ""
    }

    func copyResponse() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(response, forType: .string)
    }

    // MARK: - Quick Prompts

    let quickPrompts = [
        ("Summarize", "Summarize this briefly: "),
        ("Explain", "Explain this simply: "),
        ("Fix", "Fix this code: "),
        ("Translate", "Translate to English: ")
    ]

    func useQuickPrompt(_ prefix: String) {
        prompt = prefix
    }
}
