import SwiftUI

struct TaskFormSheet: View {
    let title: String
    @Binding var name: String
    @Binding var duration: String
    @Binding var selectedTaskType: TaskType

    @FocusState private var isNameFocused: Bool

    let taskTypes = [TaskType.task, TaskType.milestone]

    let onDismiss: () -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                Picker("Select a task type", selection: $selectedTaskType) {
                    ForEach(taskTypes, id: \.self) { taskType in
                        Text(taskType.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 36)

                TextField("Task Name", text: $name)
                    .focused($isNameFocused)
                    .padding()
                    .background(Color.muted)
                    .cornerRadius(12)

                if selectedTaskType == TaskType.task {
                    TextField("Duration (minutes)", text: $duration)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                        .padding()
                        .background(Color.muted)
                        .cornerRadius(12)
                }
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
