import SwiftData
import SwiftUI

struct RoutineItem: View {
    let item: RoutineDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    @State private var editedName = ""
    @State private var editedIcon = ""
    @State private var showIconPicker = false

    let commonIcons = [
        "list.bullet", "star.fill", "heart.fill", "moon.fill", "sun.max.fill",
        "drop.fill", "flame.fill", "leaf.fill", "bolt.fill", "sparkles",
        "book.fill", "pencil", "paintbrush.fill", "music.note", "camera.fill",
        "gamecontroller.fill", "dumbbell.fill", "figure.walk", "bed.double.fill",
        "cup.and.saucer.fill",
    ]

    var body: some View {
        RoutineItemContent(
            item: item,
            onDelete: { modelContext.delete(item) },
            onEdit: {
                editedName = item.name
                editedIcon = item.icon
                showEditSheet = true
            }
        )
        .sheet(isPresented: $showEditSheet) {
            EditRoutineSheet(
                item: item,
                editedName: $editedName,
                editedIcon: $editedIcon,
                showIconPicker: $showIconPicker,
                commonIcons: commonIcons,
                onDismiss: { showEditSheet = false }
            )
        }
    }
}

private struct RoutineItemContent: View {
    let item: RoutineDataItem
    let onDelete: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: item.icon)
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
        }
        .swipeActions {
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
            .tint(.red)

            Button(action: onEdit) {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
    }
}

private struct EditRoutineSheet: View {
    let item: RoutineDataItem
    @Binding var editedName: String
    @Binding var editedIcon: String
    @Binding var showIconPicker: Bool
    let commonIcons: [String]
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Name", text: $editedName)
                    .padding()
                    .background(Color.secondary.brightness(-0.7).saturation(-1))
                    .cornerRadius(12)

                IconPickerButton(
                    icon: editedIcon,
                    onTap: { showIconPicker = true }
                )

                Spacer()
            }
            .padding(12)
            .navigationTitle("Edit Routine")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        item.name = editedName
                        item.icon = editedIcon
                        onDismiss()
                    }
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerGrid(
                    selectedIcon: $editedIcon,
                    icons: commonIcons,
                    onDismiss: { showIconPicker = false }
                )
            }
        }
    }
}

private struct IconPickerButton: View {
    let icon: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.accentColor)
                Text("Select Icon")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.secondary.brightness(-0.7).saturation(-1))
            .cornerRadius(12)
        }
    }
}

private struct IconPickerGrid: View {
    @Binding var selectedIcon: String
    let icons: [String]
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 60))
                    ], spacing: 20
                ) {
                    ForEach(icons, id: \.self) { icon in
                        IconGridItem(
                            icon: icon,
                            isSelected: selectedIcon == icon,
                            onSelect: {
                                selectedIcon = icon
                                onDismiss()
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Select Icon")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
        }
    }
}

private struct IconGridItem: View {
    let icon: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected
                                ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground)
                        )
                )
        }
    }
}
