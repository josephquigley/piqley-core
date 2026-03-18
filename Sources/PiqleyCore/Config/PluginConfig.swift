/// Runtime configuration for a piqley plugin instance.
public struct PluginConfig: Codable, Sendable, Equatable {
    /// The key-value configuration values for this plugin instance.
    public let values: [String: JSONValue]
    /// Whether the plugin has been set up. Nil if unknown.
    public let isSetUp: Bool?
    /// The declarative metadata rules configured for this plugin.
    public let rules: [Rule]

    public init(values: [String: JSONValue] = [:], isSetUp: Bool? = nil, rules: [Rule] = []) {
        self.values = values
        self.isSetUp = isSetUp
        self.rules = rules
    }

    private enum CodingKeys: String, CodingKey {
        case values
        case isSetUp
        case rules
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        values = try container.decodeIfPresent([String: JSONValue].self, forKey: .values) ?? [:]
        isSetUp = try container.decodeIfPresent(Bool.self, forKey: .isSetUp)
        rules = try container.decodeIfPresent([Rule].self, forKey: .rules) ?? []
    }
}
