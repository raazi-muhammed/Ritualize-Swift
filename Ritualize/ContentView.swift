import SwiftData
//
//  ContentView.swift
//  Ritualize
//
//  Created by Raazi Muhammed on 19/05/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View = RoutineHomeView()
}

#Preview {
    do {
        let previewer = try Previewer()
        return ContentView().modelContainer(previewer.container)
    } catch {
        fatalError("Failed to create previewer: \(error.localizedDescription)")
    }
}
