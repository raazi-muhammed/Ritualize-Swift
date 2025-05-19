//
//  ContentView.swift
//  Ritualize
//
//  Created by Raazi Muhammed on 19/05/25.
//

import SwiftData
import SwiftUI

struct TaskItem: View {
    let task: TaskDataItem
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle" : "circle").onTapGesture {
                task.isCompleted.toggle()
            }
            VStack {
                HStack {
                    Text(task.name)
                    Spacer()
                }
                HStack {
                    Text("\(task.id)  min").font(.caption)
                    Spacer()
                }
            }
        }.swipeActions {
            Button(action: {
                modelContext.delete(task)
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
        }.swipeActions(edge: .leading) {
            Button(action: {
                task.isCompleted.toggle()
            }) {
                Image(systemName: "checkmark")
            }
            .tint(.blue)
        }
    }
}

struct RoutineStartDetails: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(routine.tasks) { item in
                        TaskItem(task: item)
                    }
                }.navigationTitle(routine.name)

                VStack {
                    Spacer()
                    Button(action: {
                        // Start routine action
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct RoutineDetails: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    @State private var showAddTaskModal: Bool = false
    @State private var taskInput: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(routine.tasks) { item in
                        TaskItem(task: item)
                    }
                }.navigationTitle(routine.name)

                VStack {
                    Spacer()
                    Button(action: {
                        // Start routine action
                    }) {
                        Text("Start")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
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
            VStack {
                Text("Add task to \(routine.name)")
                TextField("Name", text: $taskInput).textFieldStyle(.roundedBorder).padding()
                Button("Add") {
                    let newTask = TaskDataItem(name: taskInput, routine: routine)
                    modelContext.insert(newTask)

                    showAddTaskModal.toggle()
                    self.taskInput = ""
                }
            }
        }
    }
}

struct RoutineItem: View {
    let item: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Image(systemName: "list.bullet")
            VStack {
                HStack {
                    Text(item.name)
                    Spacer()
                }
                HStack {
                    Text("sop").font(.caption)
                    Spacer()
                }
            }
            Spacer()
            NavigationLink(
                destination: RoutineDetails(routine: item)
            ) {
                Spacer()
            }
        }.swipeActions {
            Button(action: {
                modelContext.delete(item)
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [RoutineDataItem]
    @State private var showAddRoutineModal: Bool = false
    @State private var routineInput: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    RoutineItem(item: item)
                }
            }
            .navigationTitle("Routines")
            .toolbar {
                Button("Add Item") {
                    self.showAddRoutineModal.toggle()
                }
            }
        }.sheet(isPresented: $showAddRoutineModal) {
            VStack {
                TextField("Name", text: $routineInput).textFieldStyle(.roundedBorder).padding()
                Button("Add") {
                    addItem(name: routineInput)
                    showAddRoutineModal.toggle()
                    self.routineInput = ""
                }
            }
        }
    }

    private func addItem(name: String) {
        withAnimation {
            let newItem = RoutineDataItem(name: name)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: RoutineDataItem.self)
}
