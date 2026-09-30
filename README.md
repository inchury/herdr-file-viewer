# herdr-file-viewer

[한국어 README](README_KO.md)

[![CI](https://github.com/inchury/herdr-file-viewer/actions/workflows/ci.yml/badge.svg)](https://github.com/inchury/herdr-file-viewer/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Rust 1.96+](https://img.shields.io/badge/rust-1.96%2B-orange.svg)
![herdr 0.7+](https://img.shields.io/badge/herdr-0.7%2B-8a2be2)
![platforms: linux • macOS • Windows (preview)](https://img.shields.io/badge/platforms-linux%20%E2%80%A2%20macOS%20%E2%80%A2%20Windows%20(preview)-informational)

**A git-aware, read-only file viewer in a herdr pane.** Tree on the left. On the right, the view
that file deserves: a **diff** if it changed, **rendered markdown**, or **highlighted code**.
Agents can drop you on a file or a line. You pin one file, mark a range, and paste those notes
back into the chat. It never touches your files.

![herdr-file-viewer open in a herdr split beside your work: the directory tree on the left, syntax-highlighted content on the right](assets/File-viewer.png)

*The right view per file, here a markdown file rendered (headings, inline code, tables) in your terminal's theme:*

![herdr-file-viewer rendering a markdown file: colored headings and styled inline code on the right, the git-status tree on the left](assets/Markdown-view.png)

*…and running full-screen, the same tree + content, filling the terminal:*

![herdr-file-viewer running full-screen](assets/File-Viewer-FS.png)

*Pin a file with `p` and keep browsing: tree, the file you are on, and a frozen `Pinned: [main]` beside it:*

![herdr-file-viewer with a pinned preview: tree on the left, the active file in the middle, a frozen pin of another file on the right](assets/Pinned-preview.png)

## Why you'd want it

- **The right view, automatically.** Markdown opens as a rendered document preview (including changed
  README/CHANGELOG files), changed source opens as a diff, and code is syntax-highlighted. Compact
  diffs are colored natively (`+` green / `-` red) for stable Windows/ConPTY rendering. Press
  Markdown tables reflow to the content pane width instead of stretching the terminal; turn wrapping off with `w` when you prefer horizontal scrolling. Press `v` only when you want another available view.
- **Git in the tree.** `M`/`A`/`D`/`?` on every row, a changed-only filter (`c`), jump next/prev
  changed file (`]`/`[`), flip the baseline between your branch and `HEAD` (`b`). Not a separate
  git client.
- **Pin one file, keep browsing.** `p` freezes it on the right. Switch worktree (`W`) and compare
  it with another checkout, or pin the old version and walk the new one.
- **Agents show you the spot. You send notes back.** Teach them the [bundled skill](skills/herdr-file-viewer/SKILL.md)
  and "open `src/app.rs:42` in Files" lands you there. Mark a file or a range (`a`), copy the
  notes (`A` then `y`), paste them into the chat.
- **Edit in *your* editor.** `e` suspends the viewer and opens the file in neovim, vim, micro, or
  whatever you set as `editor` (else `$EDITOR`). You change the file there; the viewer never writes
  it, and comes back when you quit the editor.
- **Beside your work, safe on anything.** One keypress in a herdr split (or its own tab). Read-only,
  hardened for an agent's worktree or a fresh clone. Markdown is parsed with pulldown-cmark/CommonMark+GFM and rendered natively; compact diffs render natively; `delta` / `bat` remain optional enhancements.
  See [SECURITY.md](SECURITY.md).

## Highlights

A taste of what the keys do — the [full key & mouse reference](docs/keys.md) has them all, and the
[usage guide](docs/usage.md) walks through each feature:

| Key | Does |
| --- | --- |
| `f` | Fuzzy-find any file in the tree |
| `p` | Pin the current file and keep browsing (compare across worktrees with `W`) |
| `a` / `A` | Annotate a file or range; copy the notes out for an agent |
| `v` | Cycle the view (diff ⇄ rendered ⇄ syntax) |
| `]` / `[` | Jump to the next / previous changed file |
| `b` | Flip the diff baseline: your branch's merge-base ⇄ `HEAD` |
| `W` | Switch to another git worktree, in place |
| `L` | Copy a `path:line` reference (or the selected lines) |
| `Z` | Full-screen the current file |
| `e` / `O` / `R` | Hand off: editor / OS default app / file manager |
| `?` | Help overlay: What's New, keys, settings, about |
| `Esc` | Close the current overlay/zoom; at the outer level, show an explicit exit confirmation before leaving the viewer |

## v0.1.0 binary release

Download the prebuilt binary for Windows x64, Linux x64 (musl), macOS Apple Silicon, or macOS Intel from [GitHub Releases](https://github.com/inchury/herdr-file-viewer/releases/tag/v0.1.0). The release also includes `SHA256SUMS` for integrity verification. Windows support remains preview.

## Quick start

> [!IMPORTANT]
> Install this fork from `inchury/herdr-file-viewer`. Installing `smarzban/herdr-file-viewer`
> installs the upstream project and does **not** include this fork's native Markdown, Windows,
> responsiveness, and exit-confirmation changes.

```bash
# Install this fork. A matching release binary is used when this fork publishes one;
# otherwise the installer builds this checkout from source with Rust 1.96+.
herdr plugin install inchury/herdr-file-viewer

# Optional: install external renderers for full diff / source highlighting:
# Markdown preview and compact diff need no external tools.
brew install git-delta bat           # macOS, or use your package manager
#   Linux/macOS helper: ./scripts/install-renderers.sh
#   Windows PowerShell: powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-renderers.ps1
```

Then **bind a key** in your herdr config (`~/.config/herdr/config.toml`) so one press summons it:

```toml
[[keys.command]]
key = "prefix+f"
type = "plugin_action"
command = "herdr-file-viewer.open-file-viewer"
description = "open file viewer in split"

[[keys.command]]
key = "prefix+shift+f"
type = "plugin_action"
command = "herdr-file-viewer.open-file-viewer-tab"
description = "open file viewer in tab"
```

Run `herdr server reload-config`, then press your key. That's the whole setup: the split-pane
viewer and its open actions ship **inside** the plugin and register automatically on install, so
you only add the keybinding.

Deeper detail lives in the docs: [install & updating](docs/install.md),
[summoning the viewer](docs/summoning.md) (split vs. tab, the launcher, `--remote`),
[external renderers](docs/renderers.md), and the [keys reference](docs/keys.md).

## Configuration

An optional, **read-only** TOML config file lets you override the editor, the renderer/opener
commands, a couple of startup toggles, the tree layout, and the keybindings. A fully-commented
[`config.example.toml`](config.example.toml) ships in the plugin folder; copy it as `config.toml`
into the directory `herdr plugin config-dir herdr-file-viewer` prints, then uncomment what you want.

The full reference — file location, precedence, every key, and `[keys]` remapping — is in
**[docs/configuration.md](docs/configuration.md)**. See your effective settings any time in the `?`
help overlay's **Settings** section.

## Windows

Native Windows is supported as a **preview** (install works the same way; the open actions use
`-windows` action ids and herdr's preview channel). Targeted `path[:line]` opens are supported by
the bundled PowerShell launchers. The built-in Markdown preview requires no `glow`, compact diffs
render natively, and optional `delta` / `bat` can be installed with
`scripts/install-renderers.ps1`.

On focus regain, Git status/changed-set refresh runs off the input thread so a cold Git index,
filesystem, or antivirus path does not intentionally block keyboard/mouse handling. Exiting from
the outer viewer now asks for confirmation first, making the close key immediately visible before
terminal teardown. WSL remains the mature fallback with zero extra plugin setup. See
[docs/windows.md](docs/windows.md).

## Documentation

Full docs live in **[docs/](docs/README.md)**:

- **[Install & updating](docs/install.md)** — prebuilt vs. source, pinning a version, local-dev linking, and remote notices.
- **[Summoning the viewer](docs/summoning.md)** — the open actions, the idempotent launcher, split vs. tab, and the `--remote` caveat.
- **[Usage guide](docs/usage.md)** — a feature-by-feature tour of the whole viewer.
- **[Keys & mouse](docs/keys.md)** — the complete key table, mouse gestures, and editor hand-off.
- **[Configuration](docs/configuration.md)** — the full `config.toml` reference and `[keys]` remapping.
- **[External renderers](docs/renderers.md)** — built-in Markdown/compact-diff rendering plus optional `delta` / `bat` enhancements (and legacy/help `glow` paths).
- **[Windows (preview)](docs/windows.md)** — native-Windows specifics and WSL.
- **[Architecture](ARCHITECTURE.md)** — one in-process TUI owning both columns, the component map, and the load-bearing decisions.
- **[Security](SECURITY.md)** — the threat model for opening untrusted content, and how to report a vulnerability.

## Contributing

This repository is a fork with additional native Markdown/Windows/UX work. Report issues for this
fork at [inchury/herdr-file-viewer/issues](https://github.com/inchury/herdr-file-viewer/issues).
For source builds and contribution conventions, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © Saeed Marzban
