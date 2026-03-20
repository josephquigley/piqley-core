import Testing
import Foundation
@testable import PiqleyCore

@Suite("ManifestValidator")
struct ManifestValidatorTests {

    // MARK: - Helpers

    func makeManifest(
        identifier: String = "com.test.my-plugin",
        name: String = "MyPlugin",
        pluginSchemaVersion: String = "1",
        supportedFormats: [String]? = nil,
        conversionFormat: String? = nil
    ) -> PluginManifest {
        PluginManifest(
            identifier: identifier,
            name: name,
            pluginSchemaVersion: pluginSchemaVersion,
            supportedFormats: supportedFormats,
            conversionFormat: conversionFormat
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

    @Test func reservedIdentifierOriginalFails() {
        let manifest = makeManifest(identifier: "original")
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.contains { $0.contains("reserved") })
    }

    @Test func reservedIdentifierSkipFails() {
        let manifest = makeManifest(identifier: "skip")
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.contains { $0.contains("reserved") })
    }

    // MARK: - Format validation

    @Test func conversionFormatWithoutSupportedFormats() {
        let manifest = makeManifest(conversionFormat: "jpeg")
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.contains { $0.contains("conversionFormat requires supportedFormats") })
    }

    @Test func conversionFormatWithSupportedFormats() {
        let manifest = makeManifest(supportedFormats: ["raw", "jpeg"], conversionFormat: "jpeg")
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.isEmpty)
    }

    @Test func supportedFormatsAlone() {
        let manifest = makeManifest(supportedFormats: ["raw", "jpeg"])
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.isEmpty)
    }
}
