import Foundation
import Observation

@MainActor
@Observable
final class MenuBarModel {
    private let engine: TimerEngine
    private let now: () -> Date
    private let notifier: PhaseNotifying
    private let preferencesStore: NotificationPreferencesStore

    let availableSounds: [String]

    private(set) var state: TimerEngine.State = .idle
    private(set) var remaining: TimeInterval = 0
    private(set) var isMuted: Bool
    private(set) var soundName: String
    @ObservationIgnored private var tickTask: Task<Void, Never>?

    init(
        engine: TimerEngine = TimerEngine(),
        now: @escaping () -> Date = { Date() },
        notifier: PhaseNotifying = SystemPhaseNotifier(),
        availableSounds: [String] = SystemSoundCatalog().names,
        preferencesStore: NotificationPreferencesStore = NotificationPreferencesStore()
    ) {
        self.engine = engine
        self.now = now
        self.notifier = notifier
        self.availableSounds = availableSounds
        self.preferencesStore = preferencesStore
        let preferences = preferencesStore.load()
        isMuted = preferences.isMuted
        soundName = availableSounds.contains(preferences.soundName)
            ? preferences.soundName
            : NotificationPreferences.defaultSoundName
        notifier.requestAuthorization()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                self.tick()
            }
        }
    }

    var phase: TimerPhase {
        switch state {
        case .idle: .idle
        case .running(let phase, _): phase
        case .paused(let phase, _): phase
        }
    }

    var isRunning: Bool {
        if case .running = state { true } else { false }
    }

    var isPaused: Bool {
        if case .paused = state { true } else { false }
    }

    var isIdle: Bool { state == .idle }

    var menuBarLabel: String {
        isIdle ? PhaseDisplayName.string(for: .idle) : CountdownFormatter.string(from: remaining)
    }

    func start() {
        engine.start(at: now())
        sync()
    }

    func pause() {
        engine.pause(at: now())
        sync()
    }

    func resume() {
        engine.resume(at: now())
        sync()
    }

    func reset() {
        engine.reset()
        sync()
    }

    func tick() {
        if let completed = engine.advance(to: now()) {
            notifier.notify(completed, sound: isMuted ? nil : soundName)
        }
        sync()
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        persist()
    }

    func selectSound(_ name: String) {
        guard availableSounds.contains(name) else { return }
        soundName = name
        persist()
    }

    private func persist() {
        preferencesStore.save(NotificationPreferences(isMuted: isMuted, soundName: soundName))
    }

    private func sync() {
        let newState = engine.state
        let newRemaining = engine.remaining(at: now())
        if newState != state {
            state = newState
        }
        if newRemaining != remaining {
            remaining = newRemaining
        }
    }
}
