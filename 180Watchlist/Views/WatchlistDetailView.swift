//
//  WatchlistDetailView.swift
//  180Watchlist
//

import SwiftUI

struct WatchlistDetailView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Environment(\.dismiss) private var dismiss

    let item: WatchlistModel
    @Binding var navigationPath: NavigationPath

    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var newNoteText = ""
    @State private var newNoteRating = 3
    @State private var rewatchNote = ""

    private var currentItem: WatchlistModel {
        viewModel.items.first(where: { $0.id == item.id }) ?? item
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DetailHeroHeader(item: currentItem)

                quickActions

                infoGrid

                if currentItem.type == .tvSeries {
                    EpisodeChecklistView(item: currentItem)
                }

                noteHistorySection
                statusChangeSection
                secondaryActions
            }
            .padding(AppLayout.horizontalPadding)
            .padding(.bottom, 24)
        }
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                IconToolbarButton(icon: "square.and.arrow.up") {
                    shareImage = ShareCardRenderer.renderImage(for: currentItem)
                    showShareSheet = shareImage != nil
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                IconToolbarButton(icon: "pencil") {
                    navigationPath.append(WatchlistNavigation.edit(currentItem.id))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.appDestructive)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ShareSheet(items: [shareImage])
            }
        }
        .alert("Delete Entry", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteItem(currentItem)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(currentItem.title)\"?")
        }
        .onAppear { newNoteRating = currentItem.rating }
    }

    private var quickActions: some View {
        QuickActionBar(actions: quickActionItems)
    }

    private var quickActionItems: [(icon: String, title: String, tint: Color, action: () -> Void)] {
        var items: [(String, String, Color, () -> Void)] = []

        if currentItem.status.isActiveList {
            items.append(("checkmark.circle.fill", "Watched", Color(hex: "#2dc653"), { viewModel.markAsWatched(currentItem) }))
            items.append(("play.circle.fill", "Watching", .appAccent, { viewModel.setStatus(.watching, for: currentItem) }))
            items.append(("pause.circle", "Hold", .orange, { viewModel.setStatus(.onHold, for: currentItem) }))
        }
        items.append((currentItem.isPinned ? "pin.slash" : "pin.fill", currentItem.isPinned ? "Unpin" : "Pin", .appAccent, { viewModel.togglePin(currentItem) }))
        items.append(("doc.on.doc", "Copy", Color(hex: "#3a86ff"), { navigationPath.append(WatchlistNavigation.addDuplicate(currentItem.id)) }))

        return items
    }

    private var infoGrid: some View {
        VStack(spacing: 10) {
            if !currentItem.tags.isEmpty {
                DetailInfoCard(title: "Tags", icon: "tag") {
                    TagFlowView(tags: currentItem.tags)
                }
            }

            HStack(spacing: 10) {
                if let year = currentItem.releaseYear {
                    DetailInfoCard(title: "Year", icon: "calendar") {
                        Text("\(year)").font(.title3.weight(.bold))
                    }
                }
                if let duration = currentItem.durationMinutes {
                    DetailInfoCard(title: "Duration", icon: "clock") {
                        Text("\(duration / 60)h \(duration % 60)m").font(.title3.weight(.bold))
                    }
                }
            }

            if let afterId = currentItem.watchAfterId,
               let afterTitle = viewModel.itemTitle(for: afterId) {
                DetailInfoCard(title: "Watch After", icon: "arrow.right.circle") {
                    Text(afterTitle)
                }
            }

            if let franchiseId = currentItem.franchiseId,
               let franchise = viewModel.franchises.first(where: { $0.id == franchiseId }) {
                DetailInfoCard(title: "Franchise", icon: "link") {
                    Text(franchise.name).font(.headline)
                }
            }

            if let watchedDate = currentItem.watchedDate {
                DetailInfoCard(title: "Watched", icon: "checkmark.seal") {
                    Text(dateFormatter.string(from: watchedDate))
                }
            }

            if let scheduled = currentItem.scheduledWatchDate {
                DetailInfoCard(title: "Scheduled", icon: "timer") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateFormatter.string(from: scheduled))
                        if let countdown = currentItem.countdownText {
                            MetaChip(icon: "hourglass", text: countdown)
                        }
                    }
                }
            }

            if currentItem.rewatchCount > 0 {
                DetailInfoCard(title: "Rewatches", icon: "arrow.counterclockwise") {
                    Text("\(currentItem.rewatchCount) extra view\(currentItem.rewatchCount == 1 ? "" : "s")")
                        .font(.headline)
                }
            }
        }
    }

    private var noteHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Impressions", subtitle: "Your watch notes", icon: "text.quote")

            if currentItem.noteHistory.isEmpty {
                Text("No notes yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(currentItem.noteHistory.sorted { $0.date > $1.date }) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(dateFormatter.string(from: entry.date))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appAccent)
                            Spacer()
                            StarRatingView(rating: entry.rating)
                        }
                        Text(entry.text)
                            .font(.body)
                    }
                    .padding(12)
                    .background(Color.appBackground.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }

            CustomTextEditor(text: $newNoteText, minHeight: 70)
            StarRatingView(rating: newNoteRating, isInteractive: true, onRatingChanged: { newNoteRating = $0 })
            Button("Add Note") {
                let trimmed = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                viewModel.addNoteEntry(to: currentItem, text: trimmed, rating: newNoteRating)
                newNoteText = ""
            }
            .buttonStyle(AccentButtonStyle())
            .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .appCard(tint: currentItem.genre.cardTint.opacity(0.3))
    }

    private var statusChangeSection: some View {
        VStack(spacing: 10) {
            if currentItem.status.isActiveList {
                Button("Mark as Watched") { viewModel.markAsWatched(currentItem) }
                    .buttonStyle(AccentButtonStyle())
                Button("Drop This Title") { viewModel.setStatus(.dropped, for: currentItem) }
                    .buttonStyle(GhostButtonStyle(tint: .secondary))
            }

            if currentItem.status == .watched {
                CustomTextEditor(text: $rewatchNote, minHeight: 60)
                Button("Log Rewatch") {
                    viewModel.markAsRewatched(
                        currentItem,
                        note: rewatchNote.isEmpty ? nil : rewatchNote,
                        rating: currentItem.rating
                    )
                    rewatchNote = ""
                }
                .buttonStyle(AccentButtonStyle())
            }

            if currentItem.status == .dropped {
                Button("Move Back to Watch") { viewModel.setStatus(.planned, for: currentItem) }
                    .buttonStyle(AccentButtonStyle())
            }
        }
    }

    private var secondaryActions: some View {
        Button("Share Card") {
            shareImage = ShareCardRenderer.renderImage(for: currentItem)
            showShareSheet = shareImage != nil
        }
        .buttonStyle(GhostButtonStyle())
    }
}
