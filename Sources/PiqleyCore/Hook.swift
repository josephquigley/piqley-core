import Foundation

/// Protocol for pipeline hook stages.
///
/// Plugins define custom hooks by creating enums that conform to this protocol.
/// The built-in hooks are provided by ``StandardHook``.
public protocol Hook: RawRepresentable, CaseIterable, Codable, Sendable
    where RawValue == String {
    /// The stage configuration for this hook, used to generate stage files
    /// during the build/packaging process via `--create-stage-files`.
    var stageConfig: StageConfig { get }
}
