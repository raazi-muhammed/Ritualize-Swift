import SwiftData
import SwiftUI

struct StartTaskItem: View {
    let task: TaskDataItem
    let isActive: Bool

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(
                    task.isCompleted
                        ? getColor(color: task.routine?.color ?? DefaultValues.color)
                        : .primary
                )
                .padding(.trailing, 8)
                .onTapGesture {
                    task.isCompleted.toggle()
                }
            VStack {
                HStack {
                    Text(task.name)
                        .font(
                            .system(size: isActive ? 40 : 18, weight: isActive ? .bold : .regular)
                        )
                        .foregroundStyle(
                            isActive
                                ? getColor(
                                    color: task.routine?.color ?? DefaultValues.color)
                                : Color.primary)

                    Spacer()
                }
            }
        }
        .animation(.spring(response: 0.75, dampingFraction: 0.7), value: isActive)
    }
}
