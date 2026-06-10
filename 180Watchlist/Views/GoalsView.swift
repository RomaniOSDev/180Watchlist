//
//  GoalsView.swift
//  180Watchlist
//

import SwiftUI

struct GoalsView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @State private var monthlyTarget: Int = 4

    private var streakInfo: WatchStreakInfo { viewModel.streakInfo() }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    AppSectionHeader(title: "Monthly Goal", subtitle: "Keep the momentum", icon: "target")

                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(streakInfo.watchedThisMonth)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appAccent)
                        Text("/ \(monthlyTarget)")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08))
                            Capsule()
                                .fill(LinearGradient(colors: [Color.appAccent, Color.appAccent.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * streakInfo.monthlyProgress)
                        }
                    }
                    .frame(height: 10)

                    Stepper("Monthly target: \(monthlyTarget)", value: $monthlyTarget, in: 1...50)
                        .onChange(of: monthlyTarget) { newValue in
                            var settings = viewModel.goalSettings
                            settings.monthlyTarget = newValue
                            viewModel.updateGoalSettings(settings)
                        }
                }
                .appCard(tint: Color.appAccent.opacity(0.25), elevation: .floating)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatsCardView(title: "Current Streak", value: "\(streakInfo.currentStreak)d", icon: "flame.fill", tint: Color(hex: "#f77f00"))
                    StatsCardView(title: "Best Streak", value: "\(streakInfo.longestStreak)d", icon: "trophy.fill", tint: Color.appAccent)
                }

                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "Notifications", icon: "bell.badge")
                    Toggle("Goal progress alerts", isOn: goalNotificationBinding).tint(Color.appAccent)
                    Toggle("Streak reminders", isOn: streakNotificationBinding).tint(Color.appAccent)
                }
                .appCard()
            }
            .padding()
        }
        .appScreenBackground()
        .navigationTitle("Goals & Streak")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { monthlyTarget = viewModel.goalSettings.monthlyTarget }
    }

    private var goalNotificationBinding: Binding<Bool> {
        Binding(
            get: { viewModel.goalSettings.goalNotificationsEnabled },
            set: { v in
                var s = viewModel.goalSettings
                s.goalNotificationsEnabled = v
                viewModel.updateGoalSettings(s)
            }
        )
    }

    private var streakNotificationBinding: Binding<Bool> {
        Binding(
            get: { viewModel.goalSettings.streakNotificationsEnabled },
            set: { v in
                var s = viewModel.goalSettings
                s.streakNotificationsEnabled = v
                viewModel.updateGoalSettings(s)
            }
        )
    }
}
