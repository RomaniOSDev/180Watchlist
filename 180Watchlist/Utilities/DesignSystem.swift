//
//  DesignSystem.swift
//  180Watchlist
//

import SwiftUI

enum AppLayout {
    static let cardRadius: CGFloat = 16
    static let smallRadius: CGFloat = 10
    static let horizontalPadding: CGFloat = 16
    static let cardPadding: CGFloat = 14
}

/// Performance rule: `.flat` for scrolling lists (no shadow),
/// `.raised` / `.floating` for static screens (single shadow + compositingGroup).
enum SurfaceElevation {
    case flat
    case raised
    case floating
}

extension WatchStatus {
    var accentColor: Color {
        switch self {
        case .planned: return Color(hex: "#5c7cfa")
        case .watching: return Color(hex: "#ffbe00")
        case .onHold: return Color(hex: "#f77f00")
        case .watched: return Color(hex: "#2dc653")
        case .dropped: return Color(hex: "#bd0e1b")
        }
    }
}

// MARK: - Optimized surface renderer (shared shape, minimal layers)

struct CardSurfaceBackground: View {
    var tint: Color = .clear
    var elevation: SurfaceElevation = .raised
    var cornerRadius: CGFloat = AppLayout.cardRadius

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    var body: some View {
        ZStack {
            shape.fill(Color.appCard)

            shape.fill(
                LinearGradient(
                    colors: [
                        tint.opacity(elevation == .flat ? 0.16 : 0.24),
                        tint.opacity(0.04),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Fake depth highlight — cheaper than a second shadow
            shape.fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.10), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )
            )

            shape.strokeBorder(
                LinearGradient(
                    colors: [
                        tint.opacity(0.55),
                        tint.opacity(0.12),
                        Color.white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
        }
    }
}

struct SurfaceElevationModifier: ViewModifier {
    var tint: Color
    var elevation: SurfaceElevation
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                CardSurfaceBackground(
                    tint: tint,
                    elevation: elevation,
                    cornerRadius: cornerRadius
                )
            }
            .modifier(ShadowModifier(elevation: elevation, tint: tint))
    }
}

private struct ShadowModifier: ViewModifier {
    let elevation: SurfaceElevation
    let tint: Color

    func body(content: Content) -> some View {
        switch elevation {
        case .flat:
            content
        case .raised:
            content
                .compositingGroup()
                .shadow(color: .black.opacity(0.20), radius: 6, x: 0, y: 3)
        case .floating:
            content
                .compositingGroup()
                .shadow(color: .black.opacity(0.30), radius: 12, x: 0, y: 6)
        }
    }
}

// MARK: - Background

struct CinematicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color(hex: "#031530"),
                    Color.appBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.appAccent.opacity(0.10), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 380
            )

            RadialGradient(
                colors: [Color(hex: "#3a86ff").opacity(0.07), .clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }
}

struct AppScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(CinematicBackground())
    }
}

// MARK: - Legacy card wrapper

struct AppCardStyle: ViewModifier {
    var tint: Color = .clear
    var elevation: SurfaceElevation = .raised

    func body(content: Content) -> some View {
        content
            .padding(AppLayout.cardPadding)
            .surface(elevation: elevation, tint: tint)
    }
}

struct AppSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 30, height: 30)
                    .background(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.22), Color.appAccent.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.25), lineWidth: 1)
                    }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Buttons

struct AccentButtonStyle: ButtonStyle {
    var fullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.appBackground)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, 12)
            .padding(.horizontal, fullWidth ? 0 : 16)
            .background(
                LinearGradient(
                    colors: [Color.appAccent, Color(hex: "#e6a800")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            }
            .compositingGroup()
            .shadow(color: Color.appAccent.opacity(configuration.isPressed ? 0.1 : 0.28), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct GhostButtonStyle: ButtonStyle {
    var tint: Color = .appAccent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [tint.opacity(0.16), tint.opacity(0.06)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous)
                    .stroke(tint.opacity(0.35), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct DestructiveOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.appDestructive)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.appDestructive.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppLayout.smallRadius, style: .continuous)
                    .stroke(Color.appDestructive.opacity(0.4), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct IconToolbarButton: View {
    let icon: String
    var filled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 36, height: 36)
                .background(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(filled ? 0.26 : 0.14),
                            Color.appAccent.opacity(filled ? 0.12 : 0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.appAccent.opacity(0.28), lineWidth: 1))
        }
    }
}

// MARK: - View extensions

extension View {
    func appScreenBackground() -> some View {
        modifier(AppScreenBackground())
    }

    func surface(
        elevation: SurfaceElevation = .raised,
        tint: Color = .clear,
        cornerRadius: CGFloat = AppLayout.cardRadius
    ) -> some View {
        modifier(SurfaceElevationModifier(tint: tint, elevation: elevation, cornerRadius: cornerRadius))
    }

    /// Static cards on scroll-free screens.
    func appCard(tint: Color = .clear, elevation: SurfaceElevation = .raised) -> some View {
        modifier(AppCardStyle(tint: tint, elevation: elevation))
    }

    /// Scrolling list cells — no shadow, gradient border only.
    func listCard(tint: Color = .clear) -> some View {
        modifier(AppCardStyle(tint: tint, elevation: .flat))
    }
}
