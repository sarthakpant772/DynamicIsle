import SwiftUI

struct AIExpandedView: View {
    @ObservedObject var viewModel: AIViewModel
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            if !viewModel.isConfigured {
                apiKeySetupView
            } else if viewModel.showAPIKeyInput {
                apiKeySetupView
            } else {
                mainView
            }
        }
    }

    // MARK: - Main View

    private var mainView: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI Quick Access")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                // Settings button
                Button(action: { viewModel.showAPIKeyInput = true }) {
                    Image(systemName: "gear")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Quick prompts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.quickPrompts, id: \.0) { prompt in
                        Button(action: { viewModel.useQuickPrompt(prompt.1) }) {
                            Text(prompt.0)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }

            // Input field
            HStack(spacing: 8) {
                TextField("Ask anything...", text: $viewModel.prompt)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                    .onSubmit {
                        viewModel.submit()
                    }

                if viewModel.isLoading {
                    Button(action: viewModel.cancel) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: viewModel.submit) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.prompt.isEmpty ? .gray : .purple)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.prompt.isEmpty)
                }
            }
            .padding(8)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)

            // Response area
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Thinking...")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.system(size: 10))
                        .foregroundColor(.red.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.response.isEmpty {
                ScrollView {
                    HStack {
                        Text(viewModel.response)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.9))
                            .textSelection(.enabled)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Copy button
                HStack {
                    Spacer()
                    Button(action: viewModel.copyResponse) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                Text("Ask a question to get started")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }

    // MARK: - API Key Setup

    private var apiKeySetupView: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.system(size: 24))
                .foregroundColor(.purple)

            Text("Configure AI Provider")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            // Provider picker
            Picker("Provider", selection: $viewModel.selectedProvider) {
                ForEach(AIService.AIProvider.allCases, id: \.self) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)

            // API Key input
            SecureField("API Key", text: $viewModel.apiKeyInput)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
                .frame(width: 250)

            HStack(spacing: 12) {
                if viewModel.isConfigured {
                    Button("Cancel") {
                        viewModel.showAPIKeyInput = false
                        viewModel.apiKeyInput = ""
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.white.opacity(0.6))
                }

                Button("Save") {
                    viewModel.saveAPIKey()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.purple)
                .disabled(viewModel.apiKeyInput.isEmpty)
            }

            Text("Get your API key from anthropic.com or openai.com")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
        }
    }
}

#Preview {
    AIExpandedView(viewModel: AIViewModel())
        .frame(width: 328, height: 180)
        .padding(16)
        .background(Color.black)
        .cornerRadius(24)
}
