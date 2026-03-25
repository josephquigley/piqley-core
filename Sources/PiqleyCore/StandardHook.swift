/// The built-in pipeline hook stages for piqley plugins.
public enum StandardHook: String, Hook {
    case pipelineStart = "pipeline-start"
    case preProcess = "pre-process"
    case postProcess = "post-process"
    case publish = "publish"
    case postPublish = "post-publish"
    case pipelineFinished = "pipeline-finished"

    /// The canonical pipeline order for built-in hooks.
    public static let canonicalOrder: [StandardHook] = [
        .pipelineStart,
        .preProcess,
        .postProcess,
        .publish,
        .postPublish,
        .pipelineFinished
    ]

    /// Default stage names used to seed the stage registry.
    public static let defaultStageNames: [String] = canonicalOrder.map(\.rawValue)

    /// Stages that cannot be deactivated, removed, or renamed.
    public static let requiredStages: Set<StandardHook> = [.pipelineStart, .pipelineFinished]

    /// Required stage name strings for use in validation.
    public static let requiredStageNames: Set<String> = Set(requiredStages.map(\.rawValue))

    /// Built-in hooks return empty stage configs. Their stage files are managed
    /// by the CLI, not generated via `--create-stage-files`.
    public var stageConfig: StageConfig {
        StageConfig(preRules: nil, binary: nil, postRules: nil)
    }
}
