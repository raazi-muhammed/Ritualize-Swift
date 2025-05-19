//
//  ContentView.swift
//  Ritualize
//
//  Created by Raazi Muhammed on 19/05/25.
//

import SwiftUI
import SwiftData

struct TaskItem: View {
    let name: String
    let min: Int

    var body: some View {
        HStack {
            Image(systemName: "circle")
            VStack {
                HStack {
                    Text(name)
                    Spacer()
                }
                HStack {
                    Text("\(min) min").font(.caption)
                    Spacer()
                }
            }
        }.swipeActions {
            Button(action: {
                print("Delete")
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
            Button(action: {
                print("Edit")
            }) {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
    }
}

struct RoutineDetails: View {
    let name: String

    var body: some View {
        NavigationStack {
            List {
                TaskItem(name: "Drink water", min: 2)
                TaskItem(name: "Check weight", min: 1)
                TaskItem(name: "Check weight", min: 5)
            }.navigationTitle(name)
        }
    }
}

struct RoutineItem: View {
    let name: String
    var body: some View {
        HStack {
            Image(systemName: "list.bullet")
            VStack {
                HStack {
                    Text(name)
                    Spacer()
                }
                HStack {
                    Text("sop").font(.caption)
                    Spacer()
                }
            }
            Spacer()
            NavigationLink(
                destination: RoutineDetails(name: name)
            ) {
                Spacer()
            }
        }.swipeActions {
            Button(action: {
                print("Delete")
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
            Button(action: {
                print("Edit")
            }) {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationStack {
            
            List {
                ForEach(items) { item in
                    RoutineItem(name: item.name)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Routines")
            .toolbar {
                Button("Add Item") {
                    addItem()
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(name: "Test")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
