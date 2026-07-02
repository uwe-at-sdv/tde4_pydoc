# 3DE4 Python API

[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.3-blue)](./package.json)
[![3DEqualizer4](https://img.shields.io/badge/3DE4-3dequalizer.com-brightgreen)](https://3dequalizer.com/)
[![GitHub](https://img.shields.io/badge/GitHub-uwe--at--sdv-181717?logo=github)](https://github.com/uwe-at-sdv/tde4_pydoc)

This extension exposes the Waterloo documentation backend for the 3DE4 Python API
as a VS Code MCP server definition.

It is intentionally small: the extension does not generate docstrings, validate
Waterloo files, or bridge to a separate Python backend. It registers a local
`wtrl_mcp` server definition that points at the bundled Waterloo roots.

## Requirements

To use the extension, you need:

- VS Code `^1.115.0` or newer
- [sdv-doc-waterloo](https://github.com/uwe-at-sdv/sdv_doc_waterloo) installed locally so `wtrl_mcp` is available
- an MCP-capable client such as Copilot Chat or another MCP-aware editor tool

The extension starts `wtrl_mcp` with this command line:

```text
wtrl_mcp --config vscode/etc/wtrl_mcp.stdio.toml
```

## Features

The extension currently provides one feature:

- a VS Code MCP server definition for the 3DE4 Python API documentation

The server uses these bundled Waterloo roots:

- `vscode/roots/tde4_with_examples.wtrl.core.rfc-2119.json`
- `vscode/roots/tde4_script_config_with_examples.wtrl.core.rfc-2119.json`

## Recommended

For editing Waterloo docstrings in Python files, install the companion
extension:

- `Waterloo Docstrings`

It provides syntax highlighting and docstring-focused editor support that fits
this MCP server.

Use this extension for MCP access to the 3DE4 Python API documentation, and
use the companion extension for editing Waterloo docstrings themselves.

## Quick tutorial

1. Install the VSIX in VS Code.
2. Make sure `wtrl_mcp` from `sdv-doc-waterloo` is available on `PATH`.
3. Open Copilot Chat or another MCP client.
4. Point the client at the 3DE4 Python API MCP server definition.
5. If the client does not start the server automatically, trigger MCP tool selection once manually. Some clients need that nudge before they start the server process.

For a local test install from the repository root:

```text
tools/sdv_wtrl_install_vsix.sh vscode/tde4-pydoc-<version>.vsix
```

## Configuration

The extension ships with sensible defaults.

Optional settings:

- `tde4.mcpProvideServer`: register the MCP server definition in VS Code
- `tde4.mcpCommand`: override the `wtrl_mcp` executable name
- `tde4.mcpConfigPath`: point to a different `wtrl_mcp.stdio.toml`
- `tde4.mcpServerLabel`: change the label shown in VS Code

The default configuration file bundled with the extension is:

```text
vscode/etc/wtrl_mcp.stdio.toml
```

## Compatibility

- License: `BSD-2-Clause`
- VS Code engine constraint: `^1.115.0`
- MCP transport: stdio
- Intended backend: `wtrl_mcp` from `sdv-doc-waterloo`

The extension is compatible with MCP clients that can consume a VS Code MCP
server definition. It does not depend on the older docstring generation or
validation commands from the larger Waterloo VS Code package.

## Troubleshooting

If activation fails, open the VS Code Output panel and select the channel
`Channel.3DE4 Python API`. The extension prints the preflight result there,
including the most common reason: `sdv.doc.waterloo` is not installed in the
Python environment used by `wtrl_mcp`.
