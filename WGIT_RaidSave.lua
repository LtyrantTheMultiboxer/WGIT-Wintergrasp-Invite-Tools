-- WGIT_RaidSave.lua
-- Raid Layout Save/Restore module.
-- Saves each raid member's name, group number, and slot within the group.
-- Loaded after WGIT.lua; extends WGIT.options before config is registered.

-- --- HELPERS ---

local function GetRaidIndexByName(name)
    for i = 1, GetNumRaidMembers() do
        local n = GetRaidRosterInfo(i)
        if n == name then return i end
    end
    return nil
end

local function GetSavedLayoutNames()
    local names = {}
    for k in pairs(WGIT.db.profile.savedLayouts) do
        table.insert(names, k)
    end
    table.sort(names)
    return names
end

local function BuildLayoutListText()
    local names = GetSavedLayoutNames()
    if #names == 0 then
        return "|cffaaaaaa No saved layouts yet.|r"
    end
    local lines = {}
    for _, name in ipairs(names) do
        local layout = WGIT.db.profile.savedLayouts[name]
        local count = 0
        for _ in pairs(layout) do count = count + 1 end
        table.insert(lines, "|cff00ccff" .. name .. "|r |cffaaaaaa(" .. count .. " members)|r")
    end
    return table.concat(lines, "\n")
end

-- --- MOVE QUEUE (throttled restore) ---

local moveQueue = {}
local moveTimer = nil
local movesDone = 0

local function ProcessMoveQueue()
    if #moveQueue == 0 then
        if moveTimer then
            WGIT:CancelTimer(moveTimer)
            moveTimer = nil
        end
        WGIT:Print("Restore complete. |cffffffff" .. movesDone .. "|r player(s) moved.")
        movesDone = 0
        return
    end

    local move = table.remove(moveQueue, 1)
    local idx = GetRaidIndexByName(move.name)
    if idx then
        local _, _, currentGroup = GetRaidRosterInfo(idx)
        if currentGroup ~= move.group then
            SetRaidSubgroup(idx, move.group)
            movesDone = movesDone + 1
        end
    end
end

-- --- CORE FUNCTIONS ---

function WGIT:SaveRaidLayout(name)
    name = name and name:match("^%s*(.-)%s*$") or ""
    if name == "" then
        self:Print("Usage: /wgsave <name>")
        return
    end
    if GetNumRaidMembers() == 0 then
        self:Print("You are not in a raid.")
        return
    end

    local layout = {}
    local count = 0
    for i = 1, GetNumRaidMembers() do
        local n, _, subgroup = GetRaidRosterInfo(i)
        if n then
            layout[n] = { group = subgroup }
            count = count + 1
        end
    end

    self.db.profile.savedLayouts[name] = layout
    self:Print("Layout |cff00ccff\"" .. name .. "\"|r saved with |cffffffff" .. count .. "|r member(s).")
end

function WGIT:RestoreRaidLayout(name)
    name = name and name:match("^%s*(.-)%s*$") or ""
    if name == "" then
        self:Print("Usage: /wgrestore <name>")
        return
    end
    if not IsRaidLeader() then
        self:Print("You must be the raid leader to restore layouts.")
        return
    end

    local layout = self.db.profile.savedLayouts[name]
    if not layout then
        self:Print("No saved layout found: |cffff8080\"" .. name .. "\"|r")
        return
    end

    if moveTimer then
        self:CancelTimer(moveTimer)
        moveTimer = nil
        wipe(moveQueue)
        movesDone = 0
    end

    local queued = 0
    local num = GetNumRaidMembers()
    for i = 1, num do
        local n, _, currentGroup = GetRaidRosterInfo(i)
        if n and layout[n] and layout[n].group ~= currentGroup then
            table.insert(moveQueue, { name = n, group = layout[n].group })
            queued = queued + 1
        end
    end

    if queued == 0 then
        self:Print("Everyone is already in their saved position for |cff00ccff\"" .. name .. "\"|r.")
        return
    end

    self:Print("Restoring layout |cff00ccff\"" .. name .. "\"|r — moving |cffffffff" .. queued .. "|r player(s)...")
    moveTimer = self:ScheduleRepeatingTimer(ProcessMoveQueue, 0.5)
end

function WGIT:DeleteRaidLayout(name)
    name = name and name:match("^%s*(.-)%s*$") or ""
    if name == "" then
        self:Print("Usage: /wgdellayout <name>")
        return
    end
    if not self.db.profile.savedLayouts[name] then
        self:Print("No saved layout found: |cffff8080\"" .. name .. "\"|r")
        return
    end
    self.db.profile.savedLayouts[name] = nil
    self:Print("Layout |cffff8080\"" .. name .. "\"|r deleted.")
end

function WGIT:ListRaidLayouts()
    local names = GetSavedLayoutNames()
    if #names == 0 then
        self:Print("No saved layouts.")
        return
    end
    self:Print("Saved layouts:")
    for _, name in ipairs(names) do
        local layout = self.db.profile.savedLayouts[name]
        local count = 0
        for _ in pairs(layout) do count = count + 1 end
        self:Print("  |cff00ccff" .. name .. "|r (" .. count .. " members)")
    end
end

-- --- OPTIONS TAB ---

WGIT.raidLayoutInput = ""

WGIT.options.args.raidLayouts = {
    type = "group", name = "Save & Restore Raid Layout", order = 6,
    args = {
        header = {
            type = "header", name = "Save & Restore Raid Layout", order = 1,
        },
        info = {
            type = "description", order = 2, fontSize = "medium",
            name = "Save the current raid group assignments by name. Restore them later to move everyone back to their saved group. You must be raid leader to restore.\n",
        },
        layoutName = {
            type = "input", name = "Layout Name", order = 3, width = "double",
            get = function() return WGIT.raidLayoutInput end,
            set = function(_, v) WGIT.raidLayoutInput = v end,
        },
        saveBtn = {
            type = "execute", name = "Save Layout", order = 4,
            desc = "Snapshot the current raid group assignments under this name.",
            func = function() WGIT:SaveRaidLayout(WGIT.raidLayoutInput) end,
        },
        restoreBtn = {
            type = "execute", name = "Restore Layout", order = 5,
            desc = "Move raid members back to their saved groups (throttled, 1 move per 0.5s).",
            func = function() WGIT:RestoreRaidLayout(WGIT.raidLayoutInput) end,
        },
        deleteBtn = {
            type = "execute", name = "|cffff4444Delete Layout|r", order = 6,
            desc = "Permanently delete the saved layout with this name.",
            confirm = true,
            func = function() WGIT:DeleteRaidLayout(WGIT.raidLayoutInput) end,
        },
        divider = {
            type = "header", name = "Saved Layouts", order = 7,
        },
        savedList = {
            type = "description", order = 8, fontSize = "medium",
            name = function() return BuildLayoutListText() end,
        },
    },
}
