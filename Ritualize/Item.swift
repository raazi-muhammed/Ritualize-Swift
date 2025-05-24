//
//  Item.swift
//  Ritualize
//
//  Created by Raazi Muhammed on 19/05/25.
//

import Foundation
import SwiftData
import SwiftUI

func getColor(color: String) -> Color {
    switch color {
    case DatabaseColor.blue.rawValue:
        return Color.blue
    case DatabaseColor.red.rawValue:
        return Color.red
    case DatabaseColor.green.rawValue:
        return Color.green
    case DatabaseColor.yellow.rawValue:
        return Color.yellow
    case DatabaseColor.purple.rawValue:
        return Color.purple
    case DatabaseColor.orange.rawValue:
        return Color.orange
    default:
        return Color.accentColor
    }
}

enum DatabaseColor: String {
    case blue = "blue"
    case red = "red"
    case green = "green"
    case yellow = "yellow"
    case purple = "purple"
    case orange = "orange"
    case pink = "pink"
    case brown = "brown"
    case gray = "gray"
    case black = "black"
}

@Model
final class RoutineDataItem {
    var name: String
    var id: String = UUID().uuidString
    var icon: String = DefaultValues.icon
    var order: Int = 0
    var color: String = DatabaseColor.red.rawValue

    @Relationship(deleteRule: .cascade) var tasks: [TaskDataItem] = []

    var sortedTasks: [TaskDataItem] {
        tasks.sorted { $0.order < $1.order }
    }

    var nextOrder: String {
        String(Int(sortedTasks.last?.order ?? 0) + 1)
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
                tasksWithMilestones.append(
                    TaskSection(name: lastMilestoneName, tasks: lastMilestoneTasks))
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
