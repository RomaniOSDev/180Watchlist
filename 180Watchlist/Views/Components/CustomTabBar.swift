//
//  CustomTabBar.swift
//  180Watchlist
//

import SwiftUI

struct CustomTabBar<Tab: Hashable & Identifiable>: View where Tab: RawRepresentable, Tab.RawValue == String {
    @Binding var selection: Tab
    let tabs: [Tab]
    var counts: [Tab: Int] = [:]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs) { tab in
                let isSelected = selection.id == tab.id
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(.subheadline.weight(isSelected ? .bold : .medium))
                        if let count = counts[tab], count > 0 {
                            Text("\(count)")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(isSelected ? Color.appBackground.opacity(0.25) : Color.appAccent.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .foregroundStyle(isSelected ? Color.appBackground : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if isSelected {
                            LinearGradient(
                                colors: [Color.appAccent, Color.appAccent.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            Color.appCard
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            LinearGradient(
                colors: [Color.appCard.opacity(0.85), Color.appBackground.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}
