//
//  PosterImageView.swift
//  180Watchlist
//

import SwiftUI

struct PosterImageView: View {
    let imageData: Data?
    let imageURL: String?
    var height: CGFloat = 120
    var cornerRadius: CGFloat = 8

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    default:
                        ZStack {
                            placeholder
                            ProgressView().tint(Color.appAccent)
                        }
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: height * 0.67, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appCard, Color.appBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "film")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}
