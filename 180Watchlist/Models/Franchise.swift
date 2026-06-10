//
//  Franchise.swift
//  180Watchlist
//

import Foundation

struct Franchise: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var orderedItemIds: [UUID]
    var createdAt: Date

    init(id: UUID = UUID(), name: String, orderedItemIds: [UUID] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.orderedItemIds = orderedItemIds
        self.createdAt = createdAt
    }
}
