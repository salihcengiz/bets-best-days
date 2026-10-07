import Foundation

// Template for the app's personal content.
//
// The real file is git-ignored. Create it from this template:
//   cp src/BetsBestDays/Config/BetContent.example.swift \
//      src/BetsBestDays/BetsBestDays/Shared/BetContent.swift
// then replace every value marked "TODO: fill in".
//
// This template lives outside the app's synced folder, so Xcode does not compile it.
// Keep its structure identical to the real file.

/// All personal content and settings in one place.
/// Shared by the app and the widget (target membership), so it uses Foundation only.
nonisolated enum BetContent {

    // MARK: - People and dates

    /// First name shown in messages.
    static let name = "Name" // TODO: fill in

    /// Birth date. Month and day drive the yearly countdown; the year is informational.
    static let birthDate: Date = .day(2000, 1, 1) // TODO: fill in

    /// The day the relationship started. Anniversaries repeat on this month and day.
    static let relationshipStart: Date = .day(2024, 1, 1) // TODO: fill in

    /// Until this moment the whole app shows only the lock screen with a countdown.
    /// Set it to a past date to disable the lock.
    static let appUnlockDate: Date = .day(2000, 1, 1) // TODO: fill in

    // MARK: - Messages

    /// Shown on the full-screen card for the whole birthday.
    static let birthdayMessage = "Happy birthday!" // TODO: fill in

    /// Shown on the full-screen card for the whole anniversary day.
    static let anniversaryMessage = "Happy anniversary!" // TODO: fill in

    /// First-launch welcome screen, which also asks for notification permission.
    static let welcomeTitle = "Welcome" // TODO: fill in
    static let welcomeMessage = "A short, personal welcome message." // TODO: fill in

    // MARK: - Notifications

    /// Local time for day-of reminders and note unlock notifications.
    static let notificationHour = 9
    static let notificationMinute = 0

    // MARK: - Playlist

    /// Opens in the Spotify app if installed, otherwise in the browser.
    static let playlistURL = URL(string: "https://open.spotify.com/playlist/PLAYLIST_ID")! // TODO: fill in

    // MARK: - Surprise notes
    // Each note needs its own fixed UUID (run `uuidgen` in Terminal).
    // Never change an existing UUID: the read state is stored against it.

    static let notes: [SurpriseNote] = [
        SurpriseNote(
            id: UUID(uuidString: "05D98D35-DB48-4A8C-88D2-060509A46D42")!,
            unlockDate: .day(2026, 1, 1), // TODO: fill in
            title: "First note", // TODO: fill in
            body: "Note text." // TODO: fill in
        ),
        SurpriseNote(
            id: UUID(uuidString: "3F744BE7-9DA8-4D78-A022-A657D1F60B7D")!,
            unlockDate: .day(2026, 12, 31), // TODO: fill in
            title: "Second note", // TODO: fill in
            body: "Note text." // TODO: fill in
        ),
        SurpriseNote(
            id: UUID(uuidString: "55117D09-C693-473A-90B9-FCFEEEA045F8")!,
            unlockDate: .day(2027, 6, 1), // TODO: fill in
            title: "Third note", // TODO: fill in
            body: "Note text." // TODO: fill in
        ),
    ]

    // MARK: - Coupons
    // Same UUID rules as the notes.

    static let coupons: [Coupon] = [
        Coupon(
            id: UUID(uuidString: "19C7C7B7-1242-4449-90D2-6850C4BA39D3")!,
            title: "A dinner out", // TODO: fill in
            detail: "Any place, any night." // TODO: fill in
        ),
        Coupon(
            id: UUID(uuidString: "C10C6E8F-C6A7-4BFC-8E3D-6FF20D796F51")!,
            title: "Movie night, your pick", // TODO: fill in
            detail: "No complaints about the choice." // TODO: fill in
        ),
        Coupon(
            id: UUID(uuidString: "243273D3-27A3-4B16-8726-D1E22CF81E21")!,
            title: "Win one argument", // TODO: fill in
            detail: "Redeem at the right moment." // TODO: fill in
        ),
    ]
}
