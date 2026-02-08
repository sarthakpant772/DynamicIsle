import SwiftUI

struct VoiceNotesCollapsedView: View {
    @ObservedObject var viewModel: VoiceNotesViewModel

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.isRecording ? "waveform" : "waveform.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.green)

            Text(viewModel.isRecording ? "Recording..." : "Voice Notes")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

#Preview {
    VoiceNotesCollapsedView(viewModel: VoiceNotesViewModel())
        .frame(width: 150, height: 36)
        .background(Color.black)
        .cornerRadius(18)
}
