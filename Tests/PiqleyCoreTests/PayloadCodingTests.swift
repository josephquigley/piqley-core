import Testing
import Foundation
@testable import PiqleyCore

@Suite("PayloadCoding")
struct PayloadCodingTests {

    // MARK: - PluginInputPayload

    @Test func encodeDecodeInputPayload() throws {
        let payload = PluginInputPayload(
            hook: "pre-process",
            imageFolderPath: "/data/folder",
            pluginConfig: ["apiUrl": .string("https://example.com")],
            secrets: ["API_TOKEN": "secret123"],
            executionLogPath: "/logs/exec.log",
            dataPath: "/data",
            logPath: "/logs/plugin.log",
            dryRun: false,
            debug: false,
            state: nil,
            pluginVersion: SemanticVersion(major: 1, minor: 2, patch: 3),
            lastExecutedVersion: nil
        )
        let data = try JSONEncoder.piqley.encode(payload)
        let decoded = try JSONDecoder.piqley.decode(PluginInputPayload.self, from: data)
        #expect(decoded.hook == "pre-process")
        #expect(decoded.imageFolderPath == "/data/folder")
        #expect(decoded.pluginConfig["apiUrl"] == .string("https://example.com"))
        #expect(decoded.secrets["API_TOKEN"] == "secret123")
        #expect(decoded.executionLogPath == "/logs/exec.log")
        #expect(decoded.dataPath == "/data")
        #expect(decoded.logPath == "/logs/plugin.log")
        #expect(decoded.dryRun == false)
        #expect(decoded.state == nil)
        #expect(decoded.pluginVersion == SemanticVersion(major: 1, minor: 2, patch: 3))
        #expect(decoded.lastExecutedVersion == nil)
        #expect(decoded.pipelineRunId == nil)
    }

    @Test func encodeDecodeInputPayloadWithState() throws {
        let state: [String: [String: [String: JSONValue]]] = [
            "pluginA": [
                "folder1": ["count": .number(5)]
            ]
        ]
        let payload = PluginInputPayload(
            hook: "post-process",
            imageFolderPath: "/data/folder",
            pluginConfig: [:],
            secrets: [:],
            executionLogPath: "/logs/exec.log",
            dataPath: "/data",
            logPath: "/logs/plugin.log",
            dryRun: true,
            debug: false,
            state: state,
            pluginVersion: SemanticVersion(major: 2, minor: 0, patch: 0),
            lastExecutedVersion: SemanticVersion(major: 1, minor: 9, patch: 0)
        )
        let data = try JSONEncoder.piqley.encode(payload)
        let decoded = try JSONDecoder.piqley.decode(PluginInputPayload.self, from: data)
        #expect(decoded.dryRun == true)
        #expect(decoded.state?["pluginA"]?["folder1"]?["count"] == .number(5))
        #expect(decoded.lastExecutedVersion == SemanticVersion(major: 1, minor: 9, patch: 0))
    }

    @Test func encodeDecodeInputPayloadWithPipelineRunId() throws {
        let payload = PluginInputPayload(
            hook: "pipeline-start",
            imageFolderPath: "/data/folder",
            pluginConfig: [:],
            secrets: [:],
            executionLogPath: "/logs/exec.log",
            dataPath: "/data",
            logPath: "/logs/plugin.log",
            dryRun: false,
            debug: false,
            state: nil,
            pluginVersion: SemanticVersion(major: 1, minor: 0, patch: 0),
            lastExecutedVersion: nil,
            pipelineRunId: "550e8400-e29b-41d4-a716-446655440000"
        )
        let data = try JSONEncoder.piqley.encode(payload)
        let decoded = try JSONDecoder.piqley.decode(PluginInputPayload.self, from: data)
        #expect(decoded.pipelineRunId == "550e8400-e29b-41d4-a716-446655440000")
        #expect(decoded.hook == "pipeline-start")
    }

    @Test func decodeInputPayloadWithoutPipelineRunIdBackwardsCompatible() throws {
        let json = """
        {
            "hook": "pre-process",
            "imageFolderPath": "/data/folder",
            "pluginConfig": {},
            "secrets": {},
            "executionLogPath": "/logs/exec.log",
            "dataPath": "/data",
            "logPath": "/logs/plugin.log",
            "dryRun": false,
            "pluginVersion": "1.0.0"
        }
        """
        let payload = try JSONDecoder.piqley.decode(PluginInputPayload.self, from: json.data(using: .utf8)!)
        #expect(payload.pipelineRunId == nil)
    }

    // MARK: - PluginOutputLine

    @Test func decodeOutputLineResult() throws {
        let json = #"{"type": "result", "success": true, "message": "Done"}"#
        let line = try JSONDecoder.piqley.decode(PluginOutputLine.self, from: Data(json.utf8))
        #expect(line.type == "result")
        #expect(line.success == true)
        #expect(line.message == "Done")
        #expect(line.filename == nil)
        #expect(line.error == nil)
        #expect(line.state == nil)
    }

    @Test func decodeOutputLineProgress() throws {
        let json = #"{"type": "progress", "message": "Processing 3 of 10"}"#
        let line = try JSONDecoder.piqley.decode(PluginOutputLine.self, from: Data(json.utf8))
        #expect(line.type == "progress")
        #expect(line.message == "Processing 3 of 10")
        #expect(line.success == nil)
    }

    @Test func decodeOutputLineImageResultSuccess() throws {
        let json = #"{"type": "imageResult", "filename": "photo.jpg", "status": "success"}"#
        let line = try JSONDecoder.piqley.decode(PluginOutputLine.self, from: Data(json.utf8))
        #expect(line.type == "imageResult")
        #expect(line.filename == "photo.jpg")
        #expect(line.status == .success)
    }

    @Test func decodeOutputLineImageResultFailure() throws {
        let json = #"{"type": "imageResult", "filename": "bad.jpg", "status": "failure", "error": "File not found"}"#
        let line = try JSONDecoder.piqley.decode(PluginOutputLine.self, from: Data(json.utf8))
        #expect(line.type == "imageResult")
        #expect(line.filename == "bad.jpg")
        #expect(line.status == .failure)
        #expect(line.error == "File not found")
    }

    @Test func decodeOutputLineImageResultWarning() throws {
        let json = #"{"type": "imageResult", "filename": "dim.jpg", "status": "warning", "error": "low resolution"}"#
        let line = try JSONDecoder.piqley.decode(PluginOutputLine.self, from: Data(json.utf8))
        #expect(line.type == "imageResult")
        #expect(line.filename == "dim.jpg")
        #expect(line.status == .warning)
        #expect(line.error == "low resolution")
    }

    @Test func decodeOutputLineImageResultSkip() throws {
        let json = #"{"type": "imageResult", "filename": "raw.cr3", "status": "skip", "error": "not a supported format"}"#
        let line = try JSONDecoder.piqley.decode(PluginOutputLine.self, from: Data(json.utf8))
        #expect(line.type == "imageResult")
        #expect(line.filename == "raw.cr3")
        #expect(line.status == .skip)
        #expect(line.error == "not a supported format")
    }
}
