import SwiftUI

/// Expanded view of the Dynamic Island showing full content
struct ExpandedIslandView: View {
    @ObservedObject var viewModel: IslandViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Back button header for non-idle modes
            if viewModel.currentMode != .idle {
                HStack {
                    Button(action: { viewModel.goBack() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 4)

                    Spacer()
                }
                .padding(.bottom, 4)
            }

            // Content
            Group {
                switch viewModel.currentMode {
                case .nowPlaying:
                    NowPlayingExpandedView(viewModel: viewModel.nowPlayingViewModel)

                case .timer:
                    TimerExpandedView(viewModel: viewModel.timerViewModel)

                case .calendar:
                    CalendarExpandedView(viewModel: viewModel.calendarViewModel)

                case .notification(let message):
                    NotificationExpandedView(
                        message: message,
                        viewModel: viewModel.notificationViewModel
                    )

                case .ai:
                    AIExpandedView(viewModel: viewModel.aiViewModel)

                case .meeting:
                    MeetingExpandedView(viewModel: viewModel.meetingViewModel)

                case .clipboard:
                    ClipboardExpandedView(viewModel: viewModel.clipboardViewModel)

                case .focus:
                    FocusExpandedView(viewModel: viewModel.focusViewModel)

                case .voiceNotes:
                    VoiceNotesExpandedView(viewModel: viewModel.voiceNotesViewModel)

                case .idle:
                    IdleExpandedView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// Expanded idle state with quick actions
struct IdleExpandedView: View {
    @ObservedObject var viewModel: IslandViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Dynamic Isle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            // Quick action grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    icon: "sparkles",
                    label: "AI",
                    color: .purple,
                    action: { viewModel.switchToMode(.ai) }
                )

                QuickActionButton(
                    icon: "brain.head.profile",
                    label: "Focus",
                    color: .red,
                    action: { viewModel.switchToMode(.focus) }
                )

                QuickActionButton(
                    icon: "timer",
                    label: "Timer",
                    color: .orange,
                    action: { viewModel.switchToMode(.timer) }
                )

                QuickActionButton(
                    icon: "waveform",
                    label: "Voice",
                    color: .green,
                    action: { viewModel.switchToMode(.voiceNotes) }
                )
            }

            // Secondary actions
            HStack(spacing: 16) {
                SecondaryAction(icon: "calendar", label: "Calendar") {
                    viewModel.switchToMode(.calendar)
                }

                SecondaryAction(icon: "music.note", label: "Music") {
                    viewModel.nowPlayingViewModel.refresh()
                    viewModel.switchToMode(.nowPlaying)
                }

                SecondaryAction(icon: "video.fill", label: "Meetings") {
                    viewModel.switchToMode(.meeting)
                }
            }

            Text("⌘J for AI • Click to collapse")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

/// Reusable quick action button
struct QuickActionButton: View {
    let icon: String
    let label: String
    var color: Color = .white
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

struct SecondaryAction: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundColor(.white.opacity(0.5))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// View modifier for detecting press events
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

#Preview {
    ExpandedIslandView(viewModel: IslandViewModel())
        .frame(width: 360, height: 180)
        .background(Color.black)
        .cornerRadius(24)
}
