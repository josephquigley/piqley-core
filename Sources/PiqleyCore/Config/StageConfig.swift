/// Per-stage configuration for a piqley plugin.
/// Each stage file (`stage-<name>.json`) contains up to three optional sections.
public struct StageConfig: Codable, Sendable, Equatable {
    /// Rules evaluated before the binary runs.
    public var preRules: [Rule]?
    /// Binary execution configuration.
    public let binary: HookConfig?
    /// Rules evaluated after the binary runs.
    public var postRules: [Rule]?

    public init(preRules: [Rule]? = nil, binary: HookConfig? = nil, postRules: [Rule]? = nil) {
        self.preRules = preRules
        self.binary = binary
        self.postRules = postRules
    }

    /// Whether all three sections are nil (empty stage file).
    public var isEmpty: Bool {
        preRules == nil && binary == nil && postRules == nil
    }

    /// Whether the stage has no meaningful content: no rules and no non-empty command.
    /// A binary with an empty command string is treated as empty.
    public var isEffectivelyEmpty: Bool {
        let hasRules = !(preRules ?? []).isEmpty || !(postRules ?? []).isEmpty
        let hasCommand = binary?.command != nil && !(binary?.command?.isEmpty ?? true)
        return !hasRules && !hasCommand
    }
}
