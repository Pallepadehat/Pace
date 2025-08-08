//
//  ChartsAndScroller.swift
//  Pace
//
//  Created by AI Assistant on 08/08/2025.
//

import SwiftUI
import Charts

struct HourlyChart: View {
    let data: [HourPoint]
    var body: some View {
        Chart(data) { point in
            BarMark(x: .value("Hour", point.date, unit: .hour), y: .value("Steps", point.steps))
                .foregroundStyle(.secondary)
                .cornerRadius(2)
        }
        .frame(height: 180)
        .padding(.horizontal)
    }
}

struct DayScroller: View {
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


