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
        #expect(registry.active.map(\.name) == StandardHook.defaultStageNames)
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

    // MARK: - Mutations

    @Test func activateMovesFromAvailableToActive() throws {
        var registry = try StageRegistry.load(from: tempDir)
        registry.available.append(StageEntry(name: "custom"))
        try registry.activate("custom", at: 2)
        #expect(registry.active[2].name == "custom")
        #expect(registry.available.isEmpty)
    }

    @Test func deactivateMovesFromActiveToAvailable() throws {
        var registry = try StageRegistry.load(from: tempDir)
        try registry.deactivate("pre-process")
        #expect(!registry.active.map(\.name).contains("pre-process"))
        #expect(registry.available.map(\.name).contains("pre-process"))
    }

    @Test func reorderMovesStageTo() throws {
        var registry = try StageRegistry.load(from: tempDir)
        try registry.reorder("publish", to: 1)
        #expect(registry.active[1].name == "publish")
    }

    @Test func addStageInsertsAtPosition() throws {
        var registry = try StageRegistry.load(from: tempDir)
        try registry.addStage("custom-stage", at: 2)
        #expect(registry.active[2].name == "custom-stage")
        #expect(registry.active.count == 7)
    }

    @Test func addStageDuplicateNameThrows() throws {
        var registry = try StageRegistry.load(from: tempDir)
        #expect(throws: StageRegistryError.self) {
            try registry.addStage("pre-process", at: 0)
        }
    }

    @Test func addStageInvalidNameThrows() throws {
        var registry = try StageRegistry.load(from: tempDir)
        #expect(throws: StageRegistryError.self) {
            try registry.addStage("Bad Name", at: 0)
        }
    }

    @Test func removeStageDeletesFromBothLists() throws {
        var registry = try StageRegistry.load(from: tempDir)
        registry.available.append(StageEntry(name: "custom"))
        try registry.removeStage("custom")
        #expect(!registry.isKnown("custom"))
    }

    @Test func renameStageUpdatesName() throws {
        var registry = try StageRegistry.load(from: tempDir)
        try registry.renameStage("publish", to: "publish-photos")
        #expect(registry.active.map(\.name).contains("publish-photos"))
        #expect(!registry.active.map(\.name).contains("publish"))
    }

    @Test func renameToExistingNameThrows() throws {
        var registry = try StageRegistry.load(from: tempDir)
        #expect(throws: StageRegistryError.self) {
            try registry.renameStage("publish", to: "pre-process")
        }
    }

    @Test func autoRegisterAddsToAvailable() throws {
        var registry = try StageRegistry.load(from: tempDir)
        registry.autoRegister("new-stage")
        #expect(registry.available.map(\.name).contains("new-stage"))
        // No-op for existing
        registry.autoRegister("pre-process")
        #expect(registry.available.count == 1)
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
