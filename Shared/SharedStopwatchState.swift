import Foundation

struct SharedStopwatchState: Codable {
    var accumulatedTime: TimeInterval
    var isRunning: Bool
    var lastStartDate: Date?
    var name: String

    static let suiteName = "group.com.agotimer.shared"
    static let key = "selectedStopwatchState"

    static func load() -> SharedStopwatchState? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SharedStopwatchState.self, from: data)
    }

    func save() {
        guard let defaults = UserDefaults(suiteName: Self.suiteName),
              let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: Self.key)
    }
}

func formatStopwatchTime(_ time: TimeInterval) -> String {
    let clamped = max(0, time)
    let totalCentiseconds = Int(clamped * 100)
    let hours = totalCentiseconds / 360000
    let minutes = (totalCentiseconds % 360000) / 6000
    let seconds = (totalCentiseconds % 6000) / 100
    let centiseconds = totalCentiseconds % 100

    if hours > 0 {
        return String(format: "%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds)
    }
    return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
}

/// Seconds-precision format for widgets and compact displays: `H:MM:SS`
func formatStopwatchTimeCompact(_ time: TimeInterval) -> String {
    let clamped = max(0, time)
    let total = Int(clamped)
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    let seconds = total % 60
    return String(format: "%d:%02d:%02d", hours, minutes, seconds)
}
