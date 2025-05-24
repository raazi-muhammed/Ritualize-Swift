import Foundation
import SwiftData

@Model
final class RoutineDataItem {
    var name: String
    var id: String = UUID().uuidString
    var icon: String = DefaultValues.icon
    var order: Int = 0
    var color: String = DatabaseColor.red.rawValue
    var isFavorite: Bool = false

    @Relationship(deleteRule: .cascade) var tasks: [TaskDataItem] = []

    var sortedTasks: [TaskDataItem] {
        tasks.sorted { $0.order < $1.order }
    }

    func getNewOrder() -> Int {
        (sortedTasks.last?.order ?? 0) + 1
    }

    struct TaskSection {
        let name: String
        var tasks: [TaskDataItem]
    }

    var tasksWithMilestones: [TaskSection] {
        var lastMilestoneName: String = "Others"

        var lastMilestoneTasks: [TaskDataItem] = []
        var tasksWithMilestones: [TaskSection] = []

        for task in sortedTasks {
            if task.type == TaskType.milestone.rawValue {
                if !lastMilestoneTasks.isEmpty {
                    tasksWithMilestones.append(
                        TaskSection(name: lastMilestoneName, tasks: lastMilestoneTasks))
                }
                lastMilestoneTasks = []
                lastMilestoneName = task.name
            } else {
                lastMilestoneTasks.append(task)
            }
        }

        if !lastMilestoneTasks.isEmpty {
            tasksWithMilestones.append(
                TaskSection(name: lastMilestoneName, tasks: lastMilestoneTasks))
        }

        return tasksWithMilestones
    }

    init(name: String, color: String, icon: String) {
        self.name = name
        self.id = UUID().uuidString
        self.color = color
        self.icon = icon
        self.tasks = []
    }

}
