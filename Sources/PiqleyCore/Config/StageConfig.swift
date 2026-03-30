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

    private enum CodingKeys: String, CodingKey {
        case preRules, binary, postRules
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        binary = try container.decodeIfPresent(HookConfig.self, forKey: .binary)
        preRules = try Self.decodeLossyRules(from: container, forKey: .preRules)
        postRules = try Self.decodeLossyRules(from: container, forKey: .postRules)
    }

    /// Decodes a rules array, silently skipping entries that fail to decode
    /// (e.g. comment-only objects with no `emit` key).
    private static func decodeLossyRules(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> [Rule]? {
        guard var arrayContainer = try? container.nestedUnkeyedContainer(forKey: key) else {
            return nil
        }
        var rules: [Rule] = []
        while !arrayContainer.isAtEnd {
            if let rule = try? arrayContainer.decode(Rule.self) {
                rules.append(rule)
            } else {
                // Skip past the failed element so the container advances.
                _ = try? arrayContainer.decode(AnyCodable.self)
            }
        }
        return rules.isEmpty ? nil : rules
    }

    /// Throwaway type used to advance the unkeyed container past a non-decodable element.
    private struct AnyCodable: Decodable {
        init(from decoder: any Decoder) throws {
            _ = try decoder.singleValueContainer()
        }
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
