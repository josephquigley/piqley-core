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
}
