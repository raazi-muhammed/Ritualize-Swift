import Foundation
import SwiftData

class CSVManager {
    static let shared = CSVManager()

    private init() {}

    // Export routines and their tasks to CSV
    func exportToCSV(routines: [RoutineDataItem]) -> String {
        var csvString = "Routine Name,Routine ID,Task Name,Task ID,Task Order,Task Completed\n"

        for routine in routines {
            for task in routine.sortedTasks {
                let row =
                    "\(routine.name),\(routine.id),\(task.name),\(task.id),\(task.order),\(task.isCompleted)\n"
                csvString.append(row)
            }
        }

        return csvString
    }

    // Import routines and tasks from CSV
    func importFromCSV(csvString: String, modelContext: ModelContext) throws {
        let rows = csvString.components(separatedBy: .newlines)
        guard rows.count > 1 else { return }  // Skip if only header row exists

        var currentRoutine: RoutineDataItem?
        var routineMap: [String: RoutineDataItem] = [:]

        // Skip header row
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 6 else { continue }

            let routineName = columns[0]
            let routineId = columns[1]
            let taskName = columns[2]
            let taskId = !columns[3].isEmpty ? columns[3] : UUID().uuidString
            let taskOrder = Int(columns[4]) ?? 0
            let taskCompleted = columns[5].lowercased() == "true"

            // Get or create routine
            if let existingRoutine = routineMap[routineId] {
                currentRoutine = existingRoutine
            } else {
                let newRoutine = RoutineDataItem(
                    name: routineName, color: DefaultValues.color)
                newRoutine.id = routineId
                routineMap[routineId] = newRoutine
                currentRoutine = newRoutine
                modelContext.insert(newRoutine)
            }

            // Create task
            if let routine = currentRoutine {
                let task = TaskDataItem(name: taskName, routine: routine, order: taskOrder)
                task.id = taskId
                task.isCompleted = taskCompleted
                routine.tasks.append(task)
                modelContext.insert(task)
            }
        }

        try modelContext.save()
    }

    // Save CSV to file
    func saveCSVToFile(csvString: String, fileName: String) throws {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)

        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    // Load CSV from file
    func loadCSVFromFile(fileName: String) throws -> String {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)

        return try String(contentsOf: fileURL, encoding: .utf8)
    }
}
