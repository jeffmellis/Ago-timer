import SwiftUI

struct TimerRowView: View {
    @ObservedObject var stopwatch: Stopwatch

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { _ in
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    if !stopwatch.name.isEmpty {
                        Text(stopwatch.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(formatStopwatchTimeCompact(stopwatch.currentTime))
                        .font(.system(size: 32, weight: stopwatch.isRunning ? .semibold : .light, design: .monospaced))
                        .foregroundStyle(stopwatch.isRunning ? AgoTheme.runningTime : .primary)
                        .contentTransition(.numericText())
                }

                Spacer()

                if !stopwatch.isRunning && stopwatch.hasTime {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            stopwatch.reset()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(AgoTheme.secondaryButton.opacity(0.15))
                            .clipShape(Circle())
                            .foregroundStyle(AgoTheme.secondaryButton)
                    }
                    .buttonStyle(.borderless)
                    .transition(.scale.combined(with: .opacity))
                }

                if !stopwatch.isRunning && stopwatch.pausedAtDate != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            stopwatch.resumeFromPause()
                        }
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(AgoTheme.resumeButton.opacity(0.15))
                            .clipShape(Circle())
                            .foregroundStyle(AgoTheme.resumeButton)
                    }
                    .buttonStyle(.borderless)
                    .transition(.scale.combined(with: .opacity))
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        stopwatch.isRunning ? stopwatch.pause() : stopwatch.start()
                    }
                } label: {
                    Image(systemName: stopwatch.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(
                            (stopwatch.isRunning ? AgoTheme.pauseButton : AgoTheme.playButton)
                                .opacity(0.2)
                        )
                        .clipShape(Circle())
                        .foregroundStyle(stopwatch.isRunning ? AgoTheme.pauseButton : AgoTheme.playButton)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 8)
        }
    }
}
