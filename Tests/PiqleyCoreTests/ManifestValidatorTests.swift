import Testing
import Foundation
@testable import PiqleyCore

@Suite("ManifestValidator")
struct ManifestValidatorTests {

    // MARK: - Helpers

    func makeManifest(
        identifier: String = "com.test.my-plugin",
        name: String = "MyPlugin",
        pluginProtocolVersion: String = "1.0"
    ) -> PluginManifest {
        PluginManifest(
            identifier: identifier,
            name: name,
            pluginProtocolVersion: pluginProtocolVersion
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

    @Test func emptyProtocolVersionFails() {
        let manifest = makeManifest(pluginProtocolVersion: "")
        let errors = ManifestValidator.validate(manifest)
        #expect(!errors.isEmpty)
    }
}
