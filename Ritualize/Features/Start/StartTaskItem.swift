import SwiftData
import SwiftUI

struct StartTaskItem: View {
    let task: TaskDataItem
    let isActive: Bool
    let currentTime: Int
    private let animationDuration: Double = 0.3

    @Environment(\.modelContext) private var modelContext
    var isMilestone: Bool {
        task.type == TaskType.milestone.rawValue
    }

    var body: some View {
        HStack {
            if !isMilestone {
                Image(systemName: task.isCompleted ? "checkmark.fill" : "circle")
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.spring(response: animationDuration), value: task.isCompleted)
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
                        .padding(.bottom, isMilestone ? 4 : isActive ? 12 : 0)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(
                            isActive
                                ? getColor(
                                    color: task.routine?.color ?? DefaultValues.color)
                                : Color.primary

                        )

                    Spacer()
                }
            }
            .frame(height: 50)
            .overlay(alignment: .bottom) {
                HStack {
                    ProgressView(value: Float(currentTime) / Float(task.duration))
                        .tint(getColor(color: task.routine?.color ?? DefaultValues.color))
                        .frame(width: isActive ? 100 : 0, height: 8)
                        .animation(
                            .spring(response: animationDuration * 2, dampingFraction: 0.7),
                            value: isActive)
                    Text("\(currentTime) / \(task.duration)").font(.system(size: 10))
                    Spacer()
                }.opacity(isActive ? 1 : 0)
                if isMilestone {
                    RoundedRectangle(cornerRadius: 3)
                        .frame(height: 2)
                        .foregroundColor(
                            getColor(color: task.routine?.color ?? DefaultValues.color).opacity(
                                0.3)
                        )
                }
            }

        }
        .animation(.spring(response: animationDuration * 2, dampingFraction: 0.7), value: isActive)
    }
}
