//
//  WatchlistNavigation.swift
//  180Watchlist
//

import Foundation

enum WatchlistNavigation: Hashable {
    case add
    case quickAdd
    case addFromTemplate
    case addDuplicate(UUID)
    case edit(UUID)
    case stats
    case collections
    case collectionDetail(UUID)
    case pickForMe
    case timeline
    case goals
    case monthlyWrapUp
    case franchises
    case franchiseDetail(UUID)
    case settings
}
