import Foundation
import Observation

@MainActor
@Observable
final class MenuBarModel {
    private let engine: TimerEngine
    private let now: () -> Date

    private(set) var state: TimerEngine.State = .idle
    private(set) var remaining: TimeInterval = 0
    @ObservationIgnored private var tickTask: Task<Void, Never>?

    init(engine: TimerEngine = TimerEngine(), now: @escaping () -> Date = { Date() }) {
        self.engine = engine
        self.now = now
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
        engine.advance(to: now())
        sync()
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
