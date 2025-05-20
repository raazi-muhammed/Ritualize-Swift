import SwiftData
import SwiftUI

struct StartTaskItem: View {
    let task: TaskDataItem
    let isActive: Bool

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
                        .font(.system(size: isActive ? 40 : 18))
                        .foregroundStyle(isActive ? Color.accentColor : Color.primary)

                    Spacer()
                }
            }
        }
    }
}
