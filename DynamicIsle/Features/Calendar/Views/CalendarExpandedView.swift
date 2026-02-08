import SwiftUI

struct CalendarExpandedView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 12) {
            if !viewModel.isAuthorized {
                permissionRequestView
            } else if viewModel.hasEvents {
                eventsListView
            } else {
                emptyStateView
            }
        }
    }

    // MARK: - Permission Request

    private var permissionRequestView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 32))
                .foregroundColor(.orange)

            Text("Calendar Access Required")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Text("Grant access to see your upcoming events")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button(action: viewModel.requestAccess) {
                Text("Grant Access")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Events List

    private var eventsListView: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text("Upcoming Events")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: viewModel.refresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Events
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 6) {
                    ForEach(viewModel.upcomingEvents.prefix(3)) { event in
                        EventRowView(event: event)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.4))

            Text("No Upcoming Events")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))

            Text("Your next 24 hours are clear")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

// MARK: - Event Row

struct EventRowView: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 10) {
            // Color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(eventColor)
                .frame(width: 4, height: 36)

            // Event details
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(event.formattedTimeRange)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))

                    if let location = event.location, !location.isEmpty {
                        Text("•")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))

                        Text(location)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            // Status badge
            if event.isHappeningNow {
                Text("NOW")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.green)
                    .cornerRadius(4)
            } else {
                Text(event.relativeTimeString)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }

    private var eventColor: Color {
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
    CalendarExpandedView(viewModel: CalendarViewModel())
        .frame(width: 328, height: 156)
        .padding(16)
        .background(Color.black)
        .cornerRadius(24)
}
