import Testing
import Foundation
@testable import PiqleyCore

@Suite("PluginDependency")
struct PluginDependencyTests {

    @Test func decodesFromJSON() throws {
        let json = """
        {
            "url": "https://example.com/dep.piqleyplugin",
            "version": {
                "from": "1.2.0",
                "rule": "upToNextMajor"
            }
        }
        """
        let dep = try JSONDecoder.piqley.decode(PluginDependency.self, from: Data(json.utf8))
        #expect(dep.url == "https://example.com/dep.piqleyplugin")
        #expect(dep.version.from == SemanticVersion(major: 1, minor: 2, patch: 0))
        #expect(dep.version.rule == .upToNextMajor)
        #expect(dep.name == nil)
    }

    @Test func encodesRoundTrip() throws {
        let original = PluginDependency(
            url: "https://example.com/plugin.piqleyplugin",
            version: VersionConstraint(
                from: SemanticVersion(major: 2, minor: 0, patch: 1),
                rule: .exact
            )
        )
        let data = try JSONEncoder.piqley.encode(original)
        let decoded = try JSONDecoder.piqley.decode(PluginDependency.self, from: data)
        #expect(decoded == original)
    }

    @Test func allRulesRoundTrip() throws {
        for rule in VersionRule.allCases {
            let constraint = VersionConstraint(
                from: SemanticVersion(major: 1, minor: 0, patch: 0),
                rule: rule
            )
            let dep = PluginDependency(url: "https://example.com/p", version: constraint)
            let data = try JSONEncoder.piqley.encode(dep)
            let decoded = try JSONDecoder.piqley.decode(PluginDependency.self, from: data)
            #expect(decoded.version.rule == rule)
        }
    }

    @Test func manifestDecodesStructuredDependencies() throws {
        let json = """
        {
            "identifier": "com.test.my-plugin",
            "name": "MyPlugin",
            "pluginSchemaVersion": "1.0",
            "dependencies": [
                {
                    "url": "https://example.com/dep.piqleyplugin",
                    "version": {"from": "1.0.0", "rule": "upToNextMajor"}
                }
            ]
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        #expect(manifest.dependencies?.count == 1)
        #expect(manifest.dependencies?.first?.url == "https://example.com/dep.piqleyplugin")
        #expect(manifest.dependencies?.first?.version.rule == .upToNextMajor)
    }

    @Test func manifestDecodesLegacyStringDependencies() throws {
        let json = """
        {
            "identifier": "com.test.legacy",
            "name": "LegacyPlugin",
            "pluginSchemaVersion": "1.0",
            "dependencies": ["other-plugin", "another"]
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        #expect(manifest.dependencies?.count == 2)
        #expect(manifest.dependencies?[0].name == "other-plugin")
        #expect(manifest.dependencies?[0].url == "")
        #expect(manifest.dependencies?[1].name == "another")
        #expect(manifest.dependencyIdentifiers == ["other-plugin", "another"])
    }
}
