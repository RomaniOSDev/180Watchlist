//
//  ShareCardView.swift
//  180Watchlist
//

import SwiftUI
import UIKit

struct ShareCardView: View {
    let item: WatchlistModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                PosterImageView(
                    imageData: item.posterImageData,
                    imageURL: item.posterURL,
                    height: 150,
                    cornerRadius: 14
                )

                VStack(alignment: .leading, spacing: 10) {
                    StatusBadgeView(status: item.status, compact: true)
                    Text(item.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                    HStack(spacing: 8) {
                        MediaTypeBadge(type: item.type)
                        GenreBadgeView(genre: item.genre)
                    }
                    StarRatingView(rating: item.rating)
                    if item.rewatchCount > 0 {
                        MetaChip(icon: "arrow.counterclockwise", text: "Rewatched \(item.rewatchCount)×")
                    }
                }
            }

            if let note = item.latestNote?.text, !note.isEmpty {
                Text("\"\(note)\"")
                    .font(.subheadline.italic())
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(24)
        .frame(width: 380)
        .background(
            LinearGradient(
                colors: [Color.appBackground, item.genre.cardTint.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.8), item.genre.cardTint.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
}

@MainActor
enum ShareCardRenderer {
    static func renderImage(for item: WatchlistModel) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(item: item))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
