import Foundation

/// Identifies which rule array within a StageConfig to target.
public enum RuleSlot: Sendable {
    case pre
    case post
}

/// Errors thrown by StageConfig mutation methods.
public enum RuleSlotError: Error, LocalizedError, Equatable {
    /// The targeted slot is nil (no rules have been added yet).
    case emptySlot
    /// The provided index is outside the bounds of the rule array.
    case indexOutOfBounds

    public var errorDescription: String? {
        switch self {
        case .emptySlot:
            return "The rule slot is empty."
        case .indexOutOfBounds:
            return "The index is out of bounds for this rule slot."
        }
    }
}
