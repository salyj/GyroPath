# GyroPath — BACKLOG

Maintained by **Keystone**. Last updated: 2026-09-25.

Items move into `PLAN.md` when scheduled into a phase. Nothing here is approved work until Josiah schedules it.

## Tech debt

| ID | Item | Where | Notes / plan |
| --- | --- | --- | --- |
| TD-01 | `isBCC` boolean conflates "which client" with "supports flying mounts". | `GyroPath.lua`, `GyroPathFrame.lua`, `GyroPathStats.lua` | Phases 2–3 (D-1). |
| TD-02 | Bucket selection duplicated in two if/else chains. | `GyroPath.lua` `accumulate()` | Phase 3 (D-2). |
| TD-03 | `b` (aura state) is assigned without `local`, so it leaks as a global. It also keeps its old value while Edit Mode is active. | `GyroPath.lua` `accumulate()` | Phase 3. |
| TD-04 | Slow Fall / Levitate detected by English aura name. May fail on non-English clients. | `GyroPath.lua` | Needs research (official source) on name vs spell ID lookup across all three clients. |
| TD-05 | `GyroPath.lua` does too much (saved vars, date/char checks, driver, accumulation, 13 achievement checks, slash commands). | `GyroPath.lua` | SRP split. Candidate modules: achievements, slash commands, saved-vars. |
| TD-06 | Achievement thresholds are hard-coded in logic and repeated in display text. | `GyroPath.lua`, `GyroPathStats.lua` | Single data-driven achievement table; pure "is achieved" check is unit-testable. |
| TD-07 | Version number lives in four places (`GyroPath.lua`, three TOCs) plus `Versions.txt`. | Multiple | Research reading the TOC `## Version` at runtime on all three clients. |
| TD-08 | 10k-steps achievement is only marked earned when Celebrate Milestones is on. Every other achievement is marked earned regardless. | `GyroPath.lua` | Needs Josiah: intended? |
| TD-09 | Mile High Club threshold is wrong in code (28,884.84 mi). | `GyroPath.lua`, `GyroPathStats.lua` | Confirmed bug. Correct value **24,888.84 mi** (Q8). Scheduled: PLAN Phase 3.4 (1.4.0). |
| TD-10 | Three separate `PLAYER_LOGIN` handlers; `GyroPathStats.lua` depends on `GyroPath.lua`'s handler running first. | `GyroPath.lua`, `GyroPathStats.lua`, `GyroPathOptions.lua` | Research whether handler order is guaranteed; otherwise use a single init sequence. |

## Feature / project backlog

| ID | Item | Notes |
| --- | --- | --- |
| BL-01 | README: add Forever support and install path. | After BL-02. |
| BL-02 | Confirm live Forever AddOns folder name after Nov 4, 2026 launch. | Beta: `_classic_beta_`. Q7. |
| BL-03 | Packaging: the 1.3.1 CurseForge zip includes `GyroPath/.sf/`. Define a packaging step that ships only addon files. | Decided (Q10): fixed in 1.4.0. `.sf` removed in Phase 0. |
| BL-04 | GitHub branch cleanup: delete `master`. | Decided (Q5). Scheduled in PLAN Phase 0.5. |
| BL-05 | Position-based distance (in-combat tracking). | Phase 4, 2.0.0. |
| BL-06 | Port statistics (Q11, brainstorming). | Ideas so far: **number of times ported**; **distance ported**. Findings: counting ports looks feasible on all three clients with official events (`LOADING_SCREEN_ENABLED`/`DISABLED`, `PLAYER_ENTERING_WORLD`, `ZONE_CHANGED_NEW_AREA`) or a change in `UnitPosition`'s map ID. Distance ported only makes sense when the map ID is the same before and after (same-continent teleport); across maps there is no shared coordinate space. `UNIT_SPELLCAST_SUCCEEDED` is secret-restricted on Forever, so spell-based detection is unreliable there. Possible Phase 5 in 2.0.0.<br><br>**Cross-continent distance (Josiah's idea):** it's a for-fun stat, so precision isn't needed. Overlay the departure and arrival `(x, y)` 1:1 as if on one plane, then add an estimated lore distance between the two continents. Needs: a table of continent-pair distances keyed by the map ID, a source for each estimate, and a rule for Outland (a different world). **Alternative to research (R-4):** Blizzard's own "Azeroth" world map places the continents relative to each other; if the `C_Map` position/size APIs support it on all three clients, that could give an in-game-consistent estimate instead of hand-picked numbers. |
| BL-07 | Git tags per release (e.g. `v1.3.1`). | Proposal; needs Josiah. |
