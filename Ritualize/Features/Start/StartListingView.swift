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
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .listStyle(PlainListStyle())
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            self.currentIndex += 1
                        }) {
                            HStack {
                                Image(systemName: "forward.fill")
                                Text("Skip")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.secondary)
                            .cornerRadius(25)
                        }
                        Spacer()
                        Button(action: {
                            self.routine.sortedTasks[self.currentIndex].isCompleted = true
                            try? modelContext.save()
                            self.currentIndex += 1

                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Done")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .cornerRadius(25)
                        }
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
