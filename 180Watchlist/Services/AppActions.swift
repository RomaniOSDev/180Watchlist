//
//  AppActions.swift
//  180Watchlist
//

import StoreKit
import UIKit

enum AppActions {
    static func openPolicy(_ link: AppLinks) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    static func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
