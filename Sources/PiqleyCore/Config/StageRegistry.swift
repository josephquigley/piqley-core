import Foundation

public struct StageEntry: Codable, Sendable, Equatable {
    public var name: String
    public var hook: String?

    public init(name: String, hook: String? = nil) {
        self.name = name
        self.hook = hook
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
                active: StandardHook.defaultStageNames.map { StageEntry(name: $0) },
                available: []
            )
            try seeded.save(to: directory)
            return seeded
        }
        let data = try Data(contentsOf: file)
        return try JSONDecoder.piqley.decode(StageRegistry.self, from: data)
    }

    public func save(to directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder.piqleyPrettyPrint.encode(self)
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

    public func resolvedHook(for stage: String) -> String {
        if let entry = active.first(where: { $0.name == stage }),
           let hook = entry.hook {
            return hook
        }
        return stage
    }

    // MARK: - Validation

    private static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")

    public static func isValidName(_ name: String) -> Bool {
        guard name.count >= 2 else { return false }
        guard !name.hasPrefix("-"), !name.hasSuffix("-") else { return false }
        return name.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }

    public static func isRequired(_ name: String) -> Bool {
        StandardHook.requiredStageNames.contains(name)
    }

    // MARK: - Mutations

    public mutating func addStage(_ name: String, at index: Int) throws {
        guard Self.isValidName(name) else { throw StageRegistryError.invalidName(name) }
        guard !isKnown(name) else { throw StageRegistryError.stageAlreadyExists(name) }
        guard index >= 0, index <= active.count else { throw StageRegistryError.indexOutOfBounds }
        active.insert(StageEntry(name: name), at: index)
    }

    public mutating func activate(_ name: String, at index: Int) throws {
        guard let availIdx = available.firstIndex(where: { $0.name == name }) else {
            throw StageRegistryError.stageNotFound(name)
        }
        guard index >= 0, index <= active.count else { throw StageRegistryError.indexOutOfBounds }
        let entry = available.remove(at: availIdx)
        active.insert(entry, at: index)
    }

    public mutating func deactivate(_ name: String) throws {
        guard !Self.isRequired(name) else { throw StageRegistryError.requiredStage(name) }
        guard let idx = active.firstIndex(where: { $0.name == name }) else {
            throw StageRegistryError.stageNotFound(name)
        }
        let entry = active.remove(at: idx)
        available.append(entry)
    }

    public mutating func removeStage(_ name: String) throws {
        guard !Self.isRequired(name) else { throw StageRegistryError.requiredStage(name) }
        if let idx = active.firstIndex(where: { $0.name == name }) {
            active.remove(at: idx)
        } else if let idx = available.firstIndex(where: { $0.name == name }) {
            available.remove(at: idx)
        } else {
            throw StageRegistryError.stageNotFound(name)
        }
    }

    public mutating func reorder(_ name: String, to newIndex: Int) throws {
        guard let oldIndex = active.firstIndex(where: { $0.name == name }) else {
            throw StageRegistryError.stageNotFound(name)
        }
        guard newIndex >= 0, newIndex < active.count else { throw StageRegistryError.indexOutOfBounds }
        let entry = active.remove(at: oldIndex)
        active.insert(entry, at: newIndex)
    }

    public mutating func renameStage(_ oldName: String, to newName: String) throws {
        guard !Self.isRequired(oldName) else { throw StageRegistryError.requiredStage(oldName) }
        guard Self.isValidName(newName) else { throw StageRegistryError.invalidName(newName) }
        guard !isKnown(newName) else { throw StageRegistryError.stageAlreadyExists(newName) }
        if let idx = active.firstIndex(where: { $0.name == oldName }) {
            active[idx].name = newName
        } else if let idx = available.firstIndex(where: { $0.name == oldName }) {
            available[idx].name = newName
        } else {
            throw StageRegistryError.stageNotFound(oldName)
        }
    }

    /// Register an unknown stage name into the available list.
    /// No-op if the name is already known.
    public mutating func autoRegister(_ name: String) {
        guard !isKnown(name) else { return }
        available.append(StageEntry(name: name))
    }
}

public enum StageRegistryError: Error, CustomStringConvertible {
    case stageNotFound(String)
    case stageAlreadyExists(String)
    case invalidName(String)
    case indexOutOfBounds
    case requiredStage(String)

    public var description: String {
        switch self {
        case let .stageNotFound(name): "Stage '\(name)' not found"
        case let .stageAlreadyExists(name): "Stage '\(name)' already exists"
        case let .invalidName(name): "'\(name)' is not a valid stage name"
        case .indexOutOfBounds: "Index out of bounds"
        case let .requiredStage(name): "Stage '\(name)' is required and cannot be removed or renamed"
        }
    }
}
