//
//  ContentView.swift
//  Ritualize
//
//  Created by Raazi Muhammed on 19/05/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View = RoutineListView()
}

#Preview {
    ContentView()
        .modelContainer(for: RoutineDataItem.self)
}
