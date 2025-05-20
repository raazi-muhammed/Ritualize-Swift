//
//  Item.swift
//  Ritualize
//
//  Created by Raazi Muhammed on 19/05/25.
//

import Foundation
import SwiftData

@Model
final class RoutineDataItem {
    var name: String
    var id: String = UUID().uuidString
    @Relationship(deleteRule: .cascade) var tasks: [TaskDataItem] = []

    var sortedTasks: [TaskDataItem] {
        tasks.sorted { $0.order < $1.order }
    }

    init(name: String) {
        self.name = name
        self.id = UUID().uuidString
        self.tasks = []
    }
}

@Model
final class TaskDataItem {
    var id: String = UUID().uuidString
    var name: String
    var isCompleted: Bool = false
    var order: Int = 0

    @Relationship(inverse: \RoutineDataItem.tasks) var routine: RoutineDataItem?

    init(name: String, routine: RoutineDataItem? = nil, order: Int) {
        self.id = UUID().uuidString
        self.name = name
        self.routine = routine
        self.order = order
    }
}
