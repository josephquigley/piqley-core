import Testing
import Foundation
@testable import PiqleyCore

@Suite("ConfigCoding")
struct ConfigCodingTests {

    // MARK: - Rule / MatchConfig / EmitConfig

    @Test func decodeRule() throws {
        let json = """
        {
            "match": {"field": "title", "pattern": "^Draft"},
            "emit": [{"field": "status", "values": ["draft", "wip"]}]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
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
        #expect(rule.match.field == "title")
        #expect(rule.match.pattern == ".*")
        #expect(rule.emit[0].action == nil)
        #expect(rule.emit[0].field == "keywords")
        #expect(rule.emit[0].values == ["any"])
    }

    @Test func encodeRoundTripRule() throws {
        let rule = Rule(
            match: MatchConfig(field: "category", pattern: "tech"),
            emit: [EmitConfig(field: "tag", values: ["technology"])]
        )
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(Rule.self, from: data)
        #expect(decoded.match.field == rule.match.field)
        #expect(decoded.match.pattern == rule.match.pattern)
        #expect(decoded.emit[0].field == rule.emit[0].field)
        #expect(decoded.emit[0].values == rule.emit[0].values)
    }

    @Test func decodeMatchConfigIgnoresHookField() throws {
        let json = """
        {
            "match": {"hook": "pre-process", "field": "title", "pattern": "test"},
            "emit": [{"field": "keywords", "values": ["a"]}]
        }
        """
        let rule = try JSONDecoder().decode(Rule.self, from: Data(json.utf8))
        #expect(rule.match.field == "title")
        #expect(rule.match.pattern == "test")
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

    @Test func decodePluginConfigIgnoresLegacyRules() throws {
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
    }

    @Test func decodeEmptyPluginConfig() throws {
        let json = "{}"
        let config = try JSONDecoder().decode(PluginConfig.self, from: Data(json.utf8))
        #expect(config.values.isEmpty)
        #expect(config.isSetUp == nil)
    }

    @Test func decodePluginConfigWithoutRules() throws {
        let json = #"{"values": {"key": "val"}}"#
        let config = try JSONDecoder().decode(PluginConfig.self, from: Data(json.utf8))
        #expect(config.values["key"] == .string("val"))
    }

    @Test func encodeRoundTripPluginConfig() throws {
        let original = PluginConfig(
            values: ["url": .string("http://example.com")],
            isSetUp: false
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PluginConfig.self, from: data)
        #expect(decoded.values["url"] == .string("http://example.com"))
        #expect(decoded.isSetUp == false)
    }

    // MARK: - StageConfig

    @Test func decodeFullStageConfig() throws {
        let json = """
        {
            "preRules": [
                {
                    "match": {"field": "original:TIFF:Model", "pattern": "glob:Canon*"},
                    "emit": [{"field": "keywords", "values": ["canon"]}]
                }
            ],
            "binary": {
                "command": "./bin/my-plugin",
                "args": ["--quality", "high"],
                "timeout": 60,
                "protocol": "json"
            },
            "postRules": [
                {
                    "match": {"field": "my-plugin:status", "pattern": "done"},
                    "emit": [{"field": "keywords", "values": ["processed"]}],
                    "write": [{"action": "add", "field": "IPTC:Keywords", "values": ["processed"]}]
                }
            ]
        }
        """
        let stage = try JSONDecoder().decode(StageConfig.self, from: Data(json.utf8))
        #expect(stage.preRules?.count == 1)
        #expect(stage.preRules?[0].match.field == "original:TIFF:Model")
        #expect(stage.binary?.command == "./bin/my-plugin")
        #expect(stage.binary?.timeout == 60)
        #expect(stage.postRules?.count == 1)
        #expect(stage.postRules?[0].write.count == 1)
    }

    @Test func decodeBinaryOnlyStageConfig() throws {
        let json = """
        {
            "binary": {"command": "./bin/tool", "timeout": 30}
        }
        """
        let stage = try JSONDecoder().decode(StageConfig.self, from: Data(json.utf8))
        #expect(stage.preRules == nil)
        #expect(stage.binary?.command == "./bin/tool")
        #expect(stage.postRules == nil)
    }

    @Test func decodeRulesOnlyStageConfig() throws {
        let json = """
        {
            "preRules": [
                {
                    "match": {"field": "title", "pattern": ".*"},
                    "emit": [{"field": "keywords", "values": ["tagged"]}]
                }
            ]
        }
        """
        let stage = try JSONDecoder().decode(StageConfig.self, from: Data(json.utf8))
        #expect(stage.preRules?.count == 1)
        #expect(stage.binary == nil)
        #expect(stage.postRules == nil)
    }

    @Test func decodeEmptyStageConfig() throws {
        let json = "{}"
        let stage = try JSONDecoder().decode(StageConfig.self, from: Data(json.utf8))
        #expect(stage.preRules == nil)
        #expect(stage.binary == nil)
        #expect(stage.postRules == nil)
    }

    @Test func encodeRoundTripStageConfig() throws {
        let stage = StageConfig(
            preRules: [Rule(
                match: MatchConfig(field: "title", pattern: "test"),
                emit: [EmitConfig(field: "keywords", values: ["a"])]
            )],
            binary: HookConfig(command: "./bin/tool", timeout: 30),
            postRules: nil
        )
        let data = try JSONEncoder().encode(stage)
        let decoded = try JSONDecoder().decode(StageConfig.self, from: data)
        #expect(decoded.preRules?.count == 1)
        #expect(decoded.binary?.command == "./bin/tool")
        #expect(decoded.postRules == nil)
    }

    @Test func stageConfigIsEmpty() {
        let empty = StageConfig(preRules: nil, binary: nil, postRules: nil)
        #expect(empty.isEmpty)

        let notEmpty = StageConfig(
            preRules: [Rule(match: MatchConfig(field: "x", pattern: "y"), emit: [])],
            binary: nil,
            postRules: nil
        )
        #expect(!notEmpty.isEmpty)
    }
}
