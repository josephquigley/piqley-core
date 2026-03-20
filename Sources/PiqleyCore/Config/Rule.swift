/// Match configuration for a declarative metadata rule.
public struct MatchConfig: Codable, Sendable, Equatable {
    /// The metadata field to match against.
    public let field: String
    /// The regex pattern to match against the field value.
    public let pattern: String
    /// When true, inverts the match so the rule fires on non-matching values.
    public let not: Bool?

    public init(field: String, pattern: String, not: Bool? = nil) {
        self.field = field
        self.pattern = pattern
        self.not = not
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
    /// The action to perform: "add", "remove", "replace", "removeField", "clone". Nil defaults to "add".
    public let action: String?
    /// The target field. Optional. Nil is valid for actions that require no field (e.g. "skip"). Use "*" with removeField/clone to target all fields.
    public let field: String?
    /// Values to add or patterns to remove. Required for add and remove actions.
    public let values: [String]?
    /// Ordered pattern-to-replacement mappings for the replace action.
    public let replacements: [Replacement]?
    /// Source namespace:field reference for clone action.
    public let source: String?
    /// When true, inverts the emit so it applies to non-matching values.
    public let not: Bool?

    public init(action: String?, field: String?, values: [String]?, replacements: [Replacement]?, source: String?, not: Bool? = nil) {
        self.action = action
        self.field = field
        self.values = values
        self.replacements = replacements
        self.source = source
        self.not = not
    }
}

/// A declarative metadata rule that matches a field pattern and emits operations.
public struct Rule: Codable, Sendable, Equatable {
    public let match: MatchConfig
    public let emit: [EmitConfig]
    public let write: [EmitConfig]

    public init(match: MatchConfig, emit: [EmitConfig], write: [EmitConfig] = []) {
        self.match = match
        self.emit = emit
        self.write = write
    }

    private enum CodingKeys: String, CodingKey {
        case match, emit, write
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        match = try container.decode(MatchConfig.self, forKey: .match)
        emit = try container.decode([EmitConfig].self, forKey: .emit)
        write = try container.decodeIfPresent([EmitConfig].self, forKey: .write) ?? []
    }
}
