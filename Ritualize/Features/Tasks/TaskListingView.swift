import SwiftData
import SwiftUI

struct TaskListingView: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    @State private var showAddTaskModal: Bool = false
    @State private var taskInput: String = ""
    @State private var taskDuration: String = DefaultValues.duration
    @State private var isEditMode: Bool = false
    @State private var selectedTaskType: TaskType = TaskType.task

    init(routine: RoutineDataItem) {
        self.routine = routine
        self.taskDuration = routine.nextOrder
    }

    func handleUncheckAllTasks() {
        for task: TaskDataItem in routine.sortedTasks {
            task.isCompleted = false
        }
        try? modelContext.save()
    }

    func isAllTasksCompleted() -> Bool {
        if routine.sortedTasks.isEmpty {
            return false
        }

        for task in routine.sortedTasks {
            if !task.isCompleted {
                return false
            }
        }
        return true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(routine.sortedTasks) { item in
                    TaskItem(task: item)
                        .tag(item)
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
                    try? modelContext.save()
                }
            }
            .contentMargins(.bottom, 100)
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
            #if os(iOS)
                .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            #endif
            HStack {
                Spacer()

                if isAllTasksCompleted() {
                    Button(action: {
                        handleUncheckAllTasks()
                    }) {
                        Label("Uncheck all", systemImage: "checkmark.circle.badge.xmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .clipShape(Capsule())
                    .disabled(routine.sortedTasks.isEmpty || isEditMode)
                    .tint(Color.muted)
                } else {
                    NavigationLink(destination: StartListingView(routine: routine)) {
                        Label("Start", systemImage: "play.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .clipShape(Capsule())
                    .disabled(routine.sortedTasks.isEmpty || isEditMode)
                    .tint(getColor(color: routine.color))
                }
            }
            .padding(.horizontal, 34)
        }
        .toolbar {
            if isEditMode == true {
                Button(action: {
                    isEditMode.toggle()
                }) {
                    Text(isEditMode ? "Done" : "Edit tasks")
                }
            } else {
                Button(action: {
                    taskDuration = routine.nextOrder
                    self.showAddTaskModal.toggle()
                }) {
                    Image(systemName: "plus")
                }
                Menu {
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Label(
                            isEditMode ? "Done" : "Edit tasks",
                            systemImage: isEditMode ? "checkmark.circle" : "pencil")
                    }
                    Button(action: {
                        handleUncheckAllTasks()
                    }) {
                        Label("Uncheck all tasks", systemImage: "checkmark.circle.badge.xmark")
                    }

                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .sheet(isPresented: $showAddTaskModal) {
            TaskFormSheet(
                title: "Add Task",
                name: $taskInput,
                duration: $taskDuration,
                selectedTaskType: $selectedTaskType,
                onDismiss: {
                    showAddTaskModal = false
                    taskInput = ""
                    taskDuration = routine.nextOrder
                },
                onSave: {
                    let newTask = TaskDataItem(
                        name: taskInput,
                        routine: routine,
                        order: Int(taskDuration) ?? 0,
                        type: selectedTaskType
                    )
                    modelContext.insert(newTask)
                    try? modelContext.save()

                    showAddTaskModal = false
                    taskInput = ""
                    taskDuration = routine.nextOrder
                }
            )
        }
    }
}
