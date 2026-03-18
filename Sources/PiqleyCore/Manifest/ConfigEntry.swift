/// A configuration entry in a piqley plugin manifest.
/// Either a plain value entry or a secret (environment variable) entry.
public enum ConfigEntry: Codable, Sendable, Equatable {
    case value(key: String, type: ConfigValueType, value: JSONValue)
    case secret(secretKey: String, type: ConfigValueType)

    private enum CodingKeys: String, CodingKey {
        case key
        case secretKey = "secret_key"
        case type
        case value
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
            self = .value(key: key, type: type_, value: value)
        } else if hasSecretKey {
            let secretKey = try container.decode(String.self, forKey: .secretKey)
            let type_ = try container.decode(ConfigValueType.self, forKey: .type)
            self = .secret(secretKey: secretKey, type: type_)
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
        case .value(let key, let type_, let value):
            try container.encode(key, forKey: .key)
            try container.encode(type_, forKey: .type)
            try container.encode(value, forKey: .value)
        case .secret(let secretKey, let type_):
            try container.encode(secretKey, forKey: .secretKey)
            try container.encode(type_, forKey: .type)
        }
    }
}
