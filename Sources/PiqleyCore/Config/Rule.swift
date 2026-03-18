/// Match configuration for a declarative metadata rule.
public struct MatchConfig: Codable, Sendable, Equatable {
    /// The hook this rule applies to. If nil, applies to all hooks.
    public let hook: String?
    /// The metadata field to match against.
    public let field: String
    /// The regex pattern to match against the field value.
    public let pattern: String

    public init(hook: String? = nil, field: String, pattern: String) {
        self.hook = hook
        self.field = field
        self.pattern = pattern
    }
}

/// Emit configuration for a declarative metadata rule.
public struct EmitConfig: Codable, Sendable, Equatable {
    /// The field to emit the values into. If nil, uses the matched field.
    public let field: String?
    /// The values to emit.
    public let values: [String]

    public init(field: String? = nil, values: [String]) {
        self.field = field
        self.values = values
    }
}

/// A declarative metadata rule that matches a field pattern and emits values.
public struct Rule: Codable, Sendable, Equatable {
    public let match: MatchConfig
    public let emit: EmitConfig

    public init(match: MatchConfig, emit: EmitConfig) {
        self.match = match
        self.emit = emit
    }
}
