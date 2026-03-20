/// The input payload sent to a piqley plugin when a hook is invoked.
public struct PluginInputPayload: Codable, Sendable, Equatable {
    /// The hook stage being executed.
    public let hook: String
    /// The path to the image folder being processed.
    public let imageFolderPath: String
    /// The key-value configuration for this plugin instance.
    public let pluginConfig: [String: JSONValue]
    /// Secret values resolved from environment variables.
    public let secrets: [String: String]
    /// Path to the execution log file.
    public let executionLogPath: String
    /// Path to the data directory.
    public let dataPath: String
    /// Path to the plugin's log file.
    public let logPath: String
    /// Whether this is a dry run (no side effects).
    public let dryRun: Bool
    /// Persisted state from previous executions, keyed by plugin name, then folder path, then key.
    public let state: [String: [String: [String: JSONValue]]]?
    /// The version of this plugin.
    public let pluginVersion: SemanticVersion
    /// The last version of this plugin that was executed.
    public let lastExecutedVersion: SemanticVersion?
    /// Images that were skipped during pipeline processing.
    public let skipped: [SkipRecord]

    public init(
        hook: String,
        imageFolderPath: String,
        pluginConfig: [String: JSONValue],
        secrets: [String: String],
        executionLogPath: String,
        dataPath: String,
        logPath: String,
        dryRun: Bool,
        state: [String: [String: [String: JSONValue]]]?,
        pluginVersion: SemanticVersion,
        lastExecutedVersion: SemanticVersion?,
        skipped: [SkipRecord] = []
    ) {
        self.hook = hook
        self.imageFolderPath = imageFolderPath
        self.pluginConfig = pluginConfig
        self.secrets = secrets
        self.executionLogPath = executionLogPath
        self.dataPath = dataPath
        self.logPath = logPath
        self.dryRun = dryRun
        self.state = state
        self.pluginVersion = pluginVersion
        self.lastExecutedVersion = lastExecutedVersion
        self.skipped = skipped
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hook = try container.decode(String.self, forKey: .hook)
        imageFolderPath = try container.decode(String.self, forKey: .imageFolderPath)
        pluginConfig = try container.decode([String: JSONValue].self, forKey: .pluginConfig)
        secrets = try container.decode([String: String].self, forKey: .secrets)
        executionLogPath = try container.decode(String.self, forKey: .executionLogPath)
        dataPath = try container.decode(String.self, forKey: .dataPath)
        logPath = try container.decode(String.self, forKey: .logPath)
        dryRun = try container.decode(Bool.self, forKey: .dryRun)
        state = try container.decodeIfPresent([String: [String: [String: JSONValue]]].self, forKey: .state)
        pluginVersion = try container.decode(SemanticVersion.self, forKey: .pluginVersion)
        lastExecutedVersion = try container.decodeIfPresent(SemanticVersion.self, forKey: .lastExecutedVersion)
        skipped = try container.decodeIfPresent([SkipRecord].self, forKey: .skipped) ?? []
    }
}
