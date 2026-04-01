import Foundation

/// A dictionary-backed file-system manager for testing.
public final class InMemoryFileManager: FileSystemManager, @unchecked Sendable {

    // MARK: - Storage

    enum Entry {
        case file(Data, [FileAttributeKey: Any])
        case directory([FileAttributeKey: Any])

        var attributes: [FileAttributeKey: Any] {
            switch self {
            case .file(_, let attrs): return attrs
            case .directory(let attrs): return attrs
            }
        }
    }

    private var storage: [String: Entry] = [:]
    private let lock = NSLock()

    // MARK: - Init

    public init() {}

    // MARK: - Properties

    public var temporaryDirectory: URL {
        URL(fileURLWithPath: "/tmp/in-memory")
    }

    public var homeDirectoryForCurrentUser: URL {
        URL(fileURLWithPath: "/Users/test")
    }

    // MARK: - Helpers

    private func normalizePath(_ path: String) -> String {
        // Remove trailing slash unless root
        var result = path
        while result.count > 1 && result.hasSuffix("/") {
            result = String(result.dropLast())
        }
        return result
    }

    private func parentPath(of path: String) -> String? {
        let normalized = normalizePath(path)
        guard normalized != "/" else { return nil }
        let url = URL(fileURLWithPath: normalized)
        let parent = url.deletingLastPathComponent().path
        return normalizePath(parent)
    }

    private func ensureParentDirectories(for path: String) {
        var ancestors: [String] = []
        var current = path
        while let parent = parentPath(of: current) {
            if storage[parent] != nil { break }
            ancestors.append(parent)
            current = parent
        }
        for ancestor in ancestors.reversed() {
            storage[ancestor] = .directory([:])
        }
    }

    // MARK: - Existence

    public func fileExists(atPath path: String) -> Bool {
        lock.withLock {
            storage[normalizePath(path)] != nil
        }
    }

    public func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        lock.withLock {
            let normalized = normalizePath(path)
            guard let entry = storage[normalized] else { return false }
            if let isDirectory {
                switch entry {
                case .directory:
                    isDirectory.pointee = true
                case .file:
                    isDirectory.pointee = false
                }
            }
            return true
        }
    }

    public func isExecutableFile(atPath path: String) -> Bool {
        lock.withLock {
            let normalized = normalizePath(path)
            guard case .file(_, let attrs) = storage[normalized] else { return false }
            if let perms = attrs[.posixPermissions] as? Int {
                return perms & 0o111 != 0
            }
            return false
        }
    }

    // MARK: - Directory Operations

    public func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws {
        try createDirectory(
            atPath: url.path,
            withIntermediateDirectories: createIntermediates,
            attributes: attributes
        )
    }

    public func createDirectory(
        atPath path: String,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws {
        try lock.withLock {
            let normalized = normalizePath(path)

            if createIntermediates {
                // Create all intermediate directories
                var components: [String] = []
                var current = normalized
                while current != "/" {
                    if storage[current] != nil { break }
                    components.append(current)
                    current = parentPath(of: current) ?? "/"
                }
                for component in components.reversed() {
                    storage[component] = .directory(attributes ?? [:])
                }
            } else {
                // Parent must exist
                if let parent = parentPath(of: normalized) {
                    guard case .directory? = storage[parent] else {
                        throw CocoaError(.fileNoSuchFile)
                    }
                }
                storage[normalized] = .directory(attributes ?? [:])
            }
        }
    }

    public func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL] {
        let names = try contentsOfDirectory(atPath: url.path)
        var urls = names.map { url.appendingPathComponent($0) }
        if mask.contains(.skipsHiddenFiles) {
            urls = urls.filter { !$0.lastPathComponent.hasPrefix(".") }
        }
        return urls
    }

    public func contentsOfDirectory(atPath path: String) throws -> [String] {
        try lock.withLock {
            let normalized = normalizePath(path)
            guard case .directory? = storage[normalized] else {
                throw CocoaError(.fileReadNoSuchFile)
            }
            let prefix = normalized == "/" ? "/" : normalized + "/"
            var names: Set<String> = []
            for key in storage.keys where key.hasPrefix(prefix) && key != normalized {
                let remainder = String(key.dropFirst(prefix.count))
                // Only direct children (no nested path separators)
                if let slashIndex = remainder.firstIndex(of: "/") {
                    names.insert(String(remainder[remainder.startIndex..<slashIndex]))
                } else {
                    names.insert(remainder)
                }
            }
            return names.sorted()
        }
    }

    public func enumerator(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?
    ) -> FileManager.DirectoryEnumerator? {
        let urls: [URL] = lock.withLock {
            let normalized = normalizePath(url.path)
            let prefix = normalized == "/" ? "/" : normalized + "/"
            return storage.keys
                .filter { $0.hasPrefix(prefix) && $0 != normalized }
                .sorted()
                .map { URL(fileURLWithPath: $0) }
        }
        return InMemoryDirectoryEnumerator(urls: urls)
    }

    // MARK: - File Operations

    public func copyItem(at srcURL: URL, to dstURL: URL) throws {
        try lock.withLock {
            let srcPath = normalizePath(srcURL.path)
            let dstPath = normalizePath(dstURL.path)
            guard let srcEntry = storage[srcPath] else {
                throw CocoaError(.fileReadNoSuchFile)
            }
            guard storage[dstPath] == nil else {
                throw CocoaError(.fileWriteFileExists)
            }

            switch srcEntry {
            case .file(let data, let attrs):
                storage[dstPath] = .file(data, attrs)
            case .directory(let attrs):
                storage[dstPath] = .directory(attrs)
                // Copy descendants
                let srcPrefix = srcPath + "/"
                let dstPrefix = dstPath + "/"
                let keysToCopy = storage.keys.filter { $0.hasPrefix(srcPrefix) }
                for key in keysToCopy {
                    let relative = String(key.dropFirst(srcPrefix.count))
                    storage[dstPrefix + relative] = storage[key]
                }
            }
        }
    }

    public func moveItem(at srcURL: URL, to dstURL: URL) throws {
        try lock.withLock {
            let srcPath = normalizePath(srcURL.path)
            let dstPath = normalizePath(dstURL.path)
            guard let srcEntry = storage[srcPath] else {
                throw CocoaError(.fileReadNoSuchFile)
            }
            guard storage[dstPath] == nil else {
                throw CocoaError(.fileWriteFileExists)
            }

            // Move the item itself
            storage[dstPath] = srcEntry
            storage.removeValue(forKey: srcPath)

            // Move descendants
            let srcPrefix = srcPath + "/"
            let dstPrefix = dstPath + "/"
            let keysToMove = storage.keys.filter { $0.hasPrefix(srcPrefix) }
            for key in keysToMove {
                let relative = String(key.dropFirst(srcPrefix.count))
                storage[dstPrefix + relative] = storage.removeValue(forKey: key)
            }
        }
    }

    public func removeItem(at url: URL) throws {
        try removeItem(atPath: url.path)
    }

    public func removeItem(atPath path: String) throws {
        try lock.withLock {
            let normalized = normalizePath(path)
            guard storage[normalized] != nil else {
                throw CocoaError(.fileNoSuchFile)
            }
            storage.removeValue(forKey: normalized)
            // Remove descendants
            let prefix = normalized + "/"
            let keysToRemove = storage.keys.filter { $0.hasPrefix(prefix) }
            for key in keysToRemove {
                storage.removeValue(forKey: key)
            }
        }
    }

    @discardableResult
    public func replaceItemAt(_ originalItemURL: URL, withItemAt newItemURL: URL) throws -> URL? {
        try lock.withLock {
            let originalPath = normalizePath(originalItemURL.path)
            let newPath = normalizePath(newItemURL.path)
            guard let newEntry = storage[newPath] else {
                throw CocoaError(.fileReadNoSuchFile)
            }

            // Remove original and its descendants
            storage.removeValue(forKey: originalPath)
            let originalPrefix = originalPath + "/"
            let keysToRemove = storage.keys.filter { $0.hasPrefix(originalPrefix) }
            for key in keysToRemove {
                storage.removeValue(forKey: key)
            }

            // Move new item to original path
            storage[originalPath] = newEntry
            storage.removeValue(forKey: newPath)

            // Move new item descendants
            let newPrefix = newPath + "/"
            let destPrefix = originalPath + "/"
            let keysToMove = storage.keys.filter { $0.hasPrefix(newPrefix) }
            for key in keysToMove {
                let relative = String(key.dropFirst(newPrefix.count))
                storage[destPrefix + relative] = storage.removeValue(forKey: key)
            }

            return originalItemURL
        }
    }

    // MARK: - Content Operations

    public func contents(atPath path: String) -> Data? {
        lock.withLock {
            let normalized = normalizePath(path)
            guard case .file(let data, _) = storage[normalized] else { return nil }
            return data
        }
    }

    @discardableResult
    public func createFile(atPath path: String, contents data: Data?, attributes: [FileAttributeKey: Any]?) -> Bool {
        lock.withLock {
            let normalized = normalizePath(path)
            ensureParentDirectories(for: normalized)
            storage[normalized] = .file(data ?? Data(), attributes ?? [:])
            return true
        }
    }

    // MARK: - Attributes

    public func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtPath path: String) throws {
        try lock.withLock {
            let normalized = normalizePath(path)
            guard let entry = storage[normalized] else {
                throw CocoaError(.fileNoSuchFile)
            }
            switch entry {
            case .file(let data, var attrs):
                for (key, value) in attributes { attrs[key] = value }
                storage[normalized] = .file(data, attrs)
            case .directory(var attrs):
                for (key, value) in attributes { attrs[key] = value }
                storage[normalized] = .directory(attrs)
            }
        }
    }

    public func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        try lock.withLock {
            let normalized = normalizePath(path)
            guard let entry = storage[normalized] else {
                throw CocoaError(.fileNoSuchFile)
            }
            return entry.attributes
        }
    }

    // MARK: - Data I/O

    public func contents(of url: URL) throws -> Data {
        try lock.withLock {
            let normalized = normalizePath(url.path)
            guard case .file(let data, _) = storage[normalized] else {
                throw CocoaError(.fileReadNoSuchFile)
            }
            return data
        }
    }

    public func write(_ data: Data, to url: URL, options: Data.WritingOptions) throws {
        lock.withLock {
            let normalized = normalizePath(url.path)
            ensureParentDirectories(for: normalized)
            let existingAttrs: [FileAttributeKey: Any]
            if case .file(_, let attrs) = storage[normalized] {
                existingAttrs = attrs
            } else {
                existingAttrs = [:]
            }
            storage[normalized] = .file(data, existingAttrs)
        }
    }
}

// MARK: - InMemoryDirectoryEnumerator

/// A directory enumerator backed by a pre-collected list of URLs.
public final class InMemoryDirectoryEnumerator: FileManager.DirectoryEnumerator {
    private let urls: [URL]
    private var index: Int = 0

    init(urls: [URL]) {
        self.urls = urls
    }

    public override func nextObject() -> Any? {
        guard index < urls.count else { return nil }
        defer { index += 1 }
        return urls[index]
    }
}
