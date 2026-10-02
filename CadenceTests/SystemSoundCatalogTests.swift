import Foundation
import Testing
@testable import Cadence

@Suite("SystemSoundCatalog")
struct SystemSoundCatalogTests {

    @Test func listsSoundNamesSortedWithoutExtensions() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SystemSoundCatalogTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try Data().write(to: directory.appendingPathComponent("Ping.aiff"))
        try Data().write(to: directory.appendingPathComponent("Glass.aiff"))
        try Data().write(to: directory.appendingPathComponent("notes.txt"))

        let catalog = SystemSoundCatalog(directory: directory)

        #expect(catalog.names == ["Glass", "Ping"])
    }

    @Test func missingDirectoryYieldsNoSounds() {
        let directory = URL(fileURLWithPath: "/nonexistent-\(UUID().uuidString)")
        let catalog = SystemSoundCatalog(directory: directory)
        #expect(catalog.names.isEmpty)
    }
}
