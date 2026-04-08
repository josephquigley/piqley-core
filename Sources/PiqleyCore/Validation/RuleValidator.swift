import Foundation

/// Validates match and emit configurations for declarative metadata rules.
public enum RuleValidator {

    /// The complete set of supported emit action strings.
    /// Note: "writeBack" is designed for image forking (not yet implemented).
    public static let validActions: Set<String> = ["add", "remove", "replace", "removeField", "clone", "skip", "writeBack"]

    // MARK: - validateMatch

    /// Validates a match configuration's field name and pattern.
    ///
    /// - Parameters:
    ///   - field: The metadata field name to match against.
    ///   - pattern: The pattern string; may carry a `regex:` or `glob:` prefix.
    /// - Returns: `.success(())` if valid, or a `.failure` with the specific error.
    public static func validateMatch(field: String, pattern: String) -> Result<Void, RuleValidationError> {
        guard !field.isEmpty else {
            return .failure(.emptyField)
        }

        if pattern.hasPrefix(PatternPrefix.regex) {
            let raw = String(pattern.dropFirst(PatternPrefix.regex.count))
            do {
                _ = try NSRegularExpression(pattern: raw)
            } catch {
                return .failure(.invalidPattern(pattern, underlying: error))
            }
        }

        // Glob and exact patterns are always syntactically valid.
        return .success(())
    }

    // MARK: - validateEmit

    /// Validates an emit configuration for structural correctness.
    ///
    /// A nil action is treated as `"add"` (the default).
    ///
    /// - Parameter emit: The emit configuration to validate.
    /// - Returns: `.success(())` if valid, or a `.failure` with the specific error.
    public static func validateEmit(_ emit: EmitConfig) -> Result<Void, RuleValidationError> {
        if let field = emit.field, field.isEmpty {
            return .failure(.emptyField)
        }

        let action = emit.action ?? "add"

        guard validActions.contains(action) else {
            return .failure(.unknownAction(action))
        }

        switch action {
        case "add", "remove":
            // Conflicting fields check first
            if emit.replacements != nil || emit.source != nil {
                return .failure(.conflictingFields(action: action))
            }
            // Must have non-empty values
            guard let values = emit.values, !values.isEmpty else {
                return .failure(.missingValues(action: action))
            }

        case "replace":
            // Conflicting fields check first
            if emit.values != nil || emit.source != nil {
                return .failure(.conflictingFields(action: action))
            }
            // Must have non-empty replacements
            guard let replacements = emit.replacements, !replacements.isEmpty else {
                return .failure(.missingValues(action: action))
            }

        case "removeField":
            // Must have no values, replacements, or source
            if emit.values != nil || emit.replacements != nil || emit.source != nil {
                return .failure(.conflictingFields(action: action))
            }

        case "clone":
            // Conflicting fields check first
            if emit.values != nil || emit.replacements != nil {
                return .failure(.conflictingFields(action: action))
            }
            // Must have a non-empty source
            guard let source = emit.source, !source.isEmpty else {
                return .failure(.missingSource)
            }

        case "skip":
            // skip must have no field, values, replacements, or source
            if emit.field != nil || emit.values != nil || emit.replacements != nil || emit.source != nil {
                return .failure(.conflictingFields(action: action))
            }

        case "writeBack":
            // writeBack must have no field, values, replacements, or source
            if emit.field != nil || emit.values != nil || emit.replacements != nil || emit.source != nil {
                return .failure(.conflictingFields(action: action))
            }

        default:
            break
        }

        if let not = emit.not, not {
            let effectiveAction = emit.action ?? "add"
            let allowedNotActions: Set<String> = ["remove", "removeField"]
            if !allowedNotActions.contains(effectiveAction) {
                return .failure(.notNotAllowed(action: effectiveAction))
            }
        }

        return .success(())
    }

    // MARK: - validateRule

    /// Validates a rule for structural correctness, including skip-specific constraints.
    ///
    /// - Parameter rule: The rule to validate.
    /// - Returns: `.success(())` if valid, or a `.failure` with the specific error.
    public static func validateRule(_ rule: Rule) -> Result<Void, RuleValidationError> {
        let hasSkip = rule.emit.contains { $0.action == "skip" }
        let hasWriteBackInEmit = rule.emit.contains { $0.action == "writeBack" }
        let hasWriteBackInWrite = rule.write.contains { $0.action == "writeBack" }

        if hasWriteBackInEmit {
            return .failure(.writeBackInEmit)
        }

        if hasWriteBackInWrite && rule.write.count > 1 {
            return .failure(.writeBackNotAlone)
        }

        guard hasSkip else {
            return .success(())
        }

        if !rule.write.isEmpty {
            return .failure(.skipWithWrite)
        }

        if rule.emit.count > 1 {
            return .failure(.skipNotAlone)
        }

        return .success(())
    }
}
