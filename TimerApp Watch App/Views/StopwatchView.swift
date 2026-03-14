import SwiftUI

struct StopwatchView: View {
    @ObservedObject var stopwatch: Stopwatch
    @State private var showingEditSheet = false
    @State private var showingNameInput = false
    @State private var hapticTrigger = 0

    private static let runningGreen = Color(red: 0.35, green: 0.9, blue: 0.45)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !stopwatch.isRunning)) { _ in
            VStack(spacing: 6) {
                HStack {
                    Text(stopwatch.name.isEmpty ? "Untitled" : stopwatch.name)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(stopwatch.name.isEmpty ? 0.35 : 0.7))
                        .lineLimit(1)
                        .onTapGesture { showingNameInput = true }
                    Spacer()
                }

                Spacer()

                timeDisplay

                if !stopwatch.isRunning, let pausedDate = stopwatch.pausedAtDate {
                    Button(action: stopwatch.resumeFromPause) {
                        HStack(spacing: 4) {
                            Text("Paused \(pausedDate.formatted(date: .omitted, time: .shortened))")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 11))
                                .foregroundStyle(.orange)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                buttonRow
            }
            .padding(.horizontal, 4)
        }
        .sensoryFeedback(.impact(flexibility: .solid), trigger: hapticTrigger)
        .sheet(isPresented: $showingEditSheet) {
            EditTimeView(stopwatch: stopwatch)
        }
        .sheet(isPresented: $showingNameInput) {
            NameInputView(name: $stopwatch.name)
        }
    }

    private var timeDisplay: some View {
        Text(formatStopwatchTime(stopwatch.currentTime))
            .font(.system(size: 38, weight: .semibold, design: .monospaced))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundStyle(stopwatch.isRunning ? Self.runningGreen : .primary)
    }

    @ViewBuilder
    private var buttonRow: some View {
        if stopwatch.isRunning {
            Button(action: { hapticTrigger += 1; stopwatch.pause() }) {
                Image(systemName: "pause.fill")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
            }
            .tint(.orange)
        } else {
            VStack(spacing: 6) {
                Button(action: { hapticTrigger += 1; stopwatch.start() }) {
                    Image(systemName: "play.fill")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
                .tint(.green)

                if stopwatch.hasTime {
                    HStack(spacing: 6) {
                        Button(action: { hapticTrigger += 1; stopwatch.reset() }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.gray)

                        Button(action: { showingEditSheet = true }) {
                            Image(systemName: "pencil")
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.gray)
                    }
                }
            }
        }
    }
}
