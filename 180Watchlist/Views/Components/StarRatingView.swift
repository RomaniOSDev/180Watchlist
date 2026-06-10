//
//  StarRatingView.swift
//  180Watchlist
//

import SwiftUI

struct StarRatingView: View {
    let rating: Int
    var maxRating: Int = 5
    var isInteractive: Bool = false
    var onRatingChanged: ((Int) -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundStyle(Color.appAccent)
                    .font(.system(size: isInteractive ? 28 : 16))
                    .onTapGesture {
                        guard isInteractive else { return }
                        onRatingChanged?(index)
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating \(rating) out of \(maxRating)")
    }
}
