/// A structured plugin dependency with URL and version constraint.
public struct PluginDependency: Codable, Sendable, Equatable {
    /// Optional human-readable name (used by legacy string-only dependencies).
    public let name: String?
    public let url: String
    public let version: VersionConstraint

    public init(url: String, version: VersionConstraint, name: String? = nil) {
        self.name = name
        self.url = url
        self.version = version
    }

    /// Legacy initializer for backward compatibility with string-only dependencies.
    public init(name: String) {
        self.name = name
        self.url = ""
        self.version = VersionConstraint(
            from: SemanticVersion(major: 0, minor: 0, patch: 0),
            rule: .exact
        )
    }

    /// Resolved identifier: the name if present, otherwise the URL.
    public var identifier: String {
        if let name, !name.isEmpty { return name }
        return url
    }
}

/// A version constraint pairing a base version with a resolution rule.
public struct VersionConstraint: Codable, Sendable, Equatable {
    public let from: SemanticVersion
    public let rule: VersionRule

    public init(from: SemanticVersion, rule: VersionRule) {
        self.from = from
        self.rule = rule
    }
}

/// The rule used to resolve a version constraint.
public enum VersionRule: String, Codable, Sendable, Equatable, CaseIterable {
    case upToNextMajor
    case upToNextMinor
    case exact
}
