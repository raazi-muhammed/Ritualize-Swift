import SwiftData
import SwiftUI

struct RoutineItem: View {
    let item: RoutineDataItem
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Image(systemName: "list.bullet")
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, 8)
            VStack {
                HStack {
                    Text(item.name)
                    Spacer()
                }
                HStack {
                    Text("sop").font(.caption)
                    Spacer()
                }
            }
            Spacer()
            NavigationLink(
                destination: TaskListingView(routine: item)
            ) {
                Spacer()
            }
        }.swipeActions {
            Button(action: {
                modelContext.delete(item)
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
    }
}
