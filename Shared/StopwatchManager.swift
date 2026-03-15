import Foundation
import Combine
import WidgetKit

class StopwatchManager: ObservableObject {
    @Published var stopwatches: [Stopwatch] = []
    @Published var selectedTab: Int = 0 {
        didSet { syncToWidget() }
    }

    private var cancellables = Set<AnyCancellable>()
    private let syncManager = SyncManager()

    init() {
        syncManager.manager = self
        syncManager.activate()
        addStopwatch()
    }

    @discardableResult
    func addStopwatch() -> Stopwatch {
        let sw = Stopwatch()
        stopwatches.append(sw)
        observeStopwatch(sw)
        syncToPeer()
        return sw
    }

    func removeStopwatches(at offsets: IndexSet) {
        stopwatches.remove(atOffsets: offsets)
        if selectedTab >= stopwatches.count {
            selectedTab = max(0, stopwatches.count - 1)
        }
        syncToWidget()
        syncToPeer()
    }

    func applySnapshots(_ snapshots: [StopwatchSnapshot]) {
        var updated: [Stopwatch] = []

        for snapshot in snapshots {
            if let existing = stopwatches.first(where: { $0.id == snapshot.id }) {
                existing.apply(snapshot)
                updated.append(existing)
            } else {
                let sw = Stopwatch(id: snapshot.id)
                sw.apply(snapshot)
                observeStopwatch(sw)
                updated.append(sw)
            }
        }

        stopwatches = updated

        if selectedTab >= stopwatches.count {
            selectedTab = max(0, stopwatches.count - 1)
        }

        syncToWidget()
    }

    private func observeStopwatch(_ sw: Stopwatch) {
        sw.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
                self?.syncToWidget()
                self?.syncToPeer()
            }
            .store(in: &cancellables)
    }

    private func syncToWidget() {
        guard selectedTab < stopwatches.count else { return }
        stopwatches[selectedTab].sharedState().save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func syncToPeer() {
        syncManager.sendState(stopwatches)
    }
}
