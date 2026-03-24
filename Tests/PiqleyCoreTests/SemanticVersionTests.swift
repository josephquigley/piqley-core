import Testing
import Foundation
@testable import PiqleyCore

@Suite("SemanticVersion")
struct SemanticVersionTests {

    // MARK: - Parse valid

    @Test func parseFullVersion() throws {
        let v = try SemanticVersion("1.2.3")
        #expect(v.major == 1)
        #expect(v.minor == 2)
        #expect(v.patch == 3)
    }

    @Test func parseZeroVersion() throws {
        let v = try SemanticVersion("0.0.0")
        #expect(v.major == 0)
        #expect(v.minor == 0)
        #expect(v.patch == 0)
    }

    // MARK: - Parse without patch (defaults to 0)

    @Test func parseTwoComponentVersion() throws {
        let v = try SemanticVersion("1.0")
        #expect(v.major == 1)
        #expect(v.minor == 0)
        #expect(v.patch == 0)
    }

    @Test func parseTwoComponentVersionWithMinor() throws {
        let v = try SemanticVersion("2.5")
        #expect(v.major == 2)
        #expect(v.minor == 5)
        #expect(v.patch == 0)
    }

    // MARK: - Invalid throws

    @Test func invalidSingleComponentThrows() {
        #expect(throws: SemanticVersionError.invalidFormat) {
            try SemanticVersion("1")
        }
    }

    @Test func invalidStringThrows() {
        #expect(throws: SemanticVersionError.invalidFormat) {
            try SemanticVersion("abc")
        }
    }

    @Test func invalidNonNumericThrows() {
        #expect(throws: SemanticVersionError.invalidFormat) {
            try SemanticVersion("1.a.3")
        }
    }

    @Test func tooManyComponentsThrows() {
        #expect(throws: SemanticVersionError.invalidFormat) {
            try SemanticVersion("1.2.3.4")
        }
    }

    // MARK: - Empty throws

    @Test func emptyStringThrows() {
        #expect(throws: SemanticVersionError.invalidFormat) {
            try SemanticVersion("")
        }
    }

    // MARK: - Comparison

    @Test func lessThanByMajor() throws {
        let v1 = try SemanticVersion("1.0.0")
        let v2 = try SemanticVersion("2.0.0")
        #expect(v1 < v2)
    }

    @Test func lessThanByMinor() throws {
        let v1 = try SemanticVersion("1.0.0")
        let v2 = try SemanticVersion("1.1.0")
        #expect(v1 < v2)
    }

    @Test func lessThanByPatch() throws {
        let v1 = try SemanticVersion("1.0.0")
        let v2 = try SemanticVersion("1.0.1")
        #expect(v1 < v2)
    }

    @Test func greaterThan() throws {
        let v1 = try SemanticVersion("2.0.0")
        let v2 = try SemanticVersion("1.9.9")
        #expect(v1 > v2)
    }

    // MARK: - Equality

    @Test func equalVersions() throws {
        let v1 = try SemanticVersion("1.2.3")
        let v2 = try SemanticVersion("1.2.3")
        #expect(v1 == v2)
    }

    @Test func notEqualVersions() throws {
        let v1 = try SemanticVersion("1.2.3")
        let v2 = try SemanticVersion("1.2.4")
        #expect(v1 != v2)
    }

    // MARK: - Codable round-trip

    @Test func codableRoundTrip() throws {
        let original = try SemanticVersion("3.14.159")
        let data = try JSONEncoder.piqley.encode(original)
        let decoded = try JSONDecoder.piqley.decode(SemanticVersion.self, from: data)
        #expect(decoded == original)
    }

    @Test func encodesAsString() throws {
        let version = try SemanticVersion("1.2.3")
        let data = try JSONEncoder.piqley.encode(version)
        let string = String(data: data, encoding: .utf8)
        #expect(string == #""1.2.3""#)
    }

    @Test func decodesFromString() throws {
        let json = #""2.0.1""#
        let version = try JSONDecoder.piqley.decode(SemanticVersion.self, from: Data(json.utf8))
        #expect(version.major == 2)
        #expect(version.minor == 0)
        #expect(version.patch == 1)
    }

    // MARK: - Init with components

    @Test func initWithComponents() {
        let v = SemanticVersion(major: 4, minor: 5, patch: 6)
        #expect(v.major == 4)
        #expect(v.minor == 5)
        #expect(v.patch == 6)
    }

    // MARK: - description format

    @Test func descriptionFormat() throws {
        let v = try SemanticVersion("1.2.3")
        #expect(v.description == "1.2.3")
    }

    @Test func descriptionFromComponents() {
        let v = SemanticVersion(major: 0, minor: 1, patch: 0)
        #expect(v.description == "0.1.0")
    }
}
