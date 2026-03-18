import Testing
import Foundation
@testable import PiqleyCore

@Suite("ConfigCoding")
struct ConfigCodingTests {

    // MARK: - Rule / MatchConfig / EmitConfig

    @Test func decodeRule() throws {
        let json = """
        {
            "match": {"hook": "pre-process", "field": "title", "pattern": "^Draft"},
            "emit": {"field": "status", "values": ["draft", "wip"]}
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.match.hook == "pre-process")
        #expect(rule.match.field == "title")
        #expect(rule.match.pattern == "^Draft")
        #expect(rule.emit.field == "status")
        #expect(rule.emit.values == ["draft", "wip"])
    }

    @Test func decodeMinimalRule() throws {
        let json = """
        {
            "match": {"field": "title", "pattern": ".*"},
            "emit": {"values": ["any"]}
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.match.hook == nil)
        #expect(rule.match.field == "title")
        #expect(rule.match.pattern == ".*")
        #expect(rule.emit.field == nil)
        #expect(rule.emit.values == ["any"])
    }

    @Test func encodeRoundTripRule() throws {
        let rule = Rule(
            match: MatchConfig(hook: "publish", field: "category", pattern: "tech"),
            emit: EmitConfig(field: "tag", values: ["technology"])
        )
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(Rule.self, from: data)
        #expect(decoded.match.hook == rule.match.hook)
        #expect(decoded.match.field == rule.match.field)
        #expect(decoded.match.pattern == rule.match.pattern)
        #expect(decoded.emit.field == rule.emit.field)
        #expect(decoded.emit.values == rule.emit.values)
    }

    // MARK: - PluginConfig

    @Test func decodePluginConfigWithRules() throws {
        let json = """
        {
            "values": {"apiUrl": "https://example.com", "retries": 3},
            "isSetUp": true,
            "rules": [
                {
                    "match": {"field": "title", "pattern": ".*"},
                    "emit": {"values": ["any"]}
                }
            ]
        }
        """
        let config = try JSONDecoder().decode(PluginConfig.self, from: Data(json.utf8))
        #expect(config.values["apiUrl"] == .string("https://example.com"))
        #expect(config.values["retries"] == .number(3))
        #expect(config.isSetUp == true)
        #expect(config.rules.count == 1)
    }

    @Test func decodeEmptyPluginConfig() throws {
        let json = "{}"
        let config = try JSONDecoder().decode(PluginConfig.self, from: Data(json.utf8))
        #expect(config.values.isEmpty)
        #expect(config.isSetUp == nil)
        #expect(config.rules.isEmpty)
    }

    @Test func decodePluginConfigWithoutRules() throws {
        let json = #"{"values": {"key": "val"}}"#
        let config = try JSONDecoder().decode(PluginConfig.self, from: Data(json.utf8))
        #expect(config.values["key"] == .string("val"))
        #expect(config.rules.isEmpty)
    }

    @Test func encodeRoundTripPluginConfig() throws {
        let original = PluginConfig(
            values: ["url": .string("http://example.com")],
            isSetUp: false,
            rules: [Rule(
                match: MatchConfig(hook: nil, field: "x", pattern: "y"),
                emit: EmitConfig(field: nil, values: ["z"])
            )]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PluginConfig.self, from: data)
        #expect(decoded.values["url"] == .string("http://example.com"))
        #expect(decoded.isSetUp == false)
        #expect(decoded.rules.count == 1)
    }
}
