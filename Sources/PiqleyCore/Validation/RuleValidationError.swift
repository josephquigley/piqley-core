import Foundation

/// Errors produced by RuleValidator when validating match or emit configurations.
public enum RuleValidationError: Error, LocalizedError, Sendable, Equatable {

    /// A required field string was empty.
    case emptyField

    /// A pattern string could not be compiled (regex validation failure).
    case invalidPattern(String, underlying: any Error)

    /// The action string is not one of the recognised valid actions.
    case unknownAction(String)

    /// The action requires values (or replacements) but none were provided.
    case missingValues(action: String)

    /// The clone action requires a source reference but none was provided.
    case missingSource

    /// Fields that should not be set for this action were provided.
    case conflictingFields(action: String)

    /// The match configuration produced no matching results (runtime, not structural).
    case noMatch

    /// The emit array is empty — a rule must have at least one action.
    case noActions

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .emptyField:
            return "Field must not be empty."
        case .invalidPattern(let pattern, let underlying):
            return "Pattern '\(pattern)' is not a valid regular expression: \(underlying.localizedDescription)"
        case .unknownAction(let action):
            return "Unknown action '\(action)'."
        case .missingValues(let action):
            return "Action '\(action)' requires values or replacements but none were provided."
        case .missingSource:
            return "The 'clone' action requires a source field reference."
        case .conflictingFields(let action):
            return "Action '\(action)' has conflicting fields that should not be set together."
        case .noMatch:
            return "The rule's match configuration did not match any metadata."
        case .noActions:
            return "A rule must have at least one emit action."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .emptyField:
            return "Provide a non-empty string for the field name."
        case .invalidPattern:
            return "Check the regular expression syntax and fix any errors."
        case .unknownAction:
            let valid = ["add", "remove", "replace", "removeField", "clone"].joined(separator: ", ")
            return "Use one of the supported actions: \(valid)."
        case .missingValues(let action):
            switch action {
            case "replace":
                return "Add at least one replacement mapping to the 'replacements' field."
            default:
                return "Add at least one value to the 'values' field."
            }
        case .missingSource:
            return "Set the 'source' field to a namespace:field reference (e.g. 'exif:Keywords')."
        case .conflictingFields(let action):
            return "Remove fields that are not applicable to the '\(action)' action."
        case .noMatch:
            return "Adjust the match pattern so it matches the intended metadata field."
        case .noActions:
            return "Add at least one emit configuration to the rule."
        }
    }

    // MARK: - Equatable (underlying error is ignored for invalidPattern)

    public static func == (lhs: RuleValidationError, rhs: RuleValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.emptyField, .emptyField):
            return true
        case (.invalidPattern(let lp, _), .invalidPattern(let rp, _)):
            return lp == rp
        case (.unknownAction(let l), .unknownAction(let r)):
            return l == r
        case (.missingValues(let l), .missingValues(let r)):
            return l == r
        case (.missingSource, .missingSource):
            return true
        case (.conflictingFields(let l), .conflictingFields(let r)):
            return l == r
        case (.noMatch, .noMatch):
            return true
        case (.noActions, .noActions):
            return true
        default:
            return false
        }
    }
}
