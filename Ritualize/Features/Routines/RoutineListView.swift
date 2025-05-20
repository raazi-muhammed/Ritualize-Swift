import SwiftData
import SwiftUI

struct RoutineListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routines: [RoutineDataItem]
    @State private var showAddRoutineModal: Bool = false
    @State private var routineInput: String = ""

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
            NavigationStack {
                VStack(alignment: .leading) {
                    TextField("Name", text: $routineInput)
                        .padding()
                        .background(Color.secondary.brightness(-0.7).saturation(-1))
                        .cornerRadius(12)
                    Spacer()
                }.padding(12)
                    .navigationTitle("Add Routine")
                    #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button("Add") {
                                let newItem = RoutineDataItem(name: routineInput)
                                modelContext.insert(newItem)
                                showAddRoutineModal.toggle()
                                self.routineInput = ""
                            }
                        }
                    }
            }
        }
    }
}
