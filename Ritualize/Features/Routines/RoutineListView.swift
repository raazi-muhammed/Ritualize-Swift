import SwiftData
import SwiftUI

struct RoutineListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routines: [RoutineDataItem]
    @State private var showAddRoutineModal: Bool = false
    @State private var routineInput: String = ""
    @State private var selectedIcon: String = "list.bullet"
    @State private var showIconPicker: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(routines) { item in
                    RoutineItem(item: item)
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
        }.sheet(isPresented: $showAddRoutineModal) {
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
