WGInvite Master v4.7 - README & Change Log
-------------------------------------------
Developer: xLT69x
Version: 4.7 (Master Build)
Compatibility: WoW 3.3.5 (WotLK)

<img width="195" height="125" alt="WGInvite4 7" src="https://github.com/user-attachments/assets/75b6a0bb-a21e-4f79-9a8d-6382706db40d" />


[ DOWNLOAD LATEST VERSION HERE: [WGInvite_Master_v4.7.rar](https://github.com/LtyrantTheMultiboxer/WGInvite-Master/releases/download/untagged-29b5a9caea5da0d1366d/WGInvite.4.7.rar) ]

===========================================
1. VERSION 3.7 -> 4.7 UPDATES
===========================================

* NEW GLASS UI & VISUALS:
  - Upgraded timer to show Hours:Minutes:Seconds (0h 0m 0s).
  - Added Dynamic Scaling: All text and buttons resize when you scale the frame.
  - Right-Click Lock: Right-click the timer window to instantly lock/unlock it.
  - Opacity Control: Adjust background transparency in the settings.

* PRECISION MATH & TRACKING:
  - Fixed Kill Counter: Implemented 'Debounce' logic. No more double/triple counting 1 kill.
  - Honor Tracker: Live tracking of honor gained within the zone.
  - Smart Reset: Stats automatically wipe to 0 when you enter Wintergrasp.

* FULL AUTOMATION SUITE:
  - Direct Auto-Join: Bypasses the queue popup to join WG instantly.
  - Trusted Auto-Accept: Auto-joins groups invited by Guildies or Friends.
  - Auto-Release: Spirit releases automatically in WG and Battlegrounds.
  - Duel Blocker: Automatically declines duels to keep your screen clear.

* RAID & GUILD TOOLS:
  - Keyword Inviter: Automatically invites players who whisper keywords like 'inv' or 'wg'.
  - Mass Invite: One-click buttons for mass inviting Guild ranks or Friends list.
  - Auto-Assistant: Automatically promotes specific players to assistant upon joining.
  - The 'Nuke' Button: One-click button to disband the entire raid instantly.
  - Blacklist: Built-in list to prevent specific players from being invited.

===========================================
2. SLASH COMMANDS
===========================================

/wgi      - Open the main settings menu.
/wgshow   - Emergency command to force the minimap button to appear.
/wgreset  - Snap the timer frame back to the center of your screen.
/wgbutton - Alternative force-show for the minimap icon.

===========================================
3. INSTALLATION
===========================================

1. Place the 'WGInvite' folder in your Interface/AddOns directory.
2. Ensure you have the 'Libs' folder (Ace3) inside the 'WGInvite' folder.
3. Your folder structure should look like this:
   - AddOns/WGInvite/WGInvite.toc
   - AddOns/WGInvite/WGInvite.lua
   - AddOns/WGInvite/Libs/

===========================================
4. PROJECT LUA (v4.7 MASTER)
===========================================
(Copy and paste the LUA code we generated into your WGInvite.lua file)
