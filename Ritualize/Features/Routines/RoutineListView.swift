import SwiftData
import SwiftUI

struct RoutineListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var routines: [RoutineDataItem]
    @Binding var selectedRoutines: Set<RoutineDataItem>

    var body: some View {
        List(selection: $selectedRoutines) {
            ForEach(routines) { item in
                RoutineItem(item: item)
                    .tag(item)
            }
            .onMove { from, to in
                let fromIdx = from.first!
                for (index, routine) in routines.enumerated() {
                    if fromIdx == index {
                        routine.order = to
                    } else if index >= to {
                        routine.order = routine.order + 1
                    }
                }
                try? modelContext.save()
            }
        }
        .overlay {
            if routines.isEmpty {
                ContentUnavailableView {
                    Label("No Routines", systemImage: "checklist")
                } description: {
                    Text("Add routines to get started")
                }
            }
        }
    }
}
