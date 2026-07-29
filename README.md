# WGIT — Wintergrasp Invite Tools
<img width="1024" height="1024" alt="WGIT Logo" src="https://github.com/user-attachments/assets/dba5d936-cca2-4ba1-957d-96fd1a6f9991" />
<img width="193" height="138" alt="WGIT1 02 Demo" src="https://github.com/user-attachments/assets/5106895b-c4dc-4ccc-93e8-b1e501fe28b2" />

**Version:** 1.02
**Author:** xLT69x
**Game:** World of Warcraft — Wrath of the Lich King (3.3.0)

---

## Folder Structure

Place the `WGIT` folder inside `World of Warcraft/Interface/AddOns/`.
The folder must look exactly like this:

```
WGIT/
├── WGIT.toc
├── WGIT.lua
├── WGIT_About.lua
├── WGIT_RaidSave.lua
├── WGIT_RaidLayoutFrame.lua
└── Libs/
    ├── LibStub/
    │   └── LibStub.lua
    ├── CallbackHandler-1.0/
    │   └── CallbackHandler-1.0.xml
    ├── AceAddon-3.0/
    │   └── AceAddon-3.0.xml
    ├── AceEvent-3.0/
    │   └── AceEvent-3.0.xml
    ├── AceTimer-3.0/
    │   └── AceTimer-3.0.xml
    ├── AceConsole-3.0/
    │   └── AceConsole-3.0.xml
    ├── AceGUI-3.0/
    │   └── AceGUI-3.0.xml
    ├── AceConfig-3.0/
    │   └── AceConfig-3.0.xml
    ├── AceDB-3.0/
    │   └── AceDB-3.0.xml
    ├── LibDataBroker-1.1/
    │   └── LibDataBroker-1.1.lua
    └── LibDBIcon-1.0/
        └── LibDBIcon-1.0.lua
```

---

## Overview

WGIT is an all-in-one Wintergrasp utility addon that handles queue automation,
season stat tracking, raid management, whisper-based invites, and a full raid
layout save/restore system — all from a single lightweight package.

---

## Features

- **Live Wintergrasp Timer** — Floating countdown showing h/m/s until the next
  battle. Green when active, orange when under 15 minutes.
- **Season PvP Kill Tracker** — Tracks your PvP kills across all zones:
  Wintergrasp, battlegrounds, and open-world PvP. Can be toggled on/off.
- **Season Honor Tracker** — Tracks Honor Points earned everywhere, not just
  Wintergrasp. Numbers are comma-formatted for readability. Can be toggled on/off.
- **Honor Cap Warnings** — Displays a yellow warning in chat and on the timer
  frame when you reach 70,000 Honor Points. Shows red "CAPPED!" text and alert
  when you hit the 75,000 cap. Warning can be toggled on/off.
- **Reset Stats Button** — Manually reset season kills and honor from the timer
  window at any time. Also resets the 70k warning so it will fire again.
- **Auto-Join WG Queue** — Automatically accepts the Wintergrasp queue invite.
- **Auto-Convert to Raid** — Automatically converts party to a raid when a
  second member joins.
- **Auto-Accept Invites** — Automatically accepts group invites from guildmates
  and friends.
- **Auto-Release** — Automatically releases your corpse upon death in
  Wintergrasp or any battleground.
- **Auto-Decline Duels** — Automatically declines all incoming duel requests.
- **Whisper Invite System** — Invites players to your raid when they whisper a
  configured keyword.
- **Mass Guild Invite** — Invites all eligible online guild members in one click.
- **Mass Friends Invite** — Invites all eligible online friends in one click.
- **Auto-Promote Assistants** — Automatically promotes designated players to
  raid assistant when they join.
- **Blacklist** — Prevents specific players from being invited via the whisper
  system.
- **Minimap Icon** — Quick-access button with a live tooltip showing WG timer,
  season stats (color-coded by honor level), and auto-join status.
- **Lockable Window** — Right-click the timer frame to lock/unlock it.
- **Screen Clamping** — The timer window cannot be dragged off the edge of
  the screen.
- **Raid Layout Save/Restore** — Save the current raid group assignments by
  name and restore them later. Moves are throttled (0.5s each) to avoid
  disconnect. Requires raid leader to restore.
- **Raid Layout Manager** — Floating popup window listing all saved layouts
  with one-click Restore and Delete buttons.

---

## Slash Commands

| Command               | Description                                      |
|-----------------------|--------------------------------------------------|
| `/wgi`                | Open the settings panel                          |
| `/wgreset`            | Reset the timer window position to center screen |
| `/wgshow`             | Show the minimap icon if it was hidden           |
| `/wgsave <name>`      | Save the current raid layout under a name        |
| `/wgrestore <name>`   | Restore a saved raid layout by name              |
| `/wglayouts`          | List all saved layouts in chat                   |
| `/wgdellayout <name>` | Delete a saved layout by name                    |
| `/wglm`               | Toggle the Raid Layout Manager popup open/closed |

---

## Settings Panel

Open with `/wgi` or click the minimap icon. The panel is a scrollable floating
window with the following sections in the left sidebar:

- **WGIT** (main page) — Visuals, Automation, and Kill & Honor Tracker toggles.
- **Raid Tools** — Invite keywords, Mass Invite buttons, Disband Raid,
  Auto-Assistants list, Blacklist.
- **Save & Restore Raid Layout** — Save/restore controls and a live list of
  saved layouts.
- **About** — Addon information and feature summary.

The Interface > AddOns > WGIT entry in the Blizzard panel shows a single
"Open WGIT Config" button that launches the full settings window.

---

## Kill & Honor Tracker Options

Found under the **Kill & Honor Tracker** section of the settings panel:

| Toggle                        | Default | Description                                       |
|-------------------------------|---------|---------------------------------------------------|
| Show Season PvP Kills         | ON      | Displays your PvP kill count on the timer window  |
| Show Season Honor             | ON      | Displays your season honor on the timer window    |
| Honor Cap Warning at 70,000   | ON      | Fires a chat warning once when you hit 70k honor  |

**Honor display colors:**
- White — normal tracking
- Orange — you are at or above 70,000 (near cap)
- Red / CAPPED! — you have reached the 75,000 cap

---

## Timer Window

- **Left-click drag** — Move the window (when unlocked).
- **Right-click** — Toggle lock/unlock.
- **Bottom-right grip** — Resize the window (when unlocked).
- **Auto-Join button** — Toggle Wintergrasp auto-join on/off.
- **Reset Stats button** — Clear season kills and honor (also resets the 70k warning).
- **Layouts button** — Open/close the Raid Layout Manager popup.

---

## Dependencies

All libraries are bundled in the `Libs` folder:

- LibStub
- CallbackHandler-1.0
- AceAddon-3.0
- AceEvent-3.0
- AceTimer-3.0
- AceConsole-3.0
- AceGUI-3.0
- AceConfig-3.0
- AceDB-3.0
- LibDataBroker-1.1
- LibDBIcon-1.0

---

## Changelog

### v1.02 — Kill & Honor Tracker Overhaul

- **Season PvP Kill tracking** — Kills are now counted from any PvP zone
  (Wintergrasp, all battlegrounds, open-world PvP). Previously only counted
  in Wintergrasp. Label updated from "Kills" to "Season Kills".
- **Season Honor tracking** — Honor is now tracked everywhere, not only in
  Wintergrasp. Covers all battlegrounds, WG, and world PvP gains.
  Label updated from "Honor" to "Season Honor".
- **Honor Cap Warning** — A yellow chat warning fires once when you cross
  70,000 Honor Points. A red alert fires when you hit the 75,000 cap.
  The 70k warning resets if you use the Reset Stats button.
- **"Honor Capped" display** — Timer window shows red "CAPPED!" text and a
  sub-line "⚠ Honor Capped (75,000)" when at the cap. Shows orange
  "⚠ Near Honor Cap!" when at or above 70,000.
- **Three new toggles** added under "Kill & Honor Tracker" in the settings:
  Show Season PvP Kills, Show Season Honor, Honor Cap Warning at 70,000.
- **Honor numbers formatted with commas** — e.g. `12,450` instead of `12450`.
- **Minimap tooltip updated** — Season Kills and Season Honor respect the new
  toggles and show the same color-coded status (white / orange / red).
- **Raid Layout Save/Restore module** (`WGIT_RaidSave.lua`) — saves each raid
  member's name and group number. Throttled restore moves one player every 0.5s.
  Slash commands: `/wgsave`, `/wgrestore`, `/wglayouts`, `/wgdellayout`.
- **Raid Layout Manager popup** (`WGIT_RaidLayoutFrame.lua`) — draggable
  floating window with a name input, Save button, and a scrollable list of
  saved layouts. Each row shows the layout name, member count, and Restore /
  Delete buttons with a confirmation dialog on delete.
- **Screen clamping** — Timer window is now clamped to screen edges and cannot
  be dragged off-screen.
- **Options panel restructured** — settings open as a scrollable
  AceConfigDialog popup. Sections appear as tree items in the left sidebar.
- **Blizzard panel stub** — Interface > AddOns > WGIT now shows a single
  "Open WGIT Config" button instead of the full panel, eliminating duplication.

### v1.0

- Initial release: WG timer, session kill/honor tracking, auto-join WG,
  auto-convert raid, auto-accept invites, auto-release, auto-decline duels,
  whisper invite system, mass invite, auto-promote assistants, blacklist,
  minimap icon, lockable/resizable timer window.

---

## License

Free to use and modify. Credit appreciated but not required.

