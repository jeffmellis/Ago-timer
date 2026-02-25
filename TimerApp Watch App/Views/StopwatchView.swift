import SwiftUI

struct StopwatchView: View {
    @ObservedObject var stopwatch: Stopwatch
    @State private var showingEditSheet = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !stopwatch.isRunning)) { _ in
            VStack(spacing: 6) {
                Spacer()

                timeDisplay

                if !stopwatch.isRunning, let pausedDate = stopwatch.pausedAtDate {
                    HStack(spacing: 4) {
                        Text("Paused at \(pausedDate.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Button(action: stopwatch.resumeFromPause) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 10))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.orange)
                    }
                }

                Spacer()

                buttonRow
            }
            .padding(.horizontal, 4)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTimeView(stopwatch: stopwatch)
        }
    }

    private var timeDisplay: some View {
        Text(formatTime(stopwatch.currentTime))
            .font(.system(size: 36, weight: .medium, design: .monospaced))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundStyle(stopwatch.isRunning ? .green : .primary)
    }

    @ViewBuilder
    private var buttonRow: some View {
        if stopwatch.isRunning {
            HStack(spacing: 12) {
                Button(action: stopwatch.pause) {
                    Image(systemName: "pause.fill")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
                .tint(.orange)
            }
        } else {
            HStack(spacing: 12) {
                if stopwatch.hasTime {
                    Button(action: stopwatch.reset) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)
                    }
                    .tint(.gray)
                }

                Button(action: stopwatch.start) {
                    Image(systemName: "play.fill")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
                .tint(.green)

                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                        .font(.title3)
                }
                .tint(.blue)
            }
        }
    }
}

private func formatTime(_ time: TimeInterval) -> String {
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
