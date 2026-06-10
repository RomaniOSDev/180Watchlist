//
//  StatsView.swift
//  180Watchlist
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel

    private var stats: WatchlistStats { viewModel.stats() }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ActivityHeatmapView(data: viewModel.heatmapData())

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatsCardView(title: "This Month", value: "\(stats.watchedThisMonth)", icon: "calendar", tint: Color(hex: "#2dc653"))
                    StatsCardView(title: "This Year", value: "\(stats.watchedThisYear)", icon: "calendar.badge.clock", tint: Color(hex: "#3a86ff"))
                    StatsCardView(title: "Avg. Rating", value: String(format: "%.1f", stats.averageRating), icon: "star.fill")
                    StatsCardView(title: "Streak", value: "\(stats.currentStreak)d", icon: "flame.fill", tint: Color(hex: "#f77f00"))
                    StatsCardView(title: "Rewatches", value: "\(stats.totalRewatches)", icon: "arrow.counterclockwise")
                    StatsCardView(title: "To Watch", value: "\(stats.totalPlanned)", icon: "clock.fill", tint: Color(hex: "#5c7cfa"))
                }

                if let mostCommon = stats.mostCommonType {
                    VStack(alignment: .leading, spacing: 10) {
                        AppSectionHeader(title: "Most Watched Type", icon: "chart.pie.fill")
                        HStack(spacing: 10) {
                            Text(mostCommon.icon).font(.title)
                            Text(mostCommon.displayName).font(.headline)
                        }
                    }
                    .appCard(tint: Color.appAccent.opacity(0.15))
                }

                if !stats.topGenres.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        AppSectionHeader(title: "Top Genres", icon: "list.number")
                        ForEach(stats.topGenres, id: \.0) { genre, count in
                            HStack {
                                GenreBadgeView(genre: genre)
                                Spacer()
                                Text("\(count)")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                    }
                    .appCard()
                }

                VStack(alignment: .leading, spacing: 10) {
                    AppSectionHeader(title: "Reminders", icon: "bell")
                    Toggle("Stale watchlist alerts", isOn: $viewModel.staleRemindersEnabled)
                        .tint(Color.appAccent)
                }
                .appCard()
            }
            .padding()
        }
        .appScreenBackground()
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
}
