import Testing
import Foundation
@testable import PiqleyCore

@Suite("SkipRecord")
struct SkipRecordTests {
    @Test func encodesAndDecodes() throws {
        let record = SkipRecord(file: "IMG_001.jpg", plugin: "com.test.plugin")
        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(SkipRecord.self, from: data)
        #expect(decoded == record)
        #expect(decoded.file == "IMG_001.jpg")
        #expect(decoded.plugin == "com.test.plugin")
    }

    @Test func decodesFromJSON() throws {
        let json = #"{"file":"IMG_001.jpg","plugin":"com.test.plugin"}"#
        let record = try JSONDecoder().decode(SkipRecord.self, from: json.data(using: .utf8)!)
        #expect(record.file == "IMG_001.jpg")
        #expect(record.plugin == "com.test.plugin")
    }
}
