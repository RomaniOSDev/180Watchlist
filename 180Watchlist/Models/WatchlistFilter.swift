//
//  WatchlistFilter.swift
//  180Watchlist
//

import Foundation

enum WatchlistSortOption: String, CaseIterable, Identifiable, Codable {
    case dateAddedNewest = "Date Added (Newest)"
    case dateAddedOldest = "Date Added (Oldest)"
    case watchedDateNewest = "Watched Date (Newest)"
    case watchedDateOldest = "Watched Date (Oldest)"
    case titleAZ = "Title A–Z"
    case titleZA = "Title Z–A"
    case ratingHigh = "Rating (High)"
    case ratingLow = "Rating (Low)"
    case releaseYearNewest = "Release Year (Newest)"
    case releaseYearOldest = "Release Year (Oldest)"
    case durationShort = "Duration (Shortest)"
    case durationLong = "Duration (Longest)"

    var id: String { rawValue }
}

struct WatchlistFilter: Equatable {
    var searchText: String = ""
    var genre: Genre?
    var type: MediaType?
    var minRating: Int?
    var collectionId: UUID?
    var maxDurationMinutes: Int?
    var releaseYear: Int?
    var status: WatchStatus?

    var isActive: Bool {
        !searchText.isEmpty
        || genre != nil
        || type != nil
        || minRating != nil
        || collectionId != nil
        || maxDurationMinutes != nil
        || releaseYear != nil
        || status != nil
    }

    mutating func reset() {
        searchText = ""
        genre = nil
        type = nil
        minRating = nil
        collectionId = nil
        maxDurationMinutes = nil
        releaseYear = nil
        status = nil
    }
}

enum PredefinedTag: String, CaseIterable, Identifiable {
    case mustWatch = "must watch"
    case withFriends = "with friends"
    case rewatch = "rewatch"

    var id: String { rawValue }
}

struct AddTemplate: Codable, Equatable {
    var type: MediaType
    var genre: Genre
    var rating: Int
    var tags: [String]
    var status: WatchStatus

    static let `default` = AddTemplate(
        type: .movie,
        genre: .drama,
        rating: 3,
        tags: [],
        status: .planned
    )
}

struct WatchlistStats {
    let watchedThisMonth: Int
    let watchedThisYear: Int
    let averageRating: Double
    let topGenres: [(Genre, Int)]
    let mostCommonType: MediaType?
    let totalWatched: Int
    let totalPlanned: Int
    let stalePlannedCount: Int
    let currentStreak: Int
    let totalRewatches: Int
}
