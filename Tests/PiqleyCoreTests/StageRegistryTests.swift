import Foundation
import Testing
@testable import PiqleyCore

@Suite("StageRegistry")
struct StageRegistryTests {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("piqley-registry-\(UUID().uuidString)")

    init() throws {
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    @Test func seedsDefaultsWhenFileMissing() throws {
        let registry = try StageRegistry.load(from: tempDir)
        #expect(registry.active.map(\.name) == Hook.defaultStageNames)
        #expect(registry.available.isEmpty)
    }

    @Test func roundTrips() throws {
        var registry = try StageRegistry.load(from: tempDir)
        registry.available.append(StageEntry(name: "publish-356"))
        try registry.save(to: tempDir)
        let reloaded = try StageRegistry.load(from: tempDir)
        #expect(reloaded.available.map(\.name) == ["publish-356"])
    }

    @Test func isKnownChecksActivePlusAvailable() throws {
        var registry = try StageRegistry.load(from: tempDir)
        registry.available.append(StageEntry(name: "custom"))
        #expect(registry.isKnown("pre-process"))
        #expect(registry.isKnown("custom"))
        #expect(!registry.isKnown("nonexistent"))
    }

    @Test func validatesStageNames() {
        #expect(StageRegistry.isValidName("pre-process"))
        #expect(StageRegistry.isValidName("publish-356-project"))
        #expect(!StageRegistry.isValidName("-leading"))
        #expect(!StageRegistry.isValidName("trailing-"))
        #expect(!StageRegistry.isValidName("Capital"))
        #expect(!StageRegistry.isValidName("has spaces"))
        #expect(!StageRegistry.isValidName("a")) // minimum 2 chars
    }
}
