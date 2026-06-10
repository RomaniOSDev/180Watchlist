//
//  FeaturesMenuSheet.swift
//  180Watchlist
//

import SwiftUI

struct FeaturesMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (WatchlistNavigation) -> Void

    private let features: [(WatchlistNavigation, String, String, String, Color)] = [
        (.quickAdd, "bolt.fill", "Quick Add", "Title + type in seconds", .appAccent),
        (.stats, "chart.bar.fill", "Statistics", "Ratings, genres, heatmap", Color(hex: "#2dc653")),
        (.timeline, "calendar", "Timeline", "Watch history feed", Color(hex: "#3a86ff")),
        (.goals, "flame.fill", "Goals & Streak", "Monthly targets", Color(hex: "#f77f00")),
        (.monthlyWrapUp, "sparkles", "Monthly Wrap-Up", "Your month in review", Color(hex: "#9b5de5")),
        (.collections, "folder.fill", "Collections", "Custom grouped lists", .appAccent),
        (.franchises, "link.circle.fill", "Franchises", "Watch order chains", Color(hex: "#3a86ff")),
        (.pickForMe, "dice.fill", "Pick for Me", "Mood-based random pick", Color(hex: "#ff006e")),
        (.addFromTemplate, "doc.badge.plus", "Add Like Previous", "Reuse last settings", .secondary)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                    ForEach(features.indices, id: \.self) { index in
                        let feature = features[index]
                        Button {
                            dismiss()
                            onSelect(feature.0)
                        } label: {
                            MenuFeatureCell(
                                icon: feature.1,
                                title: feature.2,
                                subtitle: feature.3,
                                tint: feature.4
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .appScreenBackground()
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
