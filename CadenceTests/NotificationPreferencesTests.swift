import Foundation
import Testing
@testable import Cadence

@Suite("NotificationPreferences")
struct NotificationPreferencesTests {

    private func makeStore() -> NotificationPreferencesStore {
        let defaults = UserDefaults(suiteName: "NotificationPreferencesTests-\(UUID().uuidString)")!
        return NotificationPreferencesStore(userDefaults: defaults)
    }

    @Test func defaultsAreAudibleWithDefaultSound() {
        let preferences = NotificationPreferences.standard
        #expect(!preferences.isMuted)
        #expect(preferences.soundName == NotificationPreferences.defaultSoundName)
    }

    @Test func saveAndLoadRoundTrip() {
        let store = makeStore()
        let preferences = NotificationPreferences(isMuted: true, soundName: "Ping")
        store.save(preferences)
        #expect(store.load() == preferences)
    }

    @Test func emptyStoredSoundFallsBackToDefault() {
        let store = makeStore()
        store.save(NotificationPreferences(isMuted: false, soundName: ""))
        #expect(store.load().soundName == NotificationPreferences.defaultSoundName)
    }

    @Test func freshStoreLoadsStandardPreferences() {
        let store = makeStore()
        #expect(store.load() == NotificationPreferences.standard)
    }
}
