//
//  AppLinks.swift
//  180Watchlist
//

import Foundation

enum AppLinks: String {
    case privacyPolicy = "https://www.termsfeed.com/live/6d790648-b554-460f-a5f5-ae917cb795f0"
    case termsOfUse = "https://www.termsfeed.com/live/d7e174a9-6eb3-41b1-9508-a3424fca9289"

    var url: URL? {
        URL(string: rawValue)
    }
}
