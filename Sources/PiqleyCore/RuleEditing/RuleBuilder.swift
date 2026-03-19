/// A step-by-step builder for constructing a validated `Rule`.
///
/// Each mutation method validates its input via the injected `RuleEditingContext`
/// before storing it. `build()` performs a final coherence check and returns either
/// a fully-formed `Rule` or a `RuleValidationError`.
public struct RuleBuilder: Sendable {

    // MARK: - Private state

    private let context: RuleEditingContext
    private var match: MatchConfig?
    private var emitActions: [EmitConfig]
    private var writeActions: [EmitConfig]

    // MARK: - Init

    public init(context: RuleEditingContext) {
        self.context = context
        self.match = nil
        self.emitActions = []
        self.writeActions = []
    }

    // MARK: - Builder methods

    /// Validates and stores a match configuration.
    ///
    /// On success the match is stored and replaces any previously stored match.
    /// On failure the match state is unchanged.
    @discardableResult
    public mutating func setMatch(field: String, pattern: String) -> Result<Void, RuleValidationError> {
        let result = context.validateMatch(field: field, pattern: pattern)
        if case .success = result {
            match = MatchConfig(field: field, pattern: pattern)
        }
        return result
    }

    /// Validates and appends an emit action.
    ///
    /// On success the config is appended to the emit list.
    /// On failure the emit list is unchanged.
    @discardableResult
    public mutating func addEmit(_ config: EmitConfig) -> Result<Void, RuleValidationError> {
        let result = context.validateEmit(config)
        if case .success = result {
            emitActions.append(config)
        }
        return result
    }

    /// Validates and appends a write action.
    ///
    /// On success the config is appended to the write list.
    /// On failure the write list is unchanged.
    @discardableResult
    public mutating func addWrite(_ config: EmitConfig) -> Result<Void, RuleValidationError> {
        let result = context.validateEmit(config)
        if case .success = result {
            writeActions.append(config)
        }
        return result
    }

    /// Clears all stored state (match, emit actions, write actions).
    public mutating func reset() {
        match = nil
        emitActions = []
        writeActions = []
    }

    /// Performs a final coherence check and returns a `Rule` on success.
    ///
    /// Returns `.failure(.noMatch)` if no match has been set.
    /// Returns `.failure(.noActions)` if no emit actions have been added.
    public func build() -> Result<Rule, RuleValidationError> {
        guard let match else {
            return .failure(.noMatch)
        }
        guard !emitActions.isEmpty else {
            return .failure(.noActions)
        }
        return .success(Rule(match: match, emit: emitActions, write: writeActions))
    }
}
