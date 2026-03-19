/// Runtime configuration for a piqley plugin instance.
public struct PluginConfig: Codable, Sendable, Equatable {
    /// The key-value configuration values for this plugin instance.
    public let values: [String: JSONValue]
    /// Whether the plugin has been set up. Nil if unknown.
    public let isSetUp: Bool?

    public init(values: [String: JSONValue] = [:], isSetUp: Bool? = nil) {
        self.values = values
        self.isSetUp = isSetUp
    }

    private enum CodingKeys: String, CodingKey {
        case values
        case isSetUp
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        values = try container.decodeIfPresent([String: JSONValue].self, forKey: .values) ?? [:]
        isSetUp = try container.decodeIfPresent(Bool.self, forKey: .isSetUp)
    }
}
