# GyroPath — DESIGN

Maintained by **Keystone**. Last updated: 2026-09-25.

## 1. Overview

GyroPath (Gyromatic Pathometer) measures how far the player travels and sorts every yard into a movement category (on foot, mount, flight path, swim, flying, other). Totals are kept per session and per character lifetime, shown in an on-screen panel, a stats window (minimap button), and chat (`/gp stats`), and drive a set of addon-specific achievements with celebration sounds.

## 2. Repo layout

```
GyroPath/                 ← git repo root (not shipped)
├── PLAN.md DESIGN.md TESTS.md ROSTER.md BACKLOG.md
├── README.md LICENSE .gitignore .gitattributes
├── Claude outputs/       ← local handoff briefs/reports (git-ignored, never committed)
├── tests/                ← unit tests + vendored luaunit (Phase 1; not shipped)
└── GyroPath/             ← the addon folder WoW loads (this is what ships)
    ├── GyroPath-Classic.toc   GyroPath-BCC.toc   GyroPath_Camelot.toc
    ├── embeds.xml  Libs/  (Ace3, LibStub, CallbackHandler)
    ├── GyroPathFormat.lua  GyroPathFrame.lua  GyroPath.lua
    ├── GyroPathStats.lua   GyroPathOptions.lua
    └── Versions.txt
```

The nested `GyroPath/GyroPath` structure is intentional: only the inner folder is installed into `Interface\AddOns`.

## 3. Supported clients

| Client | Interface | TOC | Flying mounts | UI/API base | Minimap frame |
| --- | --- | --- | --- | --- | --- |
| Classic Era | 11509 | `GyroPath-Classic.toc` | No | Classic | 140×140 |
| BCC Anniversary | 20506 | `GyroPath-BCC.toc` | Yes | Classic | 140×140 |
| WoW Forever ("Camelot") | 16001 | `GyroPath_Camelot.toc` | No (decided) | Mainline 12.x | 198×198 |

Forever runs on Blizzard's modern Mainline UI/API (12.x line), not the Classic codebase. This is the root cause of every Forever compatibility issue so far.

## 4. Current architecture (as of 1.3.1)

### Load order (all three TOCs)
`embeds.xml` → `GyroPathFormat.lua` → `GyroPathFrame.lua` → `GyroPath.lua` → `GyroPathStats.lua` → `GyroPathOptions.lua`

### Module responsibilities

| File | Responsibility today | SRP notes |
| --- | --- | --- |
| `GyroPathFormat.lua` | Pure yards → steps/miles conversion and comma formatting (`gp.Format`, plus `gp.miles` / `gp.steps`). No WoW API. | Clean functional core. Unit-testable. |
| `GyroPath.lua` | Client detection (`isBCC`), SavedVariables defaults, new-character / date checks, the `OnUpdate` driver, distance accumulation, bucket selection, all 13 achievement checks, slash commands, login init. | Too many responsibilities. See BACKLOG TD-05. |
| `GyroPathFrame.lua` | On-screen panel build and refresh. | Reads `gp.isBCC` directly. |
| `GyroPathStats.lua` | Minimap button, stats window (Stats / Achievements tabs), achievement display definitions. | Reads `gp.isBCC` directly. Achievement text duplicates thresholds in `GyroPath.lua`. |
| `GyroPathOptions.lua` | Ace3 options panel (toggles, About tab, credits). | OK. |

### Runtime flow
1. `PLAYER_LOGIN` → apply defaults, reset session buckets, new-character and new-day checks, build panel, start 0.5 s panel refresh ticker.
2. Driver frame `OnUpdate`, throttled to 0.1 s → `accumulate(dt)`.
3. `accumulate(dt)`: read aura state (Slow Fall / Levitate) → `speed = GetUnitSpeed("player")` → **if `issecretvalue(speed)` return** → `dist = speed * dt` → select bucket → add to lifetime and session → check achievements.

### Bucket selection (priority order)
`taxi` (`UnitOnTaxi`) → `other` (Levitate, or Slow Fall while `IsFalling`) → `flying` (`IsFlying`, **BCC only**) → `mount` (`IsMounted`) → `swim` (`IsSwimming`) → `onFoot`.

### Units
`STRIDE_YARDS = 1.5`, `YARDS_PER_MILE = 1760`. Stored values are yards. On foot and mount display as steps; everything else as miles.

### SavedVariablesPerCharacter: `GyroPath`
`lifetime`, `session` (buckets), `celebrations` (13 booleans), `ui` (`show`, `x`, `y`, `point`, `minimapAngle`), `showSessionStats`, `celebrateMilestones`, `charId` (player GUID), `ssy`/`ssm`/`ssd`/`sscount` (10k-steps daily tracking).

### Achievements

| Key | Scope | Threshold |
| --- | --- | --- |
| sessionSteps | Session, once per day | 10,000 steps on foot |
| marathonRunner | Session | 66,000 steps on foot |
| triatholete | Session | 0.25 mi swim + 7,275 mount steps + 3,000 foot steps |
| mongolMessenger | Session | 29,334 mount steps |
| hadriansMarch | Session | 23,467 foot steps |
| frequentFlyer | Lifetime | 100 mi taxi |
| mileHighClub | Lifetime | 28,884.84 mi taxi (see Q8) |
| tourDeFrance | Lifetime | 2,434,667 mount steps |
| rideAroundTheWorld | Lifetime | 29,202,906 mount steps |
| longDistanceSwim | Lifetime | 21 mi swim |
| coastToCoast | Lifetime | 4,963,334 foot steps |
| downTowntoUptown | Lifetime | 15,723 foot steps |
| fromRomeToRomantic | Lifetime | 806,080 foot steps |

## 5. Testing strategy

**Functional core, imperative shell.** Pure logic with no WoW API calls lives in its own modules and is unit tested outside the game with `luaunit`. Code that touches WoW frames or globals is verified by manual in-game testing on each client. Details in `TESTS.md`.

## 6. Designs

### D-1 — Client identity and capability module · *Approved, not implemented* (Phase 2)

- New `GyroPathClient.lua`. Its only job is to identify the client and expose derived capability flags.
- Detect from the interface number, `select(4, GetBuildInfo())`: 11509 → Classic Era, 20506 → BCC, 16001 → Forever.
- First capability: `gp.client.SupportsFlyingMounts` (true only for BCC).
- Every other file asks the capability question, never the identity question.
- The mapping logic is a pure function (interface number in, client + capabilities out) so it can be unit tested.

**R-1 (review before Phase 2):** exact-match on the interface number will fail to detect the client after any patch bump (e.g. 11509 → 11510). Options must be researched from official sources before building, e.g. matching on ranges, or Blizzard's own `WOW_PROJECT_ID` constants if they exist on all three branches. Keystone to research and bring options to Josiah.

### D-2 — Pure bucket selection · *Approved, not implemented* (Phase 3)

Replace the two duplicated if/else chains in `accumulate()` with one pure function. Inputs: movement state flags (`onTaxi`, `levitate`, `slowFall`, `falling`, `flying`, `mounted`, `swimming`) and `supportsFlyingMounts`. Output: bucket key. The WoW API reads stay in the shell; the decision is unit tested.

### D-3 — Position-based distance · *Approved in principle* (Phase 4, 2.0.0)

**Problem:** since 1.3.1, all movement during combat on Forever is dropped, because `GetUnitSpeed` returns a secret value in combat and the tick is skipped.

**Evidence:** `Blizzard_APIDocumentationGenerated/UnitDocumentation.lua` flags `GetUnitSpeed` with `SecretWhenUnitStatsRestricted = true`. `UnitPosition` has no `SecretWhen*Restricted` flag on any of the three branches, and Blizzard's own UI calls `UnitPosition("player")` on `classic_era`, `classic_anniversary` and `forever`.

**Proposal:** compute distance as the straight-line distance between consecutive `UnitPosition("player")` samples instead of `speed * dt`.

**Decided:**
- When `mapID` differs between two samples, drop that delta (accumulate nothing) and re-baseline from the new position.
- Distance is 2D: `sqrt(dx² + dy²)` using `x, y` only. Vertical travel never counts (no steps on an elevator).

**Research findings (2026-09-25, Gethe/wow-ui-source at `classic_era` 1.15.9, `classic_anniversary` 2.5.6, `forever` 1.60.1):**
- `forever` `UnitDocumentation.lua` documents `UnitPosition` → `positionX, positionY, positionZ, mapID`, all non-nil, with `SecretArguments = "AllowedWhenUntainted"` and **no** `SecretWhen*` return flag (unlike `GetUnitSpeed`). Passing the literal `"player"` from our own code is the untainted case.
- The classic branches' generated docs have **no** `UnitPosition` entry, but Blizzard's shipped code calls it there (`Blizzard_PTRFeedback.lua:292`: `select(4, UnitPosition(...)) or 0`), which suggests it can return nil in some cases.
- The 4th return is a world/instance map ID, not a UI map ID (inferred from Blizzard's usage alongside `GetInstanceInfo()`; not stated outright).

**Still open:**
- **R-3 (in-game test):** on Classic Era and BCC, confirm `UnitPosition("player")` returns values in the open world and what it returns inside dungeons/raids/battlegrounds (nil?), and confirm return order. Official docs don't cover this for the classic branches; Josiah's in-game test is the source of truth.
- **R-2 (research):** horizontal movement that isn't the player's own, e.g. standing on a boat, zeppelin or moving platform, or being knocked back. Position deltas would count these as steps, which `GetUnitSpeed` may not have done. Research so far: no official API detects boats/zeppelins on any branch (`IsOnTransport`-style functions don't exist in the docs). `UnitInVehicle` / `UnitUsingVehicle` exist on `forever`; on classic they are only referenced in shared code (unconfirmed at runtime). Options for handling transports need Josiah's input before Phase 4 kickoff.
- **Q11:** optional statistics around `mapID` changes (see PLAN).

## 7. Decision log

| # | Decision | Source / basis |
| --- | --- | --- |
| DEC-01 | Forever Interface is 16001. | Josiah in-game: `/run print(GetBuildInfo())` |
| DEC-02 | Forever has no flying mounts; treat like Classic Era for that capability. | Josiah |
| DEC-03 | Forever gets its own TOC, `GyroPath_Camelot.toc`. | Confirmed loading in-game on Forever beta (1.3.0/1.3.1) |
| DEC-04 | Full Ace3 re-vendor rather than a one-file patch. | Josiah; upstream `WoWUIDev/Ace3` cross-checked with `repos.wowace.com/wow/ace3/trunk` |
| DEC-05 | Minimap button radius = `Minimap:GetWidth() / 2 + 10`. | Blizzard `Blizzard_Minimap` Classic vs Mainline XML; `MinimapMixin:OnClick` uses the same `GetWidth() / 2` pattern |
| DEC-06 | Skip the tick when `issecretvalue(speed)` (1.3.1 hotfix). | `UnitDocumentation.lua` (`SecretWhenUnitStatsRestricted`); `issecretvalue` present on all three clients |
| DEC-07 | `PlaySoundFile(568672, "Master")` works on Forever. | Josiah in-game |
| DEC-08 | Unit tests use `luaunit`, vendored. | BSD license, `bluebird75/luaunit` |
| DEC-09 | GitHub `main` becomes the source of truth; the desktop repo is the working repo. | Josiah |
| DEC-10 | Line endings: `.gitattributes` `* -text`, so git stores files byte-for-byte. | Josiah; git-scm.com/docs/gitattributes (unset `text` = no end-of-line conversion; overrides `core.autocrlf`) |
| DEC-11 | Phases 0–3 ship as 1.4.0; position-based distance (Phase 4) ships separately as 2.0.0. | Josiah |
| DEC-12 | Project docs and tests live at the repo root, outside the shipped addon folder. | Josiah |
| DEC-13 | Position rework drops the delta on `mapID` change and re-baselines. | Josiah |
| DEC-14 | Position rework measures 2D distance only. | Josiah |
| DEC-15 | `main` is the only canonical branch; `master` is deleted. Desktop is the primary workspace; the laptop is secondary. | Josiah |
| DEC-16 | Mile High Club threshold is 24,888.84 mi. | Josiah (Q8) |
| DEC-17 | Unit tests run on stock Lua 5.1.5 built from lua.org source. | Josiah (Q9); matches WoW's Lua 5.1 |
| DEC-18 | `Claude outputs/` at the repo root is git-ignored; briefs and reports stay local. | Josiah (Phase 0) |
| DEC-19 | Lua 5.1.5 installed at `C:\Tools\lua-5.1.5`, on PATH. | Josiah (Phase 1) |
| DEC-20 | Test layout: suites in `tests/`, vendored luaunit in `tests/lib/`. | Josiah (Phase 1) |
| DEC-21 | Runner: `tests/run_all.lua` does the work; `tests/run.bat` wraps it. Suites are listed explicitly in `run_all.lua` (stock Lua 5.1 has no directory listing without extra libraries). | Josiah (Phase 1); Keystone (explicit list) |

## 8. Official sources

- Blizzard's shipped UI source, `Gethe/wow-ui-source` on GitHub — branches `classic_era`, `classic_anniversary` (BCC), `forever`.
- Blizzard's generated API docs inside that source: `Blizzard_APIDocumentationGenerated/*.lua`.
- Warcraft Wiki (mirrors official patch notes and API docs).
- Josiah's in-game testing (primary-source ground truth).
- Upstream library repos for vendored code (Ace3, luaunit).
- git-scm.com documentation for git behaviour.
