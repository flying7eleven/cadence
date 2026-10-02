import Foundation

struct PhaseNotification: Equatable {
    let title: String
    let body: String

    static func ending(_ phase: TimerPhase) -> PhaseNotification? {
        switch phase {
        case .focus:
            return PhaseNotification(title: "Focus block complete", body: "Time for a break.")
        case .shortBreak:
            return PhaseNotification(title: "Break over", body: "Ready for the next focus block.")
        case .longBreak:
            return PhaseNotification(title: "Long break over", body: "Ready for the next focus block.")
        case .idle:
            return nil
        }
    }
}
