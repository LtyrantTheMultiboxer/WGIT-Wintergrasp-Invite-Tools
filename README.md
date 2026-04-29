# WGIT — Wintergrasp Invite Tools
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
session stat tracking, raid management, whisper-based invites, and a full raid
layout save/restore system — all from a single lightweight package.

---

## Features

- **Live Wintergrasp Timer** — Floating countdown showing h/m/s until the next
  battle. Green when active, orange when under 15 minutes.
- **Session Stat Tracking** — Tracks Honor Kills and Honor Points earned during
  your current Wintergrasp session.
- **Reset Stats Button** — Manually reset session kills and honor from the timer
  window at any time.
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
  session stats, and auto-join status.
- **Lockable Window** — Right-click the timer frame to lock/unlock it.
- **Raid Layout Save/Restore** — Save the current raid group assignments by
  name and restore them later. Moves are throttled (0.5s each) to avoid
  disconnect. Requires raid leader to restore.
- **Raid Layout Manager** — Floating popup window listing all saved layouts
  with one-click Restore and Delete buttons. Opened via the Layouts button on
  the timer frame or /wglm.

---

## Slash Commands

| Command              | Description                                      |
|----------------------|--------------------------------------------------|
| `/wgi`               | Open the settings panel                          |
| `/wgreset`           | Reset the timer window position to center screen |
| `/wgshow`            | Show the minimap icon if it was hidden           |
| `/wgsave <name>`     | Save the current raid layout under a name        |
| `/wgrestore <name>`  | Restore a saved raid layout by name              |
| `/wglayouts`         | List all saved layouts in chat                   |
| `/wgdellayout <name>`| Delete a saved layout by name                   |
| `/wglm`              | Toggle the Raid Layout Manager popup open/closed |

---

## Settings Panel

Open with `/wgi` or click the minimap icon. The panel is a scrollable floating
window with the following sections in the left sidebar:

- **WGIT** (main page) — Visuals and Automation toggles.
- **Raid Tools** — Invite keywords, Mass Invite buttons, Disband Raid,
  Auto-Assistants list, Blacklist.
- **Save & Restore Raid Layout** — Save/restore controls and a live list of
  saved layouts.
- **About** — Addon information and feature summary.

The Interface > AddOns > WGIT entry in the Blizzard panel shows a single
"Open WGIT Config" button that launches the full settings window.

---

## Timer Window

- **Left-click drag** — Move the window (when unlocked).
- **Right-click** — Toggle lock/unlock.
- **Bottom-right grip** — Resize the window (when unlocked).
- **Auto-Join button** — Toggle Wintergrasp auto-join on/off.
- **Reset Stats button** — Clear session kills and honor.
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

### v1.02
- **Raid Layout Save/Restore module** (`WGIT_RaidSave.lua`) — saves each raid
  member's name and group number. Throttled restore moves one player every 0.5s.
  Slash commands: `/wgsave`, `/wgrestore`, `/wglayouts`, `/wgdellayout`.
  New "Raid Layouts" input controls added to the options panel.
- **Raid Layout Manager popup** (`WGIT_RaidLayoutFrame.lua`) — draggable
  floating window with a name input, Save button, and a scrollable list of
  saved layouts. Each row shows the layout name, member count, and Restore /
  Delete buttons with a confirmation dialog on delete.
  Opened via the blue "Layouts" button on the timer frame or `/wglm`.
- **Options panel restructured** — settings now open as a scrollable
  AceConfigDialog popup instead of the fixed-size Blizzard panel. Sections
  appear as tree items in the left sidebar: Raid Tools, Save & Restore Raid
  Layout, About.
- **Management Lists moved** — Auto-Assistants and Blacklist inputs relocated
  from the main WGIT page to the Raid Tools section.
- **Blizzard panel stub** — Interface > AddOns > WGIT now shows a single
  "Open WGIT Config" button instead of the full panel, eliminating duplication.
- **Version number** updated to 1.02 across TOC, options header, and About page.

### v1.0
- Initial release: WG timer, session kill/honor tracking, auto-join WG,
  auto-convert raid, auto-accept invites, auto-release, auto-decline duels,
  whisper invite system, mass invite, auto-promote assistants, blacklist,
  minimap icon, lockable/resizable timer window.

---

## License

Free to use and modify. Credit appreciated but not required.
