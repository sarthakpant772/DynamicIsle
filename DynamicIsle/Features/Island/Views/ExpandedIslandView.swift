import SwiftUI
import AppKit
import UniformTypeIdentifiers

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

                case .fileShelf:
                    FileShelfExpandedView()

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
                    icon: "tray.full.fill",
                    label: "Shelf",
                    color: .cyan,
                    action: { viewModel.switchToMode(.fileShelf) }
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

            Text("Drop files on the island to park them temporarily")
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

 
/// In-memory, reference-only holding area. The original files are never copied,
/// moved, uploaded or deleted. Items disappear when DynamicIsle quits.
@MainActor
final class FileShelfStore: ObservableObject {
    static let shared = FileShelfStore()
    @Published private(set) var files: [URL] = []
    private let maxFiles = 20

    @discardableResult
    func add(_ urls: [URL]) -> Int {
        var added = 0
        for url in urls where url.isFileURL {
            let normalized = url.standardizedFileURL
            guard FileManager.default.fileExists(atPath: normalized.path) else { continue }
            files.removeAll { $0.standardizedFileURL == normalized }
            files.insert(normalized, at: 0)
            added += 1
        }
        files = Array(files.prefix(maxFiles))
        return added
    }

    func remove(_ url: URL) {
        files.removeAll { $0 == url }
    }

    func clear() {
        files.removeAll()
    }
}

/// Accepts local Finder file URLs. Drag a parked item out to another app,
/// or use Reveal in Finder. Dropping onto the shelf does not move the source.
struct FileShelfExpandedView: View {
    @ObservedObject private var shelf = FileShelfStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("File Shelf", systemImage: "tray.full.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(shelf.files.count)/20")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.55))
                if !shelf.files.isEmpty {
                    Button("Clear") { shelf.clear() }
                        .buttonStyle(.plain)
                        .font(.system(size: 10))
                        .foregroundColor(.cyan)
                        .accessibilityLabel("Remove all parked file references")
                }
            }
            if shelf.files.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.cyan)
                    Text("Drag files from Finder onto the island")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                    Text("Files stay in their original location")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 9) {
                        ForEach(shelf.files, id: \.self) { url in
                            VStack(spacing: 5) {
                                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                Text(url.lastPathComponent)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .font(.system(size: 9))
                                    .foregroundColor(.white)
                                    .frame(width: 74)
                                HStack(spacing: 10) {
                                    Button {
                                        NSWorkspace.shared.activateFileViewerSelecting([url])
                                    } label: {
                                        Image(systemName: "folder")
                                    }
                                    .help("Reveal in Finder")
                                    Button {
                                        shelf.remove(url)
                                    } label: {
                                        Image(systemName: "xmark.circle")
                                    }
                                    .help("Remove from shelf")
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.cyan)
                                .font(.system(size: 11))
                            }
                            .padding(7)
                            .background(Color.white.opacity(0.09))
                            .cornerRadius(10)
                            .onDrag { NSItemProvider(object: url as NSURL) }
                            .help("Drag into another app to use the original file")
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
