import SwiftUI

struct StopwatchView: View {
    @ObservedObject var stopwatch: Stopwatch
    @State private var showingEditSheet = false
    @State private var showingNameInput = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !stopwatch.isRunning)) { _ in
            VStack(spacing: 6) {
                HStack {
                    if stopwatch.name.isEmpty {
                        Button(action: { showingNameInput = true }) {
                            Image(systemName: "tag")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                    } else {
                        Text(stopwatch.name)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .onTapGesture { showingNameInput = true }
                    }
                    Spacer()
                }

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
        .sheet(isPresented: $showingNameInput) {
            NameInputView(name: $stopwatch.name)
        }
    }

    private var timeDisplay: some View {
        Text(formatStopwatchTime(stopwatch.currentTime))
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
