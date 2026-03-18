/// Setup configuration for a piqley plugin.
public struct SetupConfig: Codable, Sendable, Equatable {
    public let command: String
    public let args: [String]

    public init(command: String, args: [String] = []) {
        self.command = command
        self.args = args
    }

    private enum CodingKeys: String, CodingKey {
        case command
        case args
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        command = try container.decode(String.self, forKey: .command)
        args = try container.decodeIfPresent([String].self, forKey: .args) ?? []
    }
}
