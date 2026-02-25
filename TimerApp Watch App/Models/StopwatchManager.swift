import Foundation
import Combine

class StopwatchManager: ObservableObject {
    @Published var stopwatches: [Stopwatch] = []
    @Published var selectedTab: Int = 0

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
            }
            .store(in: &cancellables)
        return sw
    }
}
