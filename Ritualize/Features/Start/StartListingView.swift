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
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    List {
                        ForEach(Array(routine.sortedTasks.enumerated()), id: \.element.id) {
                            index, item in
                            StartTaskItem(
                                task: item,
                                isActive: currentIndex == index
                            )
                            .tag(item)
                            .id(item.id)
                            .onTapGesture {
                                currentIndex = index
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .blur(radius: getBlurRadius(index: index))
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
                    .toolbar(.hidden)
                }
                VStack {
                    Spacer()
                    HStack {
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
                        .clipShape(Capsule())
                        .controlSize(.large)
                        .disabled(currentIndex >= routine.sortedTasks.count)

                        Spacer()

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
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
