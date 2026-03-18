import Testing
import Foundation
@testable import PiqleyCore

@Suite("ManifestCoding")
struct ManifestCodingTests {

    // MARK: - ConfigEntry

    @Test func decodeValueEntry() throws {
        let json = #"{"key": "myKey", "type": "string", "value": "hello"}"#
        let entry = try JSONDecoder().decode(ConfigEntry.self, from: Data(json.utf8))
        guard case .value(let key, let type_, let value) = entry else {
            Issue.record("Expected .value case")
            return
        }
        #expect(key == "myKey")
        #expect(type_ == .string)
        #expect(value == .string("hello"))
    }

    @Test func decodeValueEntryWithDefault() throws {
        let json = #"{"key": "count", "type": "int", "value": 42}"#
        let entry = try JSONDecoder().decode(ConfigEntry.self, from: Data(json.utf8))
        guard case .value(let key, let type_, let value) = entry else {
            Issue.record("Expected .value case")
            return
        }
        #expect(key == "count")
        #expect(type_ == .int)
        #expect(value == .number(42))
    }

    @Test func decodeSecretEntry() throws {
        let json = #"{"secret_key": "API_TOKEN", "type": "string"}"#
        let entry = try JSONDecoder().decode(ConfigEntry.self, from: Data(json.utf8))
        guard case .secret(let secretKey, let type_) = entry else {
            Issue.record("Expected .secret case")
            return
        }
        #expect(secretKey == "API_TOKEN")
        #expect(type_ == .string)
    }

    @Test func decodeBothKeysThrows() throws {
        let json = #"{"key": "foo", "secret_key": "BAR", "type": "string", "value": "x"}"#
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(ConfigEntry.self, from: Data(json.utf8))
        }
    }

    @Test func decodeNeitherKeyThrows() throws {
        let json = #"{"type": "string", "value": "x"}"#
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(ConfigEntry.self, from: Data(json.utf8))
        }
    }

    @Test func encodeRoundTripValue() throws {
        let original = ConfigEntry.value(key: "myKey", type: .string, value: .string("hello"))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigEntry.self, from: data)
        guard case .value(let key, let type_, let value) = decoded else {
            Issue.record("Expected .value case")
            return
        }
        #expect(key == "myKey")
        #expect(type_ == .string)
        #expect(value == .string("hello"))
    }

    @Test func encodeRoundTripSecret() throws {
        let original = ConfigEntry.secret(secretKey: "API_TOKEN", type: .string)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ConfigEntry.self, from: data)
        guard case .secret(let secretKey, let type_) = decoded else {
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
        let hook = try JSONDecoder().decode(HookConfig.self, from: Data(json.utf8))
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
        let hook = try JSONDecoder().decode(HookConfig.self, from: Data(json.utf8))
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
        let setup = try JSONDecoder().decode(SetupConfig.self, from: Data(json.utf8))
        #expect(setup.command == "setup.sh")
        #expect(setup.args == ["--init"])
    }

    @Test func decodeSetupConfigWithoutArgs() throws {
        let json = #"{"command": "setup.sh"}"#
        let setup = try JSONDecoder().decode(SetupConfig.self, from: Data(json.utf8))
        #expect(setup.command == "setup.sh")
        #expect(setup.args == [])
    }

    // MARK: - BatchProxyConfig

    @Test func decodeBatchProxyWithSort() throws {
        let json = #"{"sort": {"key": "date", "order": "ascending"}}"#
        let proxy = try JSONDecoder().decode(BatchProxyConfig.self, from: Data(json.utf8))
        #expect(proxy.sort?.key == "date")
        #expect(proxy.sort?.order == .ascending)
    }

    @Test func decodeBatchProxyWithoutSort() throws {
        let json = "{}"
        let proxy = try JSONDecoder().decode(BatchProxyConfig.self, from: Data(json.utf8))
        #expect(proxy.sort == nil)
    }

    @Test func sortOrderRawValues() {
        #expect(SortOrder.ascending.rawValue == "ascending")
        #expect(SortOrder.descending.rawValue == "descending")
    }
}
