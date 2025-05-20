
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
                            isActive: currentIndex == index)
                    }
                }
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
                        if currentIndex < routine.tasks.count {
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
                                self.routine.tasks[self.currentIndex].isCompleted = true
                                self.currentIndex += 1
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                        } else {
                            Button(action: {
                                // go back to routine details
                                dismiss()
                                print("done")
                            }) {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor)
                                    .cornerRadius(25)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}
