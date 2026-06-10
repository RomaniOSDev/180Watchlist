//
//  NotificationService.swift
//  180Watchlist
//

import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestAuthorization() async -> Bool
    func scheduleReminder(for item: WatchlistModel)
    func scheduleCountdown(for item: WatchlistModel)
    func cancelReminder(for itemId: UUID)
    func scheduleStaleWatchlistReminder(staleCount: Int)
    func scheduleGoalReminder(watched: Int, target: Int)
    func scheduleStreakReminder(streak: Int)
}

final class NotificationService: NotificationServiceProtocol {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleReminder(for item: WatchlistModel) {
        cancelReminder(for: item.id)
        guard let reminderDate = item.reminderDate, reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to Watch"
        content.body = "Don't forget to watch \"\(item.title)\""
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: item.id),
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func scheduleCountdown(for item: WatchlistModel) {
        guard let scheduledDate = item.scheduledWatchDate, scheduledDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Scheduled Watch Time"
        content.body = "It's time for \"\(item.title)\""
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: scheduledDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: countdownIdentifier(for: item.id),
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func cancelReminder(for itemId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [
            reminderIdentifier(for: itemId),
            countdownIdentifier(for: itemId)
        ])
    }

    func scheduleStaleWatchlistReminder(staleCount: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["stale_watchlist_reminder"])
        guard staleCount > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Still on Your List"
        content.body = "You have \(staleCount) item\(staleCount == 1 ? "" : "s") waiting for more than 30 days."
        content.sound = .default

        var components = DateComponents()
        components.hour = 10
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "stale_watchlist_reminder",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func scheduleGoalReminder(watched: Int, target: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["goal_reminder"])
        guard target > 0, watched >= target - 1, watched < target else { return }

        let content = UNMutableNotificationContent()
        content.title = "Almost There!"
        content.body = "You've watched \(watched) of \(target) titles this month. One more to hit your goal!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "goal_reminder", content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleStreakReminder(streak: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["streak_reminder"])
        guard streak >= 3 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Streak Going Strong!"
        content.body = "You're on a \(streak)-day watching streak. Keep it up!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)
        center.add(request)
    }

    private func reminderIdentifier(for itemId: UUID) -> String {
        "watchlist_reminder_\(itemId.uuidString)"
    }

    private func countdownIdentifier(for itemId: UUID) -> String {
        "watchlist_countdown_\(itemId.uuidString)"
    }
}
