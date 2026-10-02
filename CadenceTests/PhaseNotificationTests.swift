import Foundation
import Testing
@testable import Cadence

@Suite("PhaseNotification")
struct PhaseNotificationTests {

    @Test func focusCompletionProducesBreakNotification() {
        let notification = PhaseNotification.ending(.focus)
        #expect(notification == PhaseNotification(title: "Focus block complete", body: "Time for a break."))
    }

    @Test func shortBreakCompletionProducesFocusNotification() {
        let notification = PhaseNotification.ending(.shortBreak)
        #expect(notification == PhaseNotification(title: "Break over", body: "Ready for the next focus block."))
    }

    @Test func longBreakCompletionProducesFocusNotification() {
        let notification = PhaseNotification.ending(.longBreak)
        #expect(notification == PhaseNotification(title: "Long break over", body: "Ready for the next focus block."))
    }

    @Test func idleProducesNoNotification() {
        #expect(PhaseNotification.ending(.idle) == nil)
    }
}
