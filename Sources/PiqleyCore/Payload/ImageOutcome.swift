/// The outcome of processing a single image in a plugin.
public enum ImageOutcome: String, Codable, Sendable, Equatable {
    case success
    case failure
    case warning
    case skip
}
