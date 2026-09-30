# herdr-file-viewer

[English README](README.md)

**Herdr pane에서 실행되는 Git 인식형 읽기 전용 파일 뷰어입니다.** 왼쪽에는 파일 트리,
오른쪽에는 파일에 맞는 보기 방식이 표시됩니다. 변경된 소스는 diff, Markdown은 렌더링된
문서, 일반 코드는 구문 강조 보기로 열립니다. 에이전트가 특정 파일이나 줄로 바로 이동시킬
수 있고, 파일을 고정하거나 범위를 표시한 뒤 메모를 채팅으로 다시 전달할 수도 있습니다.
뷰어 자체는 파일을 수정하지 않습니다.

![Herdr split에서 실행 중인 herdr-file-viewer](assets/File-viewer.png)

*Markdown 문서는 제목, 인라인 코드, 강조, 목록, 표 등을 터미널 테마에 맞춰 렌더링합니다.*

![Markdown 파일 렌더링](assets/Markdown-view.png)

*전체 화면에서도 동일한 트리와 콘텐츠를 사용할 수 있습니다.*

![전체 화면](assets/File-Viewer-FS.png)

*`p`로 파일 하나를 고정한 채 다른 파일이나 worktree를 계속 탐색할 수 있습니다.*

![Pinned preview](assets/Pinned-preview.png)

## 주요 특징

- **파일에 맞는 보기를 자동 선택합니다.** Markdown은 내장 CommonMark/GFM renderer로
  표시되므로 `glow`가 없어도 제목, 강조, 인라인 코드, 인용문, 목록/체크리스트,
  fenced code, 취소선, 표 등을 볼 수 있습니다. 변경된 README/CHANGELOG도 Markdown
  보기가 기본입니다. Markdown 표는 pane 폭에 맞춰 열 너비를 조절하고 긴 셀을 줄바꿈하며,
  `w`로 wrapping을 끄면 자연 폭 + 가로 스크롤 방식으로 볼 수 있습니다.
- **Git 상태가 트리에 통합됩니다.** 각 항목의 `M`/`A`/`D`/`?` 상태, 변경 파일만
  보기(`c`), 다음/이전 변경 파일 이동(`]`/`[`), branch 기준과 `HEAD` 기준 전환(`b`)
  등을 별도 Git 클라이언트 없이 사용할 수 있습니다.
- **Compact diff도 내장 렌더링합니다.** 추가/삭제/hunk를 Ratatui에서 직접 스타일링하여
  Windows/ConPTY에서도 안정적으로 표시합니다. `delta`는 full diff의 선택적 향상 기능입니다.
- **파일을 고정하고 계속 탐색할 수 있습니다.** `p`로 현재 파일의 snapshot을 고정하고
  다른 파일을 보거나 `W`로 다른 Git worktree로 이동해 비교할 수 있습니다.
- **에이전트가 정확한 위치를 열 수 있습니다.** bundled skill을 사용하면
  `src/app.rs:42` 또는 줄 범위를 새 Files pane에서 바로 열 수 있습니다.
- **편집은 사용자의 편집기로 넘깁니다.** `e`는 설정한 editor 또는 `$EDITOR`를 실행합니다.
  파일 수정은 외부 editor가 담당하며 이 뷰어는 계속 읽기 전용입니다.
- **포커스 복귀 시 입력을 막지 않습니다.** focus-in 시 Git status/changed-set 갱신은
  background에서 수행하고 결과가 도착하면 반영합니다. Windows에서 느린 Git index,
  파일시스템 또는 백신 I/O 때문에 입력 루프 자체가 의도적으로 막히지 않도록 구성되어 있습니다.
- **종료 입력을 명확하게 확인할 수 있습니다.** 최상위 화면에서 `Esc`를 누르면 즉시
  종료하지 않고 종료 확인 창을 표시합니다. 확인한 경우에만 terminal 복원 및 종료를 진행합니다.
- **읽기 전용과 안전성을 우선합니다.** 파일 내용과 Git 저장소를 신뢰하지 않는 입력으로
  취급하며 terminal control sequence를 무력화합니다. 자세한 내용은 [SECURITY.md](SECURITY.md)를
  참고하세요.

## 주요 키

| 키 | 동작 |
| --- | --- |
| `↑` / `↓`, `j` / `k` | 트리 이동 또는 콘텐츠 스크롤 |
| `←` / `→`, `h` / `l` | 디렉터리 접기/펼치기 또는 콘텐츠 가로 스크롤 |
| `Enter` | 디렉터리 열기/닫기 또는 파일 열기 |
| `f` | 파일 fuzzy finder |
| `p` | 현재 파일 고정/해제 |
| `a` / `A` | 파일 또는 범위 annotation 추가 / 관리 |
| `v` | 사용 가능한 보기 방식 순환 |
| `w` | 콘텐츠 wrapping 전환 |
| `]` / `[` | 다음 / 이전 변경 파일 |
| `b` | diff baseline 전환: branch merge-base ↔ `HEAD` |
| `W` | 다른 Git worktree로 전환 |
| `L` | `path:line` 또는 선택 범위 참조 복사 |
| `z` / `Z` | pane 내부 zoom / Herdr pane 전체 화면 |
| `e` / `O` / `R` | editor / OS 기본 앱 / 파일 관리자에 넘기기 |
| `/` | 현재 파일 검색 |
| `:` | 줄 번호로 이동 |
| `?` | What's New, 키, 설정, 정보 도움말 |
| `Esc` | 현재 overlay/zoom 닫기; 최상위에서는 종료 확인 창 표시 |

전체 키와 마우스 동작은 [docs/keys.md](docs/keys.md), 기능별 설명은
[docs/usage.md](docs/usage.md)를 참고하세요.

## v0.1.0 바이너리 배포

[GitHub Releases](https://github.com/inchury/herdr-file-viewer/releases/tag/v0.1.0)에서 Windows x64, Linux x64(musl), macOS Apple Silicon 및 Intel용 실행 파일을 받을 수 있습니다. 무결성 확인용 `SHA256SUMS`도 함께 제공됩니다. Windows 지원은 프리뷰 단계입니다.

## 빠른 시작

> **중요:** 이 fork의 기능을 사용하려면 반드시 `inchury/herdr-file-viewer`에서 설치해야
> 합니다. `smarzban/herdr-file-viewer`를 설치하면 upstream 버전이 설치되며, 이 fork에서
> 추가한 내장 Markdown renderer, Windows 개선, 포커스 복귀 응답성 개선, 종료 확인 기능 등이
> 포함되지 않습니다.

플러그인을 설치합니다.

```bash
herdr plugin install inchury/herdr-file-viewer
```

이 fork에 현재 버전과 일치하는 release binary가 있으면 SHA-256 검증 후 사용하고,
없으면 해당 checkout의 소스를 Rust 1.96+로 빌드합니다.

Markdown preview와 compact diff는 외부 renderer가 필요하지 않습니다. Full diff와 소스
구문 강조를 강화하려면 `delta`와 `bat`를 선택적으로 설치할 수 있습니다.

macOS 예:

```bash
brew install git-delta bat
```

Linux/macOS에서는 다음 helper를 사용할 수 있습니다.

```bash
./scripts/install-renderers.sh
```

Windows PowerShell에서는:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-renderers.ps1
```

Herdr 설정(`~/.config/herdr/config.toml`)에 실행 키를 등록합니다.

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

설정 변경 후:

```bash
herdr server reload-config
```

Windows native preview에서는 action id가 각각
`herdr-file-viewer.open-file-viewer-windows`,
`herdr-file-viewer.open-file-viewer-tab-windows`입니다. 자세한 내용은
[Windows 문서](docs/windows.md)를 참고하세요.

## 특정 파일/줄 바로 열기

standalone binary에서는:

```bash
herdr-file-viewer --open src/app.rs
herdr-file-viewer --open src/app.rs:42
herdr-file-viewer --open src/app.rs:42-58
```

`HERDR_FILE_VIEWER_OPEN` 환경 변수도 사용할 수 있으며 CLI flag가 우선합니다.

Windows에서는 bundled PowerShell launcher의 `-OpenTarget`으로 동일한 형식을 전달할 수
있습니다. Target이 지정된 요청은 이미 실행 중인 viewer에 전달하는 대신 새 Files pane을
열어 startup target을 적용합니다.

## Markdown 및 renderer

`[MD]` 파일 preview는 `pulldown-cmark` 기반 CommonMark/GFM parser와 Ratatui renderer를
사용하여 프로세스 내부에서 처리합니다. 따라서 일반 Markdown 파일을 보기 위해 `glow`를
설치할 필요가 없습니다.

Compact `[DIFF]` 역시 내부에서 렌더링합니다. `delta`는 `[DIFF+]`, `bat`은 소스
구문 강조를 위한 선택적 renderer입니다. 일부 legacy/help Markdown 경로에서는 `glow`
설정이 여전히 사용될 수 있습니다.

자세한 내용은 [docs/renderers.md](docs/renderers.md)를 참고하세요.

## 설정

선택적인 읽기 전용 `config.toml`을 통해 editor, renderer/opener 명령, 시작 옵션,
tree layout, keybinding 등을 변경할 수 있습니다.

전체 주석이 포함된 [config.example.toml](config.example.toml)을
`herdr plugin config-dir herdr-file-viewer`가 출력하는 디렉터리에 `config.toml`이라는
이름으로 복사한 뒤 필요한 항목만 활성화하면 됩니다.

전체 설정은 [docs/configuration.md](docs/configuration.md)에 있습니다. 현재 적용된 설정은
앱의 `?` 도움말에서 확인할 수 있습니다.

## Windows

Native Windows는 현재 **preview** 지원입니다.

- Windows용 action id는 `-windows` suffix를 사용합니다.
- bundled PowerShell launcher가 `-OpenTarget path[:line]`을 지원합니다.
- Markdown preview와 compact diff는 외부 도구 없이 동작합니다.
- `scripts/install-renderers.ps1`로 선택적 renderer를 설치할 수 있습니다.
- UTF-8/non-ASCII 경로와 pane title을 지원합니다.
- focus-in Git refresh는 입력 thread 밖에서 실행됩니다.
- WSL에서는 Linux 버전을 그대로 사용할 수 있습니다.

자세한 내용은 [docs/windows.md](docs/windows.md)를 참고하세요.

## 문서

- [설치 및 업데이트](docs/install.md)
- [Viewer 실행 방법](docs/summoning.md)
- [사용 가이드](docs/usage.md)
- [키 및 마우스](docs/keys.md)
- [설정](docs/configuration.md)
- [Renderer](docs/renderers.md)
- [Windows](docs/windows.md)
- [아키텍처](ARCHITECTURE.md)
- [보안](SECURITY.md)

## 개발

Rust 1.96+가 필요합니다.

```bash
cargo build --release
cargo test
```

이 fork에서 발생하는 버그나 추가 기능 요청은
[inchury/herdr-file-viewer Issues](https://github.com/inchury/herdr-file-viewer/issues)에
등록해 주세요. 기여 방법은 [CONTRIBUTING.md](CONTRIBUTING.md)를 참고하세요.

## 라이선스

[MIT](LICENSE) © Saeed Marzban
