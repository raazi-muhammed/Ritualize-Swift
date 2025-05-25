import SwiftUI

struct TaskFormSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: TaskDataItem

    let title: String
    @FocusState private var isNameFocused: Bool

    let taskTypes = [TaskType.task.rawValue, TaskType.milestone.rawValue]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $task.name)
                        .textContentType(.name)
                        .focused($isNameFocused)
                    Stepper("Order \(task.order)", value: $task.order)
                }
                Section {
                    Picker("Select a task type", selection: $task.type) {
                        ForEach(taskTypes, id: \.self) { taskType in
                            Text(taskType.capitalized)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        "Cancel",
                        action: {
                            if title == "Add Task" {
                                modelContext.delete(task)
                            }
                            dismiss()
                        })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(title == "Add Task" ? "Add" : "Save") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(task.name.isEmpty)
                }
            }
        }
        .onAppear {
            isNameFocused = true
        }

    }
}
