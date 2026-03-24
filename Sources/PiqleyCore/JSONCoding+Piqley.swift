import Foundation

extension JSONEncoder {
    /// Standard encoder for all Piqley JSON serialization.
    public static var piqley: JSONEncoder { JSONEncoder() }

    /// Encoder for writing human-readable config files to disk.
    public static var piqleyPrettyPrint: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

extension JSONDecoder {
    /// Standard decoder for all Piqley JSON deserialization.
    public static var piqley: JSONDecoder { JSONDecoder() }
}
