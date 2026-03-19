import Testing
@testable import PiqleyCore

@Suite("StageConfigMutation")
struct StageConfigMutationTests {

    // MARK: - Helpers

    private func makeRule(field: String = "title", pattern: String = ".*") -> Rule {
        Rule(
            match: MatchConfig(field: field, pattern: pattern),
            emit: [EmitConfig(action: nil, field: "keywords", values: [field], replacements: nil, source: nil)]
        )
    }

    // MARK: - appendRule

    @Test func appendRuleToNilPreRules() throws {
        var stage = StageConfig()
        let rule = makeRule(field: "a")
        try stage.appendRule(rule, slot: .pre)
        #expect(stage.preRules == [rule])
    }

    @Test func appendRuleToNilPostRules() throws {
        var stage = StageConfig()
        let rule = makeRule(field: "a")
        try stage.appendRule(rule, slot: .post)
        #expect(stage.postRules == [rule])
    }

    @Test func appendRuleToExistingPreRules() throws {
        let existing = makeRule(field: "existing")
        var stage = StageConfig(preRules: [existing])
        let rule = makeRule(field: "new")
        try stage.appendRule(rule, slot: .pre)
        #expect(stage.preRules == [existing, rule])
    }

    @Test func appendRuleToExistingPostRules() throws {
        let existing = makeRule(field: "existing")
        var stage = StageConfig(postRules: [existing])
        let rule = makeRule(field: "new")
        try stage.appendRule(rule, slot: .post)
        #expect(stage.postRules == [existing, rule])
    }

    @Test func appendRuleDoesNotAffectOtherSlot() throws {
        var stage = StageConfig()
        try stage.appendRule(makeRule(field: "a"), slot: .pre)
        #expect(stage.postRules == nil)
    }

    // MARK: - removeRule

    @Test func removeRuleFromPreRules() throws {
        let r0 = makeRule(field: "a")
        let r1 = makeRule(field: "b")
        var stage = StageConfig(preRules: [r0, r1])
        try stage.removeRule(at: 0, slot: .pre)
        #expect(stage.preRules == [r1])
    }

    @Test func removeRuleFromPostRules() throws {
        let r0 = makeRule(field: "a")
        let r1 = makeRule(field: "b")
        var stage = StageConfig(postRules: [r0, r1])
        try stage.removeRule(at: 1, slot: .post)
        #expect(stage.postRules == [r0])
    }

    @Test func removeLastRuleNilsPreRules() throws {
        let rule = makeRule(field: "only")
        var stage = StageConfig(preRules: [rule])
        try stage.removeRule(at: 0, slot: .pre)
        #expect(stage.preRules == nil)
    }

    @Test func removeLastRuleNilsPostRules() throws {
        let rule = makeRule(field: "only")
        var stage = StageConfig(postRules: [rule])
        try stage.removeRule(at: 0, slot: .post)
        #expect(stage.postRules == nil)
    }

    @Test func removeRuleFromNilSlotThrows() {
        var stage = StageConfig()
        #expect(throws: RuleSlotError.emptySlot) {
            try stage.removeRule(at: 0, slot: .pre)
        }
    }

    @Test func removeRuleOutOfBoundsThrows() {
        let rule = makeRule(field: "a")
        var stage = StageConfig(preRules: [rule])
        #expect(throws: RuleSlotError.indexOutOfBounds) {
            try stage.removeRule(at: 5, slot: .pre)
        }
    }

    // MARK: - moveRule

    @Test func moveRuleForwardInPreRules() throws {
        let r0 = makeRule(field: "a")
        let r1 = makeRule(field: "b")
        let r2 = makeRule(field: "c")
        var stage = StageConfig(preRules: [r0, r1, r2])
        try stage.moveRule(from: 0, to: 2, slot: .pre)
        #expect(stage.preRules == [r1, r2, r0])
    }

    @Test func moveRuleBackwardInPostRules() throws {
        let r0 = makeRule(field: "a")
        let r1 = makeRule(field: "b")
        let r2 = makeRule(field: "c")
        var stage = StageConfig(postRules: [r0, r1, r2])
        try stage.moveRule(from: 2, to: 0, slot: .post)
        #expect(stage.postRules == [r2, r0, r1])
    }

    @Test func moveRuleToSameIndexIsNoOp() throws {
        let r0 = makeRule(field: "a")
        let r1 = makeRule(field: "b")
        var stage = StageConfig(preRules: [r0, r1])
        try stage.moveRule(from: 1, to: 1, slot: .pre)
        #expect(stage.preRules == [r0, r1])
    }

    @Test func moveRuleFromNilSlotThrows() {
        var stage = StageConfig()
        #expect(throws: RuleSlotError.emptySlot) {
            try stage.moveRule(from: 0, to: 1, slot: .pre)
        }
    }

    @Test func moveRuleFromOutOfBoundsThrows() {
        let rule = makeRule(field: "a")
        var stage = StageConfig(preRules: [rule])
        #expect(throws: RuleSlotError.indexOutOfBounds) {
            try stage.moveRule(from: 5, to: 0, slot: .pre)
        }
    }

    @Test func moveRuleToOutOfBoundsThrows() {
        let rule = makeRule(field: "a")
        var stage = StageConfig(preRules: [rule])
        #expect(throws: RuleSlotError.indexOutOfBounds) {
            try stage.moveRule(from: 0, to: 5, slot: .pre)
        }
    }

    // MARK: - replaceRule

    @Test func replaceRuleInPreRules() throws {
        let old = makeRule(field: "old")
        let new = makeRule(field: "new")
        var stage = StageConfig(preRules: [old])
        try stage.replaceRule(at: 0, with: new, slot: .pre)
        #expect(stage.preRules == [new])
    }

    @Test func replaceRuleInPostRules() throws {
        let r0 = makeRule(field: "a")
        let r1 = makeRule(field: "b")
        let replacement = makeRule(field: "replacement")
        var stage = StageConfig(postRules: [r0, r1])
        try stage.replaceRule(at: 1, with: replacement, slot: .post)
        #expect(stage.postRules == [r0, replacement])
    }

    @Test func replaceRuleFromNilSlotThrows() {
        var stage = StageConfig()
        let rule = makeRule(field: "a")
        #expect(throws: RuleSlotError.emptySlot) {
            try stage.replaceRule(at: 0, with: rule, slot: .pre)
        }
    }

    @Test func replaceRuleOutOfBoundsThrows() {
        let rule = makeRule(field: "a")
        var stage = StageConfig(preRules: [rule])
        #expect(throws: RuleSlotError.indexOutOfBounds) {
            try stage.replaceRule(at: 5, with: makeRule(field: "new"), slot: .pre)
        }
    }
}
