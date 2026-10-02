// Temporary stub for the timer core; replaced by the tested implementation at integration.
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

    init(durations: TimerDurations = .standard) {
        self.durations = durations
    }

    private let durations: TimerDurations
    private(set) var state: State = .idle
    private(set) var completedFocusBlocks = 0

    var phase: TimerPhase {
        switch state {
        case .idle: .idle
        case .running(let phase, _): phase
        case .paused(let phase, _): phase
        }
    }

    func remaining(at date: Date) -> TimeInterval {
        switch state {
        case .idle: 0
        case .running(_, let blockEndsAt): max(0, blockEndsAt.timeIntervalSince(date))
        case .paused(_, let remaining): remaining
        }
    }

    func start(at date: Date) {
        guard state == .idle else { return }
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
    func advance(to date: Date) -> TimerPhase? {
        guard case .running(let phase, let blockEndsAt) = state, blockEndsAt <= date else { return nil }
        if phase == .focus {
            completedFocusBlocks += 1
        }
        let nextPhase: TimerPhase
        switch phase {
        case .focus:
            nextPhase = completedFocusBlocks % durations.focusBlocksUntilLongBreak == 0 ? .longBreak : .shortBreak
        case .shortBreak, .longBreak, .idle:
            nextPhase = .focus
        }
        state = .running(phase: nextPhase, blockEndsAt: date.addingTimeInterval(duration(for: nextPhase)))
        return phase
    }

    private func duration(for phase: TimerPhase) -> TimeInterval {
        switch phase {
        case .focus: durations.focus
        case .shortBreak: durations.shortBreak
        case .longBreak: durations.longBreak
        case .idle: 0
        }
    }
}
