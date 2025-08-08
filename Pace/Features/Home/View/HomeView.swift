//
//  HomeView.swift
//  Pace
//
//  Created by Patrick Jakobsen on 08/08/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Placeholder content — will be replaced with live stats later
                Text("Today")
                    .font(.largeTitle.weight(.bold))
                Text("0 steps")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .contentTransition(.numericText(value: 0))
                    .monospacedDigit()
                    .animation(.easeInOut(duration: 0.4), value: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(colors: [.blue.opacity(0.12), .purple.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("Steps")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    HomeView()
}
