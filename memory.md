# PowerShell Workspace Memory

## Purpose
This directory is a personal PowerShell runtime, not a conventional software project. Its job is to bootstrap a fast interactive shell, load a curated set of custom commands, improve terminal UX, and expose a few high-power Windows automation workflows.

The first-party logic is concentrated in:

- `Microsoft.PowerShell_profile.ps1`
- `EasyModules/`
- `Steroids/`
- `fix-codex-startup.ps1`
- `highContext.omp.json`
- `powershell.config.json`
- `.claude/settings.local.json`

Everything under `Modules/` and most of `Help/` is dependency/runtime inventory, not the main codebase.

## High-Level Architecture

### 1. Bootstrap Layer
`Microsoft.PowerShell_profile.ps1` is the entrypoint.

It is responsible for:

- minimal-mode early exit via `PWSH_MINIMAL`
- silent startup preferences
- optional debug logging
- safe module imports
- lazy-loading heavy modules
- cached file discovery for custom scripts
- prompt/theme initialization
- PSReadLine configuration
- helper import and dot-sourcing of local command packs
- startup dashboard display
- module install/update helpers
- local Claude memory helper bootstrap

This file is the orchestration layer for the whole workspace.

### 2. Shared Utilities Layer
`EasyModules/Helpers/Helpers.psm1` provides lightweight shared helpers:

- `Write-Color`
- `Confirm-Action`
- `Wait-Input`

Most custom commands depend on these for UX and confirmation behavior.

### 3. Custom Command Suite
`EasyModules/` contains 12 first-party command files. These behave like a personal toolbox for diagnostics, maintenance, profile management, and package management.

Primary commands:

- `sys`: system snapshot and reporting
- `net`: network diagnostics and reporting
- `tools`: development tool inventory and update checks
- `apps`: installed app inventory across registry and package managers
- `Optimize`: system cleanup and tuning
- `Update`: cross-package-manager updates
- `Profile`: edit/reload/backup/compare PowerShell profile
- `Restart-Terminal`: restart or relaunch shell sessions
- `Get-FormattedHelp` with alias `man`
- `help`: custom command guide
- `Get-Summary`: command availability summary
- `Clean-Old`: interactive old-file cleanup
- `Z-Statistics.ps1`: startup dashboard

### 4. Command Override / Power Wrapper Layer
`Steroids/` contains 5 interactive wrappers around external tools or OS features.

- `nav-enhance.ps1`: navigation, listings, bookmarks, fuzzy jumping
- `yt-dlp-enhance.ps1`: interactive media download workflows
- `robocopy-enhance.ps1`: interactive/scheduled sync and backup workflows
- `cipher-enhance.ps1`: EFS encryption and secure wipe workflows
- `asllock-en3hance.ps1`: ACL-based lock/unlock tool with password gate

These are not small aliases. They are full UX wrappers with saved settings and task-specific flows.

### 5. Runtime Inventory Layer
`Modules/` contains 31 installed PowerShell modules, including:

- `oh-my-posh`
- `PSReadLine`
- `PSFzf`
- `PSScriptAnalyzer`
- `PSWindowsUpdate`
- `Terminal-Icons`
- `posh-git`
- `z`
- `BurntToast`
- `Posh-SSH`
- `Microsoft.WinGet.*`

`Help/` contains 498 local help files and reference packs for PowerShell/Windows modules.

These directories are operational dependencies, not primary authored code.

## Key Files And Why They Matter

### `Microsoft.PowerShell_profile.ps1`
Most important file in the workspace.

Key design choices:

- startup speed is treated as a feature
- heavy modules are lazy-loaded when possible
- local scripts are loaded from cached file lists
- `oh-my-posh` and `zoxide` are core UX dependencies
- PSReadLine is explicitly forced to latest available version
- custom EasyModules and Steroids are dot-sourced automatically
- startup ends with a dashboard from `Z-Statistics.ps1`

Also noteworthy:

- defines `Install-PwshModules`, `Update-PwshModules`, `Profile-Stats`
- sets `ANTHROPIC_BASE_URL=http://localhost:8080`
- sets `ANTHROPIC_AUTH_TOKEN=test`
- adds `claude-mem` helper backed by local `bun`

Interpretation:
This shell is tailored for daily interactive use, local AI tooling, and fast command recall.

### `highContext.omp.json`
Defines a dense, information-rich prompt using `oh-my-posh`.

Prompt segments include:

- OS/host
- shell
- path
- git status
- node/package context
- time
- battery
- execution time
- command status

Interpretation:
The user prefers high-context visual feedback directly in the prompt.

### `fix-codex-startup.ps1`
Maintenance script for Codex local config recovery.

It:

- backs up `~/.codex/config.toml`
- removes stale `mcp_servers.github`
- removes stale `mcp_servers.context7`
- optionally disables hooks after backing up `hooks.json`

Interpretation:
This environment has already needed repair tooling for local Codex startup issues.

## First-Party Command Groups

### Diagnostics And Visibility

- `sys`: OS, CPU, RAM, storage, top processes, exportable report
- `net`: adapters, IPs, DNS, gateway, ping, trace, DNS lookup, public IP, report export
- `tools`: scans common developer tools, versions, update availability
- `apps`: enumerates installed software from registry and package managers
- `man`: enhanced formatted help viewer
- `help` / `Get-Summary`: custom command discovery

User need served:
fast machine introspection without leaving the shell.

### Maintenance And Lifecycle

- `Optimize`: multi-step cleanup, service tuning, memory cleanup, network flush, disk optimization, safe registry tweak
- `Update`: upgrade packages across Winget/Scoop/Choco/NPM/Go/Cargo/Pip/Gem/Dotnet
- `Clean-Old`: purge old files by extension and age
- `Profile`: edit, reload, backup, compare profile files
- `Restart-Terminal`: relaunch shell with preserved context/options

User need served:
use PowerShell as a control center for machine hygiene and shell self-management.

### Navigation And Daily Terminal UX

`nav-enhance.ps1` provides:

- zoxide-based jumping
- fuzzy selection with `fzf`
- enhanced file listing via `eza`
- bookmarks
- project finder
- stats
- git-oriented navigation helpers

User need served:
fast movement across projects and folders, with richer listing than stock PowerShell.

### File Movement / Backup / Sync

`robocopy-enhance.ps1` provides:

- interactive robocopy presets
- saved preferences
- logging modes
- scheduled task creation
- watch-and-sync loop
- quick preset commands

User need served:
repeatable local backup/sync workflows without memorizing robocopy flags.

### Media Acquisition

`yt-dlp-enhance.ps1` provides:

- interactive download setup
- cookie/browser auth support
- output directory management
- quick video/audio/playlist helpers
- saved defaults

User need served:
download media reliably from the shell, including harder authenticated cases.

### Local Data Protection

`cipher-enhance.ps1` provides:

- EFS encryption/decryption
- recursive folder operations
- secure wipe options
- archive-related flows
- encrypted-file stats
- key-backup guidance

`asllock-en3hance.ps1` provides:

- ACL-based path lock/unlock/status
- password hash file under `%LOCALAPPDATA%\acllock`
- ACL backup/restore
- TUI and CLI modes

User need served:
quick local protection of files/folders from the shell.

## Likely User Priorities
Based on the structure and naming, the user likely cares most about:

- fast interactive startup
- high-visibility shell UX
- strong command discoverability
- self-service machine diagnostics
- package/update control from one place
- project navigation speed
- automation without needing full scripts each time
- Windows-native admin tasks wrapped in friendlier UX
- local AI/Codex/Claude workflows integrated into the shell

## Important Findings

### 1. This is a personal operations workspace, not a reusable module project
There is no packaging, test harness, CI, or repository-style source structure. The code is optimized for local interactive use.

### 2. `Modules/` and `Help/` should usually be ignored during feature work
They are large and mostly third-party or OS-provided content. Reading them first wastes time unless the task is explicitly about installed modules or help data.

### 3. Several commands are intentionally high-impact
Potentially destructive or privileged workflows include:

- `Optimize`
- `Clean-Old`
- `Update`
- `robocopy` presets like mirror
- `cipher` secure wipe flows
- `asllock` ACL mutation
- `Restart-Terminal` because it exits current session

Any future edits here should preserve confirmations or preview modes.

### 4. Some wrappers shadow built-in or external command names
Examples:

- `help`
- `profile`
- `robocopy`
- `yt-dlp`

This is intentional for interactive UX, but it means script compatibility should be considered before changing behavior.

### 5. Startup design values speed, but not strict minimalism
The profile is performance-aware, but still loads a lot of UX behavior, modules, and welcome/dashboard output. Fast-enough daily experience matters more than bare startup.

### 6. AI tooling is part of the shell contract
The profile hardcodes local Anthropic environment values and a `claude-mem` entrypoint. `fix-codex-startup.ps1` and `.claude/settings.local.json` also show active local agent-tool workflow customization.

## Risks And Fragile Areas

### High Risk

- `Optimize` performs cleanup, service stops, DISM cleanup, disk optimization, and registry tweaks.
- `Clean-Old` can recursively delete files.
- `robocopy` mirror/sync operations can overwrite or delete destination state.
- `cipher` and `asllock` manipulate protection state and may create recovery problems if altered carelessly.

### Medium Risk

- `Restart-Terminal` launches new sessions and may close the current one.
- `Update` spans many package managers with different output formats and failure modes.
- `tools` uses parallel/version probing and package-manager-specific checks.

### Behavioral Fragility

- `Get-CachedFileList` checks latest writes recursively but only loads matching files directly under the target folder; nested future scripts would not auto-load unless the loader changes.
- many custom commands assume external tools exist: `eza`, `fzf`, `zoxide`, `yt-dlp`, `winget`, `scoop`, `choco`, `git`, `code`
- several scripts are heavily interactive and not designed first for automation pipelines

### Potential Design Smell
`Steroids/asllock-en3hance.ps1` contains top-level admin enforcement and an interactive TUI, while the profile dot-sources all `*-enhance.ps1` files. That combination is unusual and should be treated carefully if startup issues appear.

## What Matters Most For Future Work

If changing this workspace, prioritize files in this order:

1. `Microsoft.PowerShell_profile.ps1`
2. `EasyModules/Helpers/Helpers.psm1`
3. the specific `EasyModules/*.ps1` command being changed
4. the specific `Steroids/*-enhance.ps1` wrapper being changed
5. `highContext.omp.json` for prompt/UI work

Only touch `Modules/` or `Help/` if the task is explicitly about installed dependencies or local documentation.

## Practical Orientation Notes

- `Scripts/` is currently empty.
- `.cache_easymodules.json` and `.cache_steroids.json` are startup caches, not source.
- `powershell.config.json` only sets execution policy to `RemoteSigned`.
- `.claude/settings.local.json` contains local permission rules for reading Claude temp task outputs.

## Short Summary
This workspace is a customized Windows PowerShell command center built around one profile bootstrap file, a dozen first-party utility commands, five heavier task wrappers, and a large local dependency/help inventory. The most important user need is fast, rich, interactive shell control over diagnostics, maintenance, navigation, package management, sync, downloads, and local protection workflows.
