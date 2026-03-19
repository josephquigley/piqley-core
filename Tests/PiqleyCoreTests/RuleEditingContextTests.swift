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

@Suite("RuleEditingContext")
struct RuleEditingContextTests {

    // MARK: - Helpers

    private func makeContext() -> RuleEditingContext {
        let fields: [String: [FieldInfo]] = [
            "exif": [
                FieldInfo(name: "ISO", source: .exif),
                FieldInfo(name: "Aperture", source: .exif),
            ],
            "iptc": [
                FieldInfo(name: "Keywords", source: .iptc),
            ],
            "custom": [
                FieldInfo(name: "Rating", source: .exif), // category: .exif, but key is "custom"
            ],
        ]
        let stages: [String: StageConfig] = [
            "ingest": StageConfig(
                preRules: [
                    Rule(
                        match: MatchConfig(field: "Keywords", pattern: "portrait"),
                        emit: [EmitConfig(action: "add", field: "Keywords", values: ["people"], replacements: nil, source: nil)]
                    )
                ],
                binary: HookConfig(command: "/usr/bin/exiftool"),
                postRules: [
                    Rule(
                        match: MatchConfig(field: "ISO", pattern: "regex:^[0-9]+"),
                        emit: [EmitConfig(action: "removeField", field: "ISO", values: nil, replacements: nil, source: nil)]
                    )
                ]
            ),
            "export": StageConfig(
                preRules: nil,
                binary: nil,
                postRules: nil
            ),
        ]
        return RuleEditingContext(
            availableFields: fields,
            pluginIdentifier: "com.example.plugin",
            stages: stages
        )
    }

    private func makeRule(field: String = "Keywords", pattern: String = "portrait") -> Rule {
        Rule(
            match: MatchConfig(field: field, pattern: pattern),
            emit: [EmitConfig(action: "add", field: field, values: ["value"], replacements: nil, source: nil)]
        )
    }

    // MARK: - availableSources

    @Test func availableSourcesReturnsSortedKeys() {
        let ctx = makeContext()
        let sources = ctx.availableSources()
        #expect(sources == sources.sorted())
    }

    @Test func availableSourcesReturnsAllSourceNames() {
        let ctx = makeContext()
        let sources = ctx.availableSources()
        #expect(sources.contains("exif"))
        #expect(sources.contains("iptc"))
        #expect(sources.contains("custom"))
        #expect(sources.count == 3)
    }

    // MARK: - fields(in:)

    @Test func fieldsInKnownSourceReturnsSortedByCategoryThenName() {
        let fields: [String: [FieldInfo]] = [
            "mixed": [
                FieldInfo(name: "Zebra", source: .exif),
                FieldInfo(name: "Alpha", source: .iptc),
                FieldInfo(name: "Middle", source: .exif),
            ]
        ]
        let ctx = RuleEditingContext(
            availableFields: fields,
            pluginIdentifier: "com.example.plugin",
            stages: [:]
        )
        let result = ctx.fields(in: "mixed")
        // exif fields before iptc fields, within same category sorted by name
        #expect(result.count == 3)
        #expect(result[0].name == "Middle")  // exif, "Middle" < "Zebra"
        #expect(result[1].name == "Zebra")   // exif
        #expect(result[2].name == "Alpha")   // iptc
    }

    @Test func fieldsInUnknownSourceReturnsEmpty() {
        let ctx = makeContext()
        let result = ctx.fields(in: "nonexistent")
        #expect(result.isEmpty)
    }

    // MARK: - validActions

    @Test func validActionsReturnsAllFive() {
        let ctx = makeContext()
        let actions = ctx.validActions()
        #expect(actions.count == 5)
        #expect(actions.contains("add"))
        #expect(actions.contains("remove"))
        #expect(actions.contains("replace"))
        #expect(actions.contains("removeField"))
        #expect(actions.contains("clone"))
    }

    @Test func validActionsReturnsSortedArray() {
        let ctx = makeContext()
        let actions = ctx.validActions()
        #expect(actions == actions.sorted())
    }

    // MARK: - stageNames

    @Test func stageNamesReturnsLoadedStages() {
        let ctx = makeContext()
        let names = ctx.stageNames()
        #expect(names.contains("ingest"))
        #expect(names.contains("export"))
        #expect(names.count == 2)
    }

    @Test func stageNamesReturnsSorted() {
        let ctx = makeContext()
        let names = ctx.stageNames()
        #expect(names == names.sorted())
    }

    // MARK: - rules(forStage:slot:)

    @Test func rulesForStagePreSlotReturnsPreRules() {
        let ctx = makeContext()
        let rules = ctx.rules(forStage: "ingest", slot: .pre)
        #expect(rules.count == 1)
        #expect(rules[0].match.field == "Keywords")
    }

    @Test func rulesForStagePostSlotReturnsPostRules() {
        let ctx = makeContext()
        let rules = ctx.rules(forStage: "ingest", slot: .post)
        #expect(rules.count == 1)
        #expect(rules[0].match.field == "ISO")
    }

    @Test func rulesForEmptySlotReturnsEmptyArray() {
        let ctx = makeContext()
        let preRules = ctx.rules(forStage: "export", slot: .pre)
        let postRules = ctx.rules(forStage: "export", slot: .post)
        #expect(preRules.isEmpty)
        #expect(postRules.isEmpty)
    }

    @Test func rulesForUnknownStageReturnsEmptyArray() {
        let ctx = makeContext()
        let rules = ctx.rules(forStage: "nonexistent", slot: .pre)
        #expect(rules.isEmpty)
    }

    // MARK: - stageHasBinary

    @Test func stageHasBinaryReturnsTrueWhenBinaryPresent() {
        let ctx = makeContext()
        #expect(ctx.stageHasBinary("ingest") == true)
    }

    @Test func stageHasBinaryReturnsFalseWhenBinaryNil() {
        let ctx = makeContext()
        #expect(ctx.stageHasBinary("export") == false)
    }

    @Test func stageHasBinaryReturnsFalseForUnknownStage() {
        let ctx = makeContext()
        #expect(ctx.stageHasBinary("nonexistent") == false)
    }

    // MARK: - validateMatch

    @Test func validateMatchDelegatesToRuleValidator() {
        let ctx = makeContext()
        let result = ctx.validateMatch(field: "Keywords", pattern: "portrait")
        #expect(isSuccess(result))
    }

    @Test func validateMatchEmptyFieldFails() {
        let ctx = makeContext()
        let result = ctx.validateMatch(field: "", pattern: "portrait")
        #expect(isFailure(result, .emptyField))
    }

    @Test func validateMatchInvalidRegexFails() {
        let ctx = makeContext()
        let result = ctx.validateMatch(field: "Keywords", pattern: "regex:[invalid")
        if case .failure(let error) = result, case .invalidPattern = error {
            // pass
        } else {
            Issue.record("Expected .failure(.invalidPattern), got \(result)")
        }
    }

    // MARK: - validateEmit

    @Test func validateEmitDelegatesToRuleValidator() {
        let ctx = makeContext()
        let emit = EmitConfig(action: "add", field: "Keywords", values: ["portrait"], replacements: nil, source: nil)
        let result = ctx.validateEmit(emit)
        #expect(isSuccess(result))
    }

    @Test func validateEmitEmptyFieldFails() {
        let ctx = makeContext()
        let emit = EmitConfig(action: "add", field: "", values: ["portrait"], replacements: nil, source: nil)
        let result = ctx.validateEmit(emit)
        #expect(isFailure(result, .emptyField))
    }

    @Test func validateEmitUnknownActionFails() {
        let ctx = makeContext()
        let emit = EmitConfig(action: "explode", field: "Keywords", values: ["portrait"], replacements: nil, source: nil)
        let result = ctx.validateEmit(emit)
        #expect(isFailure(result, .unknownAction("explode")))
    }
}
