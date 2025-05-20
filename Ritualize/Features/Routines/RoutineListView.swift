import SwiftData
import SwiftUI

struct RoutineListView: View {
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
