import Foundation

final class EphemeralDefaults {
    private let suiteName = "CadenceTests-\(UUID().uuidString)"

    lazy var defaults: UserDefaults = UserDefaults(suiteName: suiteName)!

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }
}