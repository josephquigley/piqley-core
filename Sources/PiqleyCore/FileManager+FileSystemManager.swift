import Foundation

extension FileManager: FileSystemManager {

    public func enumerator(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?
    ) -> FileManager.DirectoryEnumerator? {
        enumerator(at: url, includingPropertiesForKeys: keys, options: [], errorHandler: nil)
    }

    public func replaceItemAt(
        _ originalItemURL: URL,
        withItemAt newItemURL: URL
    ) throws -> URL? {
        try replaceItemAt(originalItemURL, withItemAt: newItemURL, backupItemName: nil, options: [])
    }

    public func contents(of url: URL) throws -> Data {
        try Data(contentsOf: url)
    }

    public func write(_ data: Data, to url: URL, options: Data.WritingOptions) throws {
        try data.write(to: url, options: options)
    }
}
