import Foundation
import Observation

@MainActor
@Observable
final class MenuBarModel {
    private let engine: TimerEngine

    private(set) var state: TimerEngine.State = .idle
    private(set) var remaining: TimeInterval = 0
    @ObservationIgnored private var tickTask: Task<Void, Never>?

    init(engine: TimerEngine = TimerEngine()) {
        self.engine = engine
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                self.tick(at: .now)
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

    func start() {
        engine.start(at: .now)
        tick(at: .now)
    }

    func pause() {
        engine.pause(at: .now)
        tick(at: .now)
    }

    func resume() {
        engine.resume(at: .now)
        tick(at: .now)
    }

    func reset() {
        engine.reset()
        tick(at: .now)
    }

    private func tick(at date: Date) {
        engine.advance(to: date)
        state = engine.state
        remaining = engine.remaining(at: date)
    }
}