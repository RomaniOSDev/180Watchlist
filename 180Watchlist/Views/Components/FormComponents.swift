//
//  FormComponents.swift
//  180Watchlist
//

import SwiftUI

struct FormSectionCard<Content: View>: View {
    let title: String
    var icon: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: title, icon: icon)
            content
        }
        .appCard(tint: Color.appAccent.opacity(0.3))
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding(12)
            .background(Color.appBackground.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
    }
}

struct CustomTextEditor: View {
    @Binding var text: String
    var minHeight: CGFloat = 90

    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: minHeight)
            .scrollContentBackground(.hidden)
            .padding(10)
            .background(Color.appBackground.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
    }
}

struct DetailInfoCard<Content: View>: View {
    let title: String
    var icon: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon ?? "info.circle")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(tint: Color.white.opacity(0.05))
    }
}

struct DetailHeroHeader: View {
    let item: WatchlistModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [item.genre.cardTint.opacity(0.5), Color.appCard],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: item.posterImageData != nil || item.posterURL != nil ? 220 : 140)

            if item.posterImageData != nil || item.posterURL != nil {
                HStack {
                    Spacer()
                    PosterImageView(
                        imageData: item.posterImageData,
                        imageURL: item.posterURL,
                        height: 180,
                        cornerRadius: 14
                    )
                    Spacer()
                }
                .padding(.top, 16)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if item.isPinned {
                        MetaChip(icon: "pin.fill", text: "Pinned")
                    }
                    StatusBadgeView(status: item.status)
                    Spacer()
                    if item.rewatchCount > 0 {
                        MetaChip(icon: "arrow.counterclockwise", text: "×\(item.rewatchCount)")
                    }
                }

                Text(item.title)
                    .font(.title2.weight(.bold))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    MediaTypeBadge(type: item.type)
                    GenreBadgeView(genre: item.genre)
                    StarRatingView(rating: item.rating)
                }
            }
            .padding(AppLayout.cardPadding)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppLayout.cardRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [item.genre.cardTint.opacity(0.55), item.genre.cardTint.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .compositingGroup()
        .shadow(color: item.genre.cardTint.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct QuickActionBar: View {
    let actions: [(icon: String, title: String, tint: Color, action: () -> Void)]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                    Button(action: action.action) {
                        VStack(spacing: 6) {
                            Image(systemName: action.icon)
                                .font(.body.weight(.semibold))
                            Text(action.title)
                                .font(.caption2.weight(.medium))
                        }
                        .foregroundStyle(action.tint)
                        .frame(width: 72, height: 64)
                        .background(
                            LinearGradient(
                                colors: [action.tint.opacity(0.18), action.tint.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(action.tint.opacity(0.32), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
