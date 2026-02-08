import SwiftUI
import AppKit

struct VoiceNotesExpandedView: View {
    @ObservedObject var viewModel: VoiceNotesViewModel
    @State private var showingCopied = false

    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
                Text("Voice Notes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()

                // History toggle
                Button(action: { viewModel.toggleHistory() }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.showHistory ? "mic.fill" : "list.bullet")
                            .font(.system(size: 10))
                        Text(viewModel.showHistory ? "New" : "History")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
            }

            if viewModel.showHistory {
                // History View
                historyView
            } else {
                // Recording View
                recordingView
            }
        }
    }

    // MARK: - Recording View

    var recordingView: some View {
        VStack(spacing: 10) {
            // Error message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            // Main content area
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    // Transcribed text
                    if !viewModel.transcribedText.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Original")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                                Spacer()
                                Button(action: {
                                    viewModel.copyOriginal()
                                    showCopiedFeedback()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Text(viewModel.transcribedText)
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Concise text
                    if !viewModel.conciseText.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Concise")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.green.opacity(0.8))
                                Spacer()
                                Button(action: {
                                    viewModel.copyConcise()
                                    showCopiedFeedback()
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 10))
                                        .foregroundColor(.green.opacity(0.8))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Text(viewModel.conciseText)
                                .font(.system(size: 11))
                                .foregroundColor(.green)
                        }
                        .padding(8)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(8)
                    }
                }
            }
            .frame(maxHeight: 70)

            // Status
            Text(viewModel.statusText)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))

            // Controls
            HStack(spacing: 12) {
                // Record button
                Button(action: { viewModel.toggleRecording() }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRecording ? Color.red : Color.green)
                            .frame(width: 40, height: 40)

                        if viewModel.isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 14, height: 14)
                        } else {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Make Concise button
                if viewModel.canMakeConcise {
                    Button(action: { viewModel.makeConcise() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                            Text("Concise")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Save button
                if !viewModel.conciseText.isEmpty {
                    Button(action: { viewModel.saveNote() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 11))
                            Text("Save")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Processing indicator
                if viewModel.isProcessing {
                    ProgressView()
                        .scaleEffect(0.7)
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                }

                // Clear button
                if !viewModel.transcribedText.isEmpty && !viewModel.isRecording {
                    Button(action: { viewModel.clear() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            // Copied feedback
            if showingCopied {
                Text("Copied!")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - History View

    var historyView: some View {
        VStack(spacing: 8) {
            if viewModel.savedNotes.isEmpty {
                Spacer()
                Text("No saved notes yet")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                Text("Record and save a note to see it here")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.savedNotes) { note in
                            NoteCard(note: note, onCopy: {
                                viewModel.copyConcise()
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(note.conciseText, forType: .string)
                                showCopiedFeedback()
                            }, onDelete: {
                                viewModel.deleteNote(note)
                            })
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 130)
    }

    private func showCopiedFeedback() {
        withAnimation {
            showingCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingCopied = false
            }
        }
    }
}

// MARK: - Note Card

struct NoteCard: View {
    let note: SavedNote
    let onCopy: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.createdAt, style: .date)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
                Text(note.createdAt, style: .time)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 10))
                        .foregroundColor(.green.opacity(0.7))
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                        .foregroundColor(.red.opacity(0.7))
                }
                .buttonStyle(PlainButtonStyle())
            }
            Text(note.conciseText)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
        }
        .padding(8)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}

#Preview {
    VoiceNotesExpandedView(viewModel: VoiceNotesViewModel())
        .frame(width: 350, height: 180)
        .padding()
        .background(Color.black)
        .cornerRadius(24)
}
