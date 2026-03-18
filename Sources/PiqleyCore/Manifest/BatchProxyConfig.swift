/// Sort order for batch proxy operations.
public enum SortOrder: String, Codable, Sendable, Equatable {
    case ascending
    case descending
}

/// Sort configuration for batch proxy.
public struct SortConfig: Codable, Sendable, Equatable {
    public let key: String
    public let order: SortOrder

    public init(key: String, order: SortOrder) {
        self.key = key
        self.order = order
    }
}

/// Configuration for batch proxy behavior in a hook.
public struct BatchProxyConfig: Codable, Sendable, Equatable {
    public let sort: SortConfig?

    public init(sort: SortConfig? = nil) {
        self.sort = sort
    }
}
