import Foundation

@MainActor
protocol PhaseNotifying {
    func requestAuthorization()
    func notify(_ phase: TimerPhase, sound: String?)
}
