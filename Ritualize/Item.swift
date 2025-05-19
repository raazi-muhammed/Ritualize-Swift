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
    
    @Relationship(inverse: \RoutineDataItem.tasks) var routine: RoutineDataItem

    init(name: String, routine: RoutineDataItem) {
        self.id = UUID().uuidString
        self.name = name
        self.routine = routine
    }
}
