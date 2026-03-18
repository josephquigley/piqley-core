/// The input payload sent to a piqley plugin when a hook is invoked.
public struct PluginInputPayload: Codable, Sendable, Equatable {
    /// The hook stage being executed.
    public let hook: String
    /// The path to the folder being processed.
    public let folderPath: String
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

    public init(
        hook: String,
        folderPath: String,
        pluginConfig: [String: JSONValue],
        secrets: [String: String],
        executionLogPath: String,
        dataPath: String,
        logPath: String,
        dryRun: Bool,
        state: [String: [String: [String: JSONValue]]]?,
        pluginVersion: SemanticVersion,
        lastExecutedVersion: SemanticVersion?
    ) {
        self.hook = hook
        self.folderPath = folderPath
        self.pluginConfig = pluginConfig
        self.secrets = secrets
        self.executionLogPath = executionLogPath
        self.dataPath = dataPath
        self.logPath = logPath
        self.dryRun = dryRun
        self.state = state
        self.pluginVersion = pluginVersion
        self.lastExecutedVersion = lastExecutedVersion
    }
}
