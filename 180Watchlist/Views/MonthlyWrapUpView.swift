//
//  MonthlyWrapUpView.swift
//  180Watchlist
//

import SwiftUI

struct MonthlyWrapUpView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel

    private var wrapUp: MonthlyWrapUp { viewModel.monthlyWrapUp() }

    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.appAccent)
                    Text(monthFormatter.string(from: wrapUp.month))
                        .font(.title.weight(.bold))
                    Text("Your month in review")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                StatsCardView(
                    title: "Titles Watched",
                    value: "\(wrapUp.watchedCount)",
                    icon: "film.stack",
                    tint: Color.appAccent,
                    large: true
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatsCardView(title: "Avg. Rating", value: String(format: "%.1f", wrapUp.averageRating), icon: "star.fill")
                    StatsCardView(title: "Rewatches", value: "\(wrapUp.rewatchCount)", icon: "arrow.counterclockwise", tint: Color(hex: "#3a86ff"))
                    StatsCardView(title: "Streak", value: "\(wrapUp.streakDays)d", icon: "flame.fill", tint: Color(hex: "#f77f00"))
                    if let genre = wrapUp.topGenre {
                        StatsCardView(title: "Top Genre", value: genre.rawValue, icon: "heart.fill", tint: genre.cardTint)
                    }
                }

                if let genre = wrapUp.topGenre {
                    VStack(alignment: .leading, spacing: 10) {
                        AppSectionHeader(title: "Favorite Genre", icon: "crown.fill")
                        HStack {
                            GenreBadgeView(genre: genre)
                            Spacer()
                            Text("×\(wrapUp.topGenreCount)")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                    .appCard(tint: genre.cardTint.opacity(0.3))
                }

                if wrapUp.watchedCount == 0 {
                    Text("No watches recorded this month yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .appScreenBackground()
        .navigationTitle("Wrap-Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}
