//
//  HomeView.swift
//  180Watchlist
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Binding var navigationPath: NavigationPath

    @State private var pickTonightItem: WatchlistModel?

    private var streakInfo: WatchStreakInfo { viewModel.streakInfo() }
    private var stats: WatchlistStats { viewModel.stats() }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    private var continueWatching: [WatchlistModel] {
        viewModel.items.filter { $0.status == .watching }.prefix(8).map { $0 }
    }

    private var upNext: [WatchlistModel] {
        viewModel.items
            .filter { $0.status.isActiveList }
            .sorted { lhs, rhs in
                if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
                if let l = lhs.scheduledWatchDate, let r = rhs.scheduledWatchDate { return l < r }
                return lhs.createdAt > rhs.createdAt
            }
            .prefix(8)
            .map { $0 }
    }

    private var recentlyWatched: [WatchlistModel] {
        viewModel.items
            .filter { $0.status == .watched }
            .sorted { ($0.watchedDate ?? .distantPast) > ($1.watchedDate ?? .distantPast) }
            .prefix(8)
            .map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HomeHeroBanner(
                    greeting: greeting,
                    subtitle: stats.totalPlanned > 0
                        ? "You have \(stats.totalPlanned) titles waiting"
                        : "Start building your watchlist"
                )

                HomeStatsWidget(
                    watchedMonth: streakInfo.watchedThisMonth,
                    streak: streakInfo.currentStreak,
                    toWatch: stats.totalPlanned,
                    goalProgress: streakInfo.monthlyProgress,
                    monthlyTarget: streakInfo.monthlyTarget
                )

                HomePickTonightWidget(
                    item: pickTonightItem,
                    onPick: { pickTonight() },
                    onOpen: {
                        if let pickTonightItem {
                            navigationPath.append(pickTonightItem)
                        }
                    }
                )

                if !continueWatching.isEmpty {
                    HomeContinueWatchingWidget(items: continueWatching) { item in
                        navigationPath.append(item)
                    }
                }

                if !upNext.isEmpty {
                    HomeUpNextWidget(items: upNext) { item in
                        navigationPath.append(item)
                    }
                }

                if !recentlyWatched.isEmpty {
                    HomeRecentlyWatchedWidget(items: recentlyWatched) { item in
                        navigationPath.append(item)
                    }
                }

                if !viewModel.collections.isEmpty {
                    HomeCollectionsWidget(
                        collections: Array(viewModel.collections.prefix(6)),
                        itemCount: { viewModel.items(in: $0).count }
                    ) { collection in
                        navigationPath.append(WatchlistNavigation.collectionDetail(collection.id))
                    }
                }

                HomeActivityWidget(data: viewModel.heatmapData())

                quickActionsGrid

                wrapUpTeaser
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.bottom, 24)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if pickTonightItem == nil {
                pickTonight()
            }
        }
    }

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Quick Actions", icon: "bolt.fill")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                quickAction("bolt.fill", "Quick Add", .appAccent) { navigationPath.append(WatchlistNavigation.quickAdd) }
                quickAction("dice.fill", "Pick", Color(hex: "#ff006e")) { navigationPath.append(WatchlistNavigation.pickForMe) }
                quickAction("chart.bar.fill", "Stats", Color(hex: "#2dc653")) { navigationPath.append(WatchlistNavigation.stats) }
                quickAction("calendar", "Timeline", Color(hex: "#3a86ff")) { navigationPath.append(WatchlistNavigation.timeline) }
                quickAction("flame.fill", "Goals", Color(hex: "#f77f00")) { navigationPath.append(WatchlistNavigation.goals) }
                quickAction("folder.fill", "Collections", .appAccent) { navigationPath.append(WatchlistNavigation.collections) }
            }
        }
        .appCard(tint: Color.appAccent.opacity(0.12))
    }

    private var wrapUpTeaser: some View {
        let wrapUp = viewModel.monthlyWrapUp()
        return Button {
            navigationPath.append(WatchlistNavigation.monthlyWrapUp)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 48, height: 48)
                    .background(Color.appAccent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Wrap-Up")
                        .font(.headline)
                    Text("\(wrapUp.watchedCount) watched · \(String(format: "%.1f", wrapUp.averageRating)) avg rating")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .appCard(tint: Color(hex: "#9b5de5").opacity(0.25))
        }
        .buttonStyle(.plain)
    }

    private func quickAction(_ icon: String, _ title: String, _ tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HomeQuickActionTile(icon: icon, title: title, tint: tint)
        }
        .buttonStyle(.plain)
    }

    private func pickTonight() {
        withAnimation(.spring(response: 0.35)) {
            pickTonightItem = viewModel.randomPlannedItem()
        }
    }
}
