import Foundation

enum PhaseDisplayName {
    static func string(for phase: TimerPhase) -> String {
        switch phase {
        case .idle: "Ready"
        case .focus: "Focus"
        case .shortBreak: "Short break"
        case .longBreak: "Long break"
        }
    }
}
