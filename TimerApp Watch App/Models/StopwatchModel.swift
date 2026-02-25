import Foundation

class Stopwatch: Identifiable, ObservableObject {
    let id: UUID
    @Published private(set) var isRunning = false
    @Published private(set) var pausedAtDate: Date?

    @Published private var accumulatedTime: TimeInterval = 0
    private var lastStartDate: Date?

    init(id: UUID = UUID()) {
        self.id = id
    }

    var currentTime: TimeInterval {
        if isRunning, let start = lastStartDate {
            return accumulatedTime + Date().timeIntervalSince(start)
        }
        return accumulatedTime
    }

    var hasTime: Bool {
        accumulatedTime > 0
    }

    func start() {
        guard !isRunning else { return }
        lastStartDate = Date()
        isRunning = true
        pausedAtDate = nil
    }

    /// Resumes as if the stopwatch was never paused — adds the paused
    /// duration back onto accumulated time before restarting.
    func resumeFromPause() {
        guard !isRunning, let paused = pausedAtDate else { return }
        accumulatedTime += Date().timeIntervalSince(paused)
        lastStartDate = Date()
        isRunning = true
        pausedAtDate = nil
    }

    func pause() {
        guard isRunning, let start = lastStartDate else { return }
        accumulatedTime += Date().timeIntervalSince(start)
        lastStartDate = nil
        isRunning = false
        pausedAtDate = Date()
    }

    func reset() {
        lastStartDate = nil
        accumulatedTime = 0
        isRunning = false
        pausedAtDate = nil
    }

    func setTime(hours: Int, minutes: Int, seconds: Int) {
        let newTime = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        accumulatedTime = newTime
        if isRunning {
            lastStartDate = Date()
        }
        if !isRunning && pausedAtDate != nil {
            pausedAtDate = Date()
        }
    }
}
