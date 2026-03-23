import Testing
import Foundation
@testable import PiqleyCore

@Suite("StandardHook")
struct HookTests {

    // MARK: - Raw values

    @Test func rawValuePipelineStart() {
        #expect(StandardHook.pipelineStart.rawValue == "pipeline-start")
    }

    @Test func rawValuePreProcess() {
        #expect(StandardHook.preProcess.rawValue == "pre-process")
    }

    @Test func rawValuePostProcess() {
        #expect(StandardHook.postProcess.rawValue == "post-process")
    }

    @Test func rawValuePublish() {
        #expect(StandardHook.publish.rawValue == "publish")
    }

    @Test func rawValuePostPublish() {
        #expect(StandardHook.postPublish.rawValue == "post-publish")
    }

    @Test func rawValuePipelineFinished() {
        #expect(StandardHook.pipelineFinished.rawValue == "pipeline-finished")
    }

    // MARK: - Codable

    @Test func encodePreProcess() throws {
        let data = try JSONEncoder().encode(StandardHook.preProcess)
        let string = String(data: data, encoding: .utf8)
        #expect(string == #""pre-process""#)
    }

    @Test func decodePreProcess() throws {
        let json = #""pre-process""#
        let hook = try JSONDecoder().decode(StandardHook.self, from: Data(json.utf8))
        #expect(hook == .preProcess)
    }

    @Test func decodePostPublish() throws {
        let json = #""post-publish""#
        let hook = try JSONDecoder().decode(StandardHook.self, from: Data(json.utf8))
        #expect(hook == .postPublish)
    }

    @Test func decodePipelineStart() throws {
        let json = #""pipeline-start""#
        let hook = try JSONDecoder().decode(StandardHook.self, from: Data(json.utf8))
        #expect(hook == .pipelineStart)
    }

    @Test func decodePipelineFinished() throws {
        let json = #""pipeline-finished""#
        let hook = try JSONDecoder().decode(StandardHook.self, from: Data(json.utf8))
        #expect(hook == .pipelineFinished)
    }

    @Test func roundTripAllCases() throws {
        for hook in StandardHook.allCases {
            let data = try JSONEncoder().encode(hook)
            let decoded = try JSONDecoder().decode(StandardHook.self, from: data)
            #expect(decoded == hook)
        }
    }

    // MARK: - allCases count

    @Test func allCasesCount() {
        #expect(StandardHook.allCases.count == 6)
    }

    // MARK: - canonicalOrder

    @Test func canonicalOrderLength() {
        #expect(StandardHook.canonicalOrder.count == 6)
    }

    @Test func canonicalOrderSequence() {
        #expect(StandardHook.canonicalOrder == [
            .pipelineStart,
            .preProcess,
            .postProcess,
            .publish,
            .postPublish,
            .pipelineFinished
        ])
    }

    // MARK: - Hook protocol conformance

    @Test func conformsToHookProtocol() {
        let hook: any Hook = StandardHook.preProcess
        #expect(hook.rawValue == "pre-process")
    }

    @Test func stageConfigIsEmpty() {
        for hook in StandardHook.allCases {
            #expect(hook.stageConfig.isEmpty)
        }
    }
}
