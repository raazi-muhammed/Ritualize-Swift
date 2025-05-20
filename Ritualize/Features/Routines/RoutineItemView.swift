import SwiftData
import SwiftUI

struct RoutineItem: View {
    let item: RoutineDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    @State private var editedName = ""

    var body: some View {
        HStack {
            Image(systemName: "list.bullet")
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, 8)
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
                destination: TaskListingView(routine: item)
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

            Button(action: {
                editedName = item.name
                showEditSheet = true
            }) {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                VStack(alignment: .leading) {
                    TextField("Name", text: $editedName)
                        .padding()
                        .background(Color.secondary.brightness(-0.7).saturation(-1))
                        .cornerRadius(12)
                    Spacer()
                }.padding(12)
                    .navigationTitle("Edit Routine")
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
                                item.name = editedName
                                showEditSheet = false
                            }
                        }
                    }
            }
        }
    }
}
