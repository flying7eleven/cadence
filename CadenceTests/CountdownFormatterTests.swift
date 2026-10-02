import Foundation
import Testing
@testable import Cadence

@Suite("CountdownFormatter")
struct CountdownFormatterTests {
    @Test func formatsFullFocusBlock() {
        #expect(CountdownFormatter.string(from: 1500) == "25:00")
    }

    @Test func ceilsFractionalSecondsSoDisplayDoesNotDropEarly() {
        #expect(CountdownFormatter.string(from: 1499.5) == "25:00")
    }

    @Test func ceilsFractionalSecondsBelowOne() {
        #expect(CountdownFormatter.string(from: 0.4) == "00:01")
    }

    @Test func padsMinutesAndSeconds() {
        #expect(CountdownFormatter.string(from: 65) == "01:05")
    }

    @Test func formatsZero() {
        #expect(CountdownFormatter.string(from: 0) == "00:00")
    }

    @Test func clampsNegativeValuesToZero() {
        #expect(CountdownFormatter.string(from: -1) == "00:00")
        #expect(CountdownFormatter.string(from: -0.5) == "00:00")
    }

    @Test func formatsSingleMinuteAndSecondBoundaries() {
        #expect(CountdownFormatter.string(from: 59) == "00:59")
        #expect(CountdownFormatter.string(from: 60) == "01:00")
    }

    @Test func padsSingleDigitMinutes() {
        #expect(CountdownFormatter.string(from: 600) == "10:00")
    }

    @Test func formatsJustBelowAnHour() {
        #expect(CountdownFormatter.string(from: 3599) == "59:59")
    }

    @Test func formatsAnHourWithoutCappingMinutes() {
        #expect(CountdownFormatter.string(from: 3600) == "60:00")
    }
}
