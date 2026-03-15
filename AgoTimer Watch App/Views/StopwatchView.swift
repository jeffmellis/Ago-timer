import SwiftUI

struct StopwatchView: View {
    @ObservedObject var stopwatch: Stopwatch
    @State private var showingEditSheet = false
    @State private var showingNameInput = false
    @State private var hapticTrigger = 0
    @State private var timeScale: CGFloat = 1.0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !stopwatch.isRunning)) { _ in
            VStack(spacing: 0) {
                if !stopwatch.name.isEmpty {
                    Text(stopwatch.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AgoTheme.nameLabel)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            if !stopwatch.isRunning { showingNameInput = true }
                        }
                }

                Spacer()

                VStack(spacing: 4) {
                    timeDisplay
                        .scaleEffect(timeScale)

                    if !stopwatch.isRunning, let pausedDate = stopwatch.pausedAtDate {
                        Text("Paused \(pausedDate.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 13))
                            .foregroundStyle(AgoTheme.pausedLabel)
                    }
                }

                Spacer()
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

    private func timeText() -> Text {
        let formatted = formatStopwatchTime(stopwatch.currentTime)
        let weight: Font.Weight = stopwatch.isRunning ? .bold : .light
        let font = Font.system(size: 42, weight: weight, design: .monospaced)
        let color: Color = stopwatch.isRunning ? AgoTheme.runningTime : AgoTheme.pausedTime

        if let dotIndex = formatted.lastIndex(of: ".") {
            let main = String(formatted[..<dotIndex])
            let frac = String(formatted[dotIndex...])
            return Text(main).font(font).foregroundColor(color)
                 + Text(frac).font(font).foregroundColor(color.opacity(0.4))
        }
        return Text(formatted).font(font).foregroundColor(color)
    }

    private var timeDisplay: some View {
        timeText()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .animation(.easeInOut(duration: 0.3), value: stopwatch.isRunning)
    }

    @ViewBuilder
    private var buttonRow: some View {
        if stopwatch.isRunning {
            Button(action: {
                hapticTrigger += 1
                withAnimation(.easeInOut(duration: 0.25)) {
                    stopwatch.pause()
                }
            }) {
                Image(systemName: "pause.fill")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
            }
            .tint(AgoTheme.pauseButton)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            VStack(spacing: 6) {
                if stopwatch.pausedAtDate != nil {
                    HStack(spacing: 6) {
                        Button(action: {
                            hapticTrigger += 1
                            withAnimation(.easeInOut(duration: 0.25)) {
                                stopwatch.start()
                            }
                        }) {
                            Image(systemName: "play.fill")
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                        }
                        .tint(AgoTheme.playButton)

                        Button(action: {
                            hapticTrigger += 1
                            withAnimation(.easeInOut(duration: 0.25)) {
                                stopwatch.resumeFromPause()
                            }
                        }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                        }
                        .tint(AgoTheme.resumeButton)
                    }
                } else {
                    Button(action: {
                        hapticTrigger += 1
                        withAnimation(.easeInOut(duration: 0.25)) {
                            stopwatch.start()
                        }
                    }) {
                        Image(systemName: "play.fill")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(AgoTheme.playButton)
                }

                if stopwatch.hasTime {
                    HStack(spacing: 6) {
                        Button(action: {
                            hapticTrigger += 1
                            withAnimation(.easeIn(duration: 0.15)) {
                                timeScale = 0.85
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                stopwatch.reset()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    timeScale = 1.0
                                }
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                        }
                        .tint(AgoTheme.secondaryButton)

                        Button(action: { showingEditSheet = true }) {
                            Image(systemName: "pencil")
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                        }
                        .tint(AgoTheme.secondaryButton)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
