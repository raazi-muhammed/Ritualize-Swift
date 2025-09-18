import SwiftData
import SwiftUI

struct StartListingView: View {
    let routine: RoutineDataItem
    @Environment(\.modelContext) private var modelContext
    @State private var currentIndex: Int = 0
    @Environment(\.dismiss) private var dismiss

    @State private var currentTime: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func getNextUnCompletedTask(startFrom: Int = 0) -> Int {
        var index = startFrom
        for task in routine.sortedTasks[startFrom...] {
            if !task.isCompleted && task.type != TaskType.milestone.rawValue {
                return index
            }
            index += 1
        }
        return -1
    }

    func getBlurRadius(index: Int) -> CGFloat {
        let BLUR_RADIUS = 0.25
        let NON_BLUR_NEIGHBORS_COUNT = 1

        let diff = abs(currentIndex - index)
        if diff <= NON_BLUR_NEIGHBORS_COUNT {
            return CGFloat(0)
        }
        return CGFloat(BLUR_RADIUS * Double(diff - NON_BLUR_NEIGHBORS_COUNT))
    }

    var body: some View {
        VStack {
            ZStack {
                ScrollViewReader { proxy in
                    List {
                        ForEach(Array(routine.sortedTasks.enumerated()), id: \.element.id) {
                            index, item in
                            StartTaskItem(
                                task: item,
                                isActive: currentIndex == index,
                                currentTime: currentTime
                            )
                            .tag(item)
                            .id(item.id)
                            .onTapGesture {
                                currentIndex = index
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .blur(radius: getBlurRadius(index: index))
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                    .contentMargins(.bottom, 100)
                    .onChange(of: currentIndex) { _, newValue in
                        withAnimation {
                            if newValue >= 0 && newValue < routine.sortedTasks.count {
                                proxy.scrollTo(
                                    "\(routine.sortedTasks[newValue].id)",
                                    anchor: .center
                                )
                            }
                        }
                    }
                }

            }
            .onChange(of: currentIndex) { _, newValue in
                currentTime = 0
                if newValue == -1 {
                    dismiss()
                }
                if newValue >= routine.sortedTasks.count {
                    dismiss()
                }
            }
            .onAppear {
                currentIndex = getNextUnCompletedTask(startFrom: currentIndex)
            }.onReceive(timer) { _ in
                currentTime += 1
            }
        }.toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    self.currentIndex = getNextUnCompletedTask(startFrom: currentIndex + 1)
                }) {
                    Label("Skip", systemImage: "forward.fill").foregroundStyle(
                        Color.primary)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.muted)
                .disabled(currentIndex >= routine.sortedTasks.count)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    self.routine.sortedTasks[self.currentIndex].isCompleted = true
                    try? modelContext.save()
                    self.currentIndex = getNextUnCompletedTask(startFrom: currentIndex)
                }) {
                    Label("Done", systemImage: "checkmark")
                }.buttonStyle(.borderedProminent)
                    .disabled(currentIndex >= routine.sortedTasks.count)
                    .tint(getColor(color: routine.color))
            }

        }
    }
}

#Preview {
    do {
        let previewer = try Previewer()
        return StartListingView(
            routine: previewer.routine
        ).modelContainer(previewer.container)
    } catch {
        fatalError("Failed to create previewer: \(error.localizedDescription)")
    }
}
