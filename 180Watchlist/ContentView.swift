//
//  ContentView.swift
//  180Watchlist
//

import SwiftUI

enum WatchlistTab: String, CaseIterable, Identifiable {
    case watch = "Watch"
    case watched = "Watched"
    case dropped = "Dropped"

    var id: String { rawValue }

    var statuses: [WatchStatus] {
        switch self {
        case .watch: return [.planned, .watching, .onHold]
        case .watched: return [.watched]
        case .dropped: return [.dropped]
        }
    }

    var emptyIcon: String {
        switch self {
        case .watch: return "play.tv"
        case .watched: return "checkmark.seal"
        case .dropped: return "xmark.circle"
        }
    }

    var emptyTitle: String {
        switch self {
        case .watch: return "No items to watch yet"
        case .watched: return "Nothing watched yet"
        case .dropped: return "No dropped items"
        }
    }

    var emptySubtitle: String {
        switch self {
        case .watch: return "Add movies and series you want to track"
        case .watched: return "Mark items as watched to see them here"
        case .dropped: return "Items you drop will appear here"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = WatchlistViewModel()
    @State private var showOnboarding = !OnboardingStorageService.shared.hasCompletedOnboarding
    @State private var mainTab: AppMainTab = .home
    @State private var selectedTab: WatchlistTab = .watch
    @State private var navigationPath = NavigationPath()
    @State private var showFeaturesMenu = false

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    OnboardingStorageService.shared.markCompleted()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                mainApp
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showOnboarding)
    }

    private var mainApp: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                Group {
                    switch mainTab {
                    case .home:
                        HomeView(navigationPath: $navigationPath)
                    case .library:
                        WatchlistView(
                            navigationPath: $navigationPath,
                            selectedTab: $selectedTab
                        )
                    }
                }

                MainTabBar(selection: $mainTab)
            }
            .navigationDestination(for: WatchlistModel.self) { item in
                WatchlistDetailView(item: item, navigationPath: $navigationPath)
            }
            .navigationDestination(for: WatchlistNavigation.self) { route in
                destinationView(for: route)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    IconToolbarButton(icon: "square.grid.2x2", filled: true) {
                        showFeaturesMenu = true
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        IconToolbarButton(icon: "gearshape.fill") {
                            navigationPath.append(WatchlistNavigation.settings)
                        }

                        IconToolbarButton(icon: "plus", filled: true) {
                            navigationPath.append(WatchlistNavigation.add)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showFeaturesMenu) {
            FeaturesMenuSheet { route in
                navigationPath.append(route)
            }
        }
        .environmentObject(viewModel)
        .preferredColorScheme(.dark)
        .tint(Color.appAccent)
    }

    @ViewBuilder
    private func destinationView(for route: WatchlistNavigation) -> some View {
        switch route {
        case .add:
            WatchlistFormView(mode: .add)
        case .quickAdd:
            QuickAddView()
        case .addFromTemplate:
            WatchlistFormView(mode: .template, template: viewModel.addTemplate)
        case .addDuplicate(let id):
            if let item = viewModel.items.first(where: { $0.id == id }) {
                WatchlistFormView(editingItem: item, mode: .duplicate)
            }
        case .edit(let id):
            if let item = viewModel.items.first(where: { $0.id == id }) {
                WatchlistFormView(editingItem: item, mode: .edit)
            }
        case .stats:
            StatsView()
        case .collections:
            CollectionsView(navigationPath: $navigationPath)
        case .collectionDetail(let id):
            CollectionDetailView(collectionId: id)
        case .pickForMe:
            PickForMeView(navigationPath: $navigationPath)
        case .timeline:
            TimelineView()
        case .goals:
            GoalsView()
        case .monthlyWrapUp:
            MonthlyWrapUpView()
        case .franchises:
            FranchiseListView(navigationPath: $navigationPath)
        case .franchiseDetail(let id):
            FranchiseDetailView(franchiseId: id)
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
