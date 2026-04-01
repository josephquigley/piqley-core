import Foundation

/// An abstraction over file-system operations, enabling testability via in-memory replacements.
public protocol FileSystemManager: Sendable {

    // MARK: - Properties

    var temporaryDirectory: URL { get }
    var homeDirectoryForCurrentUser: URL { get }

    // MARK: - Existence

    func fileExists(atPath path: String) -> Bool
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
    func isExecutableFile(atPath path: String) -> Bool

    // MARK: - Directory Operations

    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws

    func createDirectory(
        atPath path: String,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws

    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL]

    func contentsOfDirectory(atPath path: String) throws -> [String]

    func enumerator(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?
    ) -> FileManager.DirectoryEnumerator?

    // MARK: - File Operations

    func copyItem(at srcURL: URL, to dstURL: URL) throws
    func moveItem(at srcURL: URL, to dstURL: URL) throws
    func removeItem(at url: URL) throws
    func removeItem(atPath path: String) throws
    func replaceItemAt(_ originalItemURL: URL, withItemAt newItemURL: URL) throws -> URL?

    // MARK: - Content Operations

    func contents(atPath path: String) -> Data?
    @discardableResult
    func createFile(atPath path: String, contents data: Data?, attributes: [FileAttributeKey: Any]?) -> Bool

    // MARK: - Attributes

    func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtPath path: String) throws
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any]

    // MARK: - Data I/O

    func contents(of url: URL) throws -> Data
    func write(_ data: Data, to url: URL, options: Data.WritingOptions) throws
}

// MARK: - Convenience Extensions

extension FileSystemManager {

    public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
        try createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: nil)
    }

    public func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?
    ) throws -> [URL] {
        try contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: [])
    }

    public func write(_ data: Data, to url: URL) throws {
        try write(data, to: url, options: [])
    }
}
