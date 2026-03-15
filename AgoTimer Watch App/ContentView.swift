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
        VStack {
            Spacer()
            Button(action: addNewStopwatch) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.3))
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
