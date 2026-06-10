//
//  WatchlistView.swift
//  180Watchlist
//

import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var selectedTab: WatchlistTab

    @State private var showFilterSheet = false

    private var filteredItems: [WatchlistModel] {
        viewModel.filteredItems(for: selectedTab.statuses)
    }

    private var tabCounts: [WatchlistTab: Int] {
        Dictionary(uniqueKeysWithValues: WatchlistTab.allCases.map { tab in
            (tab, viewModel.filteredItems(for: tab.statuses).count)
        })
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                CustomTabBar(selection: $selectedTab, tabs: WatchlistTab.allCases, counts: tabCounts)
                    .padding(.horizontal, AppLayout.horizontalPadding)
                    .padding(.top, 8)

                let stats = viewModel.stats()
                QuickStatsBar(
                    watchedMonth: stats.watchedThisMonth,
                    streak: stats.currentStreak,
                    toWatch: stats.totalPlanned
                )
                .padding(.horizontal, AppLayout.horizontalPadding)

                if viewModel.filter.isActive {
                    activeFiltersBar
                }
            }

            Group {
                if filteredItems.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            Button {
                                navigationPath.append(item)
                            } label: {
                                WatchlistCardView(item: item)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button { viewModel.togglePin(item) } label: {
                                    Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash" : "pin")
                                }
                                .tint(Color.appAccent)

                                if item.status.isActiveList {
                                    Button { viewModel.setStatus(.watching, for: item) } label: {
                                        Label("Watching", systemImage: "play.circle")
                                    }
                                    .tint(.purple)

                                    Button { viewModel.markAsWatched(item) } label: {
                                        Label("Watched", systemImage: "checkmark.circle")
                                    }
                                    .tint(Color(hex: "#2dc653"))
                                }

                                Button {
                                    navigationPath.append(WatchlistNavigation.edit(item.id))
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Color(hex: "#3a86ff"))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                if item.status.isActiveList {
                                    Button { viewModel.setStatus(.onHold, for: item) } label: {
                                        Label("Hold", systemImage: "pause.circle")
                                    }
                                    .tint(.orange)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .searchable(
            text: Binding(
                get: { viewModel.filter.searchText },
                set: { viewModel.filter.searchText = $0 }
            ),
            prompt: "Search by title or tag"
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                IconToolbarButton(
                    icon: viewModel.filter.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle",
                    filled: viewModel.filter.isActive
                ) {
                    showFilterSheet = true
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSortSheet().environmentObject(viewModel)
        }
        .appScreenBackground()
    }

    private var activeFiltersBar: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundStyle(Color.appAccent)
            Text("Filters active")
                .font(.caption.weight(.semibold))
            Spacer()
            Button("Reset") { viewModel.resetFilters() }
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appDestructive)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.appAccent.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, AppLayout.horizontalPadding)
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: viewModel.filter.isActive ? "magnifyingglass" : selectedTab.emptyIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
            primaryTitle: tab == .watch && !viewModel.filter.isActive ? "Add First Item" : viewModel.filter.isActive ? "Reset Filters" : nil,
            primaryAction: tab == .watch && !viewModel.filter.isActive ? {
                navigationPath.append(WatchlistNavigation.add)
            } : viewModel.filter.isActive ? {
                viewModel.resetFilters()
            } : nil,
            secondaryTitle: tab == .watch && !viewModel.filter.isActive ? "Quick Add" : nil,
            secondaryAction: tab == .watch && !viewModel.filter.isActive ? {
                navigationPath.append(WatchlistNavigation.quickAdd)
            } : nil
        )
    }

    private var tab: WatchlistTab { selectedTab }

    private var emptyTitle: String {
        viewModel.filter.isActive ? "No matching items" : selectedTab.emptyTitle
    }

    private var emptySubtitle: String {
        viewModel.filter.isActive ? "Try adjusting your filters or search" : selectedTab.emptySubtitle
    }
}
