import Foundation

/// A `Codable`, `Equatable`, `Sendable` enum representing any JSON value.
public enum JSONValue: Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])
    case null
}

// MARK: - Codable

extension JSONValue: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .number(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let arrayValue = try? container.decode([JSONValue].self) {
            self = .array(arrayValue)
        } else if let objectValue = try? container.decode([String: JSONValue].self) {
            self = .object(objectValue)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode JSONValue"
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

// MARK: - Convenience accessors

extension JSONValue {
    /// Returns the wrapped `String` if this is `.string`, otherwise `nil`.
    public var stringValue: String? {
        if case .string(let v) = self { return v }
        return nil
    }

    /// Returns the wrapped `Double` if this is `.number`, otherwise `nil`.
    public var numberValue: Double? {
        if case .number(let v) = self { return v }
        return nil
    }

    /// Returns the wrapped `Int` if this is `.number` with an integer value, otherwise `nil`.
    public var intValue: Int? {
        guard case .number(let v) = self,
              v == v.rounded(.towardZero),
              v >= Double(Int.min),
              v <= Double(Int.max) else { return nil }
        return Int(v)
    }

    /// Returns the wrapped `Bool` if this is `.bool`, otherwise `nil`.
    public var boolValue: Bool? {
        if case .bool(let v) = self { return v }
        return nil
    }

    /// Returns the wrapped `[JSONValue]` if this is `.array`, otherwise `nil`.
    public var arrayValue: [JSONValue]? {
        if case .array(let v) = self { return v }
        return nil
    }

    /// Returns the wrapped `[String: JSONValue]` if this is `.object`, otherwise `nil`.
    public var objectValue: [String: JSONValue]? {
        if case .object(let v) = self { return v }
        return nil
    }
}

// MARK: - ExpressibleBy conformances

extension JSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSONValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValue...) {
        self = .array(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }
}
