/// The manifest for a piqley plugin, describing its metadata, configuration, and hooks.
public struct PluginManifest: Codable, Sendable, Equatable {
    public let name: String
    public let pluginProtocolVersion: String
    public let pluginVersion: SemanticVersion?
    public let config: [ConfigEntry]
    public let setup: SetupConfig?
    public let dependencies: [PluginDependency]?
    public let hooks: [String: HookConfig]

    public init(
        name: String,
        pluginProtocolVersion: String,
        pluginVersion: SemanticVersion? = nil,
        config: [ConfigEntry] = [],
        setup: SetupConfig? = nil,
        dependencies: [PluginDependency]? = nil,
        hooks: [String: HookConfig] = [:]
    ) {
        self.name = name
        self.pluginProtocolVersion = pluginProtocolVersion
        self.pluginVersion = pluginVersion
        self.config = config
        self.setup = setup
        self.dependencies = dependencies
        self.hooks = hooks
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case pluginProtocolVersion
        case pluginVersion
        case config
        case setup
        case dependencies
        case hooks
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        pluginProtocolVersion = try container.decode(String.self, forKey: .pluginProtocolVersion)
        pluginVersion = try container.decodeIfPresent(SemanticVersion.self, forKey: .pluginVersion)
        config = try container.decodeIfPresent([ConfigEntry].self, forKey: .config) ?? []
        setup = try container.decodeIfPresent(SetupConfig.self, forKey: .setup)
        if let structured = try? container.decodeIfPresent([PluginDependency].self, forKey: .dependencies) {
            dependencies = structured
        } else if let names = try? container.decodeIfPresent([String].self, forKey: .dependencies) {
            dependencies = names.map { PluginDependency(name: $0) }
        } else {
            dependencies = nil
        }
        hooks = try container.decodeIfPresent([String: HookConfig].self, forKey: .hooks) ?? [:]
    }

    /// The dependency identifiers as plain strings (for backward-compatible pipeline resolution).
    ///
    /// Returns each dependency's ``PluginDependency/identifier`` (name if present, otherwise URL).
    public var dependencyNames: [String] {
        dependencies?.map(\.identifier) ?? []
    }

    /// The secret environment variable keys declared in config.
    public var secretKeys: [String] {
        config.compactMap { entry in
            if case .secret(let key, _) = entry { return key }
            return nil
        }
    }

    /// The value entries declared in config (key, type, value tuples).
    public var valueEntries: [(key: String, type: ConfigValueType, value: JSONValue)] {
        config.compactMap { entry in
            if case .value(let key, let type_, let value) = entry {
                return (key: key, type: type_, value: value)
            }
            return nil
        }
    }

    /// Returns hook keys that are not in the canonical hook order.
    public func unknownHooks() -> [String] {
        let knownRawValues = Set(Hook.canonicalOrder.map { $0.rawValue })
        return hooks.keys.filter { !knownRawValues.contains($0) }
    }
}
