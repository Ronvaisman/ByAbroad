//
//  ContentView.swift
//  ByAbroad
//
//  Created by Ron Vaisman on 22/07/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HomeView()
            .onAppear {
                // Print API configuration status on app startup (development only)
                APIConfiguration.printConfigurationStatus()
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Product.self, inMemory: true)
}
