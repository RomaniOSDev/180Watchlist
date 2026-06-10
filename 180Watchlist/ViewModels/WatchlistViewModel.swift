//
//  WatchlistViewModel.swift
//  180Watchlist
//

import Combine
import Foundation

@MainActor
final class WatchlistViewModel: ObservableObject {
    @Published private(set) var items: [WatchlistModel] = []
    @Published private(set) var collections: [MediaCollection] = []
    @Published private(set) var franchises: [Franchise] = []
    @Published private(set) var addTemplate: AddTemplate = .default
    @Published var filter = WatchlistFilter()
    @Published var sortOption: WatchlistSortOption = .dateAddedNewest
    @Published var goalSettings: WatchGoalSettings = .default
    @Published var staleRemindersEnabled = true {
        didSet { refreshStaleReminders() }
    }

    private let storageService: WatchlistStorageServiceProtocol
    private let notificationService: NotificationServiceProtocol

    init(
        storageService: WatchlistStorageServiceProtocol = WatchlistStorageService(),
        notificationService: NotificationServiceProtocol = NotificationService()
    ) {
        self.storageService = storageService
        self.notificationService = notificationService
        loadAll()
        Task { await setupNotifications() }
    }

    func loadAll() {
        items = storageService.loadItems()
        collections = storageService.loadCollections()
        franchises = storageService.loadFranchises()
        addTemplate = storageService.loadAddTemplate()
        goalSettings = storageService.loadGoalSettings()
        refreshStaleReminders()
    }

    func filteredItems(for statuses: [WatchStatus]) -> [WatchlistModel] {
        var result = items.filter { statuses.contains($0.status) }

        if let statusFilter = filter.status {
            result = result.filter { $0.status == statusFilter }
        }

        let search = filter.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !search.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(search)
                || $0.tags.contains { $0.localizedCaseInsensitiveContains(search) }
            }
        }

        if let genre = filter.genre {
            result = result.filter { $0.genre == genre }
        }

        if let type = filter.type {
            result = result.filter { $0.type == type }
        }

        if let minRating = filter.minRating {
            result = result.filter { $0.rating >= minRating }
        }

        if let collectionId = filter.collectionId {
            result = result.filter { $0.collectionIds.contains(collectionId) }
        }

        if let maxDuration = filter.maxDurationMinutes {
            result = result.filter {
                guard let duration = $0.durationMinutes else { return false }
                return duration <= maxDuration
            }
        }

        if let year = filter.releaseYear {
            result = result.filter { $0.releaseYear == year }
        }

        let pinned = result.filter(\.isPinned).sorted { sortComparator($0, $1) }
        let unpinned = result.filter { !$0.isPinned }.sorted { sortComparator($0, $1) }
        return pinned + unpinned
    }

    func filteredItems(for status: WatchStatus) -> [WatchlistModel] {
        filteredItems(for: [status])
    }

    func addItem(_ item: WatchlistModel) {
        items.insert(item, at: 0)
        syncFranchiseMembership(for: item)
        updateAddTemplate(from: item)
        persistItems()
        scheduleNotifications(for: item)
        refreshGoalNotifications()
        refreshStaleReminders()
    }

    func updateItem(_ item: WatchlistModel) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
        syncFranchiseMembership(for: item)
        persistItems()
        scheduleNotifications(for: item)
        refreshGoalNotifications()
        refreshStaleReminders()
    }

    func deleteItem(_ item: WatchlistModel) {
        items.removeAll { $0.id == item.id }
        removeItemFromFranchises(item.id)
        persistItems()
        notificationService.cancelReminder(for: item.id)
        refreshGoalNotifications()
        refreshStaleReminders()
    }

    func quickAdd(title: String, type: MediaType) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addItem(WatchlistModel(title: trimmed, type: type))
    }

    func setStatus(_ status: WatchStatus, for item: WatchlistModel) {
        var updated = item
        updated.status = status
        if status == .watched {
            updated.watchedDate = Date()
        } else if !status.isActiveList && status != .dropped {
            updated.watchedDate = nil
        }
        updateItem(updated)
    }

    func markAsWatched(_ item: WatchlistModel) {
        setStatus(.watched, for: item)
    }

    func markAsRewatched(_ item: WatchlistModel, note: String?, rating: Int) {
        var updated = item
        updated.rewatchCount += 1
        updated.watchedDate = Date()
        updated.status = .watched
        updated.rating = rating
        if let note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updated.noteHistory.insert(
                WatchNoteEntry(text: note, rating: rating),
                at: 0
            )
        } else {
            updated.noteHistory.insert(
                WatchNoteEntry(text: "Rewatch #\(updated.rewatchCount)", rating: rating),
                at: 0
            )
        }
        updateItem(updated)
    }

    func togglePin(_ item: WatchlistModel) {
        var updated = item
        updated.isPinned.toggle()
        updateItem(updated)
    }

    func toggleFavorite(_ item: WatchlistModel) {
        var updated = item
        if updated.tags.contains(PredefinedTag.mustWatch.rawValue) {
            updated.tags.removeAll { $0 == PredefinedTag.mustWatch.rawValue }
        } else {
            updated.tags.append(PredefinedTag.mustWatch.rawValue)
        }
        updateItem(updated)
    }

    func duplicateItem(_ item: WatchlistModel) -> WatchlistModel {
        let copy = WatchlistModel(
            title: "\(item.title) (Copy)",
            type: item.type,
            genre: item.genre,
            status: item.status,
            rating: item.rating,
            watchedDate: item.watchedDate,
            isPinned: false,
            tags: item.tags,
            season: item.season,
            episode: item.episode,
            posterImageData: item.posterImageData,
            posterURL: item.posterURL,
            collectionIds: item.collectionIds,
            noteHistory: item.noteHistory,
            reminderDate: item.reminderDate,
            releaseYear: item.releaseYear,
            durationMinutes: item.durationMinutes,
            scheduledWatchDate: item.scheduledWatchDate,
            totalEpisodesInSeason: item.totalEpisodesInSeason,
            watchedEpisodeNumbers: item.watchedEpisodeNumbers,
            franchiseId: item.franchiseId,
            franchiseOrder: item.franchiseOrder,
            watchAfterId: item.watchAfterId
        )
        addItem(copy)
        return copy
    }

    func addNoteEntry(to item: WatchlistModel, text: String, rating: Int) {
        var updated = item
        updated.noteHistory.insert(WatchNoteEntry(text: text, rating: rating), at: 0)
        updated.rating = rating
        updateItem(updated)
    }

    func incrementEpisode(for item: WatchlistModel) {
        guard item.type == .tvSeries else { return }
        var updated = item
        let currentEpisode = updated.episode ?? 0
        let nextEpisode = currentEpisode + 1
        let total = updated.totalEpisodesInSeason ?? max(nextEpisode, 1)

        if !updated.watchedEpisodeNumbers.contains(nextEpisode) {
            updated.watchedEpisodeNumbers.append(nextEpisode)
        }
        updated.episode = min(nextEpisode, total)
        if updated.season == nil { updated.season = 1 }
        if updated.status == .planned { updated.status = .watching }
        updateItem(updated)
    }

    func toggleEpisode(_ episodeNumber: Int, for item: WatchlistModel) {
        guard item.type == .tvSeries else { return }
        var updated = item
        if updated.watchedEpisodeNumbers.contains(episodeNumber) {
            updated.watchedEpisodeNumbers.removeAll { $0 == episodeNumber }
        } else {
            updated.watchedEpisodeNumbers.append(episodeNumber)
            updated.episode = max(updated.episode ?? 0, episodeNumber)
        }
        if updated.season == nil { updated.season = 1 }
        if !updated.watchedEpisodeNumbers.isEmpty && updated.status == .planned {
            updated.status = .watching
        }
        updateItem(updated)
    }

    func randomPlannedItem(mood: WatchMood? = nil) -> WatchlistModel? {
        let candidates = moodFilteredItems(mood: mood)
        return candidates.randomElement()
    }

    func moodFilteredItems(mood: WatchMood?) -> [WatchlistModel] {
        var candidates = filteredItems(for: [.planned, .watching, .onHold])
        guard let mood else { return candidates }

        switch mood {
        case .light:
            candidates = candidates.filter {
                [.comedy, .animation, .romance].contains($0.genre)
            }
        case .intense:
            candidates = candidates.filter {
                [.thriller, .horror, .action].contains($0.genre)
            }
        case .short:
            candidates = candidates.filter {
                if $0.type == .tvSeries { return false }
                guard let duration = $0.durationMinutes else { return true }
                return duration <= 120
            }
        case .long:
            candidates = candidates.filter {
                if $0.type == .tvSeries { return true }
                guard let duration = $0.durationMinutes else { return false }
                return duration > 120
            }
        }
        return candidates
    }

    func streakInfo() -> WatchStreakInfo {
        let watched = items.filter { $0.status == .watched }
        let calendar = Calendar.current
        let now = Date()

        let watchedThisMonth = watched.filter {
            guard let date = $0.watchedDate else { return false }
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        }.count

        let watchDates = Set(watched.compactMap { item -> Date? in
            guard let date = item.watchedDate else { return nil }
            return calendar.startOfDay(for: date)
        })

        let currentStreak = calculateCurrentStreak(from: watchDates, calendar: calendar)
        let longestStreak = calculateLongestStreak(from: watchDates, calendar: calendar)

        return WatchStreakInfo(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            watchedThisMonth: watchedThisMonth,
            monthlyTarget: goalSettings.monthlyTarget
        )
    }

    func stats() -> WatchlistStats {
        let watched = items.filter { $0.status == .watched }
        let planned = items.filter { $0.status.isActiveList }
        let calendar = Calendar.current
        let now = Date()

        let watchedThisMonth = watched.filter {
            guard let date = $0.watchedDate else { return false }
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        }.count

        let watchedThisYear = watched.filter {
            guard let date = $0.watchedDate else { return false }
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }.count

        let averageRating: Double = {
            guard !watched.isEmpty else { return 0 }
            return Double(watched.reduce(0) { $0 + $1.rating }) / Double(watched.count)
        }()

        var genreCounts: [Genre: Int] = [:]
        watched.forEach { genreCounts[$0.genre, default: 0] += 1 }
        let topGenres = genreCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }

        var typeCounts: [MediaType: Int] = [:]
        watched.forEach { typeCounts[$0.type, default: 0] += 1 }
        let mostCommonType = typeCounts.max(by: { $0.value < $1.value })?.key

        let stalePlannedCount = planned.filter { isStale($0) }.count
        let totalRewatches = watched.reduce(0) { $0 + $1.rewatchCount }

        return WatchlistStats(
            watchedThisMonth: watchedThisMonth,
            watchedThisYear: watchedThisYear,
            averageRating: averageRating,
            topGenres: Array(topGenres),
            mostCommonType: mostCommonType,
            totalWatched: watched.count,
            totalPlanned: planned.count,
            stalePlannedCount: stalePlannedCount,
            currentStreak: streakInfo().currentStreak,
            totalRewatches: totalRewatches
        )
    }

    func timelineEntries() -> [TimelineEntry] {
        items.compactMap { item -> TimelineEntry? in
            guard let date = item.watchedDate, item.status == .watched else { return nil }
            return TimelineEntry(
                id: item.id,
                title: item.title,
                date: date,
                genre: item.genre,
                rating: item.rating,
                type: item.type
            )
        }
        .sorted { $0.date > $1.date }
    }

    func heatmapData(days: Int = 90) -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var counts: [Date: Int] = [:]

        for item in items where item.status == .watched {
            guard let watchedDate = item.watchedDate else { continue }
            let day = calendar.startOfDay(for: watchedDate)
            counts[day, default: 0] += 1
        }

        return (0..<days).compactMap { offset -> HeatmapDay? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let day = calendar.startOfDay(for: date)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return HeatmapDay(
                id: formatter.string(from: day),
                date: day,
                count: counts[day, default: 0]
            )
        }
        .reversed()
    }

    func monthlyWrapUp(for month: Date = Date()) -> MonthlyWrapUp {
        let calendar = Calendar.current
        let watched = items.filter { item in
            guard item.status == .watched, let date = item.watchedDate else { return false }
            return calendar.isDate(date, equalTo: month, toGranularity: .month)
        }

        let averageRating: Double = {
            guard !watched.isEmpty else { return 0 }
            return Double(watched.reduce(0) { $0 + $1.rating }) / Double(watched.count)
        }()

        var genreCounts: [Genre: Int] = [:]
        watched.forEach { genreCounts[$0.genre, default: 0] += 1 }
        let top = genreCounts.max(by: { $0.value < $1.value })

        let rewatchCount = watched.reduce(0) { $0 + $1.rewatchCount }

        return MonthlyWrapUp(
            month: month,
            watchedCount: watched.count,
            averageRating: averageRating,
            topGenre: top?.key,
            topGenreCount: top?.value ?? 0,
            rewatchCount: rewatchCount,
            streakDays: streakInfo().currentStreak
        )
    }

    func items(in collection: MediaCollection) -> [WatchlistModel] {
        items.filter { $0.collectionIds.contains(collection.id) }
    }

    func orderedFranchiseItems(_ franchise: Franchise) -> [WatchlistModel] {
        franchise.orderedItemIds.compactMap { id in
            items.first { $0.id == id }
        }
    }

    func addCollection(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        collections.insert(MediaCollection(name: trimmed), at: 0)
        persistCollections()
    }

    func deleteCollection(_ collection: MediaCollection) {
        collections.removeAll { $0.id == collection.id }
        for index in items.indices {
            items[index].collectionIds.removeAll { $0 == collection.id }
        }
        persistCollections()
        persistItems()
    }

    func addFranchise(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        franchises.insert(Franchise(name: trimmed), at: 0)
        persistFranchises()
    }

    func deleteFranchise(_ franchise: Franchise) {
        franchises.removeAll { $0.id == franchise.id }
        for index in items.indices where items[index].franchiseId == franchise.id {
            items[index].franchiseId = nil
            items[index].franchiseOrder = nil
        }
        persistFranchises()
        persistItems()
    }

    func addItemToFranchise(_ itemId: UUID, franchiseId: UUID) {
        guard var franchise = franchises.first(where: { $0.id == franchiseId }),
              let index = items.firstIndex(where: { $0.id == itemId }) else { return }

        if !franchise.orderedItemIds.contains(itemId) {
            franchise.orderedItemIds.append(itemId)
        }
        if let fIndex = franchises.firstIndex(where: { $0.id == franchiseId }) {
            franchises[fIndex] = franchise
        }

        items[index].franchiseId = franchiseId
        items[index].franchiseOrder = franchise.orderedItemIds.firstIndex(of: itemId)
        persistFranchises()
        persistItems()
    }

    func removeItemFromFranchise(_ itemId: UUID, franchiseId: UUID) {
        guard let fIndex = franchises.firstIndex(where: { $0.id == franchiseId }) else { return }
        franchises[fIndex].orderedItemIds.removeAll { $0 == itemId }
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].franchiseId = nil
            items[index].franchiseOrder = nil
        }
        persistFranchises()
        persistItems()
    }

    func moveFranchiseItem(franchiseId: UUID, from source: IndexSet, to destination: Int) {
        guard let index = franchises.firstIndex(where: { $0.id == franchiseId }) else { return }
        var ids = franchises[index].orderedItemIds
        var itemsToMove: [UUID] = []
        for offset in source.sorted(by: >) {
            itemsToMove.insert(ids.remove(at: offset), at: 0)
        }
        let insertIndex = min(max(destination, 0), ids.count)
        ids.insert(contentsOf: itemsToMove, at: insertIndex)
        franchises[index].orderedItemIds = ids
        for (order, itemId) in ids.enumerated() {
            if let itemIndex = items.firstIndex(where: { $0.id == itemId }) {
                items[itemIndex].franchiseOrder = order
            }
        }
        persistFranchises()
        persistItems()
    }

    func setWatchAfter(itemId: UUID, afterId: UUID?) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        items[index].watchAfterId = afterId
        persistItems()
    }

    func updateGoalSettings(_ settings: WatchGoalSettings) {
        goalSettings = settings
        storageService.saveGoalSettings(settings)
        refreshGoalNotifications()
    }

    func resetFilters() {
        filter.reset()
    }

    func itemTitle(for id: UUID) -> String? {
        items.first { $0.id == id }?.title
    }

    private func sortComparator(_ lhs: WatchlistModel, _ rhs: WatchlistModel) -> Bool {
        switch sortOption {
        case .dateAddedNewest: return lhs.createdAt > rhs.createdAt
        case .dateAddedOldest: return lhs.createdAt < rhs.createdAt
        case .watchedDateNewest: return (lhs.watchedDate ?? .distantPast) > (rhs.watchedDate ?? .distantPast)
        case .watchedDateOldest: return (lhs.watchedDate ?? .distantFuture) < (rhs.watchedDate ?? .distantFuture)
        case .titleAZ: return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        case .titleZA: return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedDescending
        case .ratingHigh: return lhs.rating > rhs.rating
        case .ratingLow: return lhs.rating < rhs.rating
        case .releaseYearNewest: return (lhs.releaseYear ?? 0) > (rhs.releaseYear ?? 0)
        case .releaseYearOldest: return (lhs.releaseYear ?? Int.max) < (rhs.releaseYear ?? Int.max)
        case .durationShort: return (lhs.durationMinutes ?? Int.max) < (rhs.durationMinutes ?? Int.max)
        case .durationLong: return (lhs.durationMinutes ?? 0) > (rhs.durationMinutes ?? 0)
        }
    }

    private func calculateCurrentStreak(from dates: Set<Date>, calendar: Calendar) -> Int {
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        if !dates.contains(checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        while dates.contains(checkDate) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previous
        }
        return streak
    }

    private func calculateLongestStreak(from dates: Set<Date>, calendar: Calendar) -> Int {
        let sorted = dates.sorted()
        guard !sorted.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for index in 1..<sorted.count {
            let days = calendar.dateComponents([.day], from: sorted[index - 1], to: sorted[index]).day ?? 0
            if days == 1 {
                current += 1
                longest = max(longest, current)
            } else if days > 1 {
                current = 1
            }
        }
        return longest
    }

    private func syncFranchiseMembership(for item: WatchlistModel) {
        guard let franchiseId = item.franchiseId,
              let index = franchises.firstIndex(where: { $0.id == franchiseId }) else { return }
        if !franchises[index].orderedItemIds.contains(item.id) {
            franchises[index].orderedItemIds.append(item.id)
            persistFranchises()
        }
    }

    private func removeItemFromFranchises(_ itemId: UUID) {
        for index in franchises.indices {
            franchises[index].orderedItemIds.removeAll { $0 == itemId }
        }
        persistFranchises()
    }

    private func updateAddTemplate(from item: WatchlistModel) {
        addTemplate = AddTemplate(
            type: item.type,
            genre: item.genre,
            rating: item.rating,
            tags: item.tags,
            status: item.status
        )
        storageService.saveAddTemplate(addTemplate)
    }

    private func isStale(_ item: WatchlistModel) -> Bool {
        guard let threshold = Calendar.current.date(byAdding: .day, value: -30, to: Date()) else {
            return false
        }
        return item.createdAt < threshold
    }

    private func scheduleNotifications(for item: WatchlistModel) {
        notificationService.cancelReminder(for: item.id)
        notificationService.scheduleReminder(for: item)
        notificationService.scheduleCountdown(for: item)
    }

    private func refreshStaleReminders() {
        guard staleRemindersEnabled else {
            notificationService.scheduleStaleWatchlistReminder(staleCount: 0)
            return
        }
        let staleCount = items.filter { $0.status.isActiveList && isStale($0) }.count
        notificationService.scheduleStaleWatchlistReminder(staleCount: staleCount)
    }

    private func refreshGoalNotifications() {
        let info = streakInfo()
        if goalSettings.goalNotificationsEnabled {
            notificationService.scheduleGoalReminder(
                watched: info.watchedThisMonth,
                target: info.monthlyTarget
            )
        }
        if goalSettings.streakNotificationsEnabled {
            notificationService.scheduleStreakReminder(streak: info.currentStreak)
        }
    }

    private func setupNotifications() async {
        _ = await notificationService.requestAuthorization()
        refreshStaleReminders()
        refreshGoalNotifications()
    }

    private func persistItems() {
        storageService.saveItems(items)
    }

    private func persistCollections() {
        storageService.saveCollections(collections)
    }

    private func persistFranchises() {
        storageService.saveFranchises(franchises)
    }
}
