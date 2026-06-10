//
//  AppTheme.swift
//  180Watchlist
//

import SwiftUI

extension Color {
    static let appBackground = Color("BackgroundColor")
    static let appCard = Color("CardColor")
    static let appAccent = Color("AccentYellow")
    static let appDestructive = Color("DestructiveRed")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0
            g = 0
            b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

extension Genre {
    var cardTint: Color {
        switch self {
        case .action: return Color(hex: "#c1121f")
        case .comedy: return Color(hex: "#f77f00")
        case .drama: return Color(hex: "#4361ee")
        case .horror: return Color(hex: "#6a040f")
        case .romance: return Color(hex: "#ff006e")
        case .sciFi: return Color(hex: "#3a86ff")
        case .documentary: return Color(hex: "#588157")
        case .animation: return Color(hex: "#9b5de5")
        case .thriller: return Color(hex: "#370617")
        case .fantasy: return Color(hex: "#0077b6")
        }
    }
}

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.appScreenBackground()
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}
