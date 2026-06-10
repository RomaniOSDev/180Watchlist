//
//  OnboardingPage.swift
//  180Watchlist
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            icon: "play.tv.fill",
            title: "Track Everything",
            subtitle: "Build your personal watchlist for movies and series. Add titles, rate them, and never forget what to watch next.",
            tint: Color(hex: "#3a86ff")
        ),
        OnboardingPage(
            id: 1,
            icon: "target",
            title: "Stay on Track",
            subtitle: "Set monthly goals, build streaks, and follow your progress. Get reminders and let the app pick something for tonight.",
            tint: Color.appAccent
        ),
        OnboardingPage(
            id: 2,
            icon: "folder.fill",
            title: "Organize Your Way",
            subtitle: "Use collections, franchises, tags, and smart filters. Keep your library structured exactly how you like it.",
            tint: Color(hex: "#9b5de5")
        )
    ]
}
