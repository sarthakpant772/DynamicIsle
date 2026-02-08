import Foundation
import AppKit
import Combine

/// Service for monitoring and managing clipboard history
class ClipboardService: ObservableObject {
    static let shared = ClipboardService()

    @Published var history: [ClipboardItem] = []
    @Published var latestItem: ClipboardItem?

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxHistoryItems = 10

    private init() {
        lastChangeCount = NSPasteboard.general.changeCount
        startMonitoring()
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        // Get clipboard content
        if let item = extractClipboardItem(from: pasteboard) {
            addToHistory(item)
        }
    }

    private func extractClipboardItem(from pasteboard: NSPasteboard) -> ClipboardItem? {
        // Check for image first
        if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
            return ClipboardItem(type: .image, preview: "[Image]", image: image)
        }

        // Check for file URLs
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
            let names = urls.prefix(3).map { $0.lastPathComponent }.joined(separator: ", ")
            return ClipboardItem(type: .file, preview: names, fileURLs: urls)
        }

        // Check for text
        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            // Truncate preview
            let preview = String(text.prefix(100)).replacingOccurrences(of: "\n", with: " ")
            return ClipboardItem(type: .text, preview: preview, text: text)
        }

        return nil
    }

    private func addToHistory(_ item: ClipboardItem) {
        DispatchQueue.main.async {
            // Remove duplicate if exists
            self.history.removeAll { $0.preview == item.preview }

            // Add to front
            self.history.insert(item, at: 0)

            // Trim to max size
            if self.history.count > self.maxHistoryItems {
                self.history = Array(self.history.prefix(self.maxHistoryItems))
            }

            self.latestItem = item
        }
    }

    // MARK: - Actions

    func paste(item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.type {
        case .text:
            if let text = item.text {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let image = item.image {
                pasteboard.writeObjects([image])
            }
        case .file:
            if let urls = item.fileURLs {
                pasteboard.writeObjects(urls as [NSURL])
            }
        }

        // Simulate Cmd+V
        simulatePaste()
    }

    func copyToClipboard(item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.type {
        case .text:
            if let text = item.text {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let image = item.image {
                pasteboard.writeObjects([image])
            }
        case .file:
            if let urls = item.fileURLs {
                pasteboard.writeObjects(urls as [NSURL])
            }
        }
    }

    private func simulatePaste() {
        // Use CGEvent to simulate Cmd+V
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) // V key
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }

    func clearHistory() {
        DispatchQueue.main.async {
            self.history.removeAll()
            self.latestItem = nil
        }
    }

    func removeItem(_ item: ClipboardItem) {
        DispatchQueue.main.async {
            self.history.removeAll { $0.id == item.id }
        }
    }

    deinit {
        timer?.invalidate()
    }
}

// MARK: - Models

struct ClipboardItem: Identifiable, Equatable {
    let id = UUID()
    let type: ClipboardItemType
    let preview: String
    let timestamp = Date()

    var text: String?
    var image: NSImage?
    var fileURLs: [URL]?

    init(type: ClipboardItemType, preview: String, text: String? = nil, image: NSImage? = nil, fileURLs: [URL]? = nil) {
        self.type = type
        self.preview = preview
        self.text = text
        self.image = image
        self.fileURLs = fileURLs
    }

    var icon: String {
        switch type {
        case .text: return "doc.text"
        case .image: return "photo"
        case .file: return "folder"
        }
    }

    var relativeTime: String {
        let interval = Date().timeIntervalSince(timestamp)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else {
            return "\(Int(interval / 3600))h ago"
        }
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum ClipboardItemType {
    case text
    case image
    case file
}
