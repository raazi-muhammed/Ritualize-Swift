import SwiftData
import SwiftUI

struct TaskListingView: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    @State private var showAddTaskModal: Bool = false
    @State private var taskInput: String = ""
    @State private var taskDuration: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(routine.sortedTasks) { item in
                        TaskItem(task: item)
                    }
                    .onMove { from, to in
                        let formIdx = from.first!
                        for (index, task) in routine.sortedTasks.enumerated() {
                            if formIdx == index {
                                task.order = to
                            } else if index >= to {
                                task.order = task.order + 1
                            }
                        }
                    }
                }
                .overlay {
                    if routine.sortedTasks.isEmpty {
                        ContentUnavailableView {
                            Label("No Tasks", systemImage: "checklist")
                        } description: {
                            Text("Add tasks to get started with your routine")
                        }
                    }
                }
                .navigationTitle(routine.name)
                VStack {
                    Spacer()
                    NavigationLink(destination: StartListingView(routine: routine)) {
                        Label("Start", systemImage: "play.circle.fill")
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .buttonBorderShape(.roundedRectangle(radius: 12))
                        .disabled(routine.sortedTasks.isEmpty)
                        .padding(.bottom, 10)
                }
            }
        }
        .toolbar {
            Button(action: {
                self.showAddTaskModal.toggle()
            }) {
                Image(systemName: "plus")
            }
            Menu {
                Button(action: {
                    for task in routine.sortedTasks {
                        task.isCompleted = false
                    }
                }) {
                    Label("Uncheck all tasks", systemImage: "checkmark.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .sheet(isPresented: $showAddTaskModal) {
            TaskFormSheet(
                title: "Add Task",
                name: $taskInput,
                duration: $taskDuration,
                onDismiss: {
                    showAddTaskModal = false
                    taskInput = ""
                    taskDuration = ""
                },
                onSave: {
                    let newTask = TaskDataItem(
                        name: taskInput,
                        routine: routine,
                        order: Int(taskDuration) ?? 0
                    )
                    modelContext.insert(newTask)
                    showAddTaskModal = false
                    taskInput = ""
                    taskDuration = ""
                }
            )
        }
    }
}
