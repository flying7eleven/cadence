import Foundation
import Testing
@testable import Cadence

@Suite("PhaseDisplayName")
struct PhaseDisplayNameTests {
    @Test func namesIdlePhase() {
        #expect(PhaseDisplayName.string(for: .idle) == "Ready")
    }

    @Test func namesFocusPhase() {
        #expect(PhaseDisplayName.string(for: .focus) == "Focus")
    }

    @Test func namesShortBreakPhase() {
        #expect(PhaseDisplayName.string(for: .shortBreak) == "Short break")
    }

    @Test func namesLongBreakPhase() {
        #expect(PhaseDisplayName.string(for: .longBreak) == "Long break")
    }
}