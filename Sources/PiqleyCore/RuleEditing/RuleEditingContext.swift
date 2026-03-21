/// The central context for the rule editor.
///
/// The CLI injects available fields and stages; the context provides
/// sorted query methods and delegates validation to `RuleValidator`.
public struct RuleEditingContext: Sendable {

    // MARK: - Stored properties

    /// All available metadata fields, keyed by source name (e.g. "exif", "iptc").
    public let availableFields: [String: [FieldInfo]]

    /// The identifier of the plugin being edited.
    public let pluginIdentifier: String

    /// The loaded stage configurations, keyed by stage name.
    public var stages: [String: StageConfig]

    // MARK: - Init

    public init(
        availableFields: [String: [FieldInfo]],
        pluginIdentifier: String,
        stages: [String: StageConfig]
    ) {
        self.availableFields = availableFields
        self.pluginIdentifier = pluginIdentifier
        self.stages = stages
    }

    // MARK: - Query methods

    /// Returns all source names in sorted order.
    public func availableSources() -> [String] {
        availableFields.keys.sorted()
    }

    /// Returns the fields for a given source, sorted by category then name.
    /// Returns an empty array for unknown sources.
    public func fields(in source: String) -> [FieldInfo] {
        guard let sourceFields = availableFields[source] else {
            return []
        }
        return sourceFields.sorted {
            if $0.category != $1.category {
                return $0.category < $1.category
            }
            return $0.name < $1.name
        }
    }

    /// Returns all valid action strings in sorted order.
    public func validActions() -> [String] {
        RuleValidator.validActions.sorted()
    }

    /// Returns all loaded stage names in canonical pipeline execution order,
    /// with any non-canonical names appended alphabetically.
    public func stageNames() -> [String] {
        let canonicalOrder = Hook.canonicalOrder.map(\.rawValue)
        let canonicalSet = Set(canonicalOrder)
        var result = canonicalOrder.filter { stages.keys.contains($0) }
        let nonCanonical = stages.keys.filter { !canonicalSet.contains($0) }.sorted()
        result.append(contentsOf: nonCanonical)
        return result
    }

    /// Returns the rules for the given stage and slot.
    /// Returns an empty array if the stage is unknown or the slot is nil.
    public func rules(forStage stageName: String, slot: RuleSlot) -> [Rule] {
        guard let stage = stages[stageName] else {
            return []
        }
        switch slot {
        case .pre:
            return stage.preRules ?? []
        case .post:
            return stage.postRules ?? []
        }
    }

    /// Returns true if the named stage has a binary configured, false otherwise.
    public func stageHasBinary(_ stageName: String) -> Bool {
        stages[stageName]?.binary != nil
    }

    // MARK: - Validation

    /// Validates a match configuration. Delegates to `RuleValidator.validateMatch`.
    public func validateMatch(field: String, pattern: String) -> Result<Void, RuleValidationError> {
        RuleValidator.validateMatch(field: field, pattern: pattern)
    }

    /// Validates an emit configuration. Delegates to `RuleValidator.validateEmit`.
    public func validateEmit(_ emit: EmitConfig) -> Result<Void, RuleValidationError> {
        RuleValidator.validateEmit(emit)
    }
}
