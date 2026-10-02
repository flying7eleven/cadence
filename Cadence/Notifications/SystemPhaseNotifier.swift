import AppKit
import Foundation
import UserNotifications

@MainActor
final class SystemPhaseNotifier: NSObject, PhaseNotifying {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
        super.init()
        center.delegate = self
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notify(_ phase: TimerPhase, sound: String?) {
        guard let notification = PhaseNotification.ending(phase) else { return }
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = nil
        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
        if let sound, let systemSound = NSSound(named: NSSound.Name(sound)) {
            systemSound.play()
        }
    }
}

extension SystemPhaseNotifier: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        .banner
    }
}
