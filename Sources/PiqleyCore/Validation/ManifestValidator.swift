/// Validates a PluginManifest for constraint violations and potential issues.
public enum ManifestValidator {
    /// Returns a list of error messages for constraint violations in the manifest.
    /// An empty array means the manifest is valid.
    public static func validate(_ manifest: PluginManifest) -> [String] {
        var errors: [String] = []

        if manifest.identifier.isEmpty {
            errors.append("Plugin identifier must not be empty.")
        }

        if manifest.name.isEmpty {
            errors.append("Plugin name must not be empty.")
        }

        if manifest.pluginProtocolVersion.isEmpty {
            errors.append("Plugin protocol version must not be empty.")
        }

        return errors
    }
}
