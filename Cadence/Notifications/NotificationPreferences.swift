import Foundation

struct NotificationPreferences: Equatable {
    var isMuted: Bool
    var soundName: String

    static let defaultSoundName = "Glass"
    static let standard = NotificationPreferences(isMuted: false, soundName: defaultSoundName)
}

final class NotificationPreferencesStore {
    private static let mutedKey = "notifications.muted"
    private static let soundNameKey = "notifications.soundName"

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> NotificationPreferences {
        let storedSound = userDefaults.string(forKey: Self.soundNameKey) ?? ""
        return NotificationPreferences(
            isMuted: userDefaults.bool(forKey: Self.mutedKey),
            soundName: storedSound.isEmpty ? NotificationPreferences.defaultSoundName : storedSound
        )
    }

    func save(_ preferences: NotificationPreferences) {
        userDefaults.set(preferences.isMuted, forKey: Self.mutedKey)
        userDefaults.set(preferences.soundName, forKey: Self.soundNameKey)
    }
}
