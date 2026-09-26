# GyroPath — PLAN

Maintained by **Keystone**. Last updated: 2026-09-25.

## Status

| | |
| --- | --- |
| Current released version | **1.3.1** (CurseForge) |
| Source of truth (target) | GitHub `salyj/GyroPath`, branch `main` — **not yet in sync** (see Phase 0) |
| Working repo | `C:\Users\hellk\WoW_Addon_Dev\GyroPath` — desktop (josiah-pc), **primary workspace** |
| Secondary | Laptop (`WoWAddonWork\GyroPath`), used occasionally. Always pull `origin/main` before working there and push before switching back. |
| Supported clients | Classic Era (11509), BCC Anniversary (20506), WoW Forever (16001) |

## Versioning

`Major.Minor.Hotfix`

- **Hotfix** (+0.0.1) — small fixes and adjustments.
- **Minor** (+0.1.0) — minor feature additions.
- **Major** (+1.0.0) — major feature additions or core reworks.

Decided release targets:
- **1.4.0** — Phases 0–3 (repo cleanup incl. `.sf` removal from the package, test harness, client/capability module, bucket consolidation / `isBCC` removal).
- **2.0.0** — Phase 4 (position-based distance) as its own release; Phases 5+ may be added to it.

## Rules for every phase

- A phase closes only after **all unit tests pass** and **manual in-game testing passes on every affected client** (see `TESTS.md`).
- Never sacrifice existing Classic Era / BCC support — extend, don't replace.
- Every decision is backed by an official source (see `DESIGN.md` → Sources).
- Keystone writes no code; Josiah does all commits. Every unit of work comes with a full list of changed files.

---

## Completed work (before these docs were rebuilt)

Recovered from the prior session's handoff brief and the current code.

| Release | Work | Files |
| --- | --- | --- |
| 1.3.0 | Forever TOC (`GyroPath_Camelot.toc`, Interface 16001); removed 16001 from Classic TOC; extracted `GyroPathFormat.lua` (functional core); TOC version bumps | `GyroPath_Camelot.toc`, `GyroPath-Classic.toc`, `GyroPath-BCC.toc`, `GyroPathFormat.lua`, `GyroPath.lua` |
| 1.3.0 | Full Ace3 re-vendor (fixes AceGUI CheckBox crash on 12.x — `SetDesaturation` removed) | 16 files under `GyroPath/Libs/` |
| 1.3.0 | Minimap button radius derived from `Minimap:GetWidth()` (Forever minimap is 198×198 vs 140×140) | `GyroPathStats.lua` |
| 1.3.0 | "Thorn" added to About-tab credits | `GyroPathOptions.lua` |
| 1.3.1 | Secret Values crash hotfix — `issecretvalue(speed)` guard in `accumulate()` | `GyroPath.lua`, `Versions.txt`, TOCs |

**None of the above is committed yet.** GitHub `main` is at `5c6ccac` (1.3.0 commit that still has `11509, 16001` in the Classic TOC).

---

## Phase 0 — Repo cleanup and sync · *In progress* · 1.4.0

Goal: this working repo is clean, committed, and pushed so GitHub `main` becomes the source of truth.

- [ ] 0.1 Add `.gitattributes` at the repo root with `* -text` (decided: keep bytes as they are, no line-ending conversion).
- [ ] 0.2 Delete `GyroPath/.sf/` and add `.sf/` to `.gitignore`.
- [x] 0.3 Add `PLAN.md`, `DESIGN.md`, `TESTS.md`, `ROSTER.md`, `BACKLOG.md` at the repo root.
- [ ] 0.4 Josiah commits the full 1.3.1 state (Keystone provides the file list) and pushes to `origin/main`.
- [ ] 0.5 Josiah deletes the `master` branch on GitHub (`main` is canonical — Q5).
- Laptop cleanup is handled by Josiah outside this phase (Q6). The laptop's old `tests/` folder is not carried over; the harness is rebuilt here in Phase 1.

**Exit criteria:** `git status` clean on desktop; GitHub `main` matches the desktop; `master` branch removed. No manual in-game test needed unless addon files change beyond what shipped in 1.3.1.

## Phase 1 — Rebuild the unit test harness · *Not started* · 1.4.0

- [ ] 1.1 Vendor `luaunit` (BSD, `bluebird75/luaunit`) outside the shipped addon folder.
- [ ] 1.2 Rebuild `GyroPathFormat` tests (see `TESTS.md`).
- [ ] 1.0 Josiah builds and installs Lua 5.1.5 from lua.org source (Q9, option A — steps in `TESTS.md` §2).
- [ ] 1.3 Document how to run the tests on Windows.

**Exit criteria:** suite runs green from a single command on the desktop.

## Phase 2 — Client identity and capability module · *Not started* · 1.4.0

- [ ] 2.1 New `GyroPathClient.lua` — only job: identify the client and expose capability flags (starting with `SupportsFlyingMounts`). See `DESIGN.md` D-1 (review item R-1 must be resolved first).
- [ ] 2.2 Unit tests for the client/capability mapping.
- [ ] 2.3 Add to all three TOCs before files that use it.

**Exit criteria:** unit tests green; manual regression on all three clients.

## Phase 3 — Bucket selection consolidation and `isBCC` removal · *Not started* · 1.4.0

- [ ] 3.1 Extract bucket selection into one pure function (DESIGN D-2), with unit tests covering every branch.
- [ ] 3.2 Replace every `isBCC` / `gp.isBCC` read with the capability flag (`GyroPath.lua`, `GyroPathFrame.lua`, `GyroPathStats.lua`).
- [ ] 3.3 Fix the implicit global `b` in `accumulate()` (BACKLOG TD-03).
- [ ] 3.4 Mile High Club threshold → 24,888.84 mi in `GyroPath.lua` (check) and `GyroPathStats.lua` (achievement description) (BACKLOG TD-09).

**Exit criteria:** unit tests green; manual regression on all three clients; `isBCC` no longer appears in the codebase; Mile High Club shows 24,888.84 in code and tooltip.

## Release 1.4.0 checklist · *Not started*

- [ ] Phases 0–3 closed.
- [ ] Version bumped to 1.4.0 in `GyroPath.lua` and all three TOCs.
- [ ] `Versions.txt` entry for 1.4.0.
- [ ] Package contains only the `GyroPath/` addon folder — no `.sf`, docs or tests (BL-03).
- [ ] Josiah commits, tags (if BL-07 approved), pushes, and uploads to CurseForge.

## Phase 4 — Position-based distance · *Not started* · 2.0.0

Q1 and Q2 answered (drop the delta on `mapID` change; 2D). Still open before kickoff: R-2 (transports), R-3 (UnitPosition behaviour on Classic clients) and Q11 (port statistics — may become Phase 5). See `DESIGN.md` D-3.

- [ ] 4.1 Pure distance function from two position samples, with unit tests.
- [ ] 4.2 Replace `GetUnitSpeed`-based `dist = speed * dt` in `accumulate()`.
- [ ] 4.3 Release as 2.0.0.

**Exit criteria:** unit tests green; manual regression on all three clients, including movement during combat on Forever.

---

## Open questions (need Josiah)

| # | Question | Blocks |
| --- | --- | --- |
| Q11 | Port statistics — brainstorm in progress (ideas and options in BACKLOG BL-06). | Phase 5 scope |

### Deferred

| # | Question | Status |
| --- | --- | --- |
| Q7 | Live Forever AddOns folder name. | Can only be confirmed after the Nov 4, 2026 launch. Tracked in BL-02. |

### Answered

| # | Question | Answer (2026-09-25) |
| --- | --- | --- |
| Q1 | Drop the distance delta when `mapID` changes? | **Yes.** Drop and re-baseline. (Josiah is interested in statistics around these events — see Q11.) |
| Q2 | 2D or 3D distance? | **2D.** Vertical travel doesn't count; no steps on an elevator. |
| Q5 | Is `main` canonical; delete `master`? | **Yes.** `main` is canonical; delete `master`. |
| Q6 | Keep anything from the laptop repo? | **No.** Rebuild the test harness here. Josiah cleans up the laptop himself. Desktop is primary; laptop is used occasionally. |
| Q3 | BCC regression for Ace3 re-vendor passed before 1.3.1? | **Yes.** 1.3.1 on CurseForge is fully functional on all three clients. |
| Q4 | Release plan for Phases 1–3? | **1.4.0.** Phase 4 ships separately as 2.0.0 (may grow with Phases 5+). |
| Q8 | Mile High Club threshold? | **24,888.84 mi** (code's 28,884.84 is a bug). |
| Q9 | Lua runtime for unit tests? | **Option A:** build Lua 5.1.5 from lua.org source with `etc\luavs.bat`. |
| Q10 | Re-release to remove `.sf` from the package? | **No separate hotfix.** Removal is part of the cleanup and ships in 1.4.0. |
