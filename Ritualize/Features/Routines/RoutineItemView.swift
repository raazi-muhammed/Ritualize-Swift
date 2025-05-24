import SwiftData
import SwiftUI

struct RoutineItem: View {
    let item: RoutineDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    @State private var editedName = ""
    @State private var editedIcon = ""
    @State private var showIconPicker = false
    @State private var editedColor = ""

    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundStyle(
                    Color.white
                )
                .frame(width: 20, height: 20)
                .padding(8)
                .background(getColor(color: item.color))
                .clipShape(Circle())
                .padding(.leading, -6)

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
            NavigationLink(
                destination: TaskListingView(routine: item)
            ) {
                Text("\(item.tasks.count)")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }.frame(width: 40)

        }
        .swipeActions {
            Button(action: {
                modelContext.delete(item)
                try? modelContext.save()
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
            Button(action: {
                editedName = item.name
                editedIcon = item.icon
                showEditSheet = true
            }) {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .leading) {
            Button(action: {
                item.isFavorite.toggle()
                try? modelContext.save()
            }) {
                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
            }
            .tint(item.isFavorite ? .gray : .red)
        }
        .sheet(isPresented: $showEditSheet) {
            RoutineFormSheet(
                title: "Edit Routine",
                name: $editedName,
                icon: $editedIcon,
                showIconPicker: $showIconPicker,
                color: $editedColor,
                onDismiss: { showEditSheet = false },
                onSave: {
                    item.name = editedName
                    item.icon = editedIcon
                    item.color = editedColor
                    showEditSheet = false
                }
            )
        }
    }
}
