/// The communication protocol a piqley plugin uses.
public enum PluginProtocol: String, Codable, Sendable, Equatable {
    case json
    case pipe
}
