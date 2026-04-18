-- REGISTER WITH ALL MIXINS
WGInvite = LibStub("AceAddon-3.0"):NewAddon("WGInvite", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

-- --- 1. DATA TRACKING ---
local sessionKills = 0
local sessionHonor = 0
local lastHKTime = 0

-- --- 2. DEFAULTS ---
local defaults = {
    profile = {
        keyword = "inv, invite, wg",
        maxRank = 3, minLevel = 80,
        showTimerFrame = true,
        timerLocked = false,
        timerOpacity = 0.6,
        timerColor = { r = 0, g = 0, b = 0 },
        autoJoinWG = true, 
        autoRaid = true, 
        autoAccept = true, 
        autoRelease = true, 
        declineDuels = true,
        minimap = { hide = false, minimapPos = 220 },
        blacklist = {}, 
        assistants = {},
    }
}

-- --- 3. OPTIONS TABLE ---
local options = {
    name = "WGInvite Master v4.7",
    handler = WGInvite,
    type = "group",
    args = {
        appearance = {
            type = "group", name = "Visuals", inline = true, order = 1,
            args = {
                showTimerFrame = { type = "toggle", name = "Show Timer Window", order = 1, get = function() return WGInvite.db.profile.showTimerFrame end, set = function(_, v) WGInvite.db.profile.showTimerFrame = v; if v then WGInvite.TimerFrame:Show() else WGInvite.TimerFrame:Hide() end end },
                timerLocked = { type = "toggle", name = "Lock Window", order = 2, get = function() return WGInvite.db.profile.timerLocked end, set = function(_, v) WGInvite.db.profile.timerLocked = v; WGInvite:UpdateLockState() end },
                timerOpacity = { type = "range", name = "Opacity", min = 0, max = 1, step = 0.1, order = 3, get = function() return WGInvite.db.profile.timerOpacity end, set = function(_, v) WGInvite.db.profile.timerOpacity = v; local c = WGInvite.db.profile.timerColor; WGInvite.TimerFrame:SetBackdropColor(c.r, c.g, c.b, v) end },
            },
        },
        automation = {
            type = "group", name = "Automation", inline = true, order = 2,
            args = {
                autoJoinWG = { type = "toggle", name = "Auto-Join WG Queue", order = 1, get = function() return WGInvite.db.profile.autoJoinWG end, set = function(_, v) WGInvite.db.profile.autoJoinWG = v; WGInvite:UpdateLockButtonText() end },
                autoRaid = { type = "toggle", name = "Auto-Convert Raid", order = 2, get = function() return WGInvite.db.profile.autoRaid end, set = function(_, v) WGInvite.db.profile.autoRaid = v end },
                autoAccept = { type = "toggle", name = "Auto-Accept (Guild/Friends)", order = 3, get = function() return WGInvite.db.profile.autoAccept end, set = function(_, v) WGInvite.db.profile.autoAccept = v end },
                autoRelease = { type = "toggle", name = "Auto-Release in BG", order = 4, get = function() return WGInvite.db.profile.autoRelease end, set = function(_, v) WGInvite.db.profile.autoRelease = v end },
                declineDuels = { type = "toggle", name = "Auto-Decline Duels", order = 5, get = function() return WGInvite.db.profile.declineDuels end, set = function(_, v) WGInvite.db.profile.declineDuels = v end },
            },
        },
        tools = {
            type = "group", name = "Raid Tools", inline = true, order = 3,
            args = {
                keyword = { type = "input", name = "Keywords", order = 1, get = function() return WGInvite.db.profile.keyword end, set = function(_, v) WGInvite.db.profile.keyword = v end },
                massGuild = { type = "execute", name = "Mass Invite Guild", order = 2, func = "DoMassInvite" },
                massFriends = { type = "execute", name = "Mass Invite Friends", order = 3, func = "DoFriendsInvite" },
                disbandRaid = { type = "execute", name = "|cffff0000Disband Raid|r", order = 4, confirm = true, func = "DoDisbandRaid" },
            },
        },
        lists = {
            type = "group", name = "Management Lists", inline = true, order = 4,
            args = {
                assistants = { type = "input", name = "Auto-Assistants", multiline = 5, width = "full", order = 1, get = function() local n={}; for k in pairs(WGInvite.db.profile.assistants) do table.insert(n,k) end; table.sort(n); return table.concat(n,"\n") end, set = function(_, v) wipe(WGInvite.db.profile.assistants); for m in v:gmatch("%S+") do WGInvite.db.profile.assistants[m:gsub("^%l", string.upper)] = true end end },
                blacklist = { type = "input", name = "Blacklist", multiline = 5, width = "full", order = 2, get = function() local n={}; for k in pairs(WGInvite.db.profile.blacklist) do table.insert(n,k) end; table.sort(n); return table.concat(n,"\n") end, set = function(_, v) wipe(WGInvite.db.profile.blacklist); for m in v:gmatch("%S+") do WGInvite.db.profile.blacklist[m:gsub("^%l", string.upper)] = true end end },
            },
        },
    },
}

-- --- 4. TIMER & UI FRAME (SECONDS ADDED) ---
local function GetWGTimer()
    local wgTime = GetWintergraspWaitTime()
    if not wgTime or wgTime <= 0 then return "Active", true, false end
    
    local hours = math.floor(wgTime / 3600)
    local mins = math.floor((wgTime % 3600) / 60)
    local secs = math.floor(wgTime % 60)
    
    -- Format: 0h 0m 0s
    return string.format("%dh %dm %ds", hours, mins, secs), false, (wgTime < 900)
end

local function CreateStyledTimer()
    local f = CreateFrame("Frame", "WGInviteTimerFrame", UIParent)
    f:SetSize(180, 115)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetMovable(true); f:EnableMouse(true); f:SetResizable(true); f:SetMinResize(140, 100)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) if not WGInvite.db.profile.timerLocked then self:StartMoving() end end)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    f.rb = CreateFrame("Button", nil, f)
    f.rb:SetPoint("BOTTOMRIGHT", -2, 2); f.rb:SetSize(16, 16)
    f.rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.rb:SetScript("OnMouseDown", function() if not WGInvite.db.profile.timerLocked then f:StartSizing() end end)
    f.rb:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", 0, -8); f.title:SetText("WINTERGRASP")

    f.time = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.time:SetPoint("TOP", 0, -22)

    f.statKills = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.statKills:SetPoint("TOPLEFT", 15, -48)

    f.statHonor = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.statHonor:SetPoint("TOPLEFT", 15, -62)

    f.toggle = CreateFrame("Button", nil, f)
    f.toggle:SetSize(120, 18); f.toggle:SetPoint("BOTTOM", 0, 10)
    f.toggle:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
    f.toggle:SetBackdropColor(0, 0, 0, 0.5)
    f.toggle.text = f.toggle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.toggle.text:SetPoint("CENTER")
    f.toggle:SetScript("OnClick", function() WGInvite.db.profile.autoJoinWG = not WGInvite.db.profile.autoJoinWG; WGInvite:UpdateLockButtonText() end)
    
    f:SetScript("OnUpdate", function(self, elapsed)
        self.tick = (self.tick or 0) + elapsed
        if self.tick > 0.1 then -- Faster refresh for seconds
            local text, active, urgent = GetWGTimer()
            f.time:SetText(text)
            f.statKills:SetText("Kills: |cffffffff"..sessionKills.."|r")
            f.statHonor:SetText("Honor: |cffffffff"..sessionHonor.."|r")
            if active then f.time:SetTextColor(0, 1, 0) elseif urgent then f.time:SetTextColor(1, 0.2, 0) else f.time:SetTextColor(1, 1, 1) end
            self.tick = 0
        end
    end)
    return f
end

-- --- 5. CORE ENGINE ---

function WGInvite:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WGInviteDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("WGInvite", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WGInvite", "WGInvite")
    
    self:RegisterChatCommand("wgi", "OpenConfig")
    self:RegisterChatCommand("wgreset", function() self.TimerFrame:ClearAllPoints(); self.TimerFrame:SetPoint("CENTER", 0, 0) end)
    self:RegisterChatCommand("wgshow", function() self.db.profile.minimap.hide = false; LibStub("LibDBIcon-1.0"):Show("WGInvite") end)
    
    self.TimerFrame = CreateStyledTimer()
    self:UpdateLockState(); self:UpdateLockButtonText()
    local c = self.db.profile.timerColor; self.TimerFrame:SetBackdropColor(c.r, c.g, c.b, self.db.profile.timerOpacity)

    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("WGInvite", {
        type = "data source", text = "WGInvite", icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance",
        OnClick = function() WGInvite:OpenConfig() end,
    })
    LibStub("LibDBIcon-1.0"):Register("WGInvite", LDB, self.db.profile.minimap)
    LibStub("LibDBIcon-1.0"):Show("WGInvite")
end

function WGInvite:OnEnable()
    self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_INVITE")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
    self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED", "HandleKillCount")
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self:RegisterEvent("PARTY_INVITE_REQUEST")
    self:RegisterEvent("RAID_ROSTER_UPDATE", "AutoPromoteAssistants")
    self:RegisterEvent("DUEL_REQUESTED")
    self:RegisterEvent("PLAYER_DEAD")
end

-- --- 6. FEATURE LOGIC ---

function WGInvite:HandleKillCount()
    if GetRealZoneText() == "Wintergrasp" then
        if (GetTime() - lastHKTime > 0.5) then 
            sessionKills = sessionKills + 1
            lastHKTime = GetTime()
        end
    end
end

function WGInvite:ZONE_CHANGED_NEW_AREA()
    if GetRealZoneText() == "Wintergrasp" then sessionKills = 0; sessionHonor = 0 end
end

function WGInvite:CHAT_MSG_COMBAT_HONOR_GAIN(_, msg)
    if GetRealZoneText() == "Wintergrasp" then
        local amount = tonumber(msg:match("%d+"))
        if amount then sessionHonor = sessionHonor + amount end
    end
end

function WGInvite:BATTLEFIELD_MGR_QUEUE_INVITE()
    if self.db.profile.autoJoinWG then
        BattlefieldMgrQueueInviteResponse(1,1)
        StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE")
        StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP")
    end
end

function WGInvite:PARTY_INVITE_REQUEST(_, sender)
    if self.db.profile.autoAccept then
        for i=1, GetNumFriends() do if GetFriendInfo(i) == sender then AcceptGroup(); StaticPopup_Hide("PARTY_INVITE"); return end end
        if IsInGuild() then
            GuildRoster()
            for i=1, GetNumGuildMembers() do if GetGuildRosterInfo(i) == sender then AcceptGroup(); StaticPopup_Hide("PARTY_INVITE"); return end end
        end
    end
end

function WGInvite:DUEL_REQUESTED(_, sender)
    if self.db.profile.declineDuels then CancelDuel(); self:Print("Declined duel from " .. sender) end
end

function WGInvite:PLAYER_DEAD()
    if self.db.profile.autoRelease and (GetRealZoneText() == "Wintergrasp" or UnitInBattleground("player")) then RepopMe() end
end

-- --- [RAID UTILITIES] ---
function WGInvite:CHAT_MSG_WHISPER(_, msg, sender)
    local name = sender:gsub("-.*", "")
    if self.db.profile.blacklist[name] then return end
    for kw in self.db.profile.keyword:gmatch("[^,]+") do
        local clean = kw:match("^%s*(.-)%s*$"):lower()
        if clean ~= "" and msg:lower():find(clean, 1, true) then InviteUnit(sender); return end
    end
end

function WGInvite:PARTY_MEMBERS_CHANGED()
    if self.db.profile.autoRaid and GetNumPartyMembers() > 0 and GetNumRaidMembers() == 0 and IsPartyLeader() then ConvertToRaid() end
end

function WGInvite:AutoPromoteAssistants()
    if IsRaidLeader() then
        for i = 1, GetNumRaidMembers() do
            local n, rank = GetRaidRosterInfo(i)
            if n and rank == 0 and self.db.profile.assistants[n] then PromoteToAssistant(n) end
        end
    end
end

function WGInvite:DoMassInvite()
    if not IsInGuild() then return end
    GuildRoster()
    for i = 1, GetNumGuildMembers() do
        local n, _, r, l, _, _, _, _, o = GetGuildRosterInfo(i)
        if o and n ~= UnitName("player") and r <= self.db.profile.maxRank and l >= 80 then
            if not self.db.profile.blacklist[n] then InviteUnit(n) end
        end
    end
end

function WGInvite:DoFriendsInvite()
    ShowFriends()
    for i = 1, GetNumFriends() do
        local n, l, _, _, o = GetFriendInfo(i)
        if n and o and not self.db.profile.blacklist[n] and l >= 80 then InviteUnit(n) end
    end
end

function WGInvite:DoDisbandRaid()
    if not (IsRaidLeader() or IsPartyLeader()) then return end
    for i = 1, 40 do local n = GetRaidRosterInfo(i); if n and n ~= UnitName("player") then UninviteUnit(n) end end
    LeaveParty()
end

function WGInvite:UpdateLockState() if self.db.profile.timerLocked then self.TimerFrame.rb:Hide() else self.TimerFrame.rb:Show() end end
function WGInvite:UpdateLockButtonText() local c = self.db.profile.autoJoinWG and "|cff00ff00ON|r" or "|cffff0000OFF|r"; self.TimerFrame.toggle.text:SetText("Auto-Join: " .. c) end
function WGInvite:OpenConfig() InterfaceOptionsFrame_OpenToCategory(self.optionsFrame); InterfaceOptionsFrame_OpenToCategory(self.optionsFrame) end
