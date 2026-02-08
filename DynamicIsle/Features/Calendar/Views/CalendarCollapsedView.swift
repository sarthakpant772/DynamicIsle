import SwiftUI

struct CalendarCollapsedView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        HStack(spacing: 8) {
            // Calendar icon with indicator
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(eventColor.opacity(0.3))
                    .frame(width: 22, height: 22)

                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundColor(eventColor)
            }

            // Event info
            VStack(alignment: .leading, spacing: 1) {
                Text(viewModel.nextEventTitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(viewModel.nextEventRelativeTime)
                    .font(.system(size: 9))
                    .foregroundColor(eventColor)
            }

            Spacer()

            // Time badge
            if viewModel.hasUpcomingEvent {
                Text(viewModel.nextEventTime)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(eventColor.opacity(0.3))
                    .cornerRadius(4)
            }
        }
    }

    private var eventColor: Color {
        guard let event = viewModel.nextEvent else {
            return .blue
        }

        if event.isHappeningNow {
            return .green
        } else if event.isHappeningSoon {
            return .orange
        } else {
            return .blue
        }
    }
}

#Preview {
    CalendarCollapsedView(viewModel: CalendarViewModel())
        .frame(width: 176, height: 20)
        .padding()
        .background(Color.black)
}
