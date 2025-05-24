import SwiftData
import SwiftUI

struct TaskItem: View {
    let task: TaskDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    @State private var editedName = ""
    @State private var editedDuration = ""
    @State private var selectedTaskType: TaskType = TaskType.task

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .contentTransition(.symbolEffect(.automatic))
                .foregroundColor(
                    task.isCompleted
                        ? getColor(color: task.routine?.color ?? DefaultValues.color)
                        : .primary
                )
                .padding(.trailing, 8)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        task.isCompleted.toggle()
                    }
                }
            VStack {
                HStack {
                    Text(task.name).foregroundColor(
                        task.type == TaskType.milestone.rawValue
                            ? getColor(color: task.routine?.color ?? DefaultValues.color)
                            : Color.primary)
                    Spacer()
                }
                HStack {
                    Text("\(task.order) min").font(.caption)
                    Text("\(task.type)").font(.caption)
                    Spacer()
                }
            }
        }.swipeActions {
            Button(action: {
                do {
                    modelContext.delete(task)
                    try modelContext.save()
                } catch {
                    print("Error deleting task: \(error)")
                }
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
            Button(action: {
                editedName = task.name
                editedDuration = "\(task.order)"
                showEditSheet = true
            }) {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }.swipeActions(edge: .leading) {
            Button(action: {
                task.isCompleted.toggle()
                try? modelContext.save()
            }) {
                Image(systemName: "checkmark")
            }
            .tint(getColor(color: task.routine?.color ?? DefaultValues.color))
        }
        .sheet(isPresented: $showEditSheet) {
            TaskFormSheet(
                title: "Edit Task",
                name: $editedName,
                duration: $editedDuration,
                selectedTaskType: $selectedTaskType,
                onDismiss: { showEditSheet = false },
                onSave: {
                    task.name = editedName
                    if let duration = Int(editedDuration) {
                        task.order = duration
                    }
                    try? modelContext.save()
                    showEditSheet = false
                }
            )
        }
    }
}
