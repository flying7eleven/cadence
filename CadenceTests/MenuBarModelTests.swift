import Foundation
import Testing
@testable import Cadence

@MainActor
@Suite("MenuBarModel")
struct MenuBarModelTests {

    final class Clock {
        var now: Date
        init(_ now: Date) { self.now = now }
    }

    let t0 = Date(timeIntervalSince1970: 2_000_000)

    private func makeModel() -> (MenuBarModel, Clock) {
        let clock = Clock(t0)
        let model = MenuBarModel(engine: TimerEngine(), now: { clock.now })
        return (model, clock)
    }

    @Test func initialStateIsMirrored() {
        let (model, _) = makeModel()
        #expect(model.isIdle)
        #expect(!model.isRunning)
        #expect(!model.isPaused)
        #expect(model.phase == .idle)
        #expect(model.remaining == 0)
    }

    @Test func startMirrorsRunningState() {
        let (model, _) = makeModel()
        model.start()
        #expect(model.isRunning)
        #expect(model.phase == .focus)
        #expect(model.remaining == 25 * 60)
    }

    @Test func pauseAndResumeMirrorState() {
        let (model, clock) = makeModel()
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
        let (model, _) = makeModel()
        model.start()
        model.reset()
        #expect(model.isIdle)
        #expect(model.remaining == 0)
    }

    @Test func tickCompletesBlockAndMirrorsNextPhase() {
        let (model, clock) = makeModel()
        model.start()
        clock.now = t0.addingTimeInterval(25 * 60)
        model.tick()
        #expect(model.phase == .shortBreak)
        #expect(model.remaining == 5 * 60)
    }

    @Test func menuBarLabelShowsReadyWhenIdle() {
        let (model, _) = makeModel()
        #expect(model.menuBarLabel == "Ready")
    }

    @Test func menuBarLabelShowsCountdownWhenRunning() {
        let (model, _) = makeModel()
        model.start()
        #expect(model.menuBarLabel == "25:00")
    }
}
