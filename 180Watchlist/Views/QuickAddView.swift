//
//  QuickAddView.swift
//  180Watchlist
//

import SwiftUI

struct QuickAddView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var type: MediaType = .movie

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.appAccent)
            }

            VStack(spacing: 8) {
                Text("Quick Add")
                    .font(.title2.weight(.bold))
                Text("Add a title in seconds. Fill in details later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                FormSectionCard(title: "Title", icon: "textformat") {
                    CustomTextField(placeholder: "Enter title", text: $title)
                }

                FormSectionCard(title: "Type", icon: "film") {
                    Picker("Type", selection: $type) {
                        ForEach(MediaType.allCases) { mediaType in
                            Text(mediaType.displayName).tag(mediaType)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            Button("Save") {
                viewModel.quickAdd(title: title, type: type)
                dismiss()
            }
            .buttonStyle(AccentButtonStyle())
            .disabled(!isValid)
        }
        .padding()
        .appScreenBackground()
        .navigationTitle("Quick Add")
        .navigationBarTitleDisplayMode(.inline)
    }
}
