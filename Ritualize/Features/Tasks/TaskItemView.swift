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
                modelContext.delete(task)
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
        }.swipeActions(edge: .leading) {
            Button(action: {
                task.isCompleted.toggle()
            }) {
                Image(systemName: "checkmark")
            }
            .tint(Color.accentColor)
        }
    }
}
