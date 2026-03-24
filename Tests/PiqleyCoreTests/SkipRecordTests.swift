import Testing
import Foundation
@testable import PiqleyCore

@Suite("SkipRecord")
struct SkipRecordTests {
    @Test func encodesAndDecodes() throws {
        let record = SkipRecord(file: "IMG_001.jpg", plugin: "com.test.plugin")
        let data = try JSONEncoder.piqley.encode(record)
        let decoded = try JSONDecoder.piqley.decode(SkipRecord.self, from: data)
        #expect(decoded == record)
        #expect(decoded.file == "IMG_001.jpg")
        #expect(decoded.plugin == "com.test.plugin")
    }

    @Test func decodesFromJSON() throws {
        let json = #"{"file":"IMG_001.jpg","plugin":"com.test.plugin"}"#
        let record = try JSONDecoder.piqley.decode(SkipRecord.self, from: json.data(using: .utf8)!)
        #expect(record.file == "IMG_001.jpg")
        #expect(record.plugin == "com.test.plugin")
    }

    @Test func payloadDecodesWithoutSkippedField() throws {
        let json = """
        {
            "hook": "publish",
            "imageFolderPath": "/tmp/images",
            "pluginConfig": {},
            "secrets": {},
            "executionLogPath": "/tmp/log",
            "dataPath": "/tmp/data",
            "logPath": "/tmp/log.txt",
            "dryRun": false,
            "pluginVersion": "1.0.0"
        }
        """
        let payload = try JSONDecoder.piqley.decode(PluginInputPayload.self, from: json.data(using: .utf8)!)
        #expect(payload.skipped.isEmpty)
    }

    @Test func payloadDecodesWithSkippedField() throws {
        let json = """
        {
            "hook": "publish",
            "imageFolderPath": "/tmp/images",
            "pluginConfig": {},
            "secrets": {},
            "executionLogPath": "/tmp/log",
            "dataPath": "/tmp/data",
            "logPath": "/tmp/log.txt",
            "dryRun": false,
            "pluginVersion": "1.0.0",
            "skipped": [{"file": "IMG_001.jpg", "plugin": "com.test.plugin"}]
        }
        """
        let payload = try JSONDecoder.piqley.decode(PluginInputPayload.self, from: json.data(using: .utf8)!)
        #expect(payload.skipped.count == 1)
        #expect(payload.skipped[0].file == "IMG_001.jpg")
    }
}
