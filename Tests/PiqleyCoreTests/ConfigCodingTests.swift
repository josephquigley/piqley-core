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
            "emit": [{"field": "status", "values": ["draft", "wip"]}]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.match.hook == "pre-process")
        #expect(rule.match.field == "title")
        #expect(rule.match.pattern == "^Draft")
        #expect(rule.emit[0].field == "status")
        #expect(rule.emit[0].values == ["draft", "wip"])
    }

    @Test func decodeMinimalRule() throws {
        let json = """
        {
            "match": {"field": "title", "pattern": ".*"},
            "emit": [{"field": "keywords", "values": ["any"]}]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.match.hook == nil)
        #expect(rule.match.field == "title")
        #expect(rule.match.pattern == ".*")
        #expect(rule.emit[0].action == nil)
        #expect(rule.emit[0].field == "keywords")
        #expect(rule.emit[0].values == ["any"])
    }

    @Test func encodeRoundTripRule() throws {
        let rule = Rule(
            match: MatchConfig(hook: "publish", field: "category", pattern: "tech"),
            emit: [EmitConfig(field: "tag", values: ["technology"])]
        )
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(Rule.self, from: data)
        #expect(decoded.match.hook == rule.match.hook)
        #expect(decoded.match.field == rule.match.field)
        #expect(decoded.match.pattern == rule.match.pattern)
        #expect(decoded.emit[0].field == rule.emit[0].field)
        #expect(decoded.emit[0].values == rule.emit[0].values)
    }

    // MARK: - Emit actions

    @Test func decodeEmitConfigWithAction() throws {
        let json = """
        {
            "match": {"field": "title", "pattern": "^Draft"},
            "emit": [{"action": "remove", "field": "keywords", "values": ["draft"]}]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.emit.count == 1)
        #expect(rule.emit[0].action == "remove")
        #expect(rule.emit[0].field == "keywords")
        #expect(rule.emit[0].values == ["draft"])
    }

    @Test func decodeReplaceAction() throws {
        let json = """
        {
            "match": {"field": "title", "pattern": ".*"},
            "emit": [{
                "action": "replace",
                "field": "keywords",
                "replacements": [
                    {"pattern": "regex:SONY(.+)", "replacement": "Sony $1"},
                    {"pattern": "old", "replacement": "new"}
                ]
            }]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.emit[0].action == "replace")
        #expect(rule.emit[0].replacements?.count == 2)
        #expect(rule.emit[0].replacements?[0].pattern == "regex:SONY(.+)")
        #expect(rule.emit[0].replacements?[0].replacement == "Sony $1")
    }

    @Test func decodeRemoveFieldAction() throws {
        let json = """
        {
            "match": {"field": "title", "pattern": ".*"},
            "emit": [{"action": "removeField", "field": "*"}]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.emit[0].action == "removeField")
        #expect(rule.emit[0].field == "*")
        #expect(rule.emit[0].values == nil)
    }

    @Test func decodeMultipleEmitActions() throws {
        let json = """
        {
            "match": {"field": "title", "pattern": ".*"},
            "emit": [
                {"action": "removeField", "field": "keywords"},
                {"field": "keywords", "values": ["fresh"]}
            ]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.emit.count == 2)
        #expect(rule.emit[0].action == "removeField")
        #expect(rule.emit[1].action == nil)
        #expect(rule.emit[1].values == ["fresh"])
    }

    // MARK: - Write array

    @Test func decodeRuleWithWrite() throws {
        let json = """
        {
            "match": {"field": "original:TIFF:Model", "pattern": "Canon"},
            "emit": [{"field": "keywords", "values": ["canon"]}],
            "write": [{"action": "add", "field": "IPTC:Keywords", "values": ["canon"]}]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.write.count == 1)
        #expect(rule.write[0].action == "add")
        #expect(rule.write[0].field == "IPTC:Keywords")
    }

    @Test func decodeRuleWithoutWriteDefaultsEmpty() throws {
        let json = """
        {
            "match": {"field": "title", "pattern": ".*"},
            "emit": [{"field": "keywords", "values": ["any"]}]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.write.isEmpty)
    }

    @Test func encodeRoundTripRuleWithWrite() throws {
        let rule = Rule(
            match: MatchConfig(field: "title", pattern: "test"),
            emit: [EmitConfig(field: "keywords", values: ["a"])],
            write: [EmitConfig(action: "remove", field: "IPTC:Keywords", values: ["old"])]
        )
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(Rule.self, from: data)
        #expect(decoded.write.count == 1)
        #expect(decoded.write[0].action == "remove")
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
                    "emit": [{"field": "keywords", "values": ["any"]}]
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
                emit: [EmitConfig(field: "keywords", values: ["z"])]
            )]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PluginConfig.self, from: data)
        #expect(decoded.values["url"] == .string("http://example.com"))
        #expect(decoded.isSetUp == false)
        #expect(decoded.rules.count == 1)
    }
}
