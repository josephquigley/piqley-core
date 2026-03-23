import Testing
import Foundation
@testable import PiqleyCore

@Suite("JSONValue")
struct JSONValueTests {

    // MARK: - Decode each type

    @Test func decodeString() throws {
        let json = #""hello""#
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value == .string("hello"))
    }

    @Test func decodeNumber() throws {
        let json = "42.5"
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value == .number(42.5))
    }

    @Test func decodeIntAsNumber() throws {
        let json = "7"
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value == .number(7))
    }

    @Test func decodeBoolTrue() throws {
        let json = "true"
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value == .bool(true))
    }

    @Test func decodeBoolFalse() throws {
        let json = "false"
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value == .bool(false))
    }

    @Test func decodeNull() throws {
        let json = "null"
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value == .null)
    }

    @Test func decodeArray() throws {
        let json = #"[1, "two", true]"#
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value == .array([.number(1), .string("two"), .bool(true)]))
    }

    @Test func decodeObject() throws {
        let json = #"{"key": "value"}"#
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value == .object(["key": .string("value")]))
    }

    // MARK: - Encode round-trip

    @Test func roundTripString() throws {
        let original = JSONValue.string("hello")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == original)
    }

    @Test func roundTripNumber() throws {
        let original = JSONValue.number(3.14)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == original)
    }

    @Test func roundTripBool() throws {
        let original = JSONValue.bool(false)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == original)
    }

    @Test func roundTripNull() throws {
        let original = JSONValue.null
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == original)
    }

    @Test func roundTripArray() throws {
        let original = JSONValue.array([.number(1), .string("two"), .bool(true), .null])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == original)
    }

    @Test func roundTripObject() throws {
        let original = JSONValue.object(["a": .number(1), "b": .string("hi")])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - ExpressibleBy conformances

    @Test func expressibleByStringLiteral() {
        let value: JSONValue = "hello"
        #expect(value == .string("hello"))
    }

    @Test func expressibleByIntegerLiteral() {
        let value: JSONValue = 42
        #expect(value == .number(42))
    }

    @Test func expressibleByFloatLiteral() {
        let value: JSONValue = 3.14
        #expect(value == .number(3.14))
    }

    @Test func expressibleByBoolLiteral() {
        let value: JSONValue = true
        #expect(value == .bool(true))
    }

    @Test func expressibleByNilLiteral() {
        let value: JSONValue = nil
        #expect(value == .null)
    }

    @Test func expressibleByArrayLiteral() {
        let value: JSONValue = [1, "two", true]
        #expect(value == .array([.number(1), .string("two"), .bool(true)]))
    }

    @Test func expressibleByDictionaryLiteral() {
        let value: JSONValue = ["key": "value"]
        #expect(value == .object(["key": .string("value")]))
    }

    // MARK: - Convenience accessors

    @Test func stringValueReturnsString() {
        #expect(JSONValue.string("hello").stringValue == "hello")
    }

    @Test func stringValueReturnsNilForNonString() {
        #expect(JSONValue.number(42).stringValue == nil)
        #expect(JSONValue.bool(true).stringValue == nil)
        #expect(JSONValue.null.stringValue == nil)
    }

    @Test func numberValueReturnsDouble() {
        #expect(JSONValue.number(3.14).numberValue == 3.14)
    }

    @Test func numberValueReturnsNilForNonNumber() {
        #expect(JSONValue.string("42").numberValue == nil)
        #expect(JSONValue.bool(true).numberValue == nil)
    }

    @Test func boolValueReturnsBool() {
        #expect(JSONValue.bool(true).boolValue == true)
        #expect(JSONValue.bool(false).boolValue == false)
    }

    @Test func boolValueReturnsNilForNonBool() {
        #expect(JSONValue.string("true").boolValue == nil)
        #expect(JSONValue.number(1).boolValue == nil)
    }

    @Test func arrayValueReturnsArray() {
        let arr: [JSONValue] = [.number(1), .string("two")]
        #expect(JSONValue.array(arr).arrayValue == arr)
    }

    @Test func arrayValueReturnsNilForNonArray() {
        #expect(JSONValue.string("[]").arrayValue == nil)
    }

    @Test func objectValueReturnsObject() {
        let obj: [String: JSONValue] = ["key": .string("value")]
        #expect(JSONValue.object(obj).objectValue == obj)
    }

    @Test func objectValueReturnsNilForNonObject() {
        #expect(JSONValue.string("{}").objectValue == nil)
    }

    @Test func intValueReturnsInt() {
        #expect(JSONValue.number(42).intValue == 42)
    }

    @Test func intValueReturnsNilForNonNumber() {
        #expect(JSONValue.string("42").intValue == nil)
    }

    @Test func intValueReturnsNilForNonIntegerNumber() {
        #expect(JSONValue.number(3.14).intValue == nil)
    }
}
