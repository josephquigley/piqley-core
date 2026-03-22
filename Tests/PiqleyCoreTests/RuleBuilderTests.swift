import Testing
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

private func isBuildFailure(_ result: Result<Rule, RuleValidationError>, _ expected: RuleValidationError) -> Bool {
    if case .failure(let e) = result { return e == expected }
    return false
}

@Suite("RuleBuilder")
struct RuleBuilderTests {

    // MARK: - Helpers

    private func makeContext() -> RuleEditingContext {
        RuleEditingContext(
            availableFields: [:],
            pluginIdentifier: "com.example.plugin",
            stages: [:]
        )
    }

    private func makeEmit(
        action: String? = "add",
        field: String = "Keywords",
        values: [String]? = ["foo"],
        replacements: [Replacement]? = nil,
        source: String? = nil
    ) -> EmitConfig {
        EmitConfig(
            action: action,
            field: field,
            values: values,
            replacements: replacements,
            source: source
        )
    }

    // MARK: - Full build flow

    @Test func fullBuildFlowEmitSucceeds() {
        var builder = RuleBuilder(context: makeContext())
        let matchResult = builder.setMatch(field: "Keywords", pattern: "portrait")
        #expect(isSuccess(matchResult))

        let emitResult = builder.addEmit(makeEmit())
        #expect(isSuccess(emitResult))

        let buildResult = builder.build()
        if case .success(let rule) = buildResult {
            #expect(rule.match.field == "Keywords")
            #expect(rule.match.pattern == "portrait")
            #expect(rule.emit.count == 1)
            #expect(rule.write.isEmpty)
        } else {
            Issue.record("Expected .success, got \(buildResult)")
        }
    }

    @Test func fullBuildFlowWithEmitAndWrite() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        _ = builder.addEmit(makeEmit(action: "add", field: "Keywords", values: ["people"]))
        _ = builder.addWrite(makeEmit(action: "removeField", field: "ISO", values: nil))

        let buildResult = builder.build()
        if case .success(let rule) = buildResult {
            #expect(rule.match.field == "Keywords")
            #expect(rule.emit.count == 1)
            #expect(rule.write.count == 1)
            #expect(rule.write[0].field == "ISO")
        } else {
            Issue.record("Expected .success, got \(buildResult)")
        }
    }

    // MARK: - setMatch validation

    @Test func setMatchRejectsEmptyField() {
        var builder = RuleBuilder(context: makeContext())
        let result = builder.setMatch(field: "", pattern: "portrait")
        #expect(isFailure(result, .emptyField))
    }

    @Test func setMatchRejectsInvalidRegex() {
        var builder = RuleBuilder(context: makeContext())
        let result = builder.setMatch(field: "Keywords", pattern: "regex:[invalid")
        if case .failure(let error) = result, case .invalidPattern = error {
            // pass
        } else {
            Issue.record("Expected .failure(.invalidPattern), got \(result)")
        }
    }

    @Test func setMatchDoesNotStoreOnValidationFailure() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "", pattern: "portrait")
        _ = builder.addEmit(makeEmit())

        let buildResult = builder.build()
        #expect(isBuildFailure(buildResult, .noMatch))
    }

    // MARK: - addEmit validation

    @Test func addEmitRejectsUnknownAction() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        let result = builder.addEmit(makeEmit(action: "explode"))
        #expect(isFailure(result, .unknownAction("explode")))
    }

    @Test func addEmitDoesNotStoreOnValidationFailure() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        _ = builder.addEmit(makeEmit(action: "explode"))

        let buildResult = builder.build()
        #expect(isBuildFailure(buildResult, .noActions))
    }

    // MARK: - addWrite validation

    @Test func addWriteRejectsUnknownAction() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        let result = builder.addWrite(makeEmit(action: "explode"))
        #expect(isFailure(result, .unknownAction("explode")))
    }

    // MARK: - build — missing match

    @Test func buildWithoutMatchFailsNoMatch() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.addEmit(makeEmit())
        let result = builder.build()
        #expect(isBuildFailure(result, .noMatch))
    }

    // MARK: - build — missing actions

    @Test func buildWithoutActionsFailsNoActions() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        let result = builder.build()
        #expect(isBuildFailure(result, .noActions))
    }

    @Test func buildWithWriteOnlySucceeds() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        _ = builder.addWrite(makeEmit(action: "removeField", field: "ISO", values: nil))
        let result = builder.build()
        if case .success(let rule) = result {
            #expect(rule.emit.isEmpty)
            #expect(rule.write.count == 1)
            #expect(rule.write[0].field == "ISO")
        } else {
            Issue.record("Expected .success for write-only rule, got \(result)")
        }
    }

    // MARK: - reset

    @Test func resetClearsAllState() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        _ = builder.addEmit(makeEmit())
        _ = builder.addWrite(makeEmit(action: "removeField", field: "ISO", values: nil))

        builder.reset()

        let result = builder.build()
        #expect(isBuildFailure(result, .noMatch))
    }

    @Test func resetAllowsRebuild() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        _ = builder.addEmit(makeEmit())
        builder.reset()

        _ = builder.setMatch(field: "ISO", pattern: "regex:^[0-9]+")
        _ = builder.addEmit(makeEmit(action: "removeField", field: "ISO", values: nil))

        let result = builder.build()
        if case .success(let rule) = result {
            #expect(rule.match.field == "ISO")
        } else {
            Issue.record("Expected .success after rebuild, got \(result)")
        }
    }

    // MARK: - Multiple actions accumulate

    @Test func multipleEmitActionsAccumulate() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        _ = builder.addEmit(makeEmit(action: "add", field: "Keywords", values: ["people"]))
        _ = builder.addEmit(makeEmit(action: "add", field: "Keywords", values: ["headshot"]))
        _ = builder.addEmit(makeEmit(action: "remove", field: "Keywords", values: ["portrait"]))

        let result = builder.build()
        if case .success(let rule) = result {
            #expect(rule.emit.count == 3)
        } else {
            Issue.record("Expected .success with 3 emit actions, got \(result)")
        }
    }

    @Test func multipleWriteActionsAccumulate() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        _ = builder.addEmit(makeEmit())
        _ = builder.addWrite(makeEmit(action: "removeField", field: "ISO", values: nil))
        _ = builder.addWrite(makeEmit(action: "removeField", field: "Aperture", values: nil))

        let result = builder.build()
        if case .success(let rule) = result {
            #expect(rule.write.count == 2)
        } else {
            Issue.record("Expected .success with 2 write actions, got \(result)")
        }
    }

    // MARK: - setMatch replaces previous match

    @Test func setMatchReplacesExistingMatch() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait")
        _ = builder.setMatch(field: "ISO", pattern: "regex:^[0-9]+")
        _ = builder.addEmit(makeEmit())

        let result = builder.build()
        if case .success(let rule) = result {
            #expect(rule.match.field == "ISO")
        } else {
            Issue.record("Expected .success with updated match field, got \(result)")
        }
    }

    // MARK: - setMatch with not flag

    @Test func setMatchWithNotFlagPreservesNegation() {
        var builder = RuleBuilder(context: makeContext())
        let result = builder.setMatch(field: "Keywords", pattern: "portrait", not: true)
        #expect(isSuccess(result))
        _ = builder.addEmit(makeEmit())

        let buildResult = builder.build()
        if case .success(let rule) = buildResult {
            #expect(rule.match.not == true)
        } else {
            Issue.record("Expected .success, got \(buildResult)")
        }
    }

    @Test func setMatchWithNotNilOmitsFlag() {
        var builder = RuleBuilder(context: makeContext())
        _ = builder.setMatch(field: "Keywords", pattern: "portrait", not: nil)
        _ = builder.addEmit(makeEmit())

        let buildResult = builder.build()
        if case .success(let rule) = buildResult {
            #expect(rule.match.not == nil)
        } else {
            Issue.record("Expected .success, got \(buildResult)")
        }
    }
}
