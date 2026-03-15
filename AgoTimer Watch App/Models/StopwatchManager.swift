import Foundation
import Combine
import WidgetKit

class StopwatchManager: ObservableObject {
    @Published var stopwatches: [Stopwatch] = []
    @Published var selectedTab: Int = 0 {
        didSet { syncToWidget() }
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        addStopwatch()
    }

    @discardableResult
    func addStopwatch() -> Stopwatch {
        let sw = Stopwatch()
        stopwatches.append(sw)
        sw.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
                self?.syncToWidget()
            }
            .store(in: &cancellables)
        return sw
    }

    private func syncToWidget() {
        guard selectedTab < stopwatches.count else { return }
        stopwatches[selectedTab].sharedState().save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
