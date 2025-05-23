import SwiftUI

struct RoutineFormSheet: View {
    let title: String
    @Binding var name: String
    @Binding var icon: String
    @Binding var showIconPicker: Bool
    @Binding var color: String
    @FocusState private var isNameFocused: Bool

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
                    .focused($isNameFocused)
                    .padding()
                    .background(Color.secondary.brightness(-0.7).saturation(-1))
                    .cornerRadius(12)

                IconPickerButton(
                    icon: icon,
                    onTap: { showIconPicker = true }
                )

                ColorPicker(color: $color)

                Spacer()
            }
            .padding(12)
            .navigationTitle(title)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                isNameFocused = true
            }
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
                Text("Select Icon")
                Spacer()
                Image(systemName: "chevron.right")
            }.foregroundStyle(Color.primary)
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
                        GridItem(.adaptive(minimum: 45))
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
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .frame(width: 45, height: 45)
                .background(
                    Circle()
                        .fill(
                            isSelected
                                ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.2)
                        )
                )
        }
    }
}

private struct ColorPicker: View {
    @Binding var color: String

    var body: some View {
        HStack {
            ColorPickerButton(color: $color, colorName: DatabaseColor.green.rawValue)
            ColorPickerButton(color: $color, colorName: DatabaseColor.red.rawValue)
            ColorPickerButton(color: $color, colorName: DatabaseColor.blue.rawValue)
            ColorPickerButton(color: $color, colorName: DatabaseColor.yellow.rawValue)
            ColorPickerButton(color: $color, colorName: DatabaseColor.purple.rawValue)
            ColorPickerButton(color: $color, colorName: DatabaseColor.orange.rawValue)
        }
    }
}

private struct ColorPickerButton: View {
    @Binding var color: String
    let colorName: String

    var body: some View {
        Button(action: { color = colorName }) {
            Image(systemName: "circle.fill")
                .foregroundStyle(getColor(color: colorName))
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(getColor(color: colorName).opacity(0.2))
                )
        }
        .foregroundStyle(getColor(color: colorName))
    }
}
