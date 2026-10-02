import Foundation
import Testing
@testable import Cadence

@MainActor
final class PhaseNotifierSpy: PhaseNotifying {
    private(set) var authorizationRequests = 0
    private(set) var notifications: [(phase: TimerPhase, sound: String?)] = []

    func requestAuthorization() {
        authorizationRequests += 1
    }

    func notify(_ phase: TimerPhase, sound: String?) {
        notifications.append((phase, sound))
    }
}

@MainActor
@Suite("MenuBarModel")
struct MenuBarModelTests {

    final class Clock {
        var now: Date
        init(_ now: Date) { self.now = now }
    }

    let t0 = Date(timeIntervalSince1970: 2_000_000)
    private let ephemeral = EphemeralDefaults()

    private func makeStore() -> NotificationPreferencesStore {
        NotificationPreferencesStore(userDefaults: ephemeral.defaults)
    }

    private func makeModel(
        store: NotificationPreferencesStore? = nil,
        availableSounds: [String] = ["Glass", "Ping"]
    ) -> (MenuBarModel, Clock, PhaseNotifierSpy) {
        let clock = Clock(t0)
        let spy = PhaseNotifierSpy()
        let model = MenuBarModel(
            engine: TimerEngine(),
            now: { clock.now },
            notifier: spy,
            availableSounds: availableSounds,
            preferencesStore: store ?? makeStore()
        )
        return (model, clock, spy)
    }

    @Test func initialStateIsMirrored() {
        let (model, _, _) = makeModel()
        #expect(model.isIdle)
        #expect(!model.isRunning)
        #expect(!model.isPaused)
        #expect(model.phase == .idle)
        #expect(model.remaining == 0)
    }

    @Test func startMirrorsRunningState() {
        let (model, _, _) = makeModel()
        model.start()
        #expect(model.isRunning)
        #expect(model.phase == .focus)
        #expect(model.remaining == 25 * 60)
    }

    @Test func pauseAndResumeMirrorState() {
        let (model, clock, _) = makeModel()
        model.start()
        clock.now = t0.addingTimeInterval(600)
        model.pause()
        #expect(model.isPaused)
        #expect(model.remaining == 900)
        clock.now = t0.addingTimeInterval(700)
        model.resume()
        #expect(model.isRunning)
        #expect(model.remaining == 900)
    }

    @Test func resetReturnsToIdle() {
        let (model, _, _) = makeModel()
        model.start()
        model.reset()
        #expect(model.isIdle)
        #expect(model.remaining == 0)
    }

    @Test func tickCompletesBlockAndMirrorsNextPhase() {
        let (model, clock, _) = makeModel()
        model.start()
        clock.now = t0.addingTimeInterval(25 * 60)
        model.tick()
        #expect(model.phase == .shortBreak)
        #expect(model.remaining == 5 * 60)
    }

    @Test func menuBarLabelShowsReadyWhenIdle() {
        let (model, _, _) = makeModel()
        #expect(model.menuBarLabel == "Ready")
    }

    @Test func menuBarLabelShowsCountdownWhenRunning() {
        let (model, _, _) = makeModel()
        model.start()
        #expect(model.menuBarLabel == "25:00")
    }

    @Test func initRequestsNotificationAuthorization() {
        let (_, _, spy) = makeModel()
        #expect(spy.authorizationRequests == 1)
    }

    @Test func blockCompletionNotifiesWithCompletedPhaseAndSound() {
        let (model, clock, spy) = makeModel()
        model.start()
        clock.now = t0.addingTimeInterval(25 * 60)
        model.tick()
        #expect(spy.notifications.count == 1)
        #expect(spy.notifications.first?.phase == .focus)
        #expect(spy.notifications.first?.sound == "Glass")
    }

    @Test func mutedModelNotifiesWithoutSound() {
        let (model, clock, spy) = makeModel()
        model.setMuted(true)
        model.start()
        clock.now = t0.addingTimeInterval(25 * 60)
        model.tick()
        #expect(spy.notifications.count == 1)
        #expect(spy.notifications.first?.sound == nil)
    }

    @Test func manualControlsDoNotNotify() {
        let (model, clock, spy) = makeModel()
        model.start()
        clock.now = t0.addingTimeInterval(600)
        model.pause()
        model.resume()
        model.reset()
        #expect(spy.notifications.isEmpty)
    }

    @Test func selectSoundIgnoresUnknownNames() {
        let (model, _, _) = makeModel()
        model.selectSound("Nope")
        #expect(model.soundName == "Glass")
    }

    @Test func selectSoundPersistsSelection() {
        let store = makeStore()
        let (model, _, _) = makeModel(store: store)
        model.selectSound("Ping")
        #expect(model.soundName == "Ping")
        #expect(store.load().soundName == "Ping")
    }

    @Test func mutePersists() {
        let store = makeStore()
        let (model, _, _) = makeModel(store: store)
        model.setMuted(true)
        #expect(store.load().isMuted)
    }

    @Test func soundFallbackSkipsMissingDefaultSound() {
        let (model, _, _) = makeModel(availableSounds: ["Ping"])
        #expect(model.soundName == "Ping")
    }

    @Test func breakCompletionNotifiesWithBreakPhase() {
        let (model, clock, spy) = makeModel()
        model.start()
        clock.now = t0.addingTimeInterval(25 * 60)
        model.tick()
        clock.now = t0.addingTimeInterval(30 * 60)
        model.tick()
        #expect(spy.notifications.count == 2)
        #expect(spy.notifications.last?.phase == .shortBreak)
    }

    @Test func selectedSoundIsPassedToNotifier() {
        let (model, clock, spy) = makeModel()
        model.selectSound("Ping")
        model.start()
        clock.now = t0.addingTimeInterval(25 * 60)
        model.tick()
        #expect(spy.notifications.first?.sound == "Ping")
    }
}
