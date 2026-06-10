//
//  WatchlistCardView.swift
//  180Watchlist
//

import SwiftUI

struct WatchlistCardView: View {
    let item: WatchlistModel
    var showChevron: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            posterBlock
            contentBlock
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding(AppLayout.cardPadding)
        .listCard(tint: item.genre.cardTint)
    }

    private var posterBlock: some View {
        ZStack(alignment: .topTrailing) {
            if item.posterImageData != nil || item.posterURL != nil {
                PosterImageView(
                    imageData: item.posterImageData,
                    imageURL: item.posterURL,
                    height: 96,
                    cornerRadius: 10
                )
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [item.genre.cardTint.opacity(0.55), Color.appCard],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 96)
                    .overlay {
                        Text(item.type.icon)
                            .font(.title)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(item.genre.cardTint.opacity(0.35), lineWidth: 1)
                    }
            }

            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.appBackground)
                    .padding(5)
                    .background(
                        LinearGradient(
                            colors: [Color.appAccent, Color(hex: "#e6a800")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(Circle())
                    .offset(x: 4, y: -4)
            }
        }
    }

    private var contentBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Spacer(minLength: 4)
                StatusBadgeView(status: item.status, compact: true)
            }

            HStack(spacing: 6) {
                MediaTypeBadge(type: item.type)
                if let year = item.releaseYear {
                    MetaChip(icon: "calendar", text: "\(year)", tint: .secondary)
                }
                if let duration = item.durationMinutes {
                    MetaChip(icon: "clock", text: formatDuration(duration), tint: .secondary)
                }
            }

            HStack(spacing: 8) {
                GenreBadgeView(genre: item.genre)
                StarRatingView(rating: item.rating)
            }

            if let progress = item.episodeProgress {
                HStack(spacing: 6) {
                    MetaChip(icon: "tv", text: progress)
                    if let percent = item.seasonProgressPercent {
                        Text("\(Int(percent * 100))%")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }

            if let percent = item.seasonProgressPercent, item.type == .tvSeries {
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    GeometryReader { geo in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent, Color(hex: "#e6a800")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * percent, 4))
                    }
                }
                .frame(height: 4)
            }

            bottomRow
        }
    }

    private var bottomRow: some View {
        HStack(spacing: 6) {
            if let countdown = item.countdownText {
                MetaChip(icon: "timer", text: countdown)
            }
            if item.rewatchCount > 0 {
                MetaChip(icon: "arrow.counterclockwise", text: "\(item.rewatchCount)")
            }
            if !item.tags.isEmpty {
                TagFlowView(tags: Array(item.tags.prefix(2)))
            }
            Spacer()
        }
    }

    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }
}
