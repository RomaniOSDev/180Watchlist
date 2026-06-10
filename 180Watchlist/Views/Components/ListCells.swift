//
//  ListCells.swift
//  180Watchlist
//

import SwiftUI

struct CollectionListCell: View {
    let name: String
    let itemCount: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.22), Color.appAccent.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Image(systemName: "folder.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appAccent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text("\(itemCount) item\(itemCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(AppLayout.cardPadding)
        .listCard(tint: Color.appAccent.opacity(0.2))
    }
}

struct FranchiseListCell: View {
    let name: String
    let itemCount: Int
    var order: Int? = nil
    var subtitle: String? = nil
    var status: WatchStatus? = nil

    private let franchiseTint = Color(hex: "#3a86ff")

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [franchiseTint.opacity(0.22), franchiseTint.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                if let order {
                    Text("\(order)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(franchiseTint)
                } else {
                    Image(systemName: "link.circle.fill")
                        .font(.title3)
                        .foregroundStyle(franchiseTint)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                if let status {
                    StatusBadgeView(status: status, compact: true)
                } else {
                    Text(subtitle ?? "\(itemCount) in watch order")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(AppLayout.cardPadding)
        .listCard(tint: franchiseTint.opacity(0.2))
    }
}

struct TimelineListCell: View {
    let entry: TimelineEntry
    let dateText: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [entry.genre.cardTint, entry.genre.cardTint.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.appAccent.opacity(0.5), lineWidth: 2))
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 2)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(dateText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appAccent)

                Text(entry.title)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(entry.type.icon)
                    GenreBadgeView(genre: entry.genre)
                    StarRatingView(rating: entry.rating)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppLayout.cardPadding)
            .listCard(tint: entry.genre.cardTint.opacity(0.3))
        }
    }
}

struct MenuFeatureCell: View {
    let icon: String
    let title: String
    let subtitle: String
    var tint: Color = .appAccent

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [tint.opacity(0.20), tint.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(tint.opacity(0.28), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .listCard(tint: tint.opacity(0.15))
    }
}

struct QuickStatsBar: View {
    let watchedMonth: Int
    let streak: Int
    let toWatch: Int

    var body: some View {
        HStack(spacing: 10) {
            miniStat(icon: "checkmark.circle.fill", value: "\(watchedMonth)", label: "Month", tint: Color(hex: "#2dc653"))
            miniStat(icon: "flame.fill", value: "\(streak)", label: "Streak", tint: Color.appAccent)
            miniStat(icon: "clock.fill", value: "\(toWatch)", label: "To Watch", tint: Color(hex: "#5c7cfa"))
        }
    }

    private func miniStat(icon: String, value: String, label: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.subheadline.weight(.bold))
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [tint.opacity(0.14), tint.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
    }
}
