# Gyromatic Pathometer (GyroPath)

A lightweight World of Warcraft addon that measures how far you travel — and breaks it down by *how* you got there. Every yard is sorted into a movement category, so you can finally answer the question that has haunted adventurers for twenty years: *exactly how much of my life have I spent walking to the flight master?*

GyroPath tracks foot travel, ground mounts, swimming, flight paths (taxi), flying mounts (Burning Crusade only), and an "Other" category that covers movement under Levitate and Slow Fall.

## Features

- **Per-category distance tracking.** Movement is continuously attributed to a category based on your current state — on foot, mounted, on a taxi, swimming, flying, or under a slow-fall effect.
- **Steps and miles.** Foot and mount travel are reported as *steps*; flight paths, swimming, flying, and Other are reported in *miles*.
- **Lifetime and session totals.** Every stat is kept both as a lifetime total (saved per character) and a fresh per-login session total. A toggle in the options panel switches the on-screen display between the two.
- **On-screen panel.** A small, movable window shows your current totals at a glance. Drag it anywhere; its position is remembered.
- **Persistent stats.** Lifetime totals are saved per character via `SavedVariablesPerCharacter`.
- **Minimal footprint.** Position is sampled on a light throttle and the addon skips work whenever you aren't moving.

### Tracked movement types

| Category | Unit | How it's detected |
| --- | --- | --- |
| On foot | Steps | Moving on the ground with no mount, taxi, or slow-fall effect active |
| Mount | Steps | Mounted (`IsMounted`) and not flying |
| Flight path (taxi) | Miles | Riding a flight master's route (`UnitOnTaxi`) |
| Swimming | Miles | Character is in the swimming state (`IsSwimming`) |
| Flying | Miles | Airborne on a flying mount (`IsFlying`) — **Burning Crusade only** |
| Other | Miles | Moving with **Levitate** active, or falling with **Slow Fall** active |

> **Note on flight:** Flying mounts don't exist in original Classic content. The Flying category is only present on the Burning Crusade build; on Classic Era it isn't tracked or displayed at all. (The client is detected at load via `GetBuildInfo`.)

## Supported game versions

- **WoW Classic Era** — Interface `11509` (`GyroPath-Classic.toc`)
- **The Burning Crusade Classic — Anniversary Edition** — Interface `20506` (`GyroPath-BCC.toc`)

Each build ships its own `.toc` so the correct feature set (including whether Flying is tracked) loads automatically.

## Installation

### Option 1 — Addon manager (recommended)

Install through CurseForge, WowUp, or your preferred addon manager and let it handle updates automatically.

### Option 2 — Manual install

1. Download the latest release and unzip it.
2. Copy the `GyroPath` folder (the one containing the `.toc` files) into your AddOns directory:
   - **Classic Era:** `World of Warcraft\_classic_era_\Interface\AddOns\`
   - **Burning Crusade Anniversary:** `World of Warcraft\_classic_\Interface\AddOns\`
3. Make sure the folder is named exactly `GyroPath` and contains `GyroPath-Classic.toc` / `GyroPath-BCC.toc`.
4. Restart the game, or type `/reload` if you're already logged in.
5. In the in-game AddOns menu, confirm **Gyromatic Pathometer** is enabled.

## Usage

Once installed, GyroPath tracks automatically and shows a small movable panel on screen. On login it prints a confirmation and resets the session counters. Both `/gyropath` and `/gp` work interchangeably.

| Command | Description |
| --- | --- |
| `/gp` | Show the list of available commands |
| `/gp stats` | Print lifetime and this-session totals to chat |
| `/gp show` | Show the on-screen panel |
| `/gp hide` | Hide the on-screen panel |
| `/gp reset` | Reset **all** stored totals (lifetime and session) for this character |
| `/gp version` | Print the installed version |

To switch the on-screen panel between session and all-time numbers, open the addon's options (Interface / AddOns options → **GyroPath**) and toggle **Track Session Stats**.

## Frequently asked questions

**Does it track other players or party members?**
No. GyroPath only measures your own character's movement.

**Why don't I see a Flying stat?**
Flying is only tracked on the Burning Crusade build, where flying mounts exist. On Classic Era the category is omitted entirely.

**How is a "flight path" different from a "flying mount"?**
Flight path (taxi) is an NPC-controlled route from a flight master. Flying is your own player-controlled flying mount (BCC only). They're counted separately.

**When does "Other" get credited?**
While you're moving with Levitate active, or while falling with Slow Fall active.

**Does the addon affect performance?**
The sampling loop runs on a throttle and does nothing while you're stationary, so the impact is negligible.

## Contributing

Contributions, bug reports, and feature requests are welcome.

1. Open an issue describing the bug or feature. For bugs, please include your game version (Classic Era or TBC Anniversary), what you were doing, and any Lua error text.
2. To contribute code, fork the repository, create a feature branch, and open a pull request against `main`.
3. Please keep changes focused and test in-game before submitting.

When reporting a tracking bug, it helps to note which category was being credited (or should have been) at the time.

## License

This project is licensed under the **GNU General Public License v3.0**. See the [`LICENSE`](LICENSE) file for the full text. In short: you're free to use, modify, and redistribute this addon, provided derivative works are also released under the GPLv3.

## Credits

Created by **HKRob** for the World of Warcraft Classic community. Built on the [Ace3](https://www.wowace.com/projects/ace3) library suite. Thanks to everyone who reports bugs and helps map the many edge cases of getting from point A to point B.
