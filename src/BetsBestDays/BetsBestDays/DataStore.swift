import Foundation
import Observation

/// The single place views get their data from.
///
/// Content comes from BetContent and never changes at runtime. Device state
/// (read notes, redeemed coupons) is saved in UserDefaults. In v2 this is the
/// class that would sync with the other phone, so views must not read BetContent directly.
@Observable
final class DataStore {

    // MARK: - Content

    let birthDate = BetContent.birthDate
    let relationshipStart = BetContent.relationshipStart
    let birthdayMessage = BetContent.birthdayMessage
    let anniversaryMessage = BetContent.anniversaryMessage
    let welcomeTitle = BetContent.welcomeTitle
    let welcomeMessage = BetContent.welcomeMessage
    let playlistURL = BetContent.playlistURL

    /// Sorted by unlock date, earliest first.
    let notes: [SurpriseNote] = BetContent.notes.sorted { $0.unlockDate < $1.unlockDate }
    let coupons: [Coupon] = BetContent.coupons

    // MARK: - Device state

    private(set) var readNoteIDs: Set<UUID> = []
    /// Coupon ID to the moment it was redeemed.
    private(set) var redeemedCoupons: [UUID: Date] = [:]

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        readNoteIDs = load(Set<UUID>.self, forKey: Keys.readNotes) ?? []
        redeemedCoupons = load([UUID: Date].self, forKey: Keys.redeemedCoupons) ?? [:]
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
