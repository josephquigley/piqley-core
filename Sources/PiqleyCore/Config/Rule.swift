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

/// A pattern-to-replacement mapping for the replace emit action.
public struct Replacement: Codable, Sendable, Equatable {
    /// The pattern to match. Supports glob: and regex: prefixes.
    public let pattern: String
    /// The replacement string. Supports $1/$2 capture group references for regex patterns.
    public let replacement: String

    public init(pattern: String, replacement: String) {
        self.pattern = pattern
        self.replacement = replacement
    }
}

/// Emit configuration for a declarative metadata rule.
public struct EmitConfig: Codable, Sendable, Equatable {
    /// The action to perform: "add", "remove", "replace", "removeField". Nil defaults to "add".
    public let action: String?
    /// The target field. Required. Use "*" with removeField to remove all fields.
    public let field: String
    /// Values to add or patterns to remove. Required for add and remove actions.
    public let values: [String]?
    /// Ordered pattern-to-replacement mappings for the replace action.
    public let replacements: [Replacement]?

    public init(action: String? = nil, field: String, values: [String]? = nil, replacements: [Replacement]? = nil) {
        self.action = action
        self.field = field
        self.values = values
        self.replacements = replacements
    }
}

/// A declarative metadata rule that matches a field pattern and emits operations.
public struct Rule: Codable, Sendable, Equatable {
    public let match: MatchConfig
    public let emit: [EmitConfig]

    public init(match: MatchConfig, emit: [EmitConfig]) {
        self.match = match
        self.emit = emit
    }
}
