//
//  OnboardingStorageService.swift
//  180Watchlist
//

import Foundation

final class OnboardingStorageService {
    static let shared = OnboardingStorageService()

    private let key = "has_completed_onboarding"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedOnboarding: Bool {
        userDefaults.bool(forKey: key)
    }

    func markCompleted() {
        userDefaults.set(true, forKey: key)
    }
}
