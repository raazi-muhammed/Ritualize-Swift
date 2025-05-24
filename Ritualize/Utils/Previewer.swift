//
//  Previewer.swift
//  Ritualize
//
//  Created by Raazi Muhammed on 24/05/25.
//

import Foundation
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    let routine: RoutineDataItem
    let task: TaskDataItem

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: RoutineDataItem.self, configurations: config)

        self.routine = RoutineDataItem(
            name: "Routine 1", color: DatabaseColor.red.rawValue, icon: "checklist")
        self.task = TaskDataItem(name: "Task 1", routine: routine, order: 0)

        container.mainContext.insert(routine)
        container.mainContext.insert(task)
        container.mainContext.insert(TaskDataItem(name: "Task 2", routine: routine, order: 1))
        container.mainContext.insert(TaskDataItem(name: "Task 3", routine: routine, order: 2))
        container.mainContext.insert(
            TaskDataItem(name: "Milestone 3", routine: routine, order: 3, type: TaskType.milestone))
        container.mainContext.insert(TaskDataItem(name: "Task 4", routine: routine, order: 4))
        container.mainContext.insert(TaskDataItem(name: "Task 5", routine: routine, order: 5))
    }

}
