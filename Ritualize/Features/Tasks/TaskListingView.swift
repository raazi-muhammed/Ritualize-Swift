import SwiftData
import SwiftUI

struct TaskListingView: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    @State private var showAddTaskModal: Bool = false
    @State private var taskInput: String = ""

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
                        Text("Start")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .toolbar {
            Button("Add task") {
                self.showAddTaskModal.toggle()
            }
        }
        .sheet(isPresented: $showAddTaskModal) {
            NavigationStack {
                VStack(alignment: .leading) {
                    TextField("Name", text: $taskInput)
                        .padding()
                        .background(Color.secondary.brightness(-0.7).saturation(-1))
                        .cornerRadius(12)
                    Spacer()
                }.padding(12)
                    .navigationTitle("Add Task")
                    #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button("Add") {
                                let newTask = TaskDataItem(
                                    name: taskInput, routine: routine, order: routine.tasks.count)
                                modelContext.insert(newTask)
                                showAddTaskModal.toggle()
                                self.taskInput = ""
                            }
                        }
                    }
            }
        }
    }
}
