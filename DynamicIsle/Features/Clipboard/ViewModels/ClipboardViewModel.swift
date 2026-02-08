import SwiftUI
import Combine

class ClipboardViewModel: ObservableObject {
    @Published var history: [ClipboardItem] = []
    @Published var latestItem: ClipboardItem?
    @Published var hasItems = false

    private let clipboardService = ClipboardService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        clipboardService.$history
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.history = items
                self?.hasItems = !items.isEmpty
            }
            .store(in: &cancellables)

        clipboardService.$latestItem
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestItem)
    }

    // MARK: - Actions

    func paste(item: ClipboardItem) {
        clipboardService.paste(item: item)
    }

    func copy(item: ClipboardItem) {
        clipboardService.copyToClipboard(item: item)
    }

    func remove(item: ClipboardItem) {
        clipboardService.removeItem(item)
    }

    func clearHistory() {
        clipboardService.clearHistory()
    }

    // MARK: - Computed

    var recentItems: [ClipboardItem] {
        Array(history.prefix(5))
    }

    var latestPreview: String {
        latestItem?.preview ?? "Clipboard empty"
    }

    var latestIcon: String {
        latestItem?.icon ?? "doc.on.clipboard"
    }
}
