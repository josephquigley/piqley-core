/// A single line of output from a piqley plugin, streamed as newline-delimited JSON.
public struct PluginOutputLine: Codable, Sendable, Equatable {
    /// The type of output line (e.g. "result", "progress", "imageResult").
    public let type: String
    /// A human-readable message.
    public let message: String?
    /// The filename associated with this output (for image results).
    public let filename: String?
    /// Whether the operation succeeded.
    public let success: Bool?
    /// An error message if the operation failed.
    public let error: String?
    /// State to persist, keyed by folder path then key.
    public let state: [String: [String: JSONValue]]?

    public init(
        type: String,
        message: String? = nil,
        filename: String? = nil,
        success: Bool? = nil,
        error: String? = nil,
        state: [String: [String: JSONValue]]? = nil
    ) {
        self.type = type
        self.message = message
        self.filename = filename
        self.success = success
        self.error = error
        self.state = state
    }
}
