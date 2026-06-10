//
//  WatchlistModel.swift
//  180Watchlist
//

import Foundation

enum MediaType: String, Codable, CaseIterable, Identifiable {
    case movie
    case tvSeries

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .movie: return "Movie"
        case .tvSeries: return "TV Series"
        }
    }

    var icon: String {
        switch self {
        case .movie: return "🎬"
        case .tvSeries: return "📺"
        }
    }
}

enum Genre: String, Codable, CaseIterable, Identifiable {
    case action = "Action"
    case comedy = "Comedy"
    case drama = "Drama"
    case horror = "Horror"
    case romance = "Romance"
    case sciFi = "Sci-Fi"
    case documentary = "Documentary"
    case animation = "Animation"
    case thriller = "Thriller"
    case fantasy = "Fantasy"

    var id: String { rawValue }
}

enum WatchStatus: String, Codable, CaseIterable, Identifiable {
    case planned = "Planned"
    case watching = "Watching"
    case onHold = "On Hold"
    case watched = "Watched"
    case dropped = "Dropped"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .planned: return "clock"
        case .watching: return "play.circle.fill"
        case .onHold: return "pause.circle"
        case .watched: return "checkmark.circle.fill"
        case .dropped: return "xmark.circle"
        }
    }

    var isActiveList: Bool {
        self == .planned || self == .watching || self == .onHold
    }
}

struct WatchlistModel: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var type: MediaType
    var genre: Genre
    var status: WatchStatus
    var rating: Int
    var note: String?
    var watchedDate: Date?
    var createdAt: Date
    var isPinned: Bool
    var tags: [String]
    var season: Int?
    var episode: Int?
    var posterImageData: Data?
    var posterURL: String?
    var collectionIds: [UUID]
    var noteHistory: [WatchNoteEntry]
    var reminderDate: Date?
    var rewatchCount: Int
    var releaseYear: Int?
    var durationMinutes: Int?
    var scheduledWatchDate: Date?
    var totalEpisodesInSeason: Int?
    var watchedEpisodeNumbers: [Int]
    var franchiseId: UUID?
    var franchiseOrder: Int?
    var watchAfterId: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        type: MediaType = .movie,
        genre: Genre = .drama,
        status: WatchStatus = .planned,
        rating: Int = 3,
        note: String? = nil,
        watchedDate: Date? = nil,
        createdAt: Date = Date(),
        isPinned: Bool = false,
        tags: [String] = [],
        season: Int? = nil,
        episode: Int? = nil,
        posterImageData: Data? = nil,
        posterURL: String? = nil,
        collectionIds: [UUID] = [],
        noteHistory: [WatchNoteEntry] = [],
        reminderDate: Date? = nil,
        rewatchCount: Int = 0,
        releaseYear: Int? = nil,
        durationMinutes: Int? = nil,
        scheduledWatchDate: Date? = nil,
        totalEpisodesInSeason: Int? = nil,
        watchedEpisodeNumbers: [Int] = [],
        franchiseId: UUID? = nil,
        franchiseOrder: Int? = nil,
        watchAfterId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.genre = genre
        self.status = status
        self.rating = min(max(rating, 1), 5)
        self.note = note
        self.watchedDate = status == .watched ? (watchedDate ?? Date()) : nil
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.tags = tags
        self.season = season
        self.episode = episode
        self.posterImageData = posterImageData
        self.posterURL = posterURL
        self.collectionIds = collectionIds
        self.noteHistory = noteHistory
        self.reminderDate = reminderDate
        self.rewatchCount = rewatchCount
        self.releaseYear = releaseYear
        self.durationMinutes = durationMinutes
        self.scheduledWatchDate = scheduledWatchDate
        self.totalEpisodesInSeason = totalEpisodesInSeason
        self.watchedEpisodeNumbers = watchedEpisodeNumbers
        self.franchiseId = franchiseId
        self.franchiseOrder = franchiseOrder
        self.watchAfterId = watchAfterId
    }

    var episodeProgress: String? {
        guard type == .tvSeries, let season, let episode else { return nil }
        return String(format: "S%02dE%02d", season, episode)
    }

    var seasonProgressPercent: Double? {
        guard type == .tvSeries, let total = totalEpisodesInSeason, total > 0 else { return nil }
        return Double(watchedEpisodeNumbers.count) / Double(total)
    }

    var countdownText: String? {
        guard let scheduledWatchDate, scheduledWatchDate > Date() else { return nil }
        let interval = scheduledWatchDate.timeIntervalSince(Date())
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h left" }
        if hours > 0 { return "\(hours)h \(minutes)m left" }
        return "\(minutes)m left"
    }

    var latestNote: WatchNoteEntry? {
        noteHistory.sorted { $0.date > $1.date }.first
    }

    mutating func migrateLegacyNoteIfNeeded() {
        guard noteHistory.isEmpty, let legacyNote = note, !legacyNote.isEmpty else { return }
        noteHistory = [WatchNoteEntry(text: legacyNote, rating: rating, date: watchedDate ?? createdAt)]
        note = nil
    }
}
