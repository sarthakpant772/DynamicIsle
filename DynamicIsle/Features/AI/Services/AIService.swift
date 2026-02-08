import Foundation
import Combine

/// Service for AI quick access (Claude/OpenAI)
class AIService: ObservableObject {
    static let shared = AIService()

    @Published var isLoading = false
    @Published var lastResponse: String?
    @Published var error: String?

    // API Configuration - User sets these in settings
    @Published var apiProvider: AIProvider = .claude
    @Published var apiKey: String = ""

    private var currentTask: Task<Void, Never>?

    enum AIProvider: String, CaseIterable {
        case claude = "Claude"
        case openai = "OpenAI"

        var baseURL: String {
            switch self {
            case .claude: return "https://api.anthropic.com/v1/messages"
            case .openai: return "https://api.openai.com/v1/chat/completions"
            }
        }

        var model: String {
            switch self {
            case .claude: return "claude-3-haiku-20240307"
            case .openai: return "gpt-4o-mini"
            }
        }
    }

    private init() {
        loadAPIKey()
    }

    // MARK: - API Key Management

    func loadAPIKey() {
        apiKey = UserDefaults.standard.string(forKey: "aiAPIKey") ?? ""
        if let provider = UserDefaults.standard.string(forKey: "aiProvider"),
           let p = AIProvider(rawValue: provider) {
            apiProvider = p
        }
    }

    func saveAPIKey(_ key: String, provider: AIProvider) {
        apiKey = key
        apiProvider = provider
        UserDefaults.standard.set(key, forKey: "aiAPIKey")
        UserDefaults.standard.set(provider.rawValue, forKey: "aiProvider")
    }

    var isConfigured: Bool {
        !apiKey.isEmpty
    }

    // MARK: - Send Prompt

    func sendPrompt(_ prompt: String) async {
        guard !apiKey.isEmpty else {
            await MainActor.run {
                self.error = "API key not configured"
            }
            return
        }

        await MainActor.run {
            self.isLoading = true
            self.error = nil
            self.lastResponse = nil
        }

        do {
            let response = try await callAPI(prompt: prompt)
            await MainActor.run {
                self.lastResponse = response
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func cancel() {
        currentTask?.cancel()
        isLoading = false
    }

    // MARK: - API Calls

    private func callAPI(prompt: String) async throws -> String {
        switch apiProvider {
        case .claude:
            return try await callClaude(prompt: prompt)
        case .openai:
            return try await callOpenAI(prompt: prompt)
        }
    }

    private func callClaude(prompt: String) async throws -> String {
        var request = URLRequest(url: URL(string: AIProvider.claude.baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": AIProvider.claude.model,
            "max_tokens": 500,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("API request failed")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let content = json?["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw AIError.parseError
        }

        return text
    }

    private func callOpenAI(prompt: String) async throws -> String {
        var request = URLRequest(url: URL(string: AIProvider.openai.baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": AIProvider.openai.model,
            "max_tokens": 500,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError("API request failed")
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw AIError.parseError
        }

        return text
    }

    enum AIError: LocalizedError {
        case apiError(String)
        case parseError

        var errorDescription: String? {
            switch self {
            case .apiError(let msg): return msg
            case .parseError: return "Failed to parse response"
            }
        }
    }
}
