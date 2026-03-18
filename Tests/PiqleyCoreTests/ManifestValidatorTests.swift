import Testing
import Foundation
@testable import PiqleyCore

@Suite("ManifestValidator")
struct ManifestValidatorTests {

    // MARK: - Helpers

    func makeManifest(
        name: String = "MyPlugin",
        pluginProtocolVersion: String = "1.0",
        hooks: [String: HookConfig] = ["publish": HookConfig(command: "publish.sh")]
    ) -> PluginManifest {
        PluginManifest(
            name: name,
            pluginProtocolVersion: pluginProtocolVersion,
            hooks: hooks
        )
    }

    // MARK: - validate(_:) — errors

    @Test func validManifestPasses() {
        let manifest = makeManifest()
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.isEmpty)
    }

    @Test func rulesOnlyHookPasses() {
        // A hook with no command (rules-only) is valid
        let manifest = makeManifest(hooks: ["publish": HookConfig()])
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.isEmpty)
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

    @Test func noHooksFails() {
        let manifest = makeManifest(hooks: [:])
        let errors = ManifestValidator.validate(manifest)
        #expect(!errors.isEmpty)
    }

    @Test func batchProxyWithJsonProtocolFails() {
        let batchProxy = BatchProxyConfig()
        let hook = HookConfig(
            command: "process.sh",
            pluginProtocol: .json,
            batchProxy: batchProxy
        )
        let manifest = makeManifest(hooks: ["pre-process": hook])
        let errors = ManifestValidator.validate(manifest)
        #expect(!errors.isEmpty)
    }

    @Test func batchProxyWithNoCommandFails() {
        let batchProxy = BatchProxyConfig()
        let hook = HookConfig(
            command: nil,
            pluginProtocol: .pipe,
            batchProxy: batchProxy
        )
        let manifest = makeManifest(hooks: ["pre-process": hook])
        let errors = ManifestValidator.validate(manifest)
        #expect(!errors.isEmpty)
    }

    @Test func batchProxyWithPipePasses() {
        let batchProxy = BatchProxyConfig()
        let hook = HookConfig(
            command: "process.sh",
            pluginProtocol: .pipe,
            batchProxy: batchProxy
        )
        let manifest = makeManifest(hooks: ["pre-process": hook])
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.isEmpty)
    }

    // MARK: - warnings(_:) — non-blocking

    @Test func unknownHooksProduceWarnings() {
        let manifest = makeManifest(hooks: [
            "publish": HookConfig(command: "pub.sh"),
            "custom-hook": HookConfig(command: "custom.sh"),
            "another-unknown": HookConfig()
        ])
        let warnings = ManifestValidator.warnings(manifest)
        #expect(warnings.count == 2)
    }

    @Test func unknownHooksAreNotErrors() {
        let manifest = makeManifest(hooks: [
            "publish": HookConfig(command: "pub.sh"),
            "custom-hook": HookConfig(command: "custom.sh")
        ])
        let errors = ManifestValidator.validate(manifest)
        #expect(errors.isEmpty)
    }

    @Test func knownHooksProduceNoWarnings() {
        let manifest = makeManifest(hooks: [
            "publish": HookConfig(command: "pub.sh"),
            "pre-process": HookConfig(command: "pre.sh")
        ])
        let warnings = ManifestValidator.warnings(manifest)
        #expect(warnings.isEmpty)
    }
}
