import Foundation

/// An error that can be thrown when parsing a semantic version string.
public enum SemanticVersionError: Error, Equatable {
    case invalidFormat
}

extension SemanticVersionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid semantic version format. Expected a version like '1.2.3' or '1.2'."
        }
    }
}

/// A semantic version number (major.minor.patch).
public struct SemanticVersion: Sendable, Equatable, CustomStringConvertible {
    public let major: Int
    public let minor: Int
    public let patch: Int

    /// Creates a SemanticVersion from components.
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Creates a SemanticVersion by parsing a string like "1.2.3" or "1.2" (patch defaults to 0).
    public init(_ string: String) throws {
        let parts = string.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 2 || parts.count == 3 else {
            throw SemanticVersionError.invalidFormat
        }
        guard
            let major = Int(parts[0]),
            let minor = Int(parts[1])
        else {
            throw SemanticVersionError.invalidFormat
        }
        let patch: Int
        if parts.count == 3 {
            guard let p = Int(parts[2]) else {
                throw SemanticVersionError.invalidFormat
            }
            patch = p
        } else {
            patch = 0
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}

// MARK: - Comparable

extension SemanticVersion: Comparable {
    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}

// MARK: - Codable

extension SemanticVersion: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        do {
            self = try SemanticVersion(string)
        } catch {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot parse '\(string)' as a semantic version"
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
