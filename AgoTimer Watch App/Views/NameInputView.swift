import SwiftUI

struct NameInputView: View {
    @Binding var name: String
    @Environment(\.dismiss) private var dismiss

    @State private var draft: String = ""

    var body: some View {
        VStack(spacing: 10) {
            Text("Name")
                .font(.headline)

            TextField("Name", text: $draft)

            HStack {
                if !name.isEmpty {
                    Button("Clear") {
                        name = ""
                        dismiss()
                    }
                    .tint(AgoTheme.destructiveAction)
                }

                Button("Save") {
                    name = draft
                    dismiss()
                }
                .tint(AgoTheme.confirmAction)
            }
        }
        .onAppear { draft = name }
    }
}
