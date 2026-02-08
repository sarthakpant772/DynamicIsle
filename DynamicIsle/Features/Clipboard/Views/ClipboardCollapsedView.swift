import SwiftUI

struct ClipboardCollapsedView: View {
    @ObservedObject var viewModel: ClipboardViewModel

    var body: some View {
        HStack(spacing: 8) {
            // Clipboard icon
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 22, height: 22)

                Image(systemName: viewModel.latestIcon)
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
            }

            // Latest item preview
            VStack(alignment: .leading, spacing: 1) {
                Text("Clipboard")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))

                Text(viewModel.latestPreview)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Spacer()

            // Item count badge
            if viewModel.hasItems {
                Text("\(viewModel.history.count)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(Color.orange.opacity(0.8))
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    ClipboardCollapsedView(viewModel: ClipboardViewModel())
        .frame(width: 176, height: 20)
        .padding()
        .background(Color.black)
}
