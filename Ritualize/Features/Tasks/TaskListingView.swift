import SwiftData
import SwiftUI

struct TaskListingView: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    @State private var showAddTaskModal: Bool = false
    @State private var isEditMode: Bool = false
    @State private var selectedTasks: Set<TaskDataItem> = []
    @State private var showDeleteConfirmation: Bool = false
    @State private var showSeparateByMilestones: Bool = true

    init(routine: RoutineDataItem) {
        self.routine = routine
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
            if !task.isCompleted && task.type != TaskType.milestone.rawValue {
                return false
            }
        }
        return true
    }

    private func createNewTask() -> TaskDataItem {
        let task = TaskDataItem(
            name: "",
            routine: routine,
            order: routine.getNewOrder(),
            type: TaskType.task
        )
        modelContext.insert(task)
        return task
    }

    var body: some View {
        NavigationView {
            List(selection: $selectedTasks) {
                TaskListViewContent(
                    routine: routine, isEditMode: isEditMode,
                    showSeparateByMilestones: showSeparateByMilestones
                )
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
            // #if os(iOS)
            //     .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            // #endif
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if isEditMode == true {
                        if !selectedTasks.isEmpty {
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                Label("Delete", systemImage: "trash")
                                    .foregroundStyle(.red)
                            }
                        }

                        Button(action: {
                            isEditMode.toggle()
                        }) {
                            Text(isEditMode ? "Done" : "Edit tasks")
                        }
                    } else {
                        Button(action: {
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
                                Label(
                                    "Uncheck all tasks", systemImage: "checkmark.circle.badge.xmark"
                                )
                            }
                            Button(action: {
                                showSeparateByMilestones.toggle()
                            }) {
                                Label(
                                    showSeparateByMilestones
                                        ? "Show all tasks" : "Separate by milestones",
                                    systemImage: showSeparateByMilestones
                                        ? "list.bullet" : "list.bullet.indent"
                                )
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    if isAllTasksCompleted() {
                        Button(action: {
                            handleUncheckAllTasks()
                        }) {
                            Label("Uncheck all", systemImage: "x")
                        }
                        .disabled(routine.sortedTasks.isEmpty || isEditMode)
                        .tint(Color.muted)
                    } else {
                        NavigationLink(destination: StartListingView(routine: routine)) {
                            Label("Start", systemImage: "play")
                        }
                        .disabled(routine.sortedTasks.isEmpty || isEditMode)
                        .tint(getColor(color: routine.color))
                    }
                }
            }
        }
        .alert("Delete Tasks", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                showDeleteConfirmation = false
            }
            Button("Delete", role: .destructive) {
                deleteSelectedTasks()
                showDeleteConfirmation = false
            }
        } message: {
            Text(
                "Are you sure you want to delete \(selectedTasks.count) task\(selectedTasks.count == 1 ? "" : "s")? This action cannot be undone."
            )
        }
        .sheet(isPresented: $showAddTaskModal) {
            TaskFormSheet(
                task: createNewTask(),
                title: "Add Task"
            )
        }
    }

    private func deleteSelectedTasks() {
        for task in selectedTasks {
            modelContext.delete(task)
        }
        selectedTasks.removeAll()
        try? modelContext.save()
    }
}

struct TaskListViewContent: View {
    let routine: RoutineDataItem
    let isEditMode: Bool
    let showSeparateByMilestones: Bool
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if !isEditMode && showSeparateByMilestones {
                ForEach(Array(routine.tasksWithMilestones.enumerated()), id: \.offset) {
                    index, item in
                    Section(header: Text(item.name)) {
                        ForEach(item.tasks) { task in
                            TaskItem(task: task)
                                .tag(task)
                        }
                    }
                }
            } else {
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
        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return TaskListingView(
            routine: previewer.routine
        ).modelContainer(previewer.container)
    } catch {
        fatalError("Failed to create previewer: \(error.localizedDescription)")
    }
}
