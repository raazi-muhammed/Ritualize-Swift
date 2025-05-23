import SwiftData
import SwiftUI

struct TaskItem: View {
    let task: TaskDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    @State private var editedName = ""
    @State private var editedDuration = ""

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(
                    task.isCompleted
                        ? getColor(color: task.routine?.color ?? DatabaseColor.blue.rawValue)
                        : .primary
                )
                .padding(.trailing, 8)
                .onTapGesture {
                    task.isCompleted.toggle()
                }
            VStack {
                HStack {
                    Text(task.name)
                    Spacer()
                }
                HStack {
                    Text("\(task.order) min").font(.caption)
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
            .tint(getColor(color: task.routine?.color ?? DatabaseColor.blue.rawValue))
        }
        .sheet(isPresented: $showEditSheet) {
            TaskFormSheet(
                title: "Edit Task",
                name: $editedName,
                duration: $editedDuration,
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
