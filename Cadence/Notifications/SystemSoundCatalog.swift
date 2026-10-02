import Foundation

struct SystemSoundCatalog {
    let directory: URL

    init(directory: URL = URL(fileURLWithPath: "/System/Library/Sounds")) {
        self.directory = directory
    }

    var names: [String] {
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        return files
            .filter { $0.pathExtension == "aiff" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()
    }
}
