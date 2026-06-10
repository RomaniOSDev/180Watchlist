//
//  WatchNoteEntry.swift
//  180Watchlist
//

import Foundation

struct WatchNoteEntry: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var text: String
    var rating: Int
    var date: Date

    init(
        id: UUID = UUID(),
        text: String,
        rating: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.rating = min(max(rating, 1), 5)
        self.date = date
    }
}
