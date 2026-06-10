//
//  WatchGoalSettings.swift
//  180Watchlist
//

import Foundation

struct WatchGoalSettings: Codable, Equatable {
    var monthlyTarget: Int
    var streakNotificationsEnabled: Bool
    var goalNotificationsEnabled: Bool

    static let `default` = WatchGoalSettings(
        monthlyTarget: 4,
        streakNotificationsEnabled: true,
        goalNotificationsEnabled: true
    )
}

struct WatchStreakInfo {
    let currentStreak: Int
    let longestStreak: Int
    let watchedThisMonth: Int
    let monthlyTarget: Int
    var monthlyProgress: Double {
        guard monthlyTarget > 0 else { return 0 }
        return min(Double(watchedThisMonth) / Double(monthlyTarget), 1.0)
    }
}

struct TimelineEntry: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let genre: Genre
    let rating: Int
    let type: MediaType
}

struct MonthlyWrapUp {
    let month: Date
    let watchedCount: Int
    let averageRating: Double
    let topGenre: Genre?
    let topGenreCount: Int
    let rewatchCount: Int
    let streakDays: Int
}

struct HeatmapDay: Identifiable {
    let id: String
    let date: Date
    let count: Int
}

enum WatchMood: String, CaseIterable, Identifiable {
    case light = "Light"
    case intense = "Intense"
    case short = "Short"
    case long = "Long"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .light: return "sun.max"
        case .intense: return "bolt.fill"
        case .short: return "hare"
        case .long: return "tortoise"
        }
    }

    var description: String {
        switch self {
        case .light: return "Comedy, Animation, Romance"
        case .intense: return "Thriller, Horror, Action"
        case .short: return "Under 2 hours"
        case .long: return "Epic films & series"
        }
    }
}
