//
//  ActivityHeatmapView.swift
//  180Watchlist
//

import SwiftUI

struct ActivityHeatmapView: View {
    let data: [HeatmapDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 13)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Activity", subtitle: "Last 90 days", icon: "square.grid.3x3.fill")

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(data) { day in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(heatColor(for: day.count))
                        .frame(height: 16)
                }
            }

            HStack(spacing: 6) {
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach(0..<5, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(heatColor(for: level))
                        .frame(width: 14, height: 14)
                }
                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .appCard(tint: Color.appAccent.opacity(0.2))
    }

    private func heatColor(for count: Int) -> Color {
        switch count {
        case 0: return Color.white.opacity(0.06)
        case 1: return Color.appAccent.opacity(0.25)
        case 2: return Color.appAccent.opacity(0.45)
        case 3: return Color.appAccent.opacity(0.65)
        default: return Color.appAccent
        }
    }
}
