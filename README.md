# WGIT — Wintergrasp Invite Tools #

<img width="187" height="138" alt="WGIT Demo" src="https://github.com/user-attachments/assets/be2b437f-49f5-4e9f-a830-4d82609ce2ed" />

Download the [HERE](https://github.com/LtyrantTheMultiboxer/WGIT-Wintergrasp-Invite-Tools/releases/download/WGIT/WGIT.rar)

**Version:** 1.0  
**Author:** xLT69x  
**Game:** World of Warcraft — Wrath of the Lich King (3.3.0)

---

## Overview ##

WGIT is an all-in-one Wintergrasp utility addon that handles queue automation, session stat tracking, raid management, and whisper-based invites — all from a single lightweight package.

---

## Features ##

- **Live Wintergrasp Timer** — Displays a floating countdown window showing hours, minutes, and seconds until the next battle. Color-coded: green when active, orange when under 15 minutes.
- **Session Stat Tracking** — Tracks Honor Kills and Honor Points earned during your current Wintergrasp session.
- **Reset Stats Button** — Manually reset your session kills and honor from the timer window at any time.
- **Auto-Join WG Queue** — Automatically accepts the Wintergrasp queue invite when it appears.
- **Auto-Convert to Raid** — Automatically converts your party to a raid group when a second member joins.
- **Auto-Accept Invites** — Automatically accepts group invites from guildmates and friends.
- **Auto-Release** — Automatically releases your corpse upon death in Wintergrasp or any battleground.
- **Auto-Decline Duels** — Automatically declines all incoming duel requests.
- **Whisper Invite System** — Invites players to your raid when they whisper a configured keyword.
- **Mass Guild Invite** — Invites all eligible online guild members in one click.
- **Mass Friends Invite** — Invites all eligible online friends in one click.
- **Auto-Promote Assistants** — Automatically promotes designated players to raid assistant when they join.
- **Blacklist** — Prevents specific players from being invited via the whisper system.
- **Minimap Icon** — Quick-access button with a live tooltip showing the WG timer, session stats, and auto-join status.
- **Lockable Window** — Right-click the timer frame to lock or unlock it. Drag to reposition when unlocked.

---

## Installation ##

1. Download and extract the addon.
2. Place the `WGIT` folder inside:  
   `World of Warcraft/Interface/AddOns/`
3. The folder structure should look like this:
   ```
   WGIT/
   ├── WGIT.toc
   ├── WGIT.lua
   ├── WGIT_About.lua
   └── Libs/
   ```
4. Launch the game and enable **WGIT** in the AddOns list on the character select screen.

---

## Slash Commands ##

| Command | Description |
|---|---|
| `/wgi` | Open the settings panel |
| `/wgreset` | Reset the timer window position to the center of the screen |
| `/wgshow` | Show the minimap icon if it has been hidden |

---

## Configuration ##

Open the settings panel with `/wgi` or by clicking the minimap icon. Options are organized into the following sections:

- **Visuals** — Show/hide the timer window, lock/unlock it, and adjust its opacity.
- **Automation** — Toggle auto-join, auto-raid, auto-accept, auto-release, and duel decline.
- **Raid Tools** — Configure invite keywords, mass invite guild or friends, disband raid.
- **Management Lists** — Manage your auto-assistant list and blacklist.
- **About** — Addon information and feature summary.

---

## Timer Window ##

- **Left-click drag** — Move the window (when unlocked).
- **Right-click** — Toggle lock/unlock.
- **Bottom-right corner grip** — Resize the window (when unlocked).
- **Auto-Join button** — Click to toggle the Wintergrasp auto-join on or off without opening settings.
- **Reset Stats button** — Clears session kills and honor back to zero.

---

## Dependencies ##

All required libraries are bundled inside the `Libs` folder:

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

## License ##

Free to use and modify. Credit appreciated but not required.
