/// Standard filenames within a plugin directory.
public enum PluginFile {
    public static let manifest = "manifest.json"
    public static let config = "config.json"
    public static let executionLog = "logs/execution.jsonl"
    /// Prefix for stage configuration files (e.g. "stage-pre-process.json").
    public static let stagePrefix = "stage-"
    /// Suffix for stage configuration files.
    public static let stageSuffix = ".json"
}
