/// Display metadata for a configuration entry shown during plugin setup.
public struct ConfigMetadata: Codable, Sendable, Equatable {
    public let label: String?
    public let description: String?

    public init(label: String? = nil, description: String? = nil) {
        self.label = label
        self.description = description
    }
}

/// A configuration entry in a piqley plugin manifest.
/// Either a plain value entry or a secret (environment variable) entry.
public enum ConfigEntry: Codable, Sendable, Equatable {
    case value(key: String, type: ConfigValueType, value: JSONValue, metadata: ConfigMetadata)
    case secret(secretKey: String, type: ConfigValueType, metadata: ConfigMetadata)

    private enum CodingKeys: String, CodingKey {
        case key
        case secretKey = "secret_key"
        case type
        case value
        case label
        case description
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hasKey = container.contains(.key)
        let hasSecretKey = container.contains(.secretKey)

        if hasKey && hasSecretKey {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "ConfigEntry cannot have both 'key' and 'secret_key'"
                )
            )
        }

        if hasKey {
            let key = try container.decode(String.self, forKey: .key)
            let type_ = try container.decode(ConfigValueType.self, forKey: .type)
            let value = try container.decode(JSONValue.self, forKey: .value)
            let label = try container.decodeIfPresent(String.self, forKey: .label)
            let description = try container.decodeIfPresent(String.self, forKey: .description)
            self = .value(key: key, type: type_, value: value, metadata: ConfigMetadata(label: label, description: description))
        } else if hasSecretKey {
            let secretKey = try container.decode(String.self, forKey: .secretKey)
            let type_ = try container.decode(ConfigValueType.self, forKey: .type)
            let label = try container.decodeIfPresent(String.self, forKey: .label)
            let description = try container.decodeIfPresent(String.self, forKey: .description)
            self = .secret(secretKey: secretKey, type: type_, metadata: ConfigMetadata(label: label, description: description))
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "ConfigEntry must have either 'key' or 'secret_key'"
                )
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .value(let key, let type_, let value, let metadata):
            try container.encode(key, forKey: .key)
            try container.encode(type_, forKey: .type)
            try container.encode(value, forKey: .value)
            try container.encodeIfPresent(metadata.label, forKey: .label)
            try container.encodeIfPresent(metadata.description, forKey: .description)
        case .secret(let secretKey, let type_, let metadata):
            try container.encode(secretKey, forKey: .secretKey)
            try container.encode(type_, forKey: .type)
            try container.encodeIfPresent(metadata.label, forKey: .label)
            try container.encodeIfPresent(metadata.description, forKey: .description)
        }
    }

    /// The user-facing label for this entry, falling back to the raw key if no label is set.
    public var displayLabel: String {
        switch self {
        case .value(let key, _, _, let metadata):
            return (metadata.label?.isEmpty == false) ? metadata.label! : key
        case .secret(let secretKey, _, let metadata):
            return (metadata.label?.isEmpty == false) ? metadata.label! : secretKey
        }
    }
}
