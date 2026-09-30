# Install & updating

## Requirements and published binaries

- **Herdr 0.7+** and **Git** on `PATH`. Git powers the tree's status and diff features.
- **Windows:** native x64 support is a preview and requires Herdr's preview channel.
- **No Rust toolchain is needed for a normal install on a supported platform.** The
  [v0.1.0 release](https://github.com/inchury/herdr-file-viewer/releases/tag/v0.1.0)
  includes SHA-256-verified binaries for Windows x64, Linux x64 (musl), macOS Apple Silicon,
  and macOS Intel, plus a `SHA256SUMS` file.

| Platform | Published asset |
| --- | --- |
| Windows x64 | `herdr-file-viewer-x86_64-pc-windows-msvc.exe` |
| Linux x64 | `herdr-file-viewer-x86_64-unknown-linux-musl` |
| macOS Apple Silicon | `herdr-file-viewer-aarch64-apple-darwin` |
| macOS Intel | `herdr-file-viewer-x86_64-apple-darwin` |

## Install through Herdr

```bash
herdr plugin install inchury/herdr-file-viewer
```

Herdr clones this fork and runs the platform-specific `[[build]]` step from
`herdr-plugin.toml`. The installer downloads the binary matching the checked-out
`Cargo.toml` version and host architecture, verifies its SHA-256 against the release's
`SHA256SUMS`, and places it under `target/release`. The bundled pane/action launchers
use that binary.

To pin the first release:

```bash
herdr plugin install inchury/herdr-file-viewer --ref v0.1.0
```

**Source-build fallback:** If the release asset or checksum cannot be downloaded or verified,
the platform is unsupported, or the checked-out version has no release, the installer tries
`cargo build --release`. This fallback requires **Rust 1.96+**. A network failure can
therefore cause an otherwise prebuilt-supported installation to request Rust; check the
download error and GitHub connectivity first. A checksum mismatch is not accepted as a valid
prebuilt download.

**Release versus checkout:** The installer selects a binary by the version declared in
`Cargo.toml`, not by exact commit. If `main` contains unreleased changes but still declares
`0.1.0`, installing from `main` uses the published v0.1.0 binary, not those newer source
changes. For reproducible behavior, use `--ref v0.1.0`; for development, build from source.

Directly downloading an executable from GitHub Releases does **not** register the plugin's
Herdr actions. Use `herdr plugin install` for Herdr integration.

## After installing

Confirm registration with `herdr plugin list`. Bind a key to the correct action IDs:

- Linux/macOS: `herdr-file-viewer.open-file-viewer` (split) or
  `herdr-file-viewer.open-file-viewer-tab` (tab).
- Windows: `herdr-file-viewer.open-file-viewer-windows` (split) or
  `herdr-file-viewer.open-file-viewer-tab-windows` (tab).

See [README](../README.md#install-v010) for copy-pasteable bindings, or
[Windows setup](windows.md) for the native launcher. Reload settings with
`herdr server reload-config` after editing your Herdr config.

The built-in Markdown preview and compact diff need no external renderer. Optional `delta`
and `bat` enhance full diff and source highlighting; `glow` may still be used for some
help/legacy paths. See [renderer setup](renderers.md).

## Updating

Herdr does not automatically update this plugin. Re-run the install command to fetch the
current repository checkout and its matching released binary:

```bash
herdr plugin install inchury/herdr-file-viewer
```

For a fixed version, keep `--ref v0.1.0`. GitHub **Watch → Custom → Releases** can
notify you when new releases are published. To disable the viewer's optional background
release notices, use `update_check = false` or set
`HERDR_FILE_VIEWER_NO_UPDATE_CHECK`. The check runs at most once every 24 hours.

## Local development and source builds

`herdr plugin link` does **not** run the manifest's `[[build]]` step. Build first:

```bash
cargo build --release
herdr plugin link /path/to/herdr-file-viewer
```

Source builds require Rust 1.96+. If a supported-platform install unexpectedly asks for
Rust, inspect the prebuilt download/checksum error before installing a toolchain.
