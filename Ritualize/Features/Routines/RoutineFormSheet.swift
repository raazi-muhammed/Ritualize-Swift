import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Binding var selectedColor: String

    let icons = [
        "sparkles", "star.fill", "heart.fill", "moon.fill", "sun.max.fill",
        "drop.fill", "flame.fill", "leaf.fill", "bolt.fill",
        "book.fill", "paintbrush.fill", "music.note", "camera.fill",
        "gamecontroller.fill", "dumbbell.fill", "figure.walk", "bed.double.fill",
        "cup.and.saucer.fill",

    ]

    let columns = [GridItem(.adaptive(minimum: 45))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(icons, id: \.self) { icon in
                Button(action: {
                    selectedIcon = icon
                }) {
                    Image(systemName: icon)
                        .foregroundStyle(Color.primary)
                        .frame(width: 45, height: 45)
                        .background(
                            Circle()
                                .fill(Color.muted)
                                .stroke(
                                    selectedIcon == icon
                                        ? Color.secondary : Color.muted,
                                    lineWidth: 2
                                )
                                .overlay(
                                    Circle()
                                        .fill(
                                            selectedIcon == icon
                                                ? getColor(color: selectedColor)
                                                : Color.secondary.opacity(0.2)
                                        )
                                        .padding(4)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: String

    let colors = [
        DatabaseColor.purple.rawValue,
        DatabaseColor.green.rawValue,
        DatabaseColor.red.rawValue,
        DatabaseColor.blue.rawValue,
        DatabaseColor.yellow.rawValue,
        DatabaseColor.orange.rawValue,
    ]

    let columns = [GridItem(.adaptive(minimum: 45))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(colors, id: \.self) { color in
                Button(action: {
                    selectedColor = color
                }) {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(Color.clear)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.muted)
                                .stroke(
                                    color == selectedColor
                                        ? Color.secondary : Color.muted,
                                    lineWidth: 2
                                )
                                .overlay(
                                    Circle()
                                        .fill(getColor(color: color))
                                        .padding(4)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct RoutineFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var routine: RoutineDataItem
    let title: String
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("Name", text: $routine.name)
                            .focused($isNameFocused)
                    }
                    Section {
                        IconPickerView(
                            selectedIcon: $routine.icon,
                            selectedColor: $routine.color,
                        )
                    }
                    Section {
                        ColorPickerView(
                            selectedColor: $routine.color,
                        )
                    }
                }
            }
            .navigationTitle(title)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                isNameFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        "Cancel",
                        action: {
                            if title == "Add Routine" {
                                modelContext.delete(routine)
                            }
                            dismiss()
                        })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(title == "Add Routine" ? "Add" : "Save") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(routine.name.isEmpty)
                }
            }
        }
    }
}
