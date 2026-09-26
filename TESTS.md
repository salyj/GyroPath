# GyroPath — TESTS

Maintained by **Keystone**. Last updated: 2026-09-25.

## 1. Strategy

- **Unit tests** cover pure logic (no WoW API calls), run outside the game with `luaunit`.
- **Manual in-game tests** cover anything that touches WoW frames, events or globals, and run on every affected client.
- A phase closes only when both pass (see `PLAN.md`).

## 2. Unit tests

### Harness · *Needs rebuild (Phase 1)*

The original harness (`tests/` + vendored `luaunit`) was lost on this machine. To rebuild:

- Location: `tests/` at the repo root (never inside the shipped `GyroPath/` addon folder).
  - `tests/*_test.lua` — test suites.
  - `tests/lib/` — vendored `luaunit.lua` 3.5 and its license, unmodified.
  - `tests/run_all.lua` — runs every suite; exit code 0 = all pass, non-zero = failures.
  - `tests/run.bat` — Windows wrapper for `run_all.lua`.
- Runtime: **Lua 5.1.5 built from lua.org source (Q9, option A)**, installed at `C:\Tools\lua-5.1.5` and on PATH.
- Run command: `tests\run.bat` (or `lua tests/run_all.lua` from the repo root). *Confirmed at Phase 1 close-out.*

#### Building Lua 5.1.5 (Josiah, one-time per machine)

1. Download `https://www.lua.org/ftp/lua-5.1.5.tar.gz`.
2. Verify it in PowerShell: `Get-FileHash .\lua-5.1.5.tar.gz -Algorithm SHA256`. Compare with the checksum listed on `https://www.lua.org/ftp/`. (Expected: `2640FC56A795F29D28EF15E13C34A47E223960B0240E8CB0A82D9B0738695333`.)
3. Extract: `tar -xzf lua-5.1.5.tar.gz` (tar is built into Windows 10/11).
4. Open **x64 Native Tools Command Prompt for VS 2022** (Start menu → Visual Studio 2022).
5. `cd` into the extracted `lua-5.1.5` folder (the top level, not `src`) and run `etc\luavs.bat`. Per the script's header, it builds `lua.exe`, `luac.exe`, `lua51.dll` and `lua51.lib` into `src`.
6. Create `C:\Tools\lua-5.1.5` and copy `lua.exe`, `luac.exe` and `lua51.dll` from `src` into it (`lua.exe` needs `lua51.dll` beside it).
7. Add `C:\Tools\lua-5.1.5` to your user PATH: Start → "Edit environment variables for your account" → `Path` → New.
8. Open a new terminal and run `lua -v`. Expected: `Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio`.

If any step errors, stop and bring the output to Keystone; don't work around it.

#### Lua runtime options (Q9 — decided: A)

WoW's addon environment is Lua 5.1 (to double-check on Warcraft Wiki's *Lua* page — the research agent could not load it). `luaunit` 3.5 (26 Mar 2026) is tested on Lua 5.1–5.5 and LuaJIT 2.0 (luaunit README).

| Option | Version | How | Source |
| --- | --- | --- | --- |
| A. Build from lua.org source | 5.1.5 (exact) | Extract `lua-5.1.5.tar.gz`; in a VS Developer Command Prompt at the top folder run `etc\luavs.bat` → `src\lua.exe` | lua.org/ftp; `INSTALL` and `etc/luavs.bat` in the tarball |
| B. LuaBinaries zip | 5.1.5 (exact) | Download `lua-5.1.5_Win64_bin.zip`, extract, add to PATH | sourceforge.net/projects/luabinaries |
| C. Scoop | 5.1.5 (exact, uses B) | `scoop bucket add versions` then `scoop install versions/lua51` | ScoopInstaller/Versions `bucket/lua51.json` |
| D. winget LuaJIT | LuaJIT 2.1 (5.1 API + extensions) | `winget install DEVCOM.LuaJIT` | microsoft/winget-pkgs `DEVCOM/LuaJIT` |
| E. WSL + Ubuntu | 5.1.5 (exact) | `sudo apt install lua5.1` inside WSL | Ubuntu 24.04 archive, `lua5.1 5.1.5-9build2` |

Note on D: LuaJIT accepts some syntax/libraries that stock Lua 5.1 in WoW does not, so a test could pass locally with code WoW rejects. A, B, C and E run the exact version.
- WoW addon files receive `...` as `(addonName, addonTable)`. Tests load a module with a stub addon table, e.g. `loadfile("GyroPath/GyroPathFormat.lua")("GyroPath", gp)`.

### Suites

| Suite | Module | Status | Cases |
| --- | --- | --- | --- |
| `GyroPathFormat_test.lua` | `GyroPathFormat.lua` | Phase 1 — in progress | Exact expected values listed in the Phase 1 builder brief: `comma` (0, 999, 1000, 100000 — leading-comma strip, 1234567, rounding 1234.4 / 1234.5 / 999.5); `steps` (1.5 → `"1"`, 15000 → `"10,000"`); `miles` (0 → `"0.00"`, 880 → `"0.50"`, 1760 → `"1.00"`); `stepsUnformatted(3)` = 2; `milesUnformatted(3520)` = 2; constants 1.5 / 1760; `gp.steps` / `gp.miles` alias `gp.Format`. |
| `GyroPathClient_test.lua` | `GyroPathClient.lua` | Planned (Phase 2) | Each supported interface → correct client. `SupportsFlyingMounts` true only for BCC. Unknown / patched interface behaviour per R-1 outcome. |
| `GyroPathBucket_test.lua` | Bucket selection (D-2) | Planned (Phase 3) | Every priority branch: taxi beats everything; Levitate → other; Slow Fall only while falling → other; flying only when supported; mount; swim; default onFoot. Flying state on a client without flying mounts → falls through to mount/onFoot. |
| `GyroPathDistance_test.lua` | Distance (D-3) | Planned (Phase 4) | 2D distance correct; z changes ignored (elevator → 0); `mapID` change → 0 and re-baseline; first sample (no previous) → 0; no movement → 0. Transport cases per R-2 outcome. |

## 3. Manual in-game test checklist

Run on each client: **Classic Era (11509)**, **BCC Anniversary (20506)**, **Forever (16001)**.

| # | Check | Expected |
| --- | --- | --- |
| M-01 | Log in | No Lua errors. "GyroPath loaded" message. |
| M-02 | On-screen panel | Shows. Flying row on BCC only. Draggable; position persists after `/reload`. |
| M-03 | Walk | Steps increase. |
| M-04 | Ground mount | Mount steps increase, not foot steps. |
| M-05 | Swim | Swam miles increase. |
| M-06 | Flight path | Flight path miles increase. |
| M-07 | Flying mount (BCC only) | Flying miles increase. |
| M-08 | Slow Fall while falling / Levitate | Other miles increase. |
| M-09 | Enter combat and move (Forever) | No error. *1.3.1: movement not counted (known). 2.0.0: movement counted.* |
| M-10 | Options panel (Interface → AddOns → GyroPath) | Opens without error; toggles work (Ace3 CheckBox fix). |
| M-11 | Minimap button | Sits on the minimap edge; drag orbits correctly; click opens/closes stats. |
| M-12 | Stats window | Stats and Achievements tabs switch; values match the panel. |
| M-13 | Milestone sound | Plays when an achievement triggers and Celebrate Milestones is on. |
| M-14 | `/gp`, `/gp stats`, `show`, `hide`, `reset`, `version` | Each works; version prints current version. |
| M-15 | Edit Mode (Forever) | No errors or lockups while Edit Mode is open. |
| M-16 | Achievements tab, hover Mile High Club (1.4.0+) | Tooltip reads 24,888.84 lifetime miles. |

### Results log

| Version | Classic Era | BCC Anniversary | Forever | Notes |
| --- | --- | --- | --- | --- |
| 1.3.0 (Ace3 re-vendor) | Pass | Pass | Pass | BCC confirmed by Josiah (Q3). |
| 1.3.1 | Pass | Pass | Pass (combat crash fixed) | Released on CurseForge; fully functional per Josiah. Itemised checklist not recorded. |
