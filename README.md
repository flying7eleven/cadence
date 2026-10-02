# Cadence

Cadence is a native macOS menu bar pomodoro timer, built with SwiftUI. It supports two ways of working:

- **Solo:** classic pomodoro cycle with focus blocks, short breaks and a long break after four focus blocks.
- **Pair (driver/navigator):** two named participants rotate roles automatically at the end of every focus block, with a notification naming the incoming driver.

## Roadmap

| Milestone | Scope |
|---|---|
| [v0.1: Solo Foundation](../../milestone/1) | Xcode project + CI, timer state machine, menu bar UI, notifications, settings |
| [v0.2: Pair Mode](../../milestone/2) | Session setup, driver/navigator rotation logic, pair UI, rotation reminders |
| [v1.0: Polish & Release](../../milestone/3) | Statistics, icons, keyboard shortcuts, release workflow |

Work is tracked as GitHub issues: stories (label `story`) for user-facing behavior, tasks (label `task`) for technical work. Area labels: `solo-mode`, `pair-mode`, `ui`, `infra`. Issues marked `agent-ready` are scoped for autonomous pickup.

The [Cadence Roadmap](https://github.com/users/flying7eleven/projects/6) project board provides the kanban view over all issues.

## Development

- SwiftUI, Swift 6, deployment target macOS 27.
- Timer and rotation logic lives in a testable, SwiftUI-free core; the UI layer stays thin.
- Build and test: `xcodebuild -project Cadence.xcodeproj -scheme Cadence -destination 'platform=macOS' test`
- CI runs on every push and PR to `main` (see `.github/workflows/ci.yml`).

Contributor and agent conventions: see [AGENTS.md](AGENTS.md).
