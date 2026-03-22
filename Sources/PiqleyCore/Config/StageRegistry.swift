import Foundation

public struct StageEntry: Codable, Sendable, Equatable {
    public var name: String

    public init(name: String) {
        self.name = name
    }
}

public struct StageRegistry: Codable, Sendable {
    public static let fileName = "stages.json"

    public var schemaVersion: Int = 1
    public var active: [StageEntry]
    public var available: [StageEntry]

    public init(active: [StageEntry] = [], available: [StageEntry] = []) {
        self.active = active
        self.available = available
    }

    // MARK: - Persistence

    public static func load(from directory: URL) throws -> StageRegistry {
        let file = directory.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: file.path) else {
            let seeded = StageRegistry(
                active: Hook.defaultStageNames.map { StageEntry(name: $0) },
                available: []
            )
            try seeded.save(to: directory)
            return seeded
        }
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(StageRegistry.self, from: data)
    }

    public func save(to directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: directory.appendingPathComponent(Self.fileName), options: .atomic)
    }

    // MARK: - Queries

    public var allKnownNames: Set<String> {
        Set(active.map(\.name) + available.map(\.name))
    }

    public func isKnown(_ name: String) -> Bool {
        allKnownNames.contains(name)
    }

    public var executionOrder: [String] {
        active.map(\.name)
    }

    // MARK: - Validation

    private static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")

    public static func isValidName(_ name: String) -> Bool {
        guard name.count >= 2 else { return false }
        guard !name.hasPrefix("-"), !name.hasSuffix("-") else { return false }
        return name.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
}
