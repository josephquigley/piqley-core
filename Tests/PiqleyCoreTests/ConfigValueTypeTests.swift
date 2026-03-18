import Testing
import Foundation
@testable import PiqleyCore

@Suite("ConfigValueType")
struct ConfigValueTypeTests {

    @Test func rawValueString() {
        #expect(ConfigValueType.string.rawValue == "string")
    }

    @Test func rawValueInt() {
        #expect(ConfigValueType.int.rawValue == "int")
    }

    @Test func rawValueFloat() {
        #expect(ConfigValueType.float.rawValue == "float")
    }

    @Test func rawValueBool() {
        #expect(ConfigValueType.bool.rawValue == "bool")
    }

    @Test func decodeString() throws {
        let json = #""string""#
        let value = try JSONDecoder().decode(ConfigValueType.self, from: Data(json.utf8))
        #expect(value == .string)
    }

    @Test func decodeInt() throws {
        let json = #""int""#
        let value = try JSONDecoder().decode(ConfigValueType.self, from: Data(json.utf8))
        #expect(value == .int)
    }

    @Test func decodeFloat() throws {
        let json = #""float""#
        let value = try JSONDecoder().decode(ConfigValueType.self, from: Data(json.utf8))
        #expect(value == .float)
    }

    @Test func decodeBool() throws {
        let json = #""bool""#
        let value = try JSONDecoder().decode(ConfigValueType.self, from: Data(json.utf8))
        #expect(value == .bool)
    }

    @Test func roundTrip() throws {
        for type_ in [ConfigValueType.string, .int, .float, .bool] {
            let data = try JSONEncoder().encode(type_)
            let decoded = try JSONDecoder().decode(ConfigValueType.self, from: data)
            #expect(decoded == type_)
        }
    }
}

@Suite("PluginProtocol")
struct PluginProtocolTests {

    @Test func rawValueJSON() {
        #expect(PluginProtocol.json.rawValue == "json")
    }

    @Test func rawValuePipe() {
        #expect(PluginProtocol.pipe.rawValue == "pipe")
    }

    @Test func decodeJSON() throws {
        let json = #""json""#
        let value = try JSONDecoder().decode(PluginProtocol.self, from: Data(json.utf8))
        #expect(value == .json)
    }

    @Test func decodePipe() throws {
        let json = #""pipe""#
        let value = try JSONDecoder().decode(PluginProtocol.self, from: Data(json.utf8))
        #expect(value == .pipe)
    }

    @Test func roundTrip() throws {
        for proto in [PluginProtocol.json, .pipe] {
            let data = try JSONEncoder().encode(proto)
            let decoded = try JSONDecoder().decode(PluginProtocol.self, from: data)
            #expect(decoded == proto)
        }
    }
}
