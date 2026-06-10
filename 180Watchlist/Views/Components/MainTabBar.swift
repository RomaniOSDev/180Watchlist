//
//  MainTabBar.swift
//  180Watchlist
//

import SwiftUI

enum AppMainTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case library = "Library"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .library: return "play.rectangle.on.rectangle.fill"
        }
    }
}

struct MainTabBar: View {
    @Binding var selection: AppMainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppMainTab.allCases) { tab in
                let isSelected = selection == tab
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.body.weight(isSelected ? .bold : .regular))
                        Text(tab.rawValue)
                            .font(.caption2.weight(isSelected ? .bold : .medium))
                    }
                    .foregroundStyle(isSelected ? Color.appAccent : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appAccent.opacity(0.22), Color.appAccent.opacity(0.10)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(Capsule().stroke(Color.appAccent.opacity(0.28), lineWidth: 1))
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background {
            LinearGradient(
                colors: [Color.appCard, Color(hex: "#0a1f3d")],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 1)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
