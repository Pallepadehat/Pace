//
//  HomeView.swift
//  Pace
//
//  Created by Patrick Jakobsen on 08/08/2025.
//

import SwiftUI
import SwiftData
import Combine

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]
    @State private var isShowingSettings = false
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                GlassCard(
                    accent: settingsList.first?.accentSwiftUIColor ?? .blue,
                    progress: viewModel.progressFraction(goal: currentGoal),
                    isLoading: viewModel.isLoading
                ) {
                    VStack(spacing: 8) {
                        Text(viewModel.selectedDayFormatted)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text(viewModel.stepsToday.formatted())
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText(value: Double(viewModel.stepsToday)))
                            .animation(.easeInOut(duration: 0.3), value: viewModel.stepsToday)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        Text("steps")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text(viewModel.distanceString(unit: settingsList.first?.distanceUnit ?? .metric))
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    }
                } refresh: {
                    await viewModel.refresh()
                }

                ZStack {
                    HourlyChart(data: viewModel.hourlySteps)
                        .opacity(viewModel.isLoading ? 0.35 : 1)
                    if viewModel.isLoading {
                        ChartSkeleton()
                            .transition(.opacity)
                    }
                }

                ZStack {
                    DayScroller(days: viewModel.last7Days, selected: $viewModel.selectedDate) { date in
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.selectedDate = date
                        }
                        Task { await viewModel.refresh(for: date) }
                    }
                    .opacity(viewModel.isLoading ? 0.35 : 1)
                    if viewModel.isLoading {
                        DayScrollerSkeleton()
                            .transition(.opacity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(gradientBackground)
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
        .task { await viewModel.onAppear() }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }

    private var currentGoal: Int { settingsList.first?.dailyStepGoal ?? 8000 }

    @Environment(\.colorScheme) private var colorScheme
    private var gradientBackground: some View {
        let theme = settingsList.first?.accentTheme ?? .blue
        let colors = theme.gradientColors(for: colorScheme)
        let themeKey = theme.rawValue + (colorScheme == .dark ? "_d" : "_l")
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: themeKey)
    }
}

// moved supporting types to Components and ViewModel files

#Preview {
    HomeView()
}
