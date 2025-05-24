import SwiftUI

struct TaskFormSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var task: TaskDataItem

    let title: String
    @FocusState private var isNameFocused: Bool

    let taskTypes = [TaskType.task, TaskType.milestone]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Select a task type", selection: $task.type) {
                    ForEach(taskTypes, id: \.self) { taskType in
                        Text(taskType.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 36)

                TextField("Task Name", text: $task.name)
                    .textContentType(.name)
                    .focused($isNameFocused)
                    .padding()
                    .background(Color.muted)
                    .cornerRadius(12)
                TextField("Duration (minutes)", value: $task.order, format: .number)
                    #if os(iOS)
                        .keyboardType(.numberPad)
                    #endif
                    .padding()
                    .background(Color.muted)
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
    }
}
