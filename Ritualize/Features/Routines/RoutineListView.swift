import SwiftData
import SwiftUI

struct RoutineListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routines: [RoutineDataItem]
    @State private var showAddRoutineModal: Bool = false
    @State private var routineInput: String = ""
    @State private var selectedIcon: String = "list.bullet"
    @State private var showIconPicker: Bool = false
    @State private var selectedRoutine: RoutineDataItem?

    var body: some View {
        NavigationSplitView {
            List(routines, selection: $selectedRoutine) { item in
                RoutineItem(item: item).onTapGesture {
                    selectedRoutine = item
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
            .navigationTitle("Routines")
            .toolbar {
                Button(action: {
                    self.showAddRoutineModal.toggle()
                }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
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
                    modelContext.insert(newItem)
                    showAddRoutineModal = false
                    routineInput = ""
                    selectedIcon = "list.bullet"
                }
            )
        }
    }
}
