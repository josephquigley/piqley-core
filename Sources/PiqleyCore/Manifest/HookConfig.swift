/// Configuration for a specific hook in a piqley plugin manifest.
public struct HookConfig: Codable, Sendable, Equatable {
    public let command: String?
    public let args: [String]
    public let timeout: Int?
    public let pluginProtocol: PluginProtocol?
    public let successCodes: [Int32]?
    public let warningCodes: [Int32]?
    public let criticalCodes: [Int32]?
    public let batchProxy: BatchProxyConfig?

    public init(
        command: String? = nil,
        args: [String] = [],
        timeout: Int? = nil,
        pluginProtocol: PluginProtocol? = nil,
        successCodes: [Int32]? = nil,
        warningCodes: [Int32]? = nil,
        criticalCodes: [Int32]? = nil,
        batchProxy: BatchProxyConfig? = nil
    ) {
        self.command = command
        self.args = args
        self.timeout = timeout
        self.pluginProtocol = pluginProtocol
        self.successCodes = successCodes
        self.warningCodes = warningCodes
        self.criticalCodes = criticalCodes
        self.batchProxy = batchProxy
    }

    private enum CodingKeys: String, CodingKey {
        case command
        case args
        case timeout
        case pluginProtocol = "protocol"
        case successCodes
        case warningCodes
        case criticalCodes
        case batchProxy
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        command = try container.decodeIfPresent(String.self, forKey: .command)
        args = try container.decodeIfPresent([String].self, forKey: .args) ?? []
        timeout = try container.decodeIfPresent(Int.self, forKey: .timeout)
        pluginProtocol = try container.decodeIfPresent(PluginProtocol.self, forKey: .pluginProtocol)
        successCodes = try container.decodeIfPresent([Int32].self, forKey: .successCodes)
        warningCodes = try container.decodeIfPresent([Int32].self, forKey: .warningCodes)
        criticalCodes = try container.decodeIfPresent([Int32].self, forKey: .criticalCodes)
        batchProxy = try container.decodeIfPresent(BatchProxyConfig.self, forKey: .batchProxy)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(command, forKey: .command)
        if !args.isEmpty {
            try container.encode(args, forKey: .args)
        }
        try container.encodeIfPresent(timeout, forKey: .timeout)
        try container.encodeIfPresent(pluginProtocol, forKey: .pluginProtocol)
        try container.encodeIfPresent(successCodes, forKey: .successCodes)
        try container.encodeIfPresent(warningCodes, forKey: .warningCodes)
        try container.encodeIfPresent(criticalCodes, forKey: .criticalCodes)
        try container.encodeIfPresent(batchProxy, forKey: .batchProxy)
    }
}
