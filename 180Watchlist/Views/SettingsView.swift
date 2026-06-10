//
//  SettingsView.swift
//  180Watchlist
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 0) {
                    SettingsRow(
                        icon: "star.fill",
                        title: "Rate Us",
                        subtitle: "Enjoying the app? Leave a review",
                        tint: Color.appAccent
                    ) {
                        AppActions.rateApp()
                    }

                    settingsDivider

                    SettingsRow(
                        icon: "hand.raised.fill",
                        title: "Privacy Policy",
                        subtitle: "How we handle your data",
                        tint: Color(hex: "#3a86ff")
                    ) {
                        AppActions.openPolicy(.privacyPolicy)
                    }

                    settingsDivider

                    SettingsRow(
                        icon: "doc.text.fill",
                        title: "Terms of Use",
                        subtitle: "Rules for using the app",
                        tint: Color(hex: "#9b5de5")
                    ) {
                        AppActions.openPolicy(.termsOfUse)
                    }
                }
                .appCard()
            }
            .padding()
        }
        .appScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 58)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(
                        LinearGradient(
                            colors: [tint.opacity(0.22), tint.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(tint.opacity(0.28), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, AppLayout.cardPadding)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
