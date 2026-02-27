import WidgetKit
import SwiftUI

struct StopwatchEntry: TimelineEntry {
    let date: Date
    let displayTime: String
    let name: String
    let isRunning: Bool
}

struct StopwatchTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StopwatchEntry {
        StopwatchEntry(date: .now, displayTime: "0:00:00", name: "", isRunning: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (StopwatchEntry) -> Void) {
        let state = SharedStopwatchState.load()
        let time = computeTime(for: state, at: .now)
        completion(StopwatchEntry(date: .now, displayTime: formatComplicationTime(time), name: state?.name ?? "", isRunning: state?.isRunning ?? false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StopwatchEntry>) -> Void) {
        let state = SharedStopwatchState.load()
        let isRunning = state?.isRunning ?? false

        if isRunning {
            var entries: [StopwatchEntry] = []
            let now = Date()
            for offset in 0..<60 {
                let entryDate = now.addingTimeInterval(Double(offset))
                let time = computeTime(for: state, at: entryDate)
                entries.append(StopwatchEntry(date: entryDate, displayTime: formatComplicationTime(time), name: state?.name ?? "", isRunning: true))
            }
            let timeline = Timeline(entries: entries, policy: .after(now.addingTimeInterval(55)))
            completion(timeline)
        } else {
            let time = computeTime(for: state, at: .now)
            let entry = StopwatchEntry(date: .now, displayTime: formatComplicationTime(time), name: state?.name ?? "", isRunning: false)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
            completion(timeline)
        }
    }

    private func computeTime(for state: SharedStopwatchState?, at date: Date) -> TimeInterval {
        guard let state else { return 0 }
        if state.isRunning, let start = state.lastStartDate {
            return state.accumulatedTime + date.timeIntervalSince(start)
        }
        return state.accumulatedTime
    }
}

struct StopwatchWidgetView: View {
    var entry: StopwatchEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            if !entry.name.isEmpty {
                Text(entry.name)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Text(entry.displayTime)
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundStyle(entry.isRunning ? .green : .primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private func formatComplicationTime(_ time: TimeInterval) -> String {
    let clamped = max(0, time)
    let total = Int(clamped)
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    let seconds = total % 60
    return String(format: "%d:%02d:%02d", hours, minutes, seconds)
}

@main
struct TimerAppWidget: Widget {
    let kind = "TimerAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StopwatchTimelineProvider()) { entry in
            StopwatchWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Stopwatch")
        .description("Shows the current stopwatch time")
        .supportedFamilies([.accessoryRectangular])
    }
}
