import SwiftUI

struct EditTimeView: View {
    @ObservedObject var stopwatch: Stopwatch
    @Environment(\.dismiss) private var dismiss

    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                HStack(spacing: 0) {
                    wheelPicker("hr", selection: $hours, range: 0..<24)
                    wheelPicker("min", selection: $minutes, range: 0..<60)
                    wheelPicker("sec", selection: $seconds, range: 0..<60)
                }
                .frame(height: 180)

                Spacer()

                Button {
                    stopwatch.setTime(hours: hours, minutes: minutes, seconds: seconds)
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(.borderedProminent)
                .tint(AgoTheme.confirmAction)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .navigationTitle("Edit Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            let total = Int(stopwatch.currentTime)
            hours = total / 3600
            minutes = (total % 3600) / 60
            seconds = total % 60
        }
    }

    private func wheelPicker(_ unit: String, selection: Binding<Int>, range: Range<Int>) -> some View {
        Picker(unit, selection: selection) {
            ForEach(range, id: \.self) { value in
                Text("\(value) \(unit)").tag(value)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
    }
}
