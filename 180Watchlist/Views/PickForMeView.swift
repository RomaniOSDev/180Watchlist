//
//  PickForMeView.swift
//  180Watchlist
//

import SwiftUI

struct PickForMeView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Binding var navigationPath: NavigationPath

    @State private var pickedItem: WatchlistModel?
    @State private var selectedMood: WatchMood?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                moodPicker

                if let pickedItem {
                    VStack(spacing: 16) {
                        Text("Tonight's Pick")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                            .textCase(.uppercase)

                        WatchlistCardView(item: pickedItem)

                        HStack(spacing: 12) {
                            Button("Pick Again") { pickRandom() }
                                .buttonStyle(GhostButtonStyle())
                            Button("View Details") { navigationPath.append(pickedItem) }
                                .buttonStyle(AccentButtonStyle())
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "dice",
                        title: "No matches",
                        subtitle: "Try a different mood or adjust your filters"
                    )
                    .frame(height: 200)
                }

                Button("Roll the Dice") { pickRandom() }
                    .buttonStyle(AccentButtonStyle())
                    .disabled(viewModel.moodFilteredItems(mood: selectedMood).isEmpty)
            }
            .padding()
        }
        .appScreenBackground()
        .navigationTitle("Pick for Me")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if pickedItem == nil { pickRandom() }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "dice.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.appAccent)
            Text("Can't decide?")
                .font(.title3.weight(.bold))
            Text("Choose your mood and we'll pick something from your list.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "Your Mood", icon: "face.smiling")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WatchMood.allCases) { mood in
                    let isSelected = selectedMood == mood
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedMood = isSelected ? nil : mood
                        }
                        pickRandom()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: mood.icon)
                                .font(.title3)
                            Text(mood.rawValue)
                                .font(.caption.weight(.bold))
                            Text(mood.description)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(isSelected ? Color.appBackground : .primary)
                        .background {
                            if isSelected {
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appAccent.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                Color.appCard
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .appCard(tint: Color.appAccent.opacity(0.15))
    }

    private func pickRandom() {
        withAnimation(.spring(response: 0.4)) {
            pickedItem = viewModel.randomPlannedItem(mood: selectedMood)
        }
    }
}
