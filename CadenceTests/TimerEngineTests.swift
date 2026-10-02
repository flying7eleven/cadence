import Foundation
import Testing
@testable import Cadence

@Suite("TimerEngine")
struct TimerEngineTests {

    let t0 = Date(timeIntervalSince1970: 1_000_000)

    @Test func initialStateIsIdle() {
        let engine = TimerEngine()
        #expect(engine.state == .idle)
        #expect(engine.phase == .idle)
        #expect(engine.completedFocusBlocks == 0)
        #expect(engine.remaining(at: t0) == 0)
    }

    @Test func startFromIdleBeginsFocusWithDefaultDuration() {
        let engine = TimerEngine()
        engine.start(at: t0)
        #expect(engine.state == .running(phase: .focus, blockEndsAt: t0.addingTimeInterval(25 * 60)))
        #expect(engine.phase == .focus)
        #expect(engine.remaining(at: t0) == 25 * 60)
    }

    @Test func focusCompletionLeadsToShortBreak() {
        let engine = TimerEngine()
        engine.start(at: t0)
        let completion = engine.advance(to: t0.addingTimeInterval(25 * 60))
        #expect(completion == .focus)
        #expect(engine.completedFocusBlocks == 1)
        #expect(engine.state == .running(phase: .shortBreak, blockEndsAt: t0.addingTimeInterval(25 * 60 + 5 * 60)))
    }

    @Test func longBreakFollowsFourthFocusBlockAndCycleRepeats() {
        let engine = TimerEngine()
        engine.start(at: t0)
        var completions: [TimerPhase] = []
        for _ in 0..<16 {
            guard case .running(_, let blockEndsAt) = engine.state else {
                Issue.record("expected a running block")
                return
            }
            completions.append(engine.advance(to: blockEndsAt)!)
        }
        #expect(completions == [
            .focus, .shortBreak, .focus, .shortBreak, .focus, .shortBreak, .focus, .longBreak,
            .focus, .shortBreak, .focus, .shortBreak, .focus, .shortBreak, .focus, .longBreak,
        ])
        #expect(engine.completedFocusBlocks == 8)
    }

    @Test func longBreakCompletionLeadsToFocus() {
        let engine = TimerEngine(durations: TimerDurations(focus: 10, shortBreak: 2, longBreak: 5, focusBlocksUntilLongBreak: 1))
        engine.start(at: t0)
        #expect(engine.advance(to: t0.addingTimeInterval(10)) == .focus)
        #expect(engine.state == .running(phase: .longBreak, blockEndsAt: t0.addingTimeInterval(15)))
        #expect(engine.advance(to: t0.addingTimeInterval(15)) == .longBreak)
        #expect(engine.state == .running(phase: .focus, blockEndsAt: t0.addingTimeInterval(25)))
    }

    @Test func pauseMidBlockPreservesRemaining() {
        let engine = TimerEngine()
        engine.start(at: t0)
        engine.pause(at: t0.addingTimeInterval(600))
        #expect(engine.state == .paused(phase: .focus, remaining: 900))
        #expect(engine.phase == .focus)
        #expect(engine.remaining(at: t0.addingTimeInterval(600)) == 900)
    }

    @Test func advanceWhilePausedDoesNothing() {
        let engine = TimerEngine()
        engine.start(at: t0)
        engine.pause(at: t0.addingTimeInterval(600))
        #expect(engine.advance(to: t0.addingTimeInterval(100_000)) == nil)
        #expect(engine.state == .paused(phase: .focus, remaining: 900))
        #expect(engine.completedFocusBlocks == 0)
    }

    @Test func resumeContinuesWithPreservedRemaining() {
        let engine = TimerEngine()
        engine.start(at: t0)
        engine.pause(at: t0.addingTimeInterval(600))
        engine.resume(at: t0.addingTimeInterval(700))
        #expect(engine.state == .running(phase: .focus, blockEndsAt: t0.addingTimeInterval(1600)))
        #expect(engine.remaining(at: t0.addingTimeInterval(700)) == 900)
    }

    @Test func resetMidBreakClearsCounterAndReturnsIdle() {
        let engine = TimerEngine()
        engine.start(at: t0)
        #expect(engine.advance(to: t0.addingTimeInterval(25 * 60)) == .focus)
        #expect(engine.phase == .shortBreak)
        #expect(engine.advance(to: t0.addingTimeInterval(25 * 60 + 60)) == nil)
        engine.reset()
        #expect(engine.state == .idle)
        #expect(engine.completedFocusBlocks == 0)
        #expect(engine.phase == .idle)
        #expect(engine.remaining(at: t0.addingTimeInterval(25 * 60 + 60)) == 0)
    }

    @Test func completionExactlyAtBoundaryCounts() {
        let engine = TimerEngine()
        engine.start(at: t0)
        #expect(engine.advance(to: t0.addingTimeInterval(25 * 60)) == .focus)
        #expect(engine.completedFocusBlocks == 1)
    }

    @Test func advanceBeforeBoundaryReturnsNil() {
        let engine = TimerEngine()
        engine.start(at: t0)
        #expect(engine.advance(to: t0.addingTimeInterval(25 * 60 - 1)) == nil)
        #expect(engine.state == .running(phase: .focus, blockEndsAt: t0.addingTimeInterval(25 * 60)))
        #expect(engine.remaining(at: t0.addingTimeInterval(25 * 60 - 1)) == 1)
    }

    @Test func advanceLongAfterBoundaryCompletesExactlyOneBlock() {
        let engine = TimerEngine()
        engine.start(at: t0)
        #expect(engine.remaining(at: t0.addingTimeInterval(36_000)) == 0)
        let completion = engine.advance(to: t0.addingTimeInterval(36_000))
        #expect(completion == .focus)
        #expect(engine.completedFocusBlocks == 1)
        #expect(engine.state == .running(phase: .shortBreak, blockEndsAt: t0.addingTimeInterval(36_000 + 5 * 60)))
        #expect(engine.remaining(at: t0.addingTimeInterval(36_000)) == 5 * 60)
    }

    @Test func startOutsideIdleIsNoOp() {
        let engine = TimerEngine()
        engine.start(at: t0)
        engine.start(at: t0.addingTimeInterval(200))
        #expect(engine.state == .running(phase: .focus, blockEndsAt: t0.addingTimeInterval(25 * 60)))
        engine.pause(at: t0.addingTimeInterval(600))
        engine.start(at: t0.addingTimeInterval(700))
        #expect(engine.state == .paused(phase: .focus, remaining: 900))
    }

    @Test func pauseOutsideRunningIsNoOp() {
        let engine = TimerEngine()
        engine.pause(at: t0)
        #expect(engine.state == .idle)
        engine.start(at: t0)
        engine.pause(at: t0.addingTimeInterval(600))
        engine.pause(at: t0.addingTimeInterval(1200))
        #expect(engine.state == .paused(phase: .focus, remaining: 900))
    }

    @Test func resumeOutsidePausedIsNoOp() {
        let engine = TimerEngine()
        engine.resume(at: t0)
        #expect(engine.state == .idle)
        engine.start(at: t0)
        engine.resume(at: t0.addingTimeInterval(100))
        #expect(engine.state == .running(phase: .focus, blockEndsAt: t0.addingTimeInterval(25 * 60)))
    }

    @Test func advanceWhileIdleReturnsNil() {
        let engine = TimerEngine()
        #expect(engine.advance(to: t0.addingTimeInterval(100_000)) == nil)
        #expect(engine.state == .idle)
        #expect(engine.completedFocusBlocks == 0)
    }

    @Test func customDurationsAreInjected() {
        let engine = TimerEngine(durations: TimerDurations(focus: 100, shortBreak: 10, longBreak: 30, focusBlocksUntilLongBreak: 2))
        engine.start(at: t0)
        #expect(engine.remaining(at: t0) == 100)
        #expect(engine.advance(to: t0.addingTimeInterval(100)) == .focus)
        #expect(engine.state == .running(phase: .shortBreak, blockEndsAt: t0.addingTimeInterval(110)))
        #expect(engine.advance(to: t0.addingTimeInterval(110)) == .shortBreak)
        #expect(engine.state == .running(phase: .focus, blockEndsAt: t0.addingTimeInterval(210)))
        #expect(engine.advance(to: t0.addingTimeInterval(210)) == .focus)
        #expect(engine.state == .running(phase: .longBreak, blockEndsAt: t0.addingTimeInterval(240)))
        #expect(engine.completedFocusBlocks == 2)
    }

    @Test func degenerateDurationsAreClamped() {
        let engine = TimerEngine(durations: TimerDurations(focus: 0, shortBreak: -5, longBreak: 0, focusBlocksUntilLongBreak: 0))
        engine.start(at: t0)
        #expect(engine.remaining(at: t0) == 1)
        #expect(engine.advance(to: t0.addingTimeInterval(1)) == .focus)
        #expect(engine.state == .running(phase: .longBreak, blockEndsAt: t0.addingTimeInterval(2)))
        #expect(engine.advance(to: t0.addingTimeInterval(2)) == .longBreak)
        #expect(engine.state == .running(phase: .focus, blockEndsAt: t0.addingTimeInterval(3)))
    }

    @Test func nonFiniteDurationsFallBackToStandard() {
        let engine = TimerEngine(durations: TimerDurations(focus: .nan, shortBreak: .infinity, longBreak: -.infinity, focusBlocksUntilLongBreak: 4))
        engine.start(at: t0)
        #expect(engine.remaining(at: t0) == 25 * 60)
        #expect(engine.advance(to: t0.addingTimeInterval(25 * 60)) == .focus)
        #expect(engine.state == .running(phase: .shortBreak, blockEndsAt: t0.addingTimeInterval(30 * 60)))
    }
}
