import SwiftUI

struct RoutineFormSheet: View {
    let title: String
    @Binding var name: String
    @Binding var icon: String
    @Binding var showIconPicker: Bool
    let commonIcons = [
        "list.bullet", "star.fill", "heart.fill", "moon.fill", "sun.max.fill",
        "drop.fill", "flame.fill", "leaf.fill", "bolt.fill", "sparkles",
        "book.fill", "pencil", "paintbrush.fill", "music.note", "camera.fill",
        "gamecontroller.fill", "dumbbell.fill", "figure.walk", "bed.double.fill",
        "cup.and.saucer.fill",
    ]

    let onDismiss: () -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.secondary.brightness(-0.7).saturation(-1))
                    .cornerRadius(12)

                IconPickerButton(
                    icon: icon,
                    onTap: { showIconPicker = true }
                )

                Spacer()
            }
            .padding(12)
            .navigationTitle(title)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(title == "Add Routine" ? "Add" : "Save") {
                        onSave()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerGrid(
                    selectedIcon: $icon,
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
                                ? Color.accentColor.opacity(0.2) : Color(Color.gray)
                        )
                )
        }
    }
}
