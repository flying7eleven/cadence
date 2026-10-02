import Foundation

enum CountdownFormatter {
    static func string(from remaining: TimeInterval) -> String {
        let totalSeconds = Int(ceil(max(0, remaining)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
