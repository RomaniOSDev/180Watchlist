//
//  HomeWidgets.swift
//  180Watchlist
//

import SwiftUI

// MARK: - Hero Banner

struct HomeHeroBanner: View {
    let greeting: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()

            LinearGradient(
                colors: [.clear, Color.appBackground.opacity(0.3), Color.appBackground.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.45), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.30), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Stats Widget

struct HomeStatsWidget: View {
    let watchedMonth: Int
    let streak: Int
    let toWatch: Int
    let goalProgress: Double
    let monthlyTarget: Int

    var body: some View {
        ZStack {
            Image("WidgetStatsBg")
                .resizable()
                .scaledToFill()
                .clipped()

            LinearGradient(
                colors: [Color.appBackground.opacity(0.72), Color.appBackground.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Monthly Goal")
                            .font(.caption.weight(.semibold))
                        Spacer()
                        Text("\(watchedMonth)/\(monthlyTarget)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.15))
                            Capsule()
                                .fill(Color.appAccent)
                                .frame(width: geo.size.width * goalProgress)
                        }
                    }
                    .frame(height: 6)
                }

                HStack(spacing: 0) {
                    statBlock(value: "\(watchedMonth)", label: "This Month", icon: "checkmark.circle.fill", tint: Color(hex: "#2dc653"))
                    Divider().frame(height: 44).overlay(Color.white.opacity(0.15))
                    statBlock(value: "\(streak)d", label: "Streak", icon: "flame.fill", tint: Color.appAccent)
                    Divider().frame(height: 44).overlay(Color.white.opacity(0.15))
                    statBlock(value: "\(toWatch)", label: "To Watch", icon: "clock.fill", tint: Color(hex: "#5c7cfa"))
                }
            }
            .padding(16)
        }
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.35), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.28), radius: 10, x: 0, y: 5)
    }

    private func statBlock(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline.weight(.bold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Pick Tonight Widget

struct HomePickTonightWidget: View {
    let item: WatchlistModel?
    let onPick: () -> Void
    let onOpen: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            Image("WidgetPickBg")
                .resizable()
                .scaledToFill()
                .frame(minHeight: 140)
                .clipped()

            LinearGradient(
                colors: [Color.appBackground.opacity(0.88), Color.appBackground.opacity(0.55)],
                startPoint: .leading,
                endPoint: .trailing
            )

            HStack(spacing: 14) {
                if let item {
                    PosterImageView(
                        imageData: item.posterImageData,
                        imageURL: item.posterURL,
                        height: 100,
                        cornerRadius: 12
                    )
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appAccent.opacity(0.15))
                            .frame(width: 67, height: 100)
                        Image(systemName: "dice.fill")
                            .font(.title)
                            .foregroundStyle(Color.appAccent)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Pick Tonight", systemImage: "sparkles")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appAccent)

                    if let item {
                        Text(item.title)
                            .font(.headline)
                            .lineLimit(2)
                        HStack(spacing: 6) {
                            GenreBadgeView(genre: item.genre)
                            StarRatingView(rating: item.rating)
                        }
                    } else {
                        Text("Roll the dice")
                            .font(.headline)
                        Text("Find something from your watchlist")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        Button("Shuffle", action: onPick)
                            .buttonStyle(GhostButtonStyle())
                            .frame(maxWidth: .infinity)
                        if item != nil {
                            Button("Open", action: onOpen)
                                .buttonStyle(AccentButtonStyle())
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.40), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .compositingGroup()
        .shadow(color: Color.appAccent.opacity(0.12), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Continue Watching

struct HomeContinueWatchingWidget: View {
    let items: [WatchlistModel]
    let onSelect: (WatchlistModel) -> Void

    var body: some View {
        HomeHorizontalWidget(
            title: "Continue Watching",
            subtitle: "\(items.count) in progress",
            icon: "play.circle.fill",
            emptyMessage: "Nothing in progress — start a series!"
        ) {
            ForEach(items) { item in
                Button { onSelect(item) } label: {
                    HomePosterTile(item: item, badge: item.episodeProgress)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Up Next

struct HomeUpNextWidget: View {
    let items: [WatchlistModel]
    let onSelect: (WatchlistModel) -> Void

    var body: some View {
        HomeHorizontalWidget(
            title: "Up Next",
            subtitle: "Scheduled & pinned",
            icon: "clock.badge.checkmark",
            emptyMessage: "Add titles to your watchlist"
        ) {
            ForEach(items) { item in
                Button { onSelect(item) } label: {
                    HomePosterTile(item: item, badge: item.countdownText)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Recently Watched

struct HomeRecentlyWatchedWidget: View {
    let items: [WatchlistModel]
    let onSelect: (WatchlistModel) -> Void

    var body: some View {
        HomeHorizontalWidget(
            title: "Recently Watched",
            subtitle: "Your latest picks",
            icon: "checkmark.seal.fill",
            emptyMessage: "Mark something as watched"
        ) {
            ForEach(items) { item in
                Button { onSelect(item) } label: {
                    HomePosterTile(item: item, badge: "★\(item.rating)")
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Collections Row

struct HomeCollectionsWidget: View {
    let collections: [MediaCollection]
    let itemCount: (MediaCollection) -> Int
    let onSelect: (MediaCollection) -> Void

    var body: some View {
        HomeHorizontalWidget(
            title: "Collections",
            subtitle: "Your curated lists",
            icon: "folder.fill",
            emptyMessage: "Create your first collection"
        ) {
            ForEach(collections) { collection in
                Button { onSelect(collection) } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appAccent.opacity(0.35), Color.appCard],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 80)
                            Image(systemName: "folder.fill")
                                .font(.title)
                                .foregroundStyle(Color.appAccent)
                        }
                        Text(collection.name)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                        Text("\(itemCount(collection)) titles")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 120)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct HomeQuickActionTile: View {
    let icon: String
    let title: String
    let tint: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(title)
                .font(.caption2.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [tint.opacity(0.14), Color.appBackground.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
    }
}

// MARK: - Activity Mini Heatmap

struct HomeActivityWidget: View {
    let data: [HeatmapDay]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Your Activity", subtitle: "Last 2 weeks", icon: "chart.bar.fill")
            let recent = Array(data.suffix(14))
            HStack(spacing: 4) {
                ForEach(recent) { day in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(heatColor(for: day.count))
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                }
            }
        }
        .appCard(tint: Color(hex: "#3a86ff").opacity(0.2))
    }

    private func heatColor(for count: Int) -> Color {
        switch count {
        case 0: return Color.white.opacity(0.06)
        case 1: return Color.appAccent.opacity(0.35)
        case 2: return Color.appAccent.opacity(0.55)
        default: return Color.appAccent
        }
    }
}

// MARK: - Helpers

struct HomeHorizontalWidget<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let emptyMessage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: title, subtitle: subtitle, icon: icon)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    content
                }
            }
        }
        .appCard()
    }
}

struct HomePosterTile: View {
    let item: WatchlistModel
    var badge: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                if item.posterImageData != nil || item.posterURL != nil {
                    PosterImageView(
                        imageData: item.posterImageData,
                        imageURL: item.posterURL,
                        height: 110,
                        cornerRadius: 12
                    )
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [item.genre.cardTint.opacity(0.5), Color.appCard],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 74, height: 110)
                        .overlay { Text(item.type.icon).font(.title) }
                }

                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.appBackground)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.appAccent)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -4)
                }
            }

            Text(item.title)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
                .frame(width: 74, alignment: .leading)

            StatusBadgeView(status: item.status, compact: true)
        }
        .frame(width: 74)
    }
}
