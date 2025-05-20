import SwiftData
import SwiftUI

struct TaskItem: View {
    let task: TaskDataItem
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .accentColor : .primary)
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
                    Text("\(task.order)  min").font(.caption)
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
        }.swipeActions(edge: .leading) {
            Button(action: {
                task.isCompleted.toggle()
                try? modelContext.save()
            }) {
                Image(systemName: "checkmark")
            }
            .tint(Color.accentColor)
        }
    }
}
