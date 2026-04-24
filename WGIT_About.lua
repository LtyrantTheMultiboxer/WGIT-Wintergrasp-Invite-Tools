-- WGIT_About.lua
-- About module — adds the About tab to the WGIT options panel.
-- Loaded after WGIT.lua; extends WGIT.options before config is registered.

WGIT.options.args.about = {
    type = "group", name = "About", inline = true, order = 5,
    args = {
        header = {
            type = "header", name = "WGIT - Wintergrasp Invite Tools v1.0", order = 1,
        },
        desc1 = {
            type = "description", order = 2, fontSize = "medium",
            name = "WGIT (Wintergrasp Invite Tools) is an all-in-one Wintergrasp utility addon designed to streamline your PvP experience on WotLK servers.\n",
        },
        desc2 = {
            type = "description", order = 3, fontSize = "medium",
            name = "|cff00ff00Features:|r\n" ..
                   "  - Displays a live Wintergrasp countdown timer with hours, minutes, and seconds.\n" ..
                   "  - Tracks session Honor Kills and Honor Points earned while in Wintergrasp.\n" ..
                   "  - Auto-joins the Wintergrasp queue when an invite is available.\n" ..
                   "  - Auto-converts your party to a raid group.\n" ..
                   "  - Auto-accepts group invites from guildmates and friends.\n" ..
                   "  - Auto-releases your corpse upon death in Wintergrasp or a battleground.\n" ..
                   "  - Auto-declines duel requests.\n" ..
                   "  - Keyword-based whisper invite system for raid recruitment.\n" ..
                   "  - Mass invite tools for guild members and friends.\n" ..
                   "  - Auto-promotes designated players to raid assistant.\n" ..
                   "  - Blacklist to block unwanted players from whisper invites.\n" ..
                   "  - Minimap icon with live status tooltip.\n" ..
                   "  - Right-click the timer window to lock or unlock it.\n",
        },
        divider = {
            type = "header", name = "", order = 4,
        },
        author = {
            type = "description", order = 5, fontSize = "medium",
            name = "|cffaaaaaa Created by |r|cff00ccffxLT69x|r",
        },
    },
}
