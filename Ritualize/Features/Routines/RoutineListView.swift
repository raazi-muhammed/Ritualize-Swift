import SwiftData
import SwiftUI

struct RoutineListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RoutineDataItem.order) private var routines: [RoutineDataItem]
    @State private var showAddRoutineModal: Bool = false
    @State private var routineInput: String = ""
    @State private var selectedIcon: String = "list.bullet"
    @State private var showIconPicker: Bool = false
    @State private var selectedRoutine: RoutineDataItem?
    @State private var isEditMode: Bool = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(routines) { item in
                    RoutineItem(item: item)
                }
                .onMove { from, to in
                    let fromIdx = from.first!
                    for (index, routine) in routines.enumerated() {
                        if fromIdx == index {
                            routine.order = to
                        } else if index >= to {
                            routine.order = routine.order + 1
                        }
                    }
                }
            }
            .overlay {
                if routines.isEmpty {
                    ContentUnavailableView {
                        Label("No Routines", systemImage: "checklist")
                    } description: {
                        Text("Add routines to get started")
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                Button(action: {
                    self.showAddRoutineModal.toggle()
                }) {
                    Label("Add Routine", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.bold)
                }
                .buttonStyle(.plain)
                .padding()
            }
            .navigationTitle("Routines")
            .toolbar {
                Button(action: {
                    isEditMode.toggle()
                }) {
                    Text(isEditMode ? "Done" : "Edit")
                }
            }
            #if os(iOS)
                .environment(\.editMode, Binding.constant(isEditMode ? .active : .inactive))
            #endif
        } detail: {
            if let selectedRoutine = selectedRoutine {
                TaskListingView(routine: selectedRoutine)
            } else {
                ContentUnavailableView("Select a Routine", systemImage: "list.bullet")
            }
        }
        .sheet(isPresented: $showAddRoutineModal) {
            RoutineFormSheet(
                title: "Add Routine",
                name: $routineInput,
                icon: $selectedIcon,
                showIconPicker: $showIconPicker,
                onDismiss: {
                    showAddRoutineModal = false
                    routineInput = ""
                    selectedIcon = "list.bullet"
                },
                onSave: {
                    let newItem = RoutineDataItem(name: routineInput)
                    newItem.icon = selectedIcon
                    newItem.order = routines.count
                    modelContext.insert(newItem)
                    showAddRoutineModal = false
                    routineInput = ""
                    selectedIcon = "list.bullet"
                }
            )
        }
    }
}
