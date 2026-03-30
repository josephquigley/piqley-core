# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Fixed

- `PluginManifest` decoding defaults missing `type` field to `.static` for backward compatibility
- `PayloadCodingTests` updated for new `debug` parameter on `PluginInputPayload`
- `ManifestValidator` now rejects `skip` (alongside `original`) as a reserved plugin identifier
- `RuleEditingContext.stageNames()` now returns stages in canonical pipeline execution order instead of alphabetical
- `StageConfig.isEffectivelyEmpty` treats a binary with an empty command as empty
- `PluginManifest.secretKeys` and `valueEntries` pattern matches updated for `ConfigEntry` metadata parameter
- `ManifestCodingTests` updated for `ConfigMetadata` fields with new decode, encode, and displayLabel tests

### Added

- Optional `hook` field on `StageEntry` for aliasing custom stages to plugin-recognized hooks
- `StageRegistry.resolvedHook(for:)` query that returns the alias when set, or the stage name when unset
- `ImageOutcome` enum (`success`, `failure`, `warning`, `skip`) for per-image plugin results
- `status: ImageOutcome?` field on `PluginOutputLine` for `imageResult` lines
- `ConsumedField.readOnly` flag to indicate fields that cannot be targeted by emit/write actions
- `FieldInfo.readOnly` flag; catalog fields from `MetadataFieldCatalog` are marked read-only
- `PluginType` enum (`static`, `mutable`) to distinguish pre-compiled from user-created plugins
- Required `type` field on `PluginManifest` with full coding support
- `debug` property on `PluginInputPayload` for forwarding the CLI `--debug` flag to plugins
- `ConfigMetadata` struct with optional `label` and `description` fields on each `ConfigEntry` case
- `ConfigEntry.displayLabel` convenience property that falls back to the raw key when no label is set
- `StandardHook.requiredStages` and `requiredStageNames` identifying pipeline-start and pipeline-finished as non-removable
- `StageRegistry.isRequired(_:)` query for checking whether a stage is protected
- `StageRegistryError.requiredStage` error thrown when attempting to deactivate, remove, or rename a required stage
- `ConsumedField` struct and `consumedFields` array on `PluginManifest` for declaring state fields a plugin works with
- `JSONEncoder.piqley`, `JSONEncoder.piqleyPrettyPrint`, and `JSONDecoder.piqley` static extensions for unified JSON coding
- Convenience accessors on `JSONValue`: `stringValue`, `numberValue`, `intValue`, `boolValue`, `arrayValue`, `objectValue`
- `Hook` protocol with `stageConfig` requirement, enabling plugins to define custom hooks as enums
- `StandardHook` enum conforming to `Hook` with the 6 built-in pipeline hooks
- `PluginDirectory` constants (`bin`, `data`, `logs`) for shared access across CLI and SDK
- `supportedPlatforms: [String]?` property on `PluginManifest` for multi-platform plugin support
- `StageRegistry` data model for managing custom pipeline stages with persistence, validation, and mutation methods (add, activate, deactivate, remove, reorder, rename, auto-register)
- `Hook.defaultStageNames` for seeding the stage registry with canonical defaults
- `pipelineStart` and `pipelineFinished` lifecycle hooks on `Hook` enum for pipeline boundary events
- `pipelineRunId: String?` field on `PluginInputPayload` for per-run identification (backwards-compatible)
- `supportedFormats` and `conversionFormat` optional fields on `PluginManifest` for image format declarations
- `fork` optional field on `HookConfig` for parallel execution support
- `ManifestValidator` rejects `conversionFormat` when `supportedFormats` is not also set
- `skipped: [SkipRecord]` field on `PluginInputPayload` for backwards-compatible propagation of skipped images via the wire payload
- `SkipRecord` type for representing a skipped image in the pipeline wire payload
- `not: Bool?` property on `MatchConfig` for inverted matching
- `RuleBuilder.setMatch(field:pattern:not:)` overload for explicit negation flag setting during rule construction
- `not: Bool?` property on `EmitConfig` for inverted emit (remove/removeField only)
- `"writeBack"` action in `RuleValidator.validActions` (now 7 actions total)
- `RuleValidationError.notNotAllowed`, `.writeBackInEmit`, and `.writeBackNotAlone` cases
- `RuleValidator.validateRule(_:)` validates writeBack placement (write-only, must be alone)
- `RuleValidator.validateRule(_:)` for rule-level validation of skip constraints
- `RuleValidationError.skipWithWrite` and `.skipNotAlone` cases
- `"skip"` action in `RuleValidator.validActions`
- `EmitConfig.field` is now optional (`String?`) to support actions that require no target field (e.g. "skip")
- `ReservedName.skip` and `ReservedName.skipRecords` constants
- `StageConfig` type for per-stage plugin configuration
- `RuleEditingContext` for rule editor query and validation
- `RuleBuilder` for step-by-step validated rule construction
- `RuleValidator` and `RuleValidationError` types
- `RuleSlot` and `StageConfig` mutation methods
- `FieldInfo` and `MetadataFieldCatalog` for rule editor field selection
- `source` property on `EmitConfig` for clone emit action
- Environment mapping field on `HookConfig`
- `identifier` and `description` fields on `PluginManifest`
- Stage file constants in `PluginConfig`
- `write` array on `Rule` for metadata write actions
- `action` and `replacements` on `EmitConfig`; `Rule.emit` as array

### Changed

- **Breaking:** `PluginManifest.consumedFields` renamed to `fields`
- `Rule.match` is now optional (`MatchConfig?`). A nil match creates an unconditional rule that fires for every item
- `RuleBuilder.build()` no longer requires a match configuration
- Removed `.noMatch` case from `RuleValidationError`
- Removed fluff test suites (`HookTests`, `HookConfigTests`, `ConfigValueTypeTests`) that only verified enum raw values and trivial Codable round-trips
- Added tests for `StageConfig.isEffectivelyEmpty`, `ConsumedField` decoding, `RuleSlotError` error descriptions, and `JSONEncoder.piqleyPrettyPrint`
- **BREAKING:** `Hook` is now a protocol instead of an enum. The 6 built-in hooks move to `StandardHook`. All references to `Hook.canonicalOrder`, `Hook.defaultStageNames`, and `Hook.allCases` must use `StandardHook` instead.
- Reverted `supportedSchemaVersions` back to `["1"]`; no version bump needed without production consumers
- Renamed `pluginProtocolVersion` to `pluginSchemaVersion` with version validation
- Renamed `folderPath` to `imageFolderPath` in plugin input payload
- Migrated `PluginManifest.dependencies` to structured `PluginDependency` type
- Removed `hook` from `MatchConfig` — stage files imply the hook
- Removed `rules` from `PluginConfig`
- Removed redundant `schedule` hook

## [0.2.0] — 2026-03-18

### Added

- Shared constants for reserved names, plugin files, and pattern prefixes

## [0.1.0] — 2026-03-18

### Added

- `JSONValue` type with `Codable` and `ExpressibleBy` conformances
- `Hook` enum with canonical pipeline stages
- `ConfigValueType` and `PluginProtocol` enums
- `SemanticVersion` type with parsing and comparison
- `ConfigEntry` type with value and secret cases
- `HookConfig`, `SetupConfig`, and `BatchProxyConfig` types
- `PluginManifest` type with config, hooks, and dependencies
- `Rule` and `PluginConfig` types for declarative metadata rules
- `PluginInputPayload` and `PluginOutputLine` types for stdin/stdout communication
- `ManifestValidator` with constraint checking

[0.2.0]: https://github.com/josephquigley/piqley-core/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/josephquigley/piqley-core/releases/tag/0.1.0
