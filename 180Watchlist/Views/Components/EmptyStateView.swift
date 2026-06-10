//
//  EmptyStateView.swift
//  180Watchlist
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var primaryTitle: String? = nil
    var primaryAction: (() -> Void)? = nil
    var secondaryTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.1))
                    .frame(width: 100, height: 100)
                Circle()
                    .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
                    .frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.appAccent)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let primaryTitle, let primaryAction {
                HStack(spacing: 12) {
                    Button(primaryTitle, action: primaryAction)
                        .buttonStyle(AccentButtonStyle())

                    if let secondaryTitle, let secondaryAction {
                        Button(secondaryTitle, action: secondaryAction)
                            .buttonStyle(GhostButtonStyle())
                    }
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
