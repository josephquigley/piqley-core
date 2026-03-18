import Testing
import Foundation
@testable import PiqleyCore

@Suite("Hook")
struct HookTests {

    // MARK: - Raw values

    @Test func rawValuePreProcess() {
        #expect(Hook.preProcess.rawValue == "pre-process")
    }

    @Test func rawValuePostProcess() {
        #expect(Hook.postProcess.rawValue == "post-process")
    }

    @Test func rawValuePublish() {
        #expect(Hook.publish.rawValue == "publish")
    }

    @Test func rawValueSchedule() {
        #expect(Hook.schedule.rawValue == "schedule")
    }

    @Test func rawValuePostPublish() {
        #expect(Hook.postPublish.rawValue == "post-publish")
    }

    // MARK: - Codable

    @Test func encodePreProcess() throws {
        let data = try JSONEncoder().encode(Hook.preProcess)
        let string = String(data: data, encoding: .utf8)
        #expect(string == #""pre-process""#)
    }

    @Test func decodePreProcess() throws {
        let json = #""pre-process""#
        let hook = try JSONDecoder().decode(Hook.self, from: Data(json.utf8))
        #expect(hook == .preProcess)
    }

    @Test func decodePostPublish() throws {
        let json = #""post-publish""#
        let hook = try JSONDecoder().decode(Hook.self, from: Data(json.utf8))
        #expect(hook == .postPublish)
    }

    @Test func roundTripAllCases() throws {
        for hook in Hook.allCases {
            let data = try JSONEncoder().encode(hook)
            let decoded = try JSONDecoder().decode(Hook.self, from: data)
            #expect(decoded == hook)
        }
    }

    // MARK: - allCases count

    @Test func allCasesCount() {
        #expect(Hook.allCases.count == 5)
    }

    // MARK: - canonicalOrder

    @Test func canonicalOrderLength() {
        #expect(Hook.canonicalOrder.count == 5)
    }

    @Test func canonicalOrderSequence() {
        #expect(Hook.canonicalOrder == [
            .preProcess,
            .postProcess,
            .publish,
            .schedule,
            .postPublish
        ])
    }
}
