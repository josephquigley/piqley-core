/// The type of a configuration value in a piqley plugin manifest.
public enum ConfigValueType: String, Codable, Sendable, Equatable {
    case string
    case int
    case float
    case bool
}
