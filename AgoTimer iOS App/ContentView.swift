import SwiftUI

struct ContentView: View {
    @StateObject private var manager = StopwatchManager()

    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.stopwatches) { stopwatch in
                    NavigationLink(value: stopwatch.id) {
                        TimerRowView(stopwatch: stopwatch)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .onDelete { offsets in
                    manager.stopwatches.remove(atOffsets: offsets)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Ago Timer")
            .navigationDestination(for: UUID.self) { id in
                if let stopwatch = manager.stopwatches.first(where: { $0.id == id }) {
                    StopwatchDetailView(stopwatch: stopwatch)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { manager.addStopwatch() }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .tint(AgoTheme.accent)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
