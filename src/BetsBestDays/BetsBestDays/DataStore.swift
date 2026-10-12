import Foundation
import Observation
import WidgetKit

/// The single place views get their data from.
///
/// Content comes from BetContent and never changes at runtime. Device state
/// (read notes, redeemed coupons) is saved in UserDefaults. In v2 this is the
/// class that would sync with the other phone, so views must not read BetContent directly.
@Observable
final class DataStore {

    // MARK: - Content

    let birthDate = BetContent.birthDate
    let birthdayMessage = BetContent.birthdayMessage
    let anniversaryMessage = BetContent.anniversaryMessage
    let welcomeTitle = BetContent.welcomeTitle
    let welcomeMessage = BetContent.welcomeMessage
    let playlistURL = BetContent.playlistURL
    /// The app shows only the lock screen until this moment.
    let appUnlockDate = BetContent.appUnlockDate

    /// Sorted by unlock date, earliest first.
    let notes: [SurpriseNote] = BetContent.notes.sorted { $0.unlockDate < $1.unlockDate }
    let coupons: [Coupon] = BetContent.coupons

    // MARK: - Device state

    private(set) var readNoteIDs: Set<UUID> = []
    /// Coupon ID to the moment it was redeemed.
    private(set) var redeemedCoupons: [UUID: Date] = [:]
    /// Whether the welcome screen has been shown once after the app unlocked.
    private(set) var hasSeenWelcome = false
    /// Anniversary day picked once with the wheel (1...9), or nil before the pick.
    /// Stored in the App Group defaults so the widget can read it too.
    private(set) var pickedAnniversaryDay: Int?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let sharedDefaults: UserDefaults

    init(defaults: UserDefaults = .standard, sharedDefaults: UserDefaults = DateLogic.sharedDefaults) {
        self.defaults = defaults
        self.sharedDefaults = sharedDefaults
        readNoteIDs = load(Set<UUID>.self, forKey: Keys.readNotes) ?? []
        redeemedCoupons = load([UUID: Date].self, forKey: Keys.redeemedCoupons) ?? [:]
        hasSeenWelcome = defaults.bool(forKey: Keys.hasSeenWelcome)
        pickedAnniversaryDay = DateLogic.pickedAnniversaryDay(in: sharedDefaults)
    }

    // MARK: - Anniversary day

    /// Effective relationship start: the picked day of the start month, or the content date.
    var relationshipStart: Date {
        DateLogic.relationshipStart(pickedDay: pickedAnniversaryDay)
    }

    var anniversaryDayChoices: ClosedRange<Int> { BetContent.anniversaryDayChoices }

    var isAnniversaryDayPicked: Bool { pickedAnniversaryDay != nil }

    /// Saves the wheel's result. Only the first pick counts; it can never be changed.
    func pickAnniversaryDay(_ day: Int) {
        guard pickedAnniversaryDay == nil, anniversaryDayChoices.contains(day) else { return }
        sharedDefaults.set(day, forKey: DateLogic.pickedAnniversaryDayKey)
        pickedAnniversaryDay = day
        // Widgets recompute their timelines with the new date.
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - App lock and welcome

    func isAppLocked(now: Date) -> Bool {
        now < appUnlockDate
    }

    func markWelcomeSeen() {
        guard !hasSeenWelcome else { return }
        hasSeenWelcome = true
        defaults.set(true, forKey: Keys.hasSeenWelcome)
    }

    // MARK: - Notes

    func isUnlocked(_ note: SurpriseNote, now: Date) -> Bool {
        DateLogic.isUnlocked(note.unlockDate, now: now)
    }

    func isRead(_ note: SurpriseNote) -> Bool {
        readNoteIDs.contains(note.id)
    }

    func markRead(_ note: SurpriseNote) {
        guard !isRead(note) else { return }
        readNoteIDs.insert(note.id)
        save(readNoteIDs, forKey: Keys.readNotes)
    }

    /// Notes that are open but not read yet. Drives the orange dot in the list.
    func unreadUnlockedCount(now: Date) -> Int {
        notes.filter { isUnlocked($0, now: now) && !isRead($0) }.count
    }

    // MARK: - Coupons

    /// When the coupon was redeemed, or nil if it is still available.
    func redeemedDate(of coupon: Coupon) -> Date? {
        redeemedCoupons[coupon.id]
    }

    func redeem(_ coupon: Coupon, at date: Date = .now) {
        guard redeemedDate(of: coupon) == nil else { return }
        redeemedCoupons[coupon.id] = date
        save(redeemedCoupons, forKey: Keys.redeemedCoupons)
    }

    // MARK: - Persistence

    private enum Keys {
        static let readNotes = "readNoteIDs"
        static let redeemedCoupons = "redeemedCoupons"
        static let hasSeenWelcome = "hasSeenWelcome"
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
