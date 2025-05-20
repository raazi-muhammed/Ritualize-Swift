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
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .listStyle(PlainListStyle())
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            self.currentIndex -= 1
                        }) {
                            Text("Prev")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.accentColor)
                                .cornerRadius(25)
                        }
                        .disabled(currentIndex <= 0)
                        Button(action: {
                            self.currentIndex += 1
                        }) {
                            Text("Skip")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.secondary)
                                .cornerRadius(25)
                        }
                        Button(action: {
                            self.routine.sortedTasks[self.currentIndex].isCompleted = true
                            try? modelContext.save()
                            self.currentIndex += 1
                            if currentIndex >= routine.sortedTasks.count {
                                dismiss()
                            }
                        }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.accentColor)
                                .cornerRadius(25)
                        }
                        .disabled(currentIndex >= routine.sortedTasks.count)

                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}
