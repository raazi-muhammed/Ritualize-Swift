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
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .accentColor : .primary)
                .padding(.trailing, 8)
                .onTapGesture {
                    task.isCompleted.toggle()
                }
            VStack {
                HStack {
                    Text(task.name)
                    Spacer()
                }
                HStack {
                    Text("\(task.order)  min").font(.caption)
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
            .tint(Color.accentColor)
        }
    }
}

struct StartTaskItem: View {
    let task: TaskDataItem
    let isActive: Bool

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .accentColor : .primary)
                .padding(.trailing, 8)
                .onTapGesture {
                task.isCompleted.toggle()
            }
            VStack {
                HStack {
                    Text(task.name).foregroundColor(isActive ? Color.accentColor : Color.primary)
                    Spacer()
                }
            }
        }
    }
}

struct RoutineStartDetails: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var currentIndex: Int = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(Array(routine.sortedTasks.enumerated()), id: \.element.id) {
                        index, item in
                        StartTaskItem(
                            task: item,
                            isActive: currentIndex == index)
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            self.currentIndex -= 1
                        }) {
                            Text("Prev")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.accentColor)
                                .cornerRadius(25)
                        }
                        if currentIndex < routine.tasks.count {
                            Button(action: {
                                self.currentIndex += 1
                            }) {
                                Text("Skip")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.secondary)
                                    .cornerRadius(25)
                            }
                            Button(action: {
                                self.routine.tasks[self.currentIndex].isCompleted = true
                                self.currentIndex += 1
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                        } else {
                            Button(action: {
                                // go back to routine details
                                dismiss()
                                print("done")
                            }) {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                        }
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
                .navigationTitle(routine.name)
                .environment(\.editMode, .constant(.inactive))
                VStack {
                    Spacer()
                    NavigationLink(destination: RoutineStartDetails(routine: routine)) {
                        Text("Start")
                            .font(.headline)
                            .foregroundColor(.white)
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
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
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
            NavigationStack {
                VStack(alignment: .leading) {
                    TextField("Name", text: $routineInput)
                        .padding()
                        .background(Color.secondary.brightness(-0.7).saturation(-1))
                        .cornerRadius(12)
                    Spacer()
                }.padding(12)
                    .navigationTitle("Add Routine")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                                addItem(name: routineInput)
                                showAddRoutineModal.toggle()
                                self.routineInput = ""
                            }
                        }
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
