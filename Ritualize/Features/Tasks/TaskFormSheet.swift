import SwiftUI

struct TaskFormSheet: View {
    let title: String
    @Binding var name: String
    @Binding var duration: String
    @FocusState private var isNameFocused: Bool

    let onDismiss: () -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Task Name", text: $name)
                    .focused($isNameFocused)
                    .padding()
                    .background(Color.secondary.brightness(-0.7).saturation(-1))
                    .cornerRadius(12)

                TextField("Duration (minutes)", text: $duration)
                    #if os(iOS)
                        .keyboardType(.numberPad)
                    #endif
                    .padding()
                    .background(Color.secondary.brightness(-0.7).saturation(-1))
                    .cornerRadius(12)

                Spacer()
            }
            .padding(12)
            .navigationTitle(title)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                isNameFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(title == "Add Task" ? "Add" : "Save") {
                        onSave()
                    }
                    .disabled(name.isEmpty || duration.isEmpty)
                }
            }
        }
    }
}
