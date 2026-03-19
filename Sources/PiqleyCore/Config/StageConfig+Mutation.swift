extension StageConfig {

    // MARK: - Private helpers

    private func rules(for slot: RuleSlot) -> [Rule]? {
        switch slot {
        case .pre: preRules
        case .post: postRules
        }
    }

    private mutating func setRules(_ rules: [Rule]?, for slot: RuleSlot) {
        switch slot {
        case .pre: preRules = rules
        case .post: postRules = rules
        }
    }

    private func validatedRules(for slot: RuleSlot) throws -> [Rule] {
        guard let existing = rules(for: slot) else { throw RuleSlotError.emptySlot }
        return existing
    }

    private func validatedIndex(_ index: Int, in rules: [Rule]) throws {
        guard rules.indices.contains(index) else { throw RuleSlotError.indexOutOfBounds }
    }

    // MARK: - Mutations

    /// Appends a rule to the given slot. Initialises the array if it was nil.
    public mutating func appendRule(_ rule: Rule, slot: RuleSlot) throws {
        var current = rules(for: slot) ?? []
        current.append(rule)
        setRules(current, for: slot)
    }

    /// Removes the rule at `index` from the given slot. Sets the slot to nil when the last rule is removed.
    public mutating func removeRule(at index: Int, slot: RuleSlot) throws {
        var current = try validatedRules(for: slot)
        try validatedIndex(index, in: current)
        current.remove(at: index)
        setRules(current.isEmpty ? nil : current, for: slot)
    }

    /// Moves the rule at `from` to `to` within the given slot.
    public mutating func moveRule(from source: Int, to destination: Int, slot: RuleSlot) throws {
        var current = try validatedRules(for: slot)
        try validatedIndex(source, in: current)
        try validatedIndex(destination, in: current)
        guard source != destination else { return }
        let rule = current.remove(at: source)
        current.insert(rule, at: destination)
        setRules(current, for: slot)
    }

    /// Replaces the rule at `index` with `rule` within the given slot.
    public mutating func replaceRule(at index: Int, with rule: Rule, slot: RuleSlot) throws {
        var current = try validatedRules(for: slot)
        try validatedIndex(index, in: current)
        current[index] = rule
        setRules(current, for: slot)
    }
}
