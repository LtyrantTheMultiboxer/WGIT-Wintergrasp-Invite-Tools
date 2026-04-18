-- REGISTER WITH ALL MIXINS
WGInvite = LibStub("AceAddon-3.0"):NewAddon("WGInvite", "AceConsole-3.0", "AceEvent-3.0")

-- --- 1. TIMER & FORMATTING ---
local function GetWGTimer()
    local wgTime = GetWintergraspWaitTime()
    if not wgTime or wgTime <= 0 then return "Active", true, false end
    local hours = math.floor(wgTime / 3600)
    local mins = math.floor((wgTime % 3600) / 60)
    local isUrgent = (wgTime < 900)
    return string.format("%dh %dm", hours, mins), false, isUrgent
end

-- --- 2. GLASS UI TIMER FRAME ---
local function CreateStyledTimer()
    local f = CreateFrame("Frame", "WGInviteTimerFrame", UIParent)
    f:SetSize(180, 65)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetResizable(true)
    f:SetMinResize(100, 45)
    f:RegisterForDrag("LeftButton")
    
    f.rb = CreateFrame("Button", nil, f)
    f.rb:SetPoint("BOTTOMRIGHT", -2, 2)
    f.rb:SetSize(16, 16)
    f.rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.rb:SetScript("OnMouseDown", function() if not WGInvite.db.profile.timerLocked then f:StartSizing() end end)
    f.rb:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    f:SetScript("OnDragStart", function(self) if not WGInvite.db.profile.timerLocked then self:StartMoving() end end)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    f:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            WGInvite.db.profile.timerLocked = not WGInvite.db.profile.timerLocked
            WGInvite:UpdateLockState()
            local state = WGInvite.db.profile.timerLocked and "|cffff0000Locked|r" or "|cff00ff00Unlocked|r"
            WGInvite:Print("Timer Window " .. state)
        end
    end)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", 0, -8)
    f.title:SetText("WINTERGRASP")
    f.title:SetTextColor(1, 0.82, 0)

    f.time = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.time:SetPoint("CENTER", 0, -8)
    
    f:SetScript("OnSizeChanged", function(self, width, height)
        local scale = height / 65
        self.title:SetFont("Fonts\\FRIZQT__.TTF", math.max(8, 10 * scale), "OUTLINE")
        self.time:SetFont("Fonts\\FRIZQT__.TTF", math.max(12, 18 * scale), "OUTLINE")
    end)

    local lastUpdate = 0
    f:SetScript("OnUpdate", function(_, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate > 5 then
            local text, active, urgent = GetWGTimer()
            f.time:SetText(text)
            if active then f.time:SetTextColor(0, 1, 0)
            elseif urgent then f.time:SetTextColor(1, 0.2, 0)
            else f.time:SetTextColor(1, 1, 1) end
            lastUpdate = 0
        end
    end)
    return f
end

-- --- 3. DEFAULTS & OPTIONS ---
local defaults = {
    profile = {
        keyword = "inv, invite, wg",
        maxRank = 3, minLevel = 80,
        showTimerFrame = true,
        timerLocked = false,
        timerOpacity = 0.6,
        timerColor = { r = 0, g = 0, b = 0 },
        autoJoinWG = true, autoRaid = true, autoAccept = true, 
        autoRelease = true, declineDuels = true,
        minimap = { hide = false }, blacklist = {}, assistants = {},
    }
}

local options = {
    name = "WGInvite Master Build v3.8",
    handler = WGInvite,
    type = "group",
    args = {
        appearance = {
            type = "group", name = "Visuals", inline = true, order = 1,
            args = {
                showTimerFrame = { type = "toggle", name = "Show Timer Window", order = 1, get = function() return WGInvite.db.profile.showTimerFrame end, set = function(_, v) WGInvite.db.profile.showTimerFrame = v; if v then WGInvite.TimerFrame:Show() else WGInvite.TimerFrame:Hide() end end },
                timerLocked = { type = "toggle", name = "Lock Window", order = 2, get = function() return WGInvite.db.profile.timerLocked end, set = function(_, v) WGInvite.db.profile.timerLocked = v; WGInvite:UpdateLockState() end },
                timerOpacity = { type = "range", name = "Opacity", min = 0, max = 1, step = 0.1, order = 3, get = function() return WGInvite.db.profile.timerOpacity end, set = function(_, v) WGInvite.db.profile.timerOpacity = v; local c = WGInvite.db.profile.timerColor; WGInvite.TimerFrame:SetBackdropColor(c.r, c.g, c.b, v) end },
                timerColor = { type = "color", name = "Window Color", order = 4, get = function() local c = WGInvite.db.profile.timerColor; return c.r, c.g, c.b end, set = function(_, r, g, b) WGInvite.db.profile.timerColor = {r=r, g=g, b=b}; WGInvite.TimerFrame:SetBackdropColor(r, g, b, WGInvite.db.profile.timerOpacity) end },
            },
        },
        automation = {
            type = "group", name = "Automation", inline = true, order = 2,
            args = {
                autoJoinWG = { type = "toggle", name = "Auto-Join WG Queue", order = 1, get = function() return WGInvite.db.profile.autoJoinWG end, set = function(_, v) WGInvite.db.profile.autoJoinWG = v end },
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
                disbandRaid = { type = "execute", name = "|cffff0000Disband Raid (Nuke)|r", order = 4, confirm = true, func = "DoDisbandRaid" },
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

-- --- 4. CORE ENGINE ---

function WGInvite:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WGInviteDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("WGInvite", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WGInvite", "WGInvite")
    
    self:RegisterChatCommand("wgi", "OpenConfig")
    
    self.TimerFrame = CreateStyledTimer()
    local c = self.db.profile.timerColor
    self.TimerFrame:SetBackdropColor(c.r, c.g, c.b, self.db.profile.timerOpacity)
    self:UpdateLockState()
    
    if not self.db.profile.showTimerFrame then self.TimerFrame:Hide() end

    -- Minimap Icon with detailed Tooltip
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("WGInvite", {
        type = "data source", text = "WGInvite",
        icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance",
        OnClick = function(_, b) WGInvite:OpenConfig() end, -- Simplified click
        OnTooltipShow = function(t)
            t:AddLine("|cff00ff00WGInvite Master|r")
            t:AddDoubleLine("WG Timer:", "|cffffffff"..(GetWGTimer()).."|r")
            t:AddLine(" ")
            t:AddLine("|cffeda55fLeft-Click:|r Open Settings")
            t:AddLine("|cffeda55fRight-Click Timer:|r Toggle Lock")
        end,
    })
    LibStub("LibDBIcon-1.0"):Register("WGInvite", LDB, self.db.profile.minimap)
    
    -- --- NEW RELIABLE AUTO-JOIN TICKER ---
    -- We check every 1 second if the battleground popup is visible
    self.joinTicker = self:ScheduleRepeatingTimer("CheckForWGPopup", 1)
    
    self:Print("v3.8 Master Build Loaded. /wgi for settings.")
end

function WGInvite:CheckForWGPopup()
    if not self.db.profile.autoJoinWG then return end
    
    -- Loop through potential static popups
    for i = 1, STATICPOPUP_NUMDIALOGS do
        local frame = _G["StaticPopup"..i]
        if frame and frame:IsVisible() and frame.which == "GO_BATTLEGROUND" then
            -- Verify it's Wintergrasp text
            local text = _G["StaticPopup"..i.."Text"]:GetText()
            if text and text:find("Wintergrasp") then
                StaticPopup_OnClick(frame, 1) -- Click 'Join Battle'
                self:Print("|cff00ff00Auto-Joined Wintergrasp!|r")
            end
        end
    end
end

-- [The rest of the functions: UpdateLockState, OnEnable, DoMassInvite, etc. remain the same]
function WGInvite:UpdateLockState()
    if self.db.profile.timerLocked then self.TimerFrame.rb:Hide() else self.TimerFrame.rb:Show() end
end

function WGInvite:OnEnable()
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self:RegisterEvent("PARTY_INVITE_REQUEST")
    self:RegisterEvent("RAID_ROSTER_UPDATE", "AutoPromoteAssistants")
    self:RegisterEvent("DUEL_REQUESTED")
    self:RegisterEvent("PLAYER_DEAD")
end

function WGInvite:OpenConfig()
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
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

function WGInvite:DoDisbandRaid()
    if not (IsRaidLeader() or IsPartyLeader()) then return end
    if GetNumRaidMembers() > 0 then
        for i = 1, 40 do
            local n = GetRaidRosterInfo(i)
            if n and n ~= UnitName("player") then UninviteUnit(n) end
        end
    else
        for i = 1, GetNumPartyMembers() do
            local n = GetPartyMember(i)
            if n then UninviteUnit(n) end
        end
    end
    LeaveParty()
end
