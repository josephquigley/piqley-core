/// Pipeline hook stages for piqley plugins.
public enum Hook: String, CaseIterable, Codable, Sendable {
    case preProcess = "pre-process"
    case postProcess = "post-process"
    case publish = "publish"
    case schedule = "schedule"
    case postPublish = "post-publish"

    /// The canonical pipeline order for hooks.
    public static let canonicalOrder: [Hook] = [
        .preProcess,
        .postProcess,
        .publish,
        .schedule,
        .postPublish
    ]
}
