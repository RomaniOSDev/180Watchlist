//
//  EpisodeChecklistView.swift
//  180Watchlist
//

import SwiftUI

struct EpisodeChecklistView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    let item: WatchlistModel

    private var currentItem: WatchlistModel {
        viewModel.items.first(where: { $0.id == item.id }) ?? item
    }

    private var totalEpisodes: Int {
        max(currentItem.totalEpisodesInSeason ?? 10, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                AppSectionHeader(
                    title: "Season \(currentItem.season ?? 1)",
                    subtitle: "Episode checklist",
                    icon: "tv.fill"
                )
                Spacer()
                if let percent = currentItem.seasonProgressPercent {
                    Text("\(Int(percent * 100))%")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                }
            }

            if let percent = currentItem.seasonProgressPercent {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appAccent.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * percent)
                    }
                }
                .frame(height: 8)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 48))], spacing: 8) {
                ForEach(1...totalEpisodes, id: \.self) { episodeNumber in
                    let isWatched = currentItem.watchedEpisodeNumbers.contains(episodeNumber)
                    Button {
                        viewModel.toggleEpisode(episodeNumber, for: currentItem)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: isWatched ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                            Text("E\(episodeNumber)")
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundStyle(isWatched ? Color.appAccent : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isWatched ? Color.appAccent.opacity(0.12) : Color.appBackground.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isWatched ? Color.appAccent.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                viewModel.incrementEpisode(for: currentItem)
            } label: {
                Label("+1 Episode", systemImage: "plus.circle.fill")
            }
            .buttonStyle(AccentButtonStyle())
        }
        .appCard(tint: Color.appAccent.opacity(0.2))
    }
}
