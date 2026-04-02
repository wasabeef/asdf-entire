# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

asdf plugin for [Entire CLI](https://github.com/entireio/cli) — AI agent session capture tool linked to git commits. Implements the standard asdf plugin protocol in Bash.

## Commands

### Lint & Format

```bash
# ShellCheck (static analysis)
shellcheck bin/* lib/*

# shfmt (format check, dry-run)
shfmt -d .

# shfmt (auto-fix)
shfmt -w .
```

### Test (via asdf plugin test)

```bash
# Requires asdf installed
asdf plugin test entire https://github.com/wasabeef/asdf-entire.git "entire --version"
```

CI runs on both Ubuntu and macOS (`build.yml`).

## Architecture

All scripts are Bash with `set -euo pipefail`.

- `bin/download` — Downloads release tarball from `entireio/cli` GitHub releases
- `bin/install` — Copies downloaded binary to `$ASDF_INSTALL_PATH/bin/`
- `bin/list-all` — Lists available versions via GitHub API tags
- `bin/latest-stable` — Returns latest stable version (filters pre-releases)
- `bin/help.*` — asdf help system hooks
- `lib/utils.bash` — Shared functions: platform/arch detection, download, checksum verification, error handling

### Key Environment Variables

| Variable | Purpose |
|---|---|
| `ASDF_INSTALL_VERSION` | Target version |
| `ASDF_INSTALL_PATH` | Installation destination |
| `ASDF_DOWNLOAD_PATH` | Temporary download directory |
| `GITHUB_API_TOKEN` / `GITHUB_TOKEN` | GitHub API auth (rate limit avoidance) |
| `ASDF_ENTIRE_OVERWRITE_ARCH` | Override architecture detection |

## Conventions

- Shebang: `#!/usr/bin/env bash`
- Indentation: **Tabs** for Bash, 2 spaces for YAML/Markdown (`.editorconfig`)
- Scripts source `lib/utils.bash` via `BASH_SOURCE[0]` relative path resolution
- Error output: `fail()` (red, exits 1) / `msg()` (green, stderr)
- Cross-platform: macOS requires `sed -E` (ERE) instead of `sed -r`
- Checksum: SHA256 verification on all downloads (`sha256sum` or `shasum -a 256`)
