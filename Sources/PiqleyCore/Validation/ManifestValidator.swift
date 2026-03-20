/// Validates a PluginManifest for constraint violations and potential issues.
public enum ManifestValidator {
    /// Returns a list of error messages for constraint violations in the manifest.
    /// An empty array means the manifest is valid.
    public static func validate(_ manifest: PluginManifest) -> [String] {
        var errors: [String] = []

        if manifest.identifier.isEmpty {
            errors.append("Plugin identifier must not be empty.")
        }

        let reservedIdentifiers: Set<String> = [ReservedName.original, ReservedName.skip]
        if reservedIdentifiers.contains(manifest.identifier) {
            errors.append("Plugin identifier '\(manifest.identifier)' is reserved and cannot be used.")
        }

        if manifest.name.isEmpty {
            errors.append("Plugin name must not be empty.")
        }

        if manifest.pluginSchemaVersion.isEmpty {
            errors.append("Plugin schema version must not be empty.")
        }

        if !PluginManifest.supportedSchemaVersions.contains(manifest.pluginSchemaVersion) {
            let supported = PluginManifest.supportedSchemaVersions.sorted().joined(separator: ", ")
            errors.append("Unsupported schema version '\(manifest.pluginSchemaVersion)' (supported: \(supported)).")
        }

        return errors
    }
}
