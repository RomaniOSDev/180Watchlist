//
//  StatsCardView.swift
//  180Watchlist
//

import SwiftUI

struct StatsCardView: View {
    let title: String
    let value: String
    var icon: String? = nil
    var tint: Color = .appAccent
    var large: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(tint)
                        .frame(width: 34, height: 34)
                        .background(
                            LinearGradient(
                                colors: [tint.opacity(0.22), tint.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .stroke(tint.opacity(0.28), lineWidth: 1)
                        }
                }
                Spacer()
            }

            Text(value)
                .font(large ? .title.weight(.bold) : .title2.weight(.bold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(tint: tint.opacity(0.25), elevation: large ? .floating : .raised)
    }
}
