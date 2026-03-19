<p align="center">
  <img src="logo.svg" alt="piqley core" width="460"/>
</p>

<h1 align="center">piqley core</h1>

<p align="center">
  Shared types and protocols for the <a href="https://github.com/josephquigley/piqley-cli">piqley</a> ecosystem.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white" alt="Swift 6.0"/>
  <img src="https://img.shields.io/badge/Platforms-macOS%20%7C%20Linux-blue" alt="Platforms"/>
  <img src="https://img.shields.io/github/license/josephquigley/piqley-core" alt="License"/>
</p>

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/I3I2LL7Y1)
---

PiqleyCore is the foundational Swift library that defines the plugin architecture, manifest format, and data types used across piqley and its plugins.

## What's Inside

- **Plugin manifest types** — `PluginManifest`, hooks, config schema, setup declarations
- **Plugin I/O** — `PluginInputPayload` and `PluginOutputLine` for stdin/stdout communication
- **Configuration** — `PluginConfig`, typed values, secrets, and declarative metadata rules
- **Supporting types** — `SemanticVersion`, `JSONValue`, `ConfigValueType`

All types are `Codable` and `Sendable`.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/josephquigley/piqley-cli-core.git", from: "0.1.0")
]
```

## Related

- [piqley-cli](https://github.com/josephquigley/piqley-cli) — CLI for photo publishing workflows
- [piqley-plugin-sdk](https://github.com/josephquigley/piqley-plugin-sdk) — Libraries for building piqley plugins

## License

[MIT](LICENSE)
