/// Pipeline hook stages for piqley plugins.
public enum Hook: String, CaseIterable, Codable, Sendable {
    case pipelineStart = "pipeline-start"
    case preProcess = "pre-process"
    case postProcess = "post-process"
    case publish = "publish"
    case postPublish = "post-publish"
    case pipelineFinished = "pipeline-finished"

    /// The canonical pipeline order for hooks.
    public static let canonicalOrder: [Hook] = [
        .pipelineStart,
        .preProcess,
        .postProcess,
        .publish,
        .postPublish,
        .pipelineFinished
    ]
}
