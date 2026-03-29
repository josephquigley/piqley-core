import Testing
import Foundation
@testable import PiqleyCore

@Suite("JSONCoding")
struct JSONCodingTests {

    @Test func prettyPrintOutputIsSortedAndFormatted() throws {
        let value: [String: String] = ["zebra": "z", "alpha": "a", "middle": "m"]
        let data = try JSONEncoder.piqleyPrettyPrint.encode(value)
        let output = String(data: data, encoding: .utf8)!

        // Keys must appear in sorted order
        let alphaIndex = output.range(of: "\"alpha\"")!.lowerBound
        let middleIndex = output.range(of: "\"middle\"")!.lowerBound
        let zebraIndex = output.range(of: "\"zebra\"")!.lowerBound
        #expect(alphaIndex < middleIndex)
        #expect(middleIndex < zebraIndex)

        // Output must be multi-line (pretty-printed)
        #expect(output.contains("\n"))
    }
}
