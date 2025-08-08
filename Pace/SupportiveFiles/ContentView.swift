//
//  ContentView.swift
//  Pace
//
//  Created by Patrick Jakobsen on 08/08/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab.init("Home", systemImage: "house") {
                HomeView()
            }
            
            Tab.init("History", systemImage: "chart.bar") {
                Text("Home")
            }
            
            Tab.init("AI", systemImage: "apple.intelligence") {
                Text("AI")
            }
        }
    }
}

#Preview {
    ContentView()
}
