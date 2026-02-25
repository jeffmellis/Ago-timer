import SwiftUI

struct EditTimeView: View {
    @ObservedObject var stopwatch: Stopwatch
    @Environment(\.dismiss) private var dismiss

    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack(spacing: 2) {
                    Picker("H", selection: $hours) {
                        ForEach(0..<24, id: \.self) { h in
                            Text("\(h)h").tag(h)
                        }
                    }
                    .frame(width: 52)

                    Picker("M", selection: $minutes) {
                        ForEach(0..<60, id: \.self) { m in
                            Text("\(m)m").tag(m)
                        }
                    }
                    .frame(width: 52)

                    Picker("S", selection: $seconds) {
                        ForEach(0..<60, id: \.self) { s in
                            Text("\(s)s").tag(s)
                        }
                    }
                    .frame(width: 52)
                }
                .frame(height: 80)

                Button("Save") {
                    stopwatch.setTime(hours: hours, minutes: minutes, seconds: seconds)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.top, 4)
        }
        .onAppear {
            let total = Int(stopwatch.currentTime)
            hours = total / 3600
            minutes = (total % 3600) / 60
            seconds = total % 60
        }
    }
}
