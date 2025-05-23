import SwiftData
import SwiftUI

struct StartListingView: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var currentIndex: Int = 0
    @Environment(\.dismiss) private var dismiss

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
                            self.currentIndex += 1
                        }) {
                            Label("Skip", systemImage: "forward.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.secondary)
                        .clipShape(Capsule())
                        .disabled(currentIndex >= routine.sortedTasks.count)
                        Spacer()
                        Button(action: {
                            self.routine.sortedTasks[self.currentIndex].isCompleted = true
                            try? modelContext.save()
                            self.currentIndex += 1
                        }) {
                            Label("Done", systemImage: "checkmark")
                        }.buttonStyle(.borderedProminent)
                            .clipShape(Capsule())
                            .disabled(currentIndex >= routine.sortedTasks.count)

                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
            .onChange(of: currentIndex) { _, newValue in
                if newValue >= routine.sortedTasks.count {
                    dismiss()
                }
            }
        }
    }
}
