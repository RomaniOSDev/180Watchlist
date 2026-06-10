//
//  StatusBadgeView.swift
//  180Watchlist
//

import SwiftUI

struct StatusBadgeView: View {
    let status: WatchStatus
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.systemImage)
                .font(compact ? .caption2 : .caption)
            Text(status.rawValue)
                .font(compact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
        }
        .foregroundStyle(status.accentColor)
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 5)
        .background(
            LinearGradient(
                colors: [status.accentColor.opacity(0.22), status.accentColor.opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .overlay(Capsule().stroke(status.accentColor.opacity(0.40), lineWidth: 1))
    }
}

struct MediaTypeBadge: View {
    let type: MediaType

    var body: some View {
        HStack(spacing: 4) {
            Text(type.icon)
                .font(.caption)
            Text(type.displayName)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
    }
}

struct MetaChip: View {
    let icon: String
    let text: String
    var tint: Color = .appAccent

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.12))
        .clipShape(Capsule())
    }
}
