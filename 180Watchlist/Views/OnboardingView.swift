//
//  OnboardingView.swift
//  180Watchlist
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0

    private let pages = OnboardingPage.all

    var body: some View {
        ZStack {
            CinematicBackground()

            VStack(spacing: 0) {
                header

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: currentPage)

                footer
            }
        }
        .preferredColorScheme(.dark)
        .tint(Color.appAccent)
    }

    private var header: some View {
        HStack {
            Spacer()
            if currentPage < pages.count - 1 {
                Button("Skip", action: onComplete)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
        .padding(.top, 8)
        .frame(height: 44)
    }

    private var footer: some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                ForEach(pages) { page in
                    Capsule()
                        .fill(
                            currentPage == page.id
                                ? Color.appAccent
                                : Color.white.opacity(0.18)
                        )
                        .frame(width: currentPage == page.id ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentPage)
                }
            }

            Button(action: advance) {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
            }
            .buttonStyle(AccentButtonStyle())
            .padding(.horizontal, AppLayout.horizontalPadding)
        }
        .padding(.bottom, 32)
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            onComplete()
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [page.tint.opacity(0.35), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.tint.opacity(0.28), page.tint.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .overlay {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [page.tint.opacity(0.55), page.tint.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }

                Image(systemName: page.icon)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [page.tint, page.tint.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 28)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
