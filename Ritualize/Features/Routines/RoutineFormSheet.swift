import SwiftUI

extension Color {
    static let muted = Color(red: 45 / 255, green: 45 / 255, blue: 46 / 255)
}

struct RoutineFormSheet: View {
    let title: String
    @Binding var name: String
    @Binding var icon: String
    @Binding var showIconPicker: Bool
    @Binding var color: String
    @FocusState private var isNameFocused: Bool

    let commonIcons = [
        "sparkles", "star.fill", "heart.fill", "moon.fill", "sun.max.fill",
        "drop.fill", "flame.fill", "leaf.fill", "bolt.fill",
        "book.fill", "paintbrush.fill", "music.note", "camera.fill",
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

                IconPickerGrid(
                    selectedIcon: $icon,
                    icons: commonIcons,
                    onDismiss: { showIconPicker = false },
                    color: color
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
        }
    }
}

private struct IconPickerGrid: View {
    @Binding var selectedIcon: String
    let icons: [String]
    let onDismiss: () -> Void
    let color: String

    var body: some View {
        VStack {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 45))
                ], spacing: 20,
            ) {
                ForEach(icons, id: \.self) { icon in
                    IconGridItem(
                        color: color,
                        icon: icon,
                        isSelected: selectedIcon == icon,
                        onSelect: {
                            selectedIcon = icon
                            onDismiss()
                        }
                    )
                }
            }.padding(12)
        }
        .background(Color.secondary.brightness(-0.7).saturation(-1))
        .cornerRadius(12)
    }
}

private struct IconGridItem: View {
    let color: String
    let icon: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Image(systemName: icon)
                .foregroundStyle(Color.primary)
                .frame(width: 45, height: 45)
                .background(
                    Circle()
                        .fill(Color.muted)
                        .stroke(
                            isSelected
                                ? Color.secondary : Color.muted,
                            lineWidth: 2
                        )
                        .overlay(
                            Circle()
                                .fill(
                                    isSelected
                                        ? getColor(color: color) : Color.secondary.opacity(0.2)
                                )
                                .padding(4)
                        )
                )
        }
    }
}

private struct ColorPicker: View {
    @Binding var color: String

    let colors = [
        DatabaseColor.green.rawValue,
        DatabaseColor.red.rawValue,
        DatabaseColor.blue.rawValue,
        DatabaseColor.yellow.rawValue,
        DatabaseColor.purple.rawValue,
        DatabaseColor.orange.rawValue,
    ]
    var body: some View {
        VStack {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 45))
                ], spacing: 20,
            ) {
                ForEach(colors, id: \.self) { icon in
                    ColorPickerButton(
                        color: $color,
                        colorName: icon
                    )
                }
            }.padding(12)
        }
        .background(Color.secondary.brightness(-0.7).saturation(-1))
        .cornerRadius(12)
    }
}

private struct ColorPickerButton: View {
    @Binding var color: String
    let colorName: String

    var body: some View {
        Button(action: { color = colorName }) {
            Image(systemName: "circle.fill")
                .foregroundStyle(Color.clear)
                .frame(width: 45, height: 45)
                .background(
                    Circle()
                        .fill(Color.muted)
                        .stroke(
                            color == colorName
                                ? Color.secondary : Color.muted,
                            lineWidth: 2
                        )
                        .overlay(
                            Circle()
                                .fill(getColor(color: colorName))
                                .padding(4)
                        )
                )
        }
        .foregroundStyle(getColor(color: colorName))
    }
}
