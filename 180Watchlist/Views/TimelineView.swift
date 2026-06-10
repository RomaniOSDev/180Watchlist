//
//  TimelineView.swift
//  180Watchlist
//

import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel

    private var entries: [TimelineEntry] { viewModel.timelineEntries() }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ActivityHeatmapView(data: viewModel.heatmapData())

                if entries.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.clock",
                        title: "No watch history",
                        subtitle: "Mark items as watched to build your timeline"
                    )
                    .frame(minHeight: 280)
                } else {
                    ForEach(entries) { entry in
                        TimelineListCell(entry: entry, dateText: dateFormatter.string(from: entry.date))
                    }
                }
            }
            .padding()
        }
        .appScreenBackground()
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.inline)
    }
}
