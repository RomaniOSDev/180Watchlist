//
//  FilterSortSheet.swift
//  180Watchlist
//

import SwiftUI

struct FilterSortSheet: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    filterCard(title: "Sort By", icon: "arrow.up.arrow.down") {
                        Picker("Sort", selection: $viewModel.sortOption) {
                            ForEach(WatchlistSortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color.appAccent)
                    }

                    filterCard(title: "Filters", icon: "line.3.horizontal.decrease") {
                        VStack(spacing: 14) {
                            filterPicker("Status", selection: statusBinding) {
                                Text("All Statuses").tag(WatchStatus?.none)
                                ForEach(WatchStatus.allCases) { status in
                                    Text(status.rawValue).tag(WatchStatus?.some(status))
                                }
                            }
                            filterPicker("Genre", selection: genreBinding) {
                                Text("All Genres").tag(Genre?.none)
                                ForEach(Genre.allCases) { genre in
                                    Text(genre.rawValue).tag(Genre?.some(genre))
                                }
                            }
                            filterPicker("Type", selection: typeBinding) {
                                Text("All Types").tag(MediaType?.none)
                                ForEach(MediaType.allCases) { type in
                                    Text(type.displayName).tag(MediaType?.some(type))
                                }
                            }
                            filterPicker("Min Rating", selection: ratingBinding) {
                                Text("Any Rating").tag(Int?.none)
                                ForEach(1...5, id: \.self) { rating in
                                    Text("\(rating)+ stars").tag(Int?.some(rating))
                                }
                            }
                            filterPicker("Max Duration", selection: durationBinding) {
                                Text("Any Duration").tag(Int?.none)
                                Text("Under 90 min").tag(Int?.some(90))
                                Text("Under 2 hours").tag(Int?.some(120))
                                Text("Under 3 hours").tag(Int?.some(180))
                            }
                            filterPicker("Release Year", selection: yearBinding) {
                                Text("Any Year").tag(Int?.none)
                                ForEach(uniqueYears, id: \.self) { year in
                                    Text("\(year)").tag(Int?.some(year))
                                }
                            }
                            filterPicker("Collection", selection: collectionBinding) {
                                Text("All Collections").tag(UUID?.none)
                                ForEach(viewModel.collections) { collection in
                                    Text(collection.name).tag(UUID?.some(collection.id))
                                }
                            }
                        }
                    }

                    if viewModel.filter.isActive {
                        Button("Reset All Filters") { viewModel.resetFilters() }
                            .buttonStyle(DestructiveOutlineButtonStyle())
                    }
                }
                .padding()
            }
            .appScreenBackground()
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func filterCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: title, icon: icon)
            content()
        }
        .appCard(tint: Color.appAccent.opacity(0.15))
    }

    @ViewBuilder
    private func filterPicker<Selection: Hashable, Content: View>(
        _ label: String,
        selection: Binding<Selection>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Picker(label, selection: selection, content: content)
                .pickerStyle(.menu)
                .tint(Color.appAccent)
        }
    }

    private var uniqueYears: [Int] {
        Array(Set(viewModel.items.compactMap(\.releaseYear))).sorted(by: >)
    }

    private var statusBinding: Binding<WatchStatus?> {
        Binding(get: { viewModel.filter.status }, set: { viewModel.filter.status = $0 })
    }

    private var genreBinding: Binding<Genre?> {
        Binding(get: { viewModel.filter.genre }, set: { viewModel.filter.genre = $0 })
    }

    private var typeBinding: Binding<MediaType?> {
        Binding(get: { viewModel.filter.type }, set: { viewModel.filter.type = $0 })
    }

    private var ratingBinding: Binding<Int?> {
        Binding(get: { viewModel.filter.minRating }, set: { viewModel.filter.minRating = $0 })
    }

    private var durationBinding: Binding<Int?> {
        Binding(get: { viewModel.filter.maxDurationMinutes }, set: { viewModel.filter.maxDurationMinutes = $0 })
    }

    private var yearBinding: Binding<Int?> {
        Binding(get: { viewModel.filter.releaseYear }, set: { viewModel.filter.releaseYear = $0 })
    }

    private var collectionBinding: Binding<UUID?> {
        Binding(get: { viewModel.filter.collectionId }, set: { viewModel.filter.collectionId = $0 })
    }
}
