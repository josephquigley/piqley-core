/// A state field that a plugin declares it works with.
///
/// Consumed fields are surfaced in the rules editor for:
/// 1. The plugin's own rules (so you can write `self:tags` rules)
/// 2. Downstream plugins (so they can reference upstream fields before any rules exist)
///
/// ```json
/// { "name": "tags", "type": "csv", "description": "Comma-separated tag names" }
/// ```
public struct ConsumedField: Codable, Sendable, Equatable {
    /// The bare field name (e.g. "tags", "title").
    public let name: String
    /// Optional type hint (e.g. "string", "csv", "bool", "duration").
    public let type: String?
    /// Optional human-readable description.
    public let description: String?

    public init(name: String, type: String? = nil, description: String? = nil) {
        self.name = name
        self.type = type
        self.description = description
    }
}
