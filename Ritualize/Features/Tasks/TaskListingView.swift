import SwiftData
import SwiftUI

struct TaskListingView: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    @State private var showAddTaskModal: Bool = false
    @State private var taskInput: String = ""
    @State private var taskDuration: String = ""
    @State private var isEditMode: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(routine.sortedTasks) { item in
                    TaskItem(task: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if isEditMode {
                                Button(role: .destructive) {
                                    modelContext.delete(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }.id(item.id)
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
            #if os(iOS)
                .environment(\.editMode, .constant(isEditMode ? .active : .inactive))
            #endif

            NavigationLink(destination: StartListingView(routine: routine)) {
                Label("Start", systemImage: "play.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .disabled(routine.sortedTasks.isEmpty || isEditMode)
            .padding(.bottom, 20)
            .padding(.horizontal)
            .background(
                Rectangle()
                    .fill(.background)
                    .shadow(radius: 2)
            )
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
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Label(
                            isEditMode ? "Done" : "Edit tasks",
                            systemImage: isEditMode ? "checkmark.circle" : "pencil")
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
