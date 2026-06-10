//
//  WatchlistFormView.swift
//  180Watchlist
//

import PhotosUI
import SwiftUI

enum WatchlistFormMode {
    case add
    case edit
    case duplicate
    case template
}

struct WatchlistFormView: View {
    @EnvironmentObject private var viewModel: WatchlistViewModel
    @Environment(\.dismiss) private var dismiss

    let mode: WatchlistFormMode
    let editingItem: WatchlistModel?

    @State private var title: String
    @State private var type: MediaType
    @State private var genre: Genre
    @State private var status: WatchStatus
    @State private var rating: Int
    @State private var watchedDate: Date
    @State private var isPinned: Bool
    @State private var tags: [String]
    @State private var customTag: String
    @State private var season: String
    @State private var episode: String
    @State private var totalEpisodes: String
    @State private var releaseYear: String
    @State private var durationMinutes: String
    @State private var posterURL: String
    @State private var posterImageData: Data?
    @State private var selectedCollectionIds: Set<UUID>
    @State private var selectedFranchiseId: UUID?
    @State private var watchAfterId: UUID?
    @State private var newNote: String
    @State private var hasReminder: Bool
    @State private var reminderDate: Date
    @State private var hasCountdown: Bool
    @State private var scheduledWatchDate: Date
    @State private var selectedPhoto: PhotosPickerItem?

    private var isEditing: Bool { mode == .edit }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(editingItem: WatchlistModel? = nil, mode: WatchlistFormMode = .add, template: AddTemplate? = nil) {
        self.editingItem = editingItem
        self.mode = mode

        let source = editingItem
        let templateValues = template ?? .default

        _title = State(initialValue: {
            if mode == .duplicate, let source { return "\(source.title) (Copy)" }
            return source?.title ?? ""
        }())
        _type = State(initialValue: source?.type ?? templateValues.type)
        _genre = State(initialValue: source?.genre ?? templateValues.genre)
        _status = State(initialValue: source?.status ?? templateValues.status)
        _rating = State(initialValue: source?.rating ?? templateValues.rating)
        _watchedDate = State(initialValue: source?.watchedDate ?? Date())
        _isPinned = State(initialValue: source?.isPinned ?? false)
        _tags = State(initialValue: source?.tags ?? templateValues.tags)
        _customTag = State(initialValue: "")
        _season = State(initialValue: source?.season.map(String.init) ?? "")
        _episode = State(initialValue: source?.episode.map(String.init) ?? "")
        _totalEpisodes = State(initialValue: source?.totalEpisodesInSeason.map(String.init) ?? "")
        _releaseYear = State(initialValue: source?.releaseYear.map(String.init) ?? "")
        _durationMinutes = State(initialValue: source?.durationMinutes.map(String.init) ?? "")
        _posterURL = State(initialValue: source?.posterURL ?? "")
        _posterImageData = State(initialValue: source?.posterImageData)
        _selectedCollectionIds = State(initialValue: Set(source?.collectionIds ?? []))
        _selectedFranchiseId = State(initialValue: source?.franchiseId)
        _watchAfterId = State(initialValue: source?.watchAfterId)
        _newNote = State(initialValue: "")
        _hasReminder = State(initialValue: source?.reminderDate != nil)
        _reminderDate = State(initialValue: source?.reminderDate ?? Date().addingTimeInterval(86400))
        _hasCountdown = State(initialValue: source?.scheduledWatchDate != nil)
        _scheduledWatchDate = State(initialValue: source?.scheduledWatchDate ?? Date().addingTimeInterval(3600))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                posterSection

                FormSectionCard(title: "Basics", icon: "film") {
                    VStack(spacing: 12) {
                        CustomTextField(placeholder: "Enter title", text: $title)
                        Picker("Type", selection: $type) {
                            ForEach(MediaType.allCases) { mediaType in
                                Text(mediaType.displayName).tag(mediaType)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                FormSectionCard(title: "Details", icon: "info.circle") {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            CustomTextField(placeholder: "Year", text: $releaseYear, keyboardType: .numberPad)
                            CustomTextField(placeholder: "Duration (min)", text: $durationMinutes, keyboardType: .numberPad)
                        }
                        Picker("Genre", selection: $genre) {
                            ForEach(Genre.allCases) { genreOption in
                                Text(genreOption.rawValue).tag(genreOption)
                            }
                        }
                        .pickerStyle(.menu).tint(Color.appAccent)
                        Picker("Status", selection: $status) {
                            ForEach(WatchStatus.allCases) { statusOption in
                                Text(statusOption.rawValue).tag(statusOption)
                            }
                        }
                        .pickerStyle(.menu).tint(Color.appAccent)
                        .onChange(of: status) { if $0 == .watched { watchedDate = Date() } }
                        StarRatingView(rating: rating, isInteractive: true, onRatingChanged: { rating = $0 })
                    }
                }

                if type == .tvSeries {
                    FormSectionCard(title: "TV Progress", icon: "tv") {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                CustomTextField(placeholder: "Season", text: $season, keyboardType: .numberPad)
                                CustomTextField(placeholder: "Episode", text: $episode, keyboardType: .numberPad)
                            }
                            CustomTextField(placeholder: "Episodes in season", text: $totalEpisodes, keyboardType: .numberPad)
                        }
                    }
                }

                FormSectionCard(title: "Tags", icon: "tag") { tagsSectionContent }
                FormSectionCard(title: "Collections", icon: "folder") { collectionsSectionContent }
                FormSectionCard(title: "Franchise", icon: "link") { franchiseSectionContent }

                FormSectionCard(title: isEditing ? "Add Note" : "Note", icon: "text.quote") {
                    CustomTextEditor(text: $newNote)
                }

                FormSectionCard(title: "Options", icon: "slider.horizontal.3") {
                    VStack(spacing: 12) {
                        Toggle("Pin to Top", isOn: $isPinned).tint(Color.appAccent)
                        Toggle("Set Reminder", isOn: $hasReminder).tint(Color.appAccent)
                        if hasReminder {
                            DatePicker("Remind Me", selection: $reminderDate).tint(Color.appAccent)
                        }
                        Toggle("Schedule Watch Time", isOn: $hasCountdown).tint(Color.appAccent)
                        if hasCountdown {
                            DatePicker("Watch At", selection: $scheduledWatchDate).tint(Color.appAccent)
                        }
                        if status == .watched {
                            DatePicker("Watched Date", selection: $watchedDate, displayedComponents: .date).tint(Color.appAccent)
                        }
                    }
                }

                HStack(spacing: 12) {
                    Button("Cancel") { dismiss() }
                        .buttonStyle(DestructiveOutlineButtonStyle())
                    Button("Save") { save() }
                        .buttonStyle(AccentButtonStyle())
                        .disabled(!isValid)
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .appScreenBackground()
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhoto) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    posterImageData = data
                }
            }
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .add: return "Add Entry"
        case .edit: return "Edit Entry"
        case .duplicate: return "Duplicate Entry"
        case .template: return "Add Like Previous"
        }
    }

    private var posterSection: some View {
        FormSectionCard(title: "Poster", icon: "photo") {
            HStack(spacing: 16) {
                PosterImageView(imageData: posterImageData, imageURL: posterURL.isEmpty ? nil : posterURL, height: 120)
                VStack(alignment: .leading, spacing: 8) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .font(.subheadline)
                    }
                    .buttonStyle(GhostButtonStyle())
                    CustomTextField(placeholder: "Image URL", text: $posterURL)
                }
            }
        }
    }

    private var tagsSectionContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(spacing: 8) {
                ForEach(PredefinedTag.allCases) { predefined in
                    let isSelected = tags.contains(predefined.rawValue)
                    Button(predefined.rawValue) { toggleTag(predefined.rawValue) }
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isSelected ? Color.appAccent : Color.appCard)
                        .foregroundStyle(isSelected ? Color.appBackground : Color.appAccent)
                        .clipShape(Capsule())
                }
            }

            HStack {
                CustomTextField(placeholder: "Custom tag", text: $customTag)
                Button("Add") { addCustomTag() }
                    .buttonStyle(GhostButtonStyle())
                    .disabled(customTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if !tags.isEmpty { TagFlowView(tags: tags) }
        }
    }

    private var collectionsSectionContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.collections.isEmpty {
                Text("No collections yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.collections) { collection in
                    Toggle(collection.name, isOn: Binding(
                        get: { selectedCollectionIds.contains(collection.id) },
                        set: { isOn in
                            if isOn { selectedCollectionIds.insert(collection.id) }
                            else { selectedCollectionIds.remove(collection.id) }
                        }
                    ))
                    .tint(Color.appAccent)
                }
            }
        }
    }

    private var franchiseSectionContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Franchise", selection: franchiseBinding) {
                Text("None").tag(UUID?.none)
                ForEach(viewModel.franchises) { franchise in
                    Text(franchise.name).tag(UUID?.some(franchise.id))
                }
            }
            .pickerStyle(.menu)
            .tint(Color.appAccent)

            if selectedFranchiseId != nil {
                Picker("Watch After", selection: watchAfterBinding) {
                    Text("No prerequisite").tag(UUID?.none)
                    ForEach(viewModel.items.filter { $0.id != editingItem?.id }) { item in
                        Text(item.title).tag(UUID?.some(item.id))
                    }
                }
                .pickerStyle(.menu)
                .tint(Color.appAccent)
            }
        }
    }

    private var franchiseBinding: Binding<UUID?> {
        Binding(get: { selectedFranchiseId }, set: { selectedFranchiseId = $0 })
    }

    private var watchAfterBinding: Binding<UUID?> {
        Binding(get: { watchAfterId }, set: { watchAfterId = $0 })
    }

    private func toggleTag(_ tag: String) {
        if tags.contains(tag) { tags.removeAll { $0 == tag } }
        else { tags.append(tag) }
    }

    private func addCustomTag() {
        let trimmed = customTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        customTag = ""
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        var noteHistory = editingItem?.noteHistory ?? []
        let trimmedNote = newNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNote.isEmpty {
            noteHistory.insert(WatchNoteEntry(text: trimmedNote, rating: rating), at: 0)
        }

        let item = WatchlistModel(
            id: mode == .edit ? (editingItem?.id ?? UUID()) : UUID(),
            title: trimmedTitle,
            type: type,
            genre: genre,
            status: status,
            rating: rating,
            watchedDate: status == .watched ? watchedDate : nil,
            createdAt: editingItem?.createdAt ?? Date(),
            isPinned: isPinned,
            tags: tags,
            season: type == .tvSeries ? Int(season) : nil,
            episode: type == .tvSeries ? Int(episode) : nil,
            posterImageData: posterImageData,
            posterURL: posterURL.isEmpty ? nil : posterURL,
            collectionIds: Array(selectedCollectionIds),
            noteHistory: noteHistory,
            reminderDate: hasReminder ? reminderDate : nil,
            rewatchCount: editingItem?.rewatchCount ?? 0,
            releaseYear: Int(releaseYear),
            durationMinutes: Int(durationMinutes),
            scheduledWatchDate: hasCountdown ? scheduledWatchDate : nil,
            totalEpisodesInSeason: type == .tvSeries ? Int(totalEpisodes) : nil,
            watchedEpisodeNumbers: editingItem?.watchedEpisodeNumbers ?? [],
            franchiseId: selectedFranchiseId,
            franchiseOrder: editingItem?.franchiseOrder,
            watchAfterId: watchAfterId
        )

        switch mode {
        case .edit: viewModel.updateItem(item)
        case .add, .duplicate, .template: viewModel.addItem(item)
        }
        dismiss()
    }
}
