/// Validates a PluginManifest for constraint violations and potential issues.
public enum ManifestValidator {

    /// Returns a list of error messages for constraint violations in the manifest.
    /// An empty array means the manifest is valid.
    public static func validate(_ manifest: PluginManifest) -> [String] {
        var errors: [String] = []

        if manifest.name.isEmpty {
            errors.append("Plugin name must not be empty.")
        }

        if manifest.pluginProtocolVersion.isEmpty {
            errors.append("Plugin protocol version must not be empty.")
        }

        if manifest.hooks.isEmpty {
            errors.append("Plugin manifest must declare at least one hook.")
        }

        for (hookName, hookConfig) in manifest.hooks {
            if let batchProxy = hookConfig.batchProxy {
                _ = batchProxy
                if hookConfig.pluginProtocol == .json {
                    errors.append("Hook '\(hookName)': batchProxy is not compatible with the json protocol.")
                }
                if hookConfig.command == nil {
                    errors.append("Hook '\(hookName)': batchProxy requires a command.")
                }
            }
        }

        return errors
    }

    /// Returns a list of non-blocking warning messages for potential issues in the manifest.
    public static func warnings(_ manifest: PluginManifest) -> [String] {
        var warnings: [String] = []

        let unknownHooks = manifest.unknownHooks()
        for hookName in unknownHooks {
            warnings.append("Hook '\(hookName)' is not a known piqley hook name.")
        }

        return warnings
    }
}
