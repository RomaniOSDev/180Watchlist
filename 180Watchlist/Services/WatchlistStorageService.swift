//
//  WatchlistStorageService.swift
//  180Watchlist
//

import Foundation

protocol WatchlistStorageServiceProtocol {
    func loadItems() -> [WatchlistModel]
    func saveItems(_ items: [WatchlistModel])
    func loadCollections() -> [MediaCollection]
    func saveCollections(_ collections: [MediaCollection])
    func loadFranchises() -> [Franchise]
    func saveFranchises(_ franchises: [Franchise])
    func loadAddTemplate() -> AddTemplate
    func saveAddTemplate(_ template: AddTemplate)
    func loadGoalSettings() -> WatchGoalSettings
    func saveGoalSettings(_ settings: WatchGoalSettings)
}

final class WatchlistStorageService: WatchlistStorageServiceProtocol {
    private let itemsKey = "watchlist_items"
    private let collectionsKey = "watchlist_collections"
    private let franchisesKey = "watchlist_franchises"
    private let templateKey = "watchlist_add_template"
    private let goalsKey = "watchlist_goals"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadItems() -> [WatchlistModel] {
        guard let data = userDefaults.data(forKey: itemsKey) else {
            return []
        }
        do {
            var items = try JSONDecoder().decode([WatchlistModel].self, from: data)
            for index in items.indices {
                items[index].migrateLegacyNoteIfNeeded()
            }
            return items.sorted { $0.createdAt > $1.createdAt }
        } catch {
            return []
        }
    }

    func saveItems(_ items: [WatchlistModel]) {
        do {
            let data = try JSONEncoder().encode(items)
            userDefaults.set(data, forKey: itemsKey)
        } catch {
            return
        }
    }

    func loadCollections() -> [MediaCollection] {
        guard let data = userDefaults.data(forKey: collectionsKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([MediaCollection].self, from: data)
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            return []
        }
    }

    func saveCollections(_ collections: [MediaCollection]) {
        do {
            let data = try JSONEncoder().encode(collections)
            userDefaults.set(data, forKey: collectionsKey)
        } catch {
            return
        }
    }

    func loadFranchises() -> [Franchise] {
        guard let data = userDefaults.data(forKey: franchisesKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([Franchise].self, from: data)
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            return []
        }
    }

    func saveFranchises(_ franchises: [Franchise]) {
        do {
            let data = try JSONEncoder().encode(franchises)
            userDefaults.set(data, forKey: franchisesKey)
        } catch {
            return
        }
    }

    func loadAddTemplate() -> AddTemplate {
        guard let data = userDefaults.data(forKey: templateKey),
              let template = try? JSONDecoder().decode(AddTemplate.self, from: data) else {
            return .default
        }
        return template
    }

    func saveAddTemplate(_ template: AddTemplate) {
        do {
            let data = try JSONEncoder().encode(template)
            userDefaults.set(data, forKey: templateKey)
        } catch {
            return
        }
    }

    func loadGoalSettings() -> WatchGoalSettings {
        guard let data = userDefaults.data(forKey: goalsKey),
              let settings = try? JSONDecoder().decode(WatchGoalSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    func saveGoalSettings(_ settings: WatchGoalSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: goalsKey)
        } catch {
            return
        }
    }
}
