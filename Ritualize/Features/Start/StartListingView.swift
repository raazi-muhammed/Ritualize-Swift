import SwiftData
import SwiftUI

struct StartListingView: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var currentIndex: Int = 0
    @Environment(\.dismiss) private var dismiss

    func getNextUnCompletedTask(startFrom: Int = 0) -> Int {
        var index = startFrom
        for task in routine.sortedTasks[startFrom...] {
            if !task.isCompleted {
                return index
            }
            index += 1
        }
        return -1
    }

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(Array(routine.sortedTasks.enumerated()), id: \.element.id) {
                        index, item in
                        StartTaskItem(
                            task: item,
                            isActive: currentIndex == index
                        )
                        .id("\(item.id)-\(index)")
                        .onTapGesture {
                            currentIndex = index
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
                .contentMargins(.bottom, 100)
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            self.currentIndex = getNextUnCompletedTask(startFrom: currentIndex + 1)
                        }) {
                            Label("Skip", systemImage: "forward.fill").foregroundStyle(
                                Color.primary)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.muted)
                        .clipShape(Capsule())
                        .controlSize(.large)
                        .disabled(currentIndex >= routine.sortedTasks.count)

                        Spacer()

                        Button(action: {
                            self.routine.sortedTasks[self.currentIndex].isCompleted = true
                            try? modelContext.save()
                            self.currentIndex = getNextUnCompletedTask(startFrom: currentIndex)
                        }) {
                            Label("Done", systemImage: "checkmark")
                        }.buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .clipShape(Capsule())
                            .disabled(currentIndex >= routine.sortedTasks.count)
                            .tint(getColor(color: routine.color))
                    }
                    .padding(.horizontal, 34)
                    .padding(.bottom, 0)
                }
            }
            .onChange(of: currentIndex) { _, newValue in
                if newValue == -1 {
                    dismiss()
                }
                if newValue >= routine.sortedTasks.count {
                    dismiss()
                }
            }
            .onAppear {
                currentIndex = getNextUnCompletedTask(startFrom: currentIndex)
            }
        }
    }
}
