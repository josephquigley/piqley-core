import Testing
import Foundation
@testable import PiqleyCore

// MARK: - Result<Void, RuleValidationError> match helpers

private func isSuccess(_ result: Result<Void, RuleValidationError>) -> Bool {
    if case .success = result { return true }
    return false
}

private func isFailure(_ result: Result<Void, RuleValidationError>, _ expected: RuleValidationError) -> Bool {
    if case .failure(let e) = result { return e == expected }
    return false
}

@Suite("RuleValidation")
struct RuleValidationTests {

    // MARK: - Helpers

    func makeEmit(
        action: String? = nil,
        field: String? = "Keywords",
        values: [String]? = ["foo"],
        replacements: [Replacement]? = nil,
        source: String? = nil,
        not: Bool? = nil
    ) -> EmitConfig {
        EmitConfig(action: action, field: field, values: values, replacements: replacements, source: source, not: not)
    }

    // MARK: - RuleValidator.validActions

    @Test func validActionsContainsAllSix() {
        let actions = RuleValidator.validActions
        #expect(actions.contains("add"))
        #expect(actions.contains("remove"))
        #expect(actions.contains("replace"))
        #expect(actions.contains("removeField"))
        #expect(actions.contains("clone"))
        #expect(actions.contains("skip"))
        #expect(actions.count == 7)
    }

    // MARK: - Skip Validation

    @Test func validActionsContainsSkip() {
        #expect(RuleValidator.validActions.contains("skip"))
        #expect(RuleValidator.validActions.count == 7)
    }

    @Test func emitSkipValid() {
        let emit = makeEmit(action: "skip", field: nil, values: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func emitSkipRejectsField() {
        let emit = makeEmit(action: "skip", field: "tags", values: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "skip")))
    }

    @Test func emitSkipRejectsValues() {
        let emit = makeEmit(action: "skip", field: nil, values: ["x"])
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "skip")))
    }

    @Test func emitSkipRejectsReplacements() {
        let emit = EmitConfig(action: "skip", field: nil, values: nil, replacements: [Replacement(pattern: "a", replacement: "b")], source: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "skip")))
    }

    @Test func emitSkipRejectsSource() {
        let emit = makeEmit(action: "skip", field: nil, values: nil, source: "original:IPTC:Keywords")
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "skip")))
    }

    @Test func validateRuleSkipWithWriteRejected() {
        let rule = Rule(
            match: MatchConfig(field: "original:IPTC:Keywords", pattern: "glob:*Draft*"),
            emit: [EmitConfig(action: "skip", field: nil, values: nil, replacements: nil, source: nil)],
            write: [EmitConfig(action: nil, field: "tags", values: ["x"], replacements: nil, source: nil)]
        )
        let result = RuleValidator.validateRule(rule)
        #expect(isFailure(result, .skipWithWrite))
    }

    @Test func validateRuleSkipNotAlone() {
        let rule = Rule(
            match: MatchConfig(field: "original:IPTC:Keywords", pattern: "glob:*Draft*"),
            emit: [
                EmitConfig(action: "skip", field: nil, values: nil, replacements: nil, source: nil),
                EmitConfig(action: nil, field: "tags", values: ["x"], replacements: nil, source: nil)
            ]
        )
        let result = RuleValidator.validateRule(rule)
        #expect(isFailure(result, .skipNotAlone))
    }

    @Test func validateRuleNonSkipPassesValidation() {
        let rule = Rule(
            match: MatchConfig(field: "original:IPTC:Keywords", pattern: "glob:*"),
            emit: [EmitConfig(action: nil, field: "tags", values: ["x"], replacements: nil, source: nil)]
        )
        let result = RuleValidator.validateRule(rule)
        #expect(isSuccess(result))
    }

    // MARK: - validateMatch — valid cases

    @Test func matchExactPatternValid() {
        let result = RuleValidator.validateMatch(field: "Keywords", pattern: "portrait")
        #expect(isSuccess(result))
    }

    @Test func matchGlobPatternValid() {
        let result = RuleValidator.validateMatch(field: "Keywords", pattern: "glob:port*")
        #expect(isSuccess(result))
    }

    @Test func matchRegexPatternValid() {
        let result = RuleValidator.validateMatch(field: "Keywords", pattern: "regex:^port.*")
        #expect(isSuccess(result))
    }

    // MARK: - validateMatch — invalid cases

    @Test func matchEmptyFieldFails() {
        let result = RuleValidator.validateMatch(field: "", pattern: "portrait")
        #expect(isFailure(result, .emptyField))
    }

    @Test func matchInvalidRegexFails() {
        let result = RuleValidator.validateMatch(field: "Keywords", pattern: "regex:[invalid")
        if case .failure(let error) = result, case .invalidPattern = error {
            // pass
        } else {
            Issue.record("Expected .failure(.invalidPattern), got \(result)")
        }
    }

    // MARK: - validateEmit — valid cases

    @Test func emitAddValid() {
        let emit = makeEmit(action: "add", values: ["foo"])
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func emitAddNilActionDefaultsToAdd() {
        let emit = makeEmit(action: nil, values: ["foo"])
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func emitRemoveValid() {
        let emit = makeEmit(action: "remove", values: ["foo"])
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func emitReplaceValid() {
        let emit = makeEmit(
            action: "replace",
            values: nil,
            replacements: [Replacement(pattern: "old", replacement: "new")]
        )
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func emitRemoveFieldValid() {
        let emit = makeEmit(action: "removeField", values: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func emitCloneValid() {
        let emit = makeEmit(action: "clone", values: nil, source: "exif:Keywords")
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    // MARK: - validateEmit — empty field

    @Test func emitEmptyFieldFails() {
        let emit = makeEmit(field: "", values: ["foo"])
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .emptyField))
    }

    // MARK: - validateEmit — unknown action

    @Test func emitUnknownActionFails() {
        let emit = makeEmit(action: "explode", values: ["foo"])
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .unknownAction("explode")))
    }

    // MARK: - validateEmit — missingValues

    @Test func emitAddMissingValuesFails() {
        let emit = makeEmit(action: "add", values: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .missingValues(action: "add")))
    }

    @Test func emitAddEmptyValuesFails() {
        let emit = makeEmit(action: "add", values: [])
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .missingValues(action: "add")))
    }

    @Test func emitRemoveMissingValuesFails() {
        let emit = makeEmit(action: "remove", values: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .missingValues(action: "remove")))
    }

    // MARK: - validateEmit — missingSource

    @Test func emitCloneMissingSourceFails() {
        let emit = makeEmit(action: "clone", values: nil, source: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .missingSource))
    }

    @Test func emitCloneEmptySourceFails() {
        let emit = makeEmit(action: "clone", values: nil, source: "")
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .missingSource))
    }

    // MARK: - validateEmit — conflicting fields

    @Test func emitAddWithReplacementsConflicts() {
        let emit = makeEmit(
            action: "add",
            values: ["foo"],
            replacements: [Replacement(pattern: "x", replacement: "y")]
        )
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "add")))
    }

    @Test func emitAddWithSourceConflicts() {
        let emit = makeEmit(action: "add", values: ["foo"], source: "exif:Keywords")
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "add")))
    }

    @Test func emitRemoveWithReplacementsConflicts() {
        let emit = makeEmit(
            action: "remove",
            values: ["foo"],
            replacements: [Replacement(pattern: "x", replacement: "y")]
        )
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "remove")))
    }

    @Test func emitRemoveWithSourceConflicts() {
        let emit = makeEmit(action: "remove", values: ["foo"], source: "exif:Keywords")
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "remove")))
    }

    @Test func emitReplaceWithValuesConflicts() {
        let emit = makeEmit(
            action: "replace",
            values: ["foo"],
            replacements: [Replacement(pattern: "x", replacement: "y")]
        )
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "replace")))
    }

    @Test func emitReplaceWithSourceConflicts() {
        let emit = makeEmit(
            action: "replace",
            values: nil,
            replacements: [Replacement(pattern: "x", replacement: "y")],
            source: "exif:Keywords"
        )
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "replace")))
    }

    @Test func emitRemoveFieldWithValuesConflicts() {
        let emit = makeEmit(action: "removeField", values: ["foo"])
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "removeField")))
    }

    @Test func emitRemoveFieldWithReplacementsConflicts() {
        let emit = makeEmit(
            action: "removeField",
            values: nil,
            replacements: [Replacement(pattern: "x", replacement: "y")]
        )
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "removeField")))
    }

    @Test func emitRemoveFieldWithSourceConflicts() {
        let emit = makeEmit(action: "removeField", values: nil, source: "exif:Keywords")
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "removeField")))
    }

    @Test func emitCloneWithValuesConflicts() {
        let emit = makeEmit(action: "clone", values: ["foo"], source: "exif:Keywords")
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "clone")))
    }

    @Test func emitCloneWithReplacementsConflicts() {
        let emit = makeEmit(
            action: "clone",
            values: nil,
            replacements: [Replacement(pattern: "x", replacement: "y")],
            source: "exif:Keywords"
        )
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "clone")))
    }

    @Test func emitReplaceMissingReplacementsFails() {
        let emit = makeEmit(action: "replace", values: nil, replacements: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .missingValues(action: "replace")))
    }

    @Test func emitReplaceEmptyReplacementsFails() {
        let emit = makeEmit(action: "replace", values: nil, replacements: [])
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .missingValues(action: "replace")))
    }

    // MARK: - Error messages

    @Test func errorDescriptionEmptyField() {
        let error = RuleValidationError.emptyField
        #expect(error.errorDescription != nil)
        #expect(!(error.errorDescription!.isEmpty))
    }

    @Test func recoverySuggestionEmptyField() {
        let error = RuleValidationError.emptyField
        #expect(error.recoverySuggestion != nil)
        #expect(!(error.recoverySuggestion!.isEmpty))
    }

    @Test func errorDescriptionInvalidPattern() {
        guard let underlyingError = makeInvalidRegexError() else {
            Issue.record("Could not create underlying error")
            return
        }
        let error = RuleValidationError.invalidPattern("regex:[bad", underlying: underlyingError)
        #expect(error.errorDescription != nil)
        #expect(!(error.errorDescription!.isEmpty))
    }

    @Test func recoverySuggestionInvalidPattern() {
        guard let underlyingError = makeInvalidRegexError() else {
            Issue.record("Could not create underlying error")
            return
        }
        let error = RuleValidationError.invalidPattern("regex:[bad", underlying: underlyingError)
        #expect(error.recoverySuggestion != nil)
        #expect(!(error.recoverySuggestion!.isEmpty))
    }

    @Test func errorDescriptionUnknownAction() {
        let error = RuleValidationError.unknownAction("explode")
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription!.contains("explode"))
    }

    @Test func recoverySuggestionUnknownAction() {
        let error = RuleValidationError.unknownAction("explode")
        #expect(error.recoverySuggestion != nil)
        #expect(!(error.recoverySuggestion!.isEmpty))
    }

    @Test func errorDescriptionMissingValues() {
        let error = RuleValidationError.missingValues(action: "add")
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription!.contains("add"))
    }

    @Test func recoverySuggestionMissingValues() {
        let error = RuleValidationError.missingValues(action: "add")
        #expect(error.recoverySuggestion != nil)
        #expect(!(error.recoverySuggestion!.isEmpty))
    }

    @Test func errorDescriptionMissingSource() {
        let error = RuleValidationError.missingSource
        #expect(error.errorDescription != nil)
        #expect(!(error.errorDescription!.isEmpty))
    }

    @Test func recoverySuggestionMissingSource() {
        let error = RuleValidationError.missingSource
        #expect(error.recoverySuggestion != nil)
        #expect(!(error.recoverySuggestion!.isEmpty))
    }

    @Test func errorDescriptionConflictingFields() {
        let error = RuleValidationError.conflictingFields(action: "add")
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription!.contains("add"))
    }

    @Test func recoverySuggestionConflictingFields() {
        let error = RuleValidationError.conflictingFields(action: "add")
        #expect(error.recoverySuggestion != nil)
        #expect(!(error.recoverySuggestion!.isEmpty))
    }

    @Test func errorDescriptionNoActions() {
        let error = RuleValidationError.noActions
        #expect(error.errorDescription != nil)
        #expect(!(error.errorDescription!.isEmpty))
    }

    @Test func recoverySuggestionNoActions() {
        let error = RuleValidationError.noActions
        #expect(error.recoverySuggestion != nil)
        #expect(!(error.recoverySuggestion!.isEmpty))
    }

    // MARK: - Equatable — invalidPattern ignores underlying error

    @Test func invalidPatternEquatableIgnoresUnderlying() {
        guard let err1 = makeInvalidRegexError(), let err2 = makeInvalidRegexError() else {
            Issue.record("Could not create underlying errors")
            return
        }
        let a = RuleValidationError.invalidPattern("regex:[bad", underlying: err1)
        let b = RuleValidationError.invalidPattern("regex:[bad", underlying: err2)
        #expect(a == b)
    }

    @Test func invalidPatternEqualityDependsOnPattern() {
        guard let err1 = makeInvalidRegexError(), let err2 = makeInvalidRegexError() else {
            Issue.record("Could not create underlying errors")
            return
        }
        let a = RuleValidationError.invalidPattern("regex:[bad", underlying: err1)
        let b = RuleValidationError.invalidPattern("regex:[different", underlying: err2)
        #expect(a != b)
    }

    // MARK: - EmitConfig.field optional

    @Test func emitConfigAcceptsNilField() {
        let config = EmitConfig(action: "skip", field: nil, values: nil, replacements: nil, source: nil)
        #expect(config.field == nil)
        #expect(config.action == "skip")
    }

    // MARK: - MatchConfig not field

    @Test func matchConfigNotFieldDecodes() throws {
        let json = #"{"field":"Keywords","pattern":"glob:*","not":true}"#
        let decoded = try JSONDecoder.piqley.decode(MatchConfig.self, from: Data(json.utf8))
        #expect(decoded.not == true)
        #expect(decoded.field == "Keywords")
        #expect(decoded.pattern == "glob:*")
        let reEncoded = try JSONEncoder.piqley.encode(decoded)
        let reDecoded = try JSONDecoder.piqley.decode(MatchConfig.self, from: reEncoded)
        #expect(reDecoded == decoded)
    }

    // MARK: - Emit not validation

    @Test func emitNotOnRemoveValid() {
        let emit = makeEmit(action: "remove", values: ["foo"], not: true)
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func emitNotOnRemoveFieldValid() {
        let emit = makeEmit(action: "removeField", values: nil, not: true)
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func emitNotOnAddRejected() {
        let emit = makeEmit(action: nil, values: ["foo"], not: true)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .notNotAllowed(action: "add")))
    }

    @Test func emitNotOnCloneRejected() {
        let emit = makeEmit(action: "clone", field: "Keywords", values: nil, source: "exif:Keywords", not: true)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .notNotAllowed(action: "clone")))
    }

    @Test func emitNotOnSkipRejected() {
        let emit = makeEmit(action: "skip", field: nil, values: nil, not: true)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .notNotAllowed(action: "skip")))
    }

    // MARK: - writeBack validation

    @Test func writeBackValid() {
        let emit = makeEmit(action: "writeBack", field: nil, values: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func writeBackWithFieldRejected() {
        let emit = makeEmit(action: "writeBack", field: "Keywords", values: nil)
        let result = RuleValidator.validateEmit(emit)
        #expect(isFailure(result, .conflictingFields(action: "writeBack")))
    }

    @Test func writeBackInEmitRejected() {
        let rule = Rule(
            match: MatchConfig(field: "original:IPTC:Keywords", pattern: "glob:*"),
            emit: [EmitConfig(action: "writeBack", field: nil, values: nil, replacements: nil, source: nil)],
            write: []
        )
        let result = RuleValidator.validateRule(rule)
        #expect(isFailure(result, .writeBackInEmit))
    }

    @Test func writeBackNotAlone() {
        let rule = Rule(
            match: MatchConfig(field: "original:IPTC:Keywords", pattern: "glob:*"),
            emit: [EmitConfig(action: nil, field: "tags", values: ["x"], replacements: nil, source: nil)],
            write: [
                EmitConfig(action: "writeBack", field: nil, values: nil, replacements: nil, source: nil),
                EmitConfig(action: nil, field: "IPTC:Keywords", values: ["y"], replacements: nil, source: nil)
            ]
        )
        let result = RuleValidator.validateRule(rule)
        #expect(isFailure(result, .writeBackNotAlone))
    }

    @Test func writeBackAloneInWriteValid() {
        let rule = Rule(
            match: MatchConfig(field: "original:IPTC:Keywords", pattern: "glob:*"),
            emit: [EmitConfig(action: nil, field: "tags", values: ["x"], replacements: nil, source: nil)],
            write: [EmitConfig(action: "writeBack", field: nil, values: nil, replacements: nil, source: nil)]
        )
        let result = RuleValidator.validateRule(rule)
        #expect(isSuccess(result))
    }

    // MARK: - Private helpers

    private func makeInvalidRegexError() -> (any Error)? {
        do {
            _ = try NSRegularExpression(pattern: "[invalid")
            return nil
        } catch {
            return error
        }
    }
}
