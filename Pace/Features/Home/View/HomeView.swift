//
//  HomeView.swift
//  Pace
//
//  Created by Patrick Jakobsen on 08/08/2025.
//

import SwiftUI
import SwiftData
import Charts
import Combine

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsList: [AppSettings]
    @State private var isShowingSettings = false
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                GlassCard(accent: settingsList.first?.accentSwiftUIColor ?? .blue,
                          progress: viewModel.progressFraction(goal: currentGoal)) {
                    VStack(spacing: 8) {
                        Text(viewModel.selectedDayFormatted)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text(viewModel.stepsToday.formatted())
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText(value: Double(viewModel.stepsToday)))
                        Text("steps")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text(viewModel.distanceString(unit: settingsList.first?.distanceUnit ?? .metric))
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                } refresh: {
                    await viewModel.refresh()
                }

                HourlyChart(data: viewModel.hourlySteps)

                DayScroller(days: viewModel.last7Days, selected: $viewModel.selectedDate) { date in
                    Task { await viewModel.refresh(for: date) }
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

// MARK: - ViewModel
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var stepsToday: Int = 0
    @Published var distanceTodayMeters: Double = 0
    @Published var hourlySteps: [HourPoint] = []
    @Published var last7Days: [DayPoint] = []
    @Published var selectedDate: Date = Date()

    private let health = HealthKitManager()

    var selectedDayFormatted: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE\nMMMM d"
        return df.string(from: selectedDate)
    }

    func distanceString(unit: AppSettings.DistanceUnit) -> String {
        switch unit {
        case .metric:
            let km = distanceTodayMeters / 1000
            return String(format: "%.2f km", km)
        case .imperial:
            let miles = distanceTodayMeters / 1609.34
            return String(format: "%.2f mi", miles)
        }
    }

    func progressFraction(goal: Int) -> CGFloat {
        guard goal > 0 else { return 0 }
        return CGFloat(min(1.0, Double(stepsToday) / Double(goal)))
    }

    func onAppear() async {
        if !health.isAuthorized { await health.requestAuthorization() }
        await refresh()
    }

    func refresh(for date: Date? = nil) async {
        if let date { selectedDate = date }
        do {
            async let steps = health.fetchSteps(for: selectedDate)
            async let dist = health.fetchDistanceMeters(for: selectedDate)
            async let hourly = health.fetchHourlySteps(for: selectedDate)
            async let daily = health.fetchDailySteps(forLast: 7)
            let (s, d, h, last) = try await (steps, dist, hourly, daily)
            stepsToday = s
            distanceTodayMeters = d
            hourlySteps = h.map { HourPoint(date: $0.0, steps: $0.1) }
            last7Days = last.map { DayPoint(date: $0.0, steps: $0.1) }
        } catch {
            // swallow for v1; add error UI later
        }
    }
}

// MARK: - Components
private struct GlassCard<Content: View>: View {
    let accent: Color
    let progress: CGFloat
    let content: () -> Content
    let refresh: () async -> Void

    init(accent: Color, progress: CGFloat, @ViewBuilder content: @escaping () -> Content, refresh: @escaping () async -> Void) {
        self.accent = accent
        self.progress = progress
        self.content = content
        self.refresh = refresh
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .background(ProgressGlow(progress: progress, color: accent))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            Button(action: { Task { await refresh() } }) {
                Image(systemName: "arrow.clockwise")
                    .imageScale(.large)
                    .padding(16)
            }
        }
        .overlay(
            content()
                .padding(28)
        )
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 360)
    }
}

private struct ProgressGlow: View {
    let progress: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let rect = proxy.size
            let radius: CGFloat = 28
            ZStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(color.opacity(0.35), lineWidth: 3)
                    .shadow(color: color.opacity(0.5), radius: 24, x: 0, y: 0)
                    .mask(progressMask(in: rect))
                    .animation(.easeInOut(duration: 0.6), value: progress)
            }
        }
    }

    private func progressMask(in size: CGSize) -> some View {
        let perimeter = (size.width + size.height) * 2
        let progressLength = max(1, perimeter * progress)
        return RoundedRectangle(cornerRadius: 28, style: .continuous)
            .trim(from: 0, to: min(0.999, progress))
            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .frame(width: size.width, height: size.height)
            .offset(x: 0, y: 0)
    }
}

private struct HourlyChart: View {
    let data: [HourPoint]
    var body: some View {
        Chart(data) { point in
            BarMark(x: .value("Hour", point.date, unit: .hour), y: .value("Steps", point.steps))
                .foregroundStyle(.secondary)
        }
        .frame(height: 130)
        .padding(.horizontal)
    }
}

private struct DayScroller: View {
    let days: [DayPoint]
    @Binding var selected: Date
    var onTap: (Date) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(days) { day in
                    let isSelected = Calendar.current.isDate(day.date, inSameDayAs: selected)
                    VStack(spacing: 6) {
                        Text(day.date, format: .dateTime.weekday(.abbreviated))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(Calendar.current.component(.day, from: day.date).formatted())
                            .font(.headline)
                            .frame(minWidth: 36)
                            .padding(6)
                            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .onTapGesture { onTap(day.date) }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Data models for charts
struct HourPoint: Identifiable {
    let date: Date
    let steps: Int
    var id: Date { date }
}

struct DayPoint: Identifiable {
    let date: Date
    let steps: Int
    var id: Date { date }
}

#Preview {
    HomeView()
}
