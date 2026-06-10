//
//  GenreBadgeView.swift
//  180Watchlist
//

import SwiftUI

struct GenreBadgeView: View {
    let genre: Genre

    var body: some View {
        Text(genre.rawValue)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.appBackground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                LinearGradient(
                    colors: [Color.appAccent, Color(hex: "#e6a800")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
    }
}
