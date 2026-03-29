import Testing
import Foundation
@testable import PiqleyCore

@Suite("ConsumedField")
struct ConsumedFieldTests {

    @Test func decodesFullJSON() throws {
        let json = """
        {
            "name": "tags",
            "type": "csv",
            "description": "Comma-separated tag names",
            "readOnly": false
        }
        """
        let field = try JSONDecoder.piqley.decode(ConsumedField.self, from: Data(json.utf8))
        #expect(field.name == "tags")
        #expect(field.type == "csv")
        #expect(field.description == "Comma-separated tag names")
        #expect(field.readOnly == false)
    }

    @Test func decodesMinimalJSON() throws {
        let json = """
        {"name": "title", "readOnly": true}
        """
        let field = try JSONDecoder.piqley.decode(ConsumedField.self, from: Data(json.utf8))
        #expect(field.name == "title")
        #expect(field.type == nil)
        #expect(field.description == nil)
        #expect(field.readOnly == true)
    }

    @Test func manifestDecodesWithFields() throws {
        let json = """
        {
            "identifier": "test-plugin",
            "name": "Test",
            "pluginSchemaVersion": "1",
            "fields": [
                {"name": "tags", "type": "csv", "readOnly": false},
                {"name": "rating", "readOnly": true}
            ]
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        #expect(manifest.fields.count == 2)
        #expect(manifest.fields[0].name == "tags")
        #expect(manifest.fields[0].readOnly == false)
        #expect(manifest.fields[1].name == "rating")
        #expect(manifest.fields[1].readOnly == true)
    }

    @Test func manifestDecodesWithoutFieldsDefaultsToEmpty() throws {
        let json = """
        {
            "identifier": "test-plugin",
            "name": "Test",
            "pluginSchemaVersion": "1"
        }
        """
        let manifest = try JSONDecoder.piqley.decode(PluginManifest.self, from: Data(json.utf8))
        #expect(manifest.fields.isEmpty)
    }
}
