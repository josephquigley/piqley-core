/// The manifest for a piqley plugin, describing its metadata, configuration, and dependencies.
public struct PluginManifest: Codable, Sendable, Equatable {
    /// Reverse TLD identifier (e.g. "com.piqley.ghost"). Used as the identity key system-wide.
    public let identifier: String
    /// Human-readable display name.
    public let name: String
    /// Short description of what the plugin does.
    public let description: String?
    public let pluginSchemaVersion: String
    public let pluginVersion: SemanticVersion?
    public let config: [ConfigEntry]
    public let setup: SetupConfig?
    public let dependencies: [PluginDependency]?

    /// The set of schema versions this build of PiqleyCore supports.
    public static let supportedSchemaVersions: Set<String> = ["1"]

    public init(
        identifier: String,
        name: String,
        description: String? = nil,
        pluginSchemaVersion: String,
        pluginVersion: SemanticVersion? = nil,
        config: [ConfigEntry] = [],
        setup: SetupConfig? = nil,
        dependencies: [PluginDependency]? = nil
    ) {
        self.identifier = identifier
        self.name = name
        self.description = description
        self.pluginSchemaVersion = pluginSchemaVersion
        self.pluginVersion = pluginVersion
        self.config = config
        self.setup = setup
        self.dependencies = dependencies
    }

    private enum CodingKeys: String, CodingKey {
        case identifier, name, description
        case pluginSchemaVersion, pluginProtocolVersion, pluginVersion
        case config, setup, dependencies
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        pluginSchemaVersion = try container.decodeIfPresent(String.self, forKey: .pluginSchemaVersion)
            ?? container.decode(String.self, forKey: .pluginProtocolVersion)
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
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(pluginSchemaVersion, forKey: .pluginSchemaVersion)
        try container.encodeIfPresent(pluginVersion, forKey: .pluginVersion)
        try container.encode(config, forKey: .config)
        try container.encodeIfPresent(setup, forKey: .setup)
        try container.encodeIfPresent(dependencies, forKey: .dependencies)
    }

    /// The dependency identifiers as plain strings.
    public var dependencyIdentifiers: [String] {
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
}
