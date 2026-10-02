import Foundation

enum TimerPhase: Equatable {
    case idle
    case focus
    case shortBreak
    case longBreak
}

struct TimerDurations: Equatable {
    var focus: TimeInterval
    var shortBreak: TimeInterval
    var longBreak: TimeInterval
    var focusBlocksUntilLongBreak: Int

    static let standard = TimerDurations(
        focus: 25 * 60,
        shortBreak: 5 * 60,
        longBreak: 15 * 60,
        focusBlocksUntilLongBreak: 4
    )
}

final class TimerEngine {

    enum State: Equatable {
        case idle
        case running(phase: TimerPhase, blockEndsAt: Date)
        case paused(phase: TimerPhase, remaining: TimeInterval)
    }

    // Degenerate injected values are clamped so the engine cannot spin on zero-length blocks.
    init(durations: TimerDurations = .standard) {
        self.durations = TimerDurations(
            focus: max(durations.focus, 1),
            shortBreak: max(durations.shortBreak, 1),
            longBreak: max(durations.longBreak, 1),
            focusBlocksUntilLongBreak: max(durations.focusBlocksUntilLongBreak, 1)
        )
    }

    private let durations: TimerDurations
    private(set) var state: State = .idle
    private(set) var completedFocusBlocks = 0

    var phase: TimerPhase {
        switch state {
        case .idle:
            return .idle
        case .running(let phase, _), .paused(let phase, _):
            return phase
        }
    }

    func remaining(at date: Date) -> TimeInterval {
        switch state {
        case .idle:
            return 0
        case .running(_, let blockEndsAt):
            return max(0, blockEndsAt.timeIntervalSince(date))
        case .paused(_, let remaining):
            return remaining
        }
    }

    func start(at date: Date) {
        guard case .idle = state else { return }
        state = .running(phase: .focus, blockEndsAt: date.addingTimeInterval(durations.focus))
    }

    func pause(at date: Date) {
        guard case .running(let phase, let blockEndsAt) = state else { return }
        state = .paused(phase: phase, remaining: max(0, blockEndsAt.timeIntervalSince(date)))
    }

    func resume(at date: Date) {
        guard case .paused(let phase, let remaining) = state else { return }
        state = .running(phase: phase, blockEndsAt: date.addingTimeInterval(remaining))
    }

    func reset() {
        state = .idle
        completedFocusBlocks = 0
    }

    @discardableResult
    func advance(to date: Date) -> [TimerPhase] {
        guard case .running(let phase, let blockEndsAt) = state, blockEndsAt <= date else { return [] }
        let next: TimerPhase
        switch phase {
        case .focus:
            completedFocusBlocks += 1
            next = completedFocusBlocks % durations.focusBlocksUntilLongBreak == 0 ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            next = .focus
        case .idle:
            return []
        }
        state = .running(phase: next, blockEndsAt: date.addingTimeInterval(duration(of: next)))
        return [phase]
    }

    private func duration(of phase: TimerPhase) -> TimeInterval {
        switch phase {
        case .focus:
            return durations.focus
        case .shortBreak:
            return durations.shortBreak
        case .longBreak:
            return durations.longBreak
        case .idle:
            return 0
        }
    }
}