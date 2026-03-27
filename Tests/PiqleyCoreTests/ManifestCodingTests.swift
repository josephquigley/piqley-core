import Testing
import Foundation
@testable import PiqleyCore

@Suite("ManifestCoding")
struct ManifestCodingTests {

    // MARK: - ConfigEntry

    @Test func decodeValueEntry() throws {
        let json = #"{"key": "myKey", "type": "string", "value": "hello"}"#
        let entry = try JSONDecoder.piqley.decode(ConfigEntry.self, from: Data(json.utf8))
        guard case .value(let key, let type_, let value, _) = entry else {
            Issue.record("Expected .value case")
            return
        }
        #expect(key == "myKey")
        #expect(type_ == .string)
        #expect(value == .string("hello"))
    }

    @Test func decodeValueEntryWithDefault() throws {
        let json = #"{"key": "count", "type": "int", "value": 42}"#
        let entry = try JSONDecoder.piqley.decode(ConfigEntry.self, from: Data(json.utf8))
        guard case .value(let key, let type_, let value, _) = entry else {
            Issue.record("Expected .value case")
            return
        }
        #expect(key == "count")
        #expect(type_ == .int)
        #expect(value == .number(42))
    }

    @Test func decodeSecretEntry() throws {
        let json = #"{"secret_key": "API_TOKEN", "type": "string"}"#
        let entry = try JSONDecoder.piqley.decode(ConfigEntry.self, from: Data(json.utf8))
        guard case .secret(let secretKey, let type_, _) = entry else {
            Issue.record("Expected .secret case")
            return
        }
        #expect(secretKey == "API_TOKEN")
        #expect(type_ == .string)
    }

    @Test func decodeBothKeysThrows() throws {
        let json = #"{"key": "foo", "secret_key": "BAR", "type": "string", "value": "x"}"#
        #expect(throws: (any Error).self) {
            try JSONDecoder.piqley.decode(ConfigEntry.self, from: Data(json.utf8))
        }
    }

    @Test func decodeNeitherKeyThrows() throws {
        let json = #"{"type": "string", "value": "x"}"#
        #expect(throws: (any Error).self) {
            try JSONDecoder.piqley.decode(ConfigEntry.self, from: Data(json.utf8))
        }
    }

    @Test func encodeRoundTripValue() throws {
        let original = ConfigEntry.value(key: "myKey", type: .string, value: .string("hello"), metadata: ConfigMetadata())
        let data = try JSONEncoder.piqley.encode(original)
        let decoded = try JSONDecoder.piqley.decode(ConfigEntry.self, from: data)
        guard case .value(let key, let type_, let value, _) = decoded else {
            Issue.record("Expected .value case")
            return
        }
        #expect(key == "myKey")
        #expect(type_ == .string)
        #expect(value == .string("hello"))
    }

    @Test func encodeRoundTripSecret() throws {
        let original = ConfigEntry.secret(secretKey: "API_TOKEN", type: .string, metadata: ConfigMetadata())
        let data = try JSONEncoder.piqley.encode(original)
        let decoded = try JSONDecoder.piqley.decode(ConfigEntry.self, from: data)
        guard case .secret(let secretKey, let type_, _) = decoded else {
            Issue.record("Expected .secret case")
            return
        }
        #expect(secretKey == "API_TOKEN")
        #expect(type_ == .string)
    }

    // MARK: - HookConfig

    @Test func decodeFullHookConfig() throws {
        let json = """
        {
            "command": "/usr/bin/plugin",
            "args": ["--verbose", "--output", "json"],
            "timeout": 30,
            "protocol": "json",
            "successCodes": [0],
            "warningCodes": [1],
            "criticalCodes": [2, 3],
            "batchProxy": {}
        }
        """
        let hook = try JSONDecoder.piqley.decode(HookConfig.self, from: Data(json.utf8))
        #expect(hook.command == "/usr/bin/plugin")
        #expect(hook.args == ["--verbose", "--output", "json"])
        #expect(hook.timeout == 30)
        #expect(hook.pluginProtocol == .json)
        #expect(hook.successCodes == [0])
        #expect(hook.warningCodes == [1])
        #expect(hook.criticalCodes == [2, 3])
        #expect(hook.batchProxy != nil)
    }

    @Test func decodeMinimalHookConfig() throws {
        let json = "{}"
        let hook = try JSONDecoder.piqley.decode(HookConfig.self, from: Data(json.utf8))
        #expect(hook.command == nil)
        #expect(hook.args == [])
        #expect(hook.timeout == nil)
        #expect(hook.pluginProtocol == nil)
        #expect(hook.successCodes == nil)
        #expect(hook.warningCodes == nil)
        #expect(hook.criticalCodes == nil)
        #expect(hook.batchProxy == nil)
    }

    // MARK: - SetupConfig

    @Test func decodeSetupConfigWithArgs() throws {
        let json = #"{"command": "setup.sh", "args": ["--init"]}"#
        let setup = try JSONDecoder.piqley.decode(SetupConfig.self, from: Data(json.utf8))
        #expect(setup.command == "setup.sh")
        #expect(setup.args == ["--init"])
    }

    @Test func decodeSetupConfigWithoutArgs() throws {
        let json = #"{"command": "setup.sh"}"#
        let setup = try JSONDecoder.piqley.decode(SetupConfig.self, from: Data(json.utf8))
        #expect(setup.command == "setup.sh")
        #expect(setup.args == [])
    }

    // MARK: - BatchProxyConfig

    @Test func decodeBatchProxyWithSort() throws {
        let json = #"{"sort": {"key": "date", "order": "ascending"}}"#
        let proxy = try JSONDecoder.piqley.decode(BatchProxyConfig.self, from: Data(json.utf8))
        #expect(proxy.sort?.key == "date")
        #expect(proxy.sort?.order == .ascending)
    }

    @Test func decodeBatchProxyWithoutSort() throws {
        let json = "{}"
        let proxy = try JSONDecoder.piqley.decode(BatchProxyConfig.self, from: Data(json.utf8))
        #expect(proxy.sort == nil)
    }

    @Test func sortOrderRawValues() {
        #expect(SortOrder.ascending.rawValue == "ascending")
        #expect(SortOrder.descending.rawValue == "descending")
    }

    // MARK: - PluginManifest

    @Test func decodeFullManifest() throws {
        let json = """
        {
            "identifier": "com.test.my-plugin",
            "name": "MyPlugin",
            "type": "static",
            "description": "A test plugin.",
            "pluginSchemaVersion": "1.0",
            "pluginVersion": "2.3.1",
            "config": [
                {"key": "apiUrl", "type": "string", "value": "https://example.com"},
                {"secret_key": "API_TOKEN", "type": "string"}
            ],
            "setup": {"command": "setup.sh"},
            "dependencies": ["other-plugin"]
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        #expect(manifest.identifier == "com.test.my-plugin")
        #expect(manifest.name == "MyPlugin")
        #expect(manifest.type == .static)
        #expect(manifest.description == "A test plugin.")
        #expect(manifest.pluginSchemaVersion == "1.0")
        #expect(manifest.pluginVersion == SemanticVersion(major: 2, minor: 3, patch: 1))
        #expect(manifest.config.count == 2)
        #expect(manifest.setup?.command == "setup.sh")
        #expect(manifest.dependencies?.count == 1)
        #expect(manifest.dependencyIdentifiers == ["other-plugin"])
    }

    @Test func decodeMinimalManifest() throws {
        let json = """
        {
            "identifier": "com.test.minimal",
            "name": "MinimalPlugin",
            "type": "mutable",
            "pluginSchemaVersion": "1.0"
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        #expect(manifest.identifier == "com.test.minimal")
        #expect(manifest.name == "MinimalPlugin")
        #expect(manifest.type == .mutable)
        #expect(manifest.description == nil)
        #expect(manifest.pluginSchemaVersion == "1.0")
        #expect(manifest.pluginVersion == nil)
        #expect(manifest.config.isEmpty)
        #expect(manifest.setup == nil)
        #expect(manifest.dependencies == nil)
    }

    @Test func secretKeys() throws {
        let json = """
        {
            "identifier": "com.test.secrets",
            "name": "MyPlugin",
            "type": "static",
            "pluginSchemaVersion": "1.0",
            "config": [
                {"key": "apiUrl", "type": "string", "value": "https://example.com"},
                {"secret_key": "API_TOKEN", "type": "string"},
                {"secret_key": "DB_PASS", "type": "string"}
            ]
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        let keys = manifest.secretKeys
        #expect(keys.count == 2)
        #expect(keys.contains("API_TOKEN"))
        #expect(keys.contains("DB_PASS"))
    }

    @Test func valueEntries() throws {
        let json = """
        {
            "identifier": "com.test.values",
            "name": "MyPlugin",
            "type": "static",
            "pluginSchemaVersion": "1.0",
            "config": [
                {"key": "apiUrl", "type": "string", "value": "https://example.com"},
                {"secret_key": "API_TOKEN", "type": "string"},
                {"key": "retries", "type": "int", "value": 3}
            ]
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        let entries = manifest.valueEntries
        #expect(entries.count == 2)
        let keys = entries.map { $0.key }
        #expect(keys.contains("apiUrl"))
        #expect(keys.contains("retries"))
    }

    // MARK: - ConfigMetadata

    @Test("decodes config entry with label and description")
    func decodesMetadata() throws {
        let json = """
        {"key": "api-url", "type": "string", "value": "", "label": "API URL", "description": "The base URL for the API"}
        """
        let entry = try JSONDecoder().decode(ConfigEntry.self, from: Data(json.utf8))
        guard case .value(_, _, _, let metadata) = entry else {
            Issue.record("Expected value entry")
            return
        }
        #expect(metadata.label == "API URL")
        #expect(metadata.description == "The base URL for the API")
    }

    @Test("decodes config entry without label or description")
    func decodesWithoutMetadata() throws {
        let json = """
        {"key": "api-url", "type": "string", "value": ""}
        """
        let entry = try JSONDecoder().decode(ConfigEntry.self, from: Data(json.utf8))
        guard case .value(_, _, _, let metadata) = entry else {
            Issue.record("Expected value entry")
            return
        }
        #expect(metadata.label == nil)
        #expect(metadata.description == nil)
    }

    @Test("displayLabel falls back to key when label is nil")
    func displayLabelFallback() {
        let entry = ConfigEntry.value(key: "BASE_URL", type: .string, value: .string(""), metadata: ConfigMetadata())
        #expect(entry.displayLabel == "BASE_URL")
    }

    @Test("displayLabel falls back to key when label is empty")
    func displayLabelFallbackEmpty() {
        let entry = ConfigEntry.value(key: "BASE_URL", type: .string, value: .string(""), metadata: ConfigMetadata(label: ""))
        #expect(entry.displayLabel == "BASE_URL")
    }

    @Test("displayLabel uses label when present")
    func displayLabelUsesLabel() {
        let entry = ConfigEntry.value(key: "BASE_URL", type: .string, value: .string(""), metadata: ConfigMetadata(label: "Base URL"))
        #expect(entry.displayLabel == "Base URL")
    }

    @Test("displayLabel works for secret entries")
    func displayLabelSecret() {
        let entry = ConfigEntry.secret(secretKey: "API_KEY", type: .string, metadata: ConfigMetadata(label: "API Key"))
        #expect(entry.displayLabel == "API Key")
    }

    @Test("encodes config entry with label and description")
    func encodesMetadata() throws {
        let entry = ConfigEntry.value(
            key: "api-url", type: .string, value: .string(""),
            metadata: ConfigMetadata(label: "API URL", description: "The base URL")
        )
        let data = try JSONEncoder().encode(entry)
        let dict = try JSONDecoder().decode([String: String].self, from: data)
        #expect(dict["label"] == "API URL")
        #expect(dict["description"] == "The base URL")
    }

    @Test("omits label and description from encoding when nil")
    func encodesWithoutMetadata() throws {
        let entry = ConfigEntry.value(
            key: "api-url", type: .string, value: .string(""),
            metadata: ConfigMetadata()
        )
        let data = try JSONEncoder().encode(entry)
        let json = String(data: data, encoding: .utf8)!
        #expect(!json.contains("label"))
        #expect(!json.contains("description"))
    }

    // MARK: - PluginManifest

    @Test func manifestEncodeRoundTrip() throws {
        let original = PluginManifest(
            identifier: "com.test.roundtrip",
            name: "TestPlugin",
            type: .static,
            pluginSchemaVersion: "1.0",
            pluginVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
            config: [.value(key: "url", type: .string, value: .string("http://example.com"), metadata: ConfigMetadata())],
            setup: nil,
            dependencies: nil
        )
        let data = try JSONEncoder.piqley.encode(original)
        let decoded = try JSONDecoder.piqley.decode(PluginManifest.self, from: data)
        #expect(decoded.identifier == original.identifier)
        #expect(decoded.name == original.name)
        #expect(decoded.type == original.type)
        #expect(decoded.pluginSchemaVersion == original.pluginSchemaVersion)
        #expect(decoded.pluginVersion == original.pluginVersion)
        #expect(decoded.config.count == original.config.count)
    }

    // MARK: - PluginType

    @Test func decodeStaticType() throws {
        let json = """
        {
            "identifier": "com.test.static-plugin",
            "name": "StaticPlugin",
            "type": "static",
            "pluginSchemaVersion": "1"
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        #expect(manifest.type == .static)
    }

    @Test func decodeMutableType() throws {
        let json = """
        {
            "identifier": "com.test.mutable-plugin",
            "name": "MutablePlugin",
            "type": "mutable",
            "pluginSchemaVersion": "1"
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        #expect(manifest.type == .mutable)
    }

    @Test func decodeMissingTypeThrows() {
        let json = """
        {
            "identifier": "com.test.no-type",
            "name": "NoTypePlugin",
            "pluginSchemaVersion": "1"
        }
        """
        #expect(throws: (any Error).self) {
            try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        }
    }
}
