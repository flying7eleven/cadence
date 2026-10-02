# AGENTS.md

Project conventions for humans and coding agents working on Cadence.

## Product

Cadence is a native macOS menu bar pomodoro timer. Two modes:

- **Solo:** classic pomodoro cycle (focus block, short break, long break after 4 focus blocks).
- **Pair:** two named participants alternate as driver and navigator. Roles swap automatically at the end of every focus
  block, with a reminder notification. The navigator of block N is the driver of block N+1.

Domain terms: focus block, short break, long break, round (one focus block plus its break), rotation (role swap),
driver, navigator.

## Stack and layout

- SwiftUI, Swift 6, current stable Xcode. Deployment target: macOS 27.
- CI runs on the `xcode-27` runner image (the only GitHub-hosted image with a macOS 27 SDK, currently a public preview
  without SLA). Keep `.github/workflows/ci.yml` in sync with this.
- Xcode project at repo root: `Cadence.xcodeproj`, shared scheme `Cadence`. These names must stay in sync with
  `.github/workflows/ci.yml`.
- App sources in `Cadence/`, unit tests in `CadenceTests/`.
- The project uses file-system-synchronized groups: new `.swift` files dropped into `Cadence/` or `CadenceTests/` are
  picked up automatically. Never edit `project.pbxproj` to add source files.
- All timer and rotation logic lives in a testable core (types under `Cadence/Core/` or a `CadenceCore` SwiftPM package)
  with no SwiftUI dependencies. The UI layer stays thin.

## Build and test

```sh
xcodebuild -project Cadence.xcodeproj -scheme Cadence -destination 'platform=macOS' build
xcodebuild -project Cadence.xcodeproj -scheme Cadence -destination 'platform=macOS' test
```

## Issue-driven workflow

- Every change traces to a GitHub issue. Stories (label `story`) describe user-facing behavior; tasks (label `task`)
  cover infra and maintenance. Issues marked `agent-ready` are scoped for autonomous pickup.
- Branch per issue: `issue-<number>-<slug>`, e.g. `issue-7-rotation-logic`.
- One PR per issue. The PR body ends with `Closes #<number>`.
- Stories are sized for a single focused work session. If a story grows, split it and file follow-up issues instead of
  widening the PR.

## Commit conventions

- Small, incremental commits: one logical change per commit.
- Gitmoji in ASCII form (`:sparkles:`, `:bug:`, `:white_check_mark:`), never the Unicode emoji.
- Every commit message carries a scope in parentheses naming the affected area, e.g. `:sparkles: (core): add
  rotation state machine` or `:bug: (ui): correct countdown display`. Scopes: `core`, `ui`, `infra`, `docs`, `ci`.
- Imperative mood; reference the issue where useful (e.g. `Refs #7`).
- No co-author attribution: no `Co-authored-by` trailers and no AI or AI-session references in commit messages.

## Definition of Done

- Behavior covered by unit tests. Core logic is built test-first: write the failing test, then the implementation.
- CI green (`xcodebuild ... test` on the macOS runner).
- README or this file updated if behavior, architecture, or conventions changed.
- PR references its issue; labels and milestone on the issue are correct.
- Project board status reflects reality (Done when the issue closes).

## Tracking conventions

- Milestones map to releases: v0.1 Solo Foundation, v0.2 Pair Mode, v1.0 Polish & Release.
- Area labels: `solo-mode`, `pair-mode`, `ui`, `infra`.
- Default timer values: 25 min focus, 5 min short break, 15 min long break, long break after 4 focus blocks. Pair
  rotation: one focus block. All values configurable in settings.
