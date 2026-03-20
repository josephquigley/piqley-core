/// A record indicating an image was skipped during pipeline processing.
public struct SkipRecord: Codable, Sendable, Equatable {
    /// The filename of the skipped image.
    public let file: String
    /// The identifier of the plugin that triggered the skip.
    public let plugin: String

    public init(file: String, plugin: String) {
        self.file = file
        self.plugin = plugin
    }
}
