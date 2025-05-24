import SwiftData
import SwiftUI

struct StartTaskItem: View {
    let task: TaskDataItem
    let isActive: Bool

    @Environment(\.modelContext) private var modelContext
    var isMilestone: Bool {
        task.type == TaskType.milestone.rawValue
    }

    var body: some View {
        HStack {
            if !isMilestone {
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
            }
            VStack {
                HStack {
                    Text(task.name)
                        .font(
                            .system(
                                size: isActive ? 40 : isMilestone ? 18 : 18,
                                weight: isActive ? .bold : .regular
                            )
                        )
                        .padding(.bottom, isMilestone ? 4 : 0)
                        .foregroundStyle(
                            isActive
                                ? getColor(
                                    color: task.routine?.color ?? DefaultValues.color)
                                : Color.primary

                        )

                    Spacer()
                }
            }
            .overlay(alignment: .bottom) {
                if isMilestone {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(
                            getColor(color: task.routine?.color ?? DefaultValues.color)
                        )
                }
            }

        }
        .animation(.spring(response: 0.75, dampingFraction: 0.7), value: isActive)
    }
}
