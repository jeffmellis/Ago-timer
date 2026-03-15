import SwiftUI

struct StopwatchDetailView: View {
    @ObservedObject var stopwatch: Stopwatch
    @State private var showingEditSheet = false
    @State private var showingRenameAlert = false
    @State private var draftName = ""
    @State private var timeScale: CGFloat = 1.0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !stopwatch.isRunning)) { _ in
            VStack(spacing: 0) {
                Spacer()

                timeDisplay
                    .scaleEffect(timeScale)

                if !stopwatch.isRunning, let pausedDate = stopwatch.pausedAtDate {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            stopwatch.resumeFromPause()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Paused \(pausedDate.formatted(date: .omitted, time: .shortened))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.uturn.backward")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }

                Spacer()
                Spacer()

                controls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .navigationTitle(stopwatch.name.isEmpty ? "Timer" : stopwatch.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    draftName = stopwatch.name
                    showingRenameAlert = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .alert("Rename Timer", isPresented: $showingRenameAlert) {
            TextField("Name", text: $draftName)
            Button("Save") { stopwatch.name = draftName }
            Button("Clear", role: .destructive) { stopwatch.name = "" }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTimeView(stopwatch: stopwatch)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Time Display

    private func timeText() -> Text {
        let formatted = formatStopwatchTime(stopwatch.currentTime)
        let weight: Font.Weight = stopwatch.isRunning ? .bold : .light
        let font = Font.system(size: 64, weight: weight, design: .monospaced)
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
            .minimumScaleFactor(0.4)
            .lineLimit(1)
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.3), value: stopwatch.isRunning)
    }

    // MARK: - Controls

    @ViewBuilder
    private var controls: some View {
        if stopwatch.isRunning {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    stopwatch.pause()
                }
            } label: {
                Label("Pause", systemImage: "pause.fill")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(AgoTheme.pauseButton)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            VStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        stopwatch.start()
                    }
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AgoTheme.playButton.opacity(0.2))
                        .foregroundStyle(AgoTheme.playButton)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.borderless)

                if stopwatch.hasTime {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.easeIn(duration: 0.15)) {
                                timeScale = 0.9
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                stopwatch.reset()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    timeScale = 1.0
                                }
                            }
                        } label: {
                            Label("Reset", systemImage: "xmark")
                                .font(.body.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AgoTheme.secondaryButton.opacity(0.3))

                        Button { showingEditSheet = true } label: {
                            Label("Edit", systemImage: "pencil")
                                .font(.body.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AgoTheme.secondaryButton.opacity(0.3))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
