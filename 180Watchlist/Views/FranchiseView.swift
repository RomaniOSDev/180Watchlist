//
//  FranchiseView.swift
//  180Watchlist
//

import SwiftUI

struct FranchiseListView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Binding var navigationPath: NavigationPath

    @State private var newFranchiseName = ""
    @State private var showAddAlert = false

    var body: some View {
        Group {
            if viewModel.franchises.isEmpty {
                EmptyStateView(
                    icon: "link.badge.plus",
                    title: "No franchises yet",
                    subtitle: "Create watch order chains like Marvel Phase 1 → 2 → 3",
                    primaryTitle: "Create Franchise",
                    primaryAction: { showAddAlert = true }
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.franchises) { franchise in
                            Button {
                                navigationPath.append(WatchlistNavigation.franchiseDetail(franchise.id))
                            } label: {
                                FranchiseListCell(
                                    name: franchise.name,
                                    itemCount: viewModel.orderedFranchiseItems(franchise).count
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("Franchises")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                IconToolbarButton(icon: "plus", filled: true) { showAddAlert = true }
            }
        }
        .alert("New Franchise", isPresented: $showAddAlert) {
            TextField("Franchise name", text: $newFranchiseName)
            Button("Cancel", role: .cancel) { newFranchiseName = "" }
            Button("Create") {
                viewModel.addFranchise(name: newFranchiseName)
                newFranchiseName = ""
            }
        }
    }
}

struct FranchiseDetailView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    let franchiseId: UUID
    @State private var showAddItem = false

    private var franchise: Franchise? {
        viewModel.franchises.first { $0.id == franchiseId }
    }

    private var orderedItems: [WatchlistModel] {
        guard let franchise else { return [] }
        return viewModel.orderedFranchiseItems(franchise)
    }

    var body: some View {
        Group {
            if franchise != nil {
                if orderedItems.isEmpty {
                    EmptyStateView(
                        icon: "link",
                        title: "No items yet",
                        subtitle: "Add titles to build the watch order",
                        primaryTitle: "Add Item",
                        primaryAction: { showAddItem = true }
                    )
                } else {
                    List {
                        ForEach(Array(orderedItems.enumerated()), id: \.element.id) { index, item in
                            NavigationLink(value: item) {
                                FranchiseListCell(
                                    name: item.title,
                                    itemCount: 0,
                                    order: index + 1,
                                    status: item.status
                                )
                            }
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onMove { source, destination in
                            viewModel.moveFranchiseItem(franchiseId: franchiseId, from: source, to: destination)
                        }
                        .onDelete { offsets in
                            offsets.compactMap { orderedItems[$0].id }.forEach {
                                viewModel.removeItemFromFranchise($0, franchiseId: franchiseId)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            } else {
                Text("Franchise not found")
            }
        }
        .appScreenBackground()
        .navigationTitle(franchise?.name ?? "Franchise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                IconToolbarButton(icon: "plus", filled: true) { showAddItem = true }
            }
            ToolbarItem(placement: .topBarTrailing) {
                EditButton().foregroundStyle(Color.appAccent)
            }
        }
        .confirmationDialog("Add to Franchise", isPresented: $showAddItem) {
            ForEach(viewModel.items.filter { $0.franchiseId != franchiseId }) { item in
                Button(item.title) {
                    viewModel.addItemToFranchise(item.id, franchiseId: franchiseId)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
