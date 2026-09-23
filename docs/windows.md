# Windows (preview)

Native Windows (`x86_64-pc-windows-msvc`) is supported as a **preview**, mirroring herdr's own
posture there: the crate builds, the test suite runs (advisory) on `windows-latest` CI, and
install works the same way as Linux/macOS: `herdr plugin install` downloads a SHA-256-verified
prebuilt binary (via `scripts/fetch-or-build.ps1`) or falls back to `cargo build --release`, no
extra tooling required beyond the in-box Windows PowerShell 5.1. The open/toggle actions work via
PowerShell launcher scripts.

- **On Windows, bind the `-windows` action ids.** herdr requires every action id to be unique, so
  the Windows launchers register as **`open-file-viewer-windows`** and
  **`open-file-viewer-tab-windows`** (the unqualified `open-file-viewer` / `open-file-viewer-tab`
  ids are the Linux/macOS variants). Point `plugin_action` bindings at the qualified Windows ids:

  ```toml
  [[keys.command]]
  key = "prefix+f"
  type = "plugin_action"
  command = "herdr-file-viewer.open-file-viewer-windows"
  description = "open file viewer in split"

  [[keys.command]]
  key = "prefix+shift+f"
  type = "plugin_action"
  command = "herdr-file-viewer.open-file-viewer-tab-windows"
  description = "open file viewer in tab"
  ```
- **Targeted opens are supported by the Windows launcher.** The generic action has no dynamic
  argument slot, but the shipped launcher accepts `-OpenTarget` and forwards it safely to a fresh
  viewer pane:

  ```powershell
  $p = ((herdr plugin list --json | ConvertFrom-Json).result.plugins |
      Where-Object { $_.plugin_id -eq 'herdr-file-viewer' }).plugin_root
  if ($p -and $p.StartsWith('\\?\')) { $p = $p.Substring(4) }
  & (Join-Path $p 'scripts\open-file-viewer.ps1') -OpenTarget 'src/app.rs:42'
  ```

  `path`, `path:line`, and `path:start-end` use the same format as `--open`. A targeted
  request deliberately opens a new Files pane instead of focusing an existing one, because launch
  targets are applied only at viewer startup.

- **Requires herdr's preview channel.** Windows herdr binaries ship only on herdr's pre-release
  update channel, so you need to be on it before installing this plugin on Windows.
- **Non-ASCII paths and pane titles are supported.** The launchers force UTF-8 before parsing
  herdr's JSON under Windows PowerShell 5.1, so names outside the active legacy code page do not
  make the viewer fall back to its plugin install directory.
- **Preview means best-effort, not a parity guarantee.** There's no Windows host in this
  project's CI gate (the `windows-latest` job is advisory, not required), so a Windows-specific
  regression can land between releases. Full feature parity with Linux/macOS is the goal, not a
  promise. Please [open an issue](https://github.com/smarzban/herdr-file-viewer/issues) if you
  hit a Windows-specific problem.
- **WSL works today, with zero extra setup.** If you'd rather not wait on native-Windows preview
  maturity, the existing Linux (`x86_64-unknown-linux-musl`) binary already runs unmodified
  inside WSL. Install herdr and this plugin from within your WSL distro exactly as you would on
  native Linux.

See also [install & updating](install.md) for the shared install flow and [summoning](summoning.md)
for the open actions and launcher.
