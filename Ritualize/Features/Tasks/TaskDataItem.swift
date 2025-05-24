import Foundation
import SwiftData

enum TaskType: String {
    case milestone = "milestone"
    case task = "task"
}

@Model
final class TaskDataItem {
    var id: String = UUID().uuidString
    var name: String
    var isCompleted: Bool = false
    var order: Int = 0
    var type: String = TaskType.task.rawValue

    @Relationship(inverse: \RoutineDataItem.tasks) var routine: RoutineDataItem?

    init(name: String, routine: RoutineDataItem? = nil, order: Int, type: TaskType = TaskType.task)
    {
        self.id = UUID().uuidString
        self.name = name
        self.routine = routine
        self.order = order
        self.type = type.rawValue
    }
}
