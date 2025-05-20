import SwiftData
import SwiftUI

struct TaskItem: View {
    let task: TaskDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    @State private var editedName = ""
    @State private var editedDuration = ""

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
                do {
                    modelContext.delete(task)
                    try modelContext.save()
                } catch {
                    print("Error deleting task: \(error)")
                }
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
            Button(action: {
                editedName = task.name
                editedDuration = "\(task.order)"
                showEditSheet = true
            }) {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }.swipeActions(edge: .leading) {
            Button(action: {
                task.isCompleted.toggle()
                try? modelContext.save()
            }) {
                Image(systemName: "checkmark")
            }
            .tint(Color.accentColor)
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Task Name", text: $editedName)
                        .padding()
                        .background(Color.secondary.brightness(-0.7).saturation(-1))
                        .cornerRadius(12)

                    TextField("Duration (minutes)", text: $editedDuration)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                        .padding()
                        .background(Color.secondary.brightness(-0.7).saturation(-1))
                        .cornerRadius(12)

                    Spacer()
                }.padding(12)
                    .navigationTitle("Edit Task")
                    #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showEditSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                task.name = editedName
                                if let duration = Int(editedDuration) {
                                    task.order = duration
                                }
                                try? modelContext.save()
                                showEditSheet = false
                            }
                        }
                    }
            }
        }
    }
}
