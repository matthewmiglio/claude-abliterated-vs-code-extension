# Claude Abliterated Button for VS Code

A VS Code extension that adds a red button next to the Claude Code button. When clicked, it opens a terminal and runs `claude-abliterated.ps1`, which routes Claude Code to [abliteration.ai](https://abliteration.ai).

Unlike a GLM/Z.ai setup, no proxy is needed: abliteration.ai exposes a native Anthropic-compatible `/v1/messages` endpoint, so the script just overrides the Anthropic env vars and runs `claude`.

## Features

- Red button in the editor title bar (next to the orange Claude button)
- Opens a terminal and executes `claude-abliterated.ps1`
- Keyboard shortcut: `Ctrl+Shift+Alt+A` (Windows/Linux) or `Cmd+Shift+Alt+A` (Mac)
- Defaults to `abliterated-model-large-v2`; swap models in-session (see below)

## Installation

1. Copy this folder to your VS Code extensions directory:
   ```
   %USERPROFILE%\.vscode\extensions\claude-abliterated-button
   ```
2. Reload VS Code (`Ctrl+Shift+P` -> "Developer: Reload Window")

## Requirements

- `ABLITERATION_API_KEY` environment variable set (User or Machine level)
- Claude Code CLI installed and on PATH

## Setting ABLITERATION_API_KEY (one time)

```powershell
[Environment]::SetEnvironmentVariable('ABLITERATION_API_KEY','<your-key>','User')
```

Then restart your terminal/VS Code.

## How It Works

`claude-abliterated.ps1`:
1. Reads `ABLITERATION_API_KEY` from environment
2. Sets `ANTHROPIC_BASE_URL` to `https://api.abliteration.ai`
3. Sets `ANTHROPIC_AUTH_TOKEN` to your key (sent as `Authorization: Bearer`)
4. Sets `ANTHROPIC_MODEL=abliterated-model-large-v2` (default) and `ANTHROPIC_SMALL_FAST_MODEL=abliterated-model` for background tasks
5. Runs `claude` with all arguments passed through
6. Restores original environment values in a `finally` block

## Models

| Model | Context | Notes |
|-------|---------|-------|
| `abliterated-model-large-v2` | 1M | **default** |
| `abliterated-model-large` | 1M | |
| `abliterated-model` | 262K | text + image; used as the small/fast background model |

Swap the active model inside a running Claude Code session with:

```
/model abliterated-model-large
/model abliterated-model
```

`/model` with no argument lists the current model. The default (`abliterated-model-large-v2`) is set by the script on launch.

## Files

- `package.json` - Extension manifest
- `extension.js` - Main extension logic
- `claude-abliterated.ps1` - PowerShell script that routes to abliteration.ai
- `resources/red-icon.svg` - Red icon for the button
