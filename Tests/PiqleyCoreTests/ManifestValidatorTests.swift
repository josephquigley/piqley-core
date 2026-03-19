import Testing
import Foundation
@testable import PiqleyCore

@Suite("ManifestValidator")
struct ManifestValidatorTests {

    // MARK: - Helpers

    func makeManifest(
        identifier: String = "com.test.my-plugin",
        name: String = "MyPlugin",
        pluginSchemaVersion: String = "1"
    ) -> PluginManifest {
        PluginManifest(
            identifier: identifier,
            name: name,
            pluginSchemaVersion: pluginSchemaVersion
        )
    }

    // MARK: - validate(_:) — errors

    @Test func validManifestPasses() {
        let manifest = makeManifest()
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.isEmpty)
    }

    @Test func emptyIdentifierFails() {
        let manifest = makeManifest(identifier: "")
        let errors = ManifestValidator.validate(manifest)
        #expect(!errors.isEmpty)
    }

    @Test func emptyNameFails() {
        let manifest = makeManifest(name: "")
        let errors = ManifestValidator.validate(manifest)
        #expect(!errors.isEmpty)
    }

    @Test func emptySchemaVersionFails() {
        let manifest = makeManifest(pluginSchemaVersion: "")
        let errors = ManifestValidator.validate(manifest)
        #expect(!errors.isEmpty)
    }

    @Test func unsupportedSchemaVersionFails() {
        let manifest = makeManifest(pluginSchemaVersion: "999")
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.contains { $0.contains("999") })
    }

    @Test func supportedSchemaVersionPasses() {
        let manifest = makeManifest(pluginSchemaVersion: "1")
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.isEmpty)
    }
}
