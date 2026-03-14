import SwiftUI

struct ContentView: View {
    @StateObject private var manager = StopwatchManager()

    var body: some View {
        TabView(selection: $manager.selectedTab) {
            ForEach(Array(manager.stopwatches.enumerated()), id: \.element.id) { index, stopwatch in
                StopwatchView(stopwatch: stopwatch)
                    .tag(index)
            }

            newStopwatchPage
                .tag(manager.stopwatches.count)
        }
        .tabViewStyle(.verticalPage)
    }

    private var newStopwatchPage: some View {
        VStack(spacing: 12) {
            Spacer()
            Button(action: addNewStopwatch) {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .opacity(0.6)
                    Text("New Stopwatch")
                        .font(.system(size: 14))
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.green)
            Spacer()
        }
    }

    private func addNewStopwatch() {
        manager.addStopwatch()
        withAnimation {
            manager.selectedTab = manager.stopwatches.count - 1
        }
    }
}

#Preview {
    ContentView()
}
