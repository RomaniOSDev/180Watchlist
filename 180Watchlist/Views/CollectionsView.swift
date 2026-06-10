//
//  CollectionsView.swift
//  180Watchlist
//

import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Binding var navigationPath: NavigationPath

    @State private var newCollectionName = ""
    @State private var showAddAlert = false

    var body: some View {
        Group {
            if viewModel.collections.isEmpty {
                EmptyStateView(
                    icon: "folder.badge.plus",
                    title: "No collections yet",
                    subtitle: "Group titles into lists like Marvel, Oscar 2025, or Weekend",
                    primaryTitle: "Create Collection",
                    primaryAction: { showAddAlert = true }
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.collections) { collection in
                            Button {
                                navigationPath.append(WatchlistNavigation.collectionDetail(collection.id))
                            } label: {
                                CollectionListCell(
                                    name: collection.name,
                                    itemCount: viewModel.items(in: collection).count
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteCollection(collection)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .appScreenBackground()
        .navigationTitle("Collections")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                IconToolbarButton(icon: "plus", filled: true) { showAddAlert = true }
            }
        }
        .alert("New Collection", isPresented: $showAddAlert) {
            TextField("Collection name", text: $newCollectionName)
            Button("Cancel", role: .cancel) { newCollectionName = "" }
            Button("Create") {
                viewModel.addCollection(name: newCollectionName)
                newCollectionName = ""
            }
        }
    }
}

struct CollectionDetailView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    let collectionId: UUID

    private var collection: MediaCollection? {
        viewModel.collections.first { $0.id == collectionId }
    }

    var body: some View {
        Group {
            if let collection {
                let items = viewModel.items(in: collection)
                if items.isEmpty {
                    EmptyStateView(
                        icon: "film",
                        title: "Empty collection",
                        subtitle: "Add items from the entry form or detail screen"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(items) { item in
                                NavigationLink(value: item) {
                                    WatchlistCardView(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            } else {
                Text("Collection not found")
            }
        }
        .appScreenBackground()
        .navigationTitle(collection?.name ?? "Collection")
        .navigationBarTitleDisplayMode(.inline)
    }
}
