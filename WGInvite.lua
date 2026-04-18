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
    f:SetSize(180, 85) -- Increased height to fit the new toggle button
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
    f:SetMinResize(120, 70)
    f:RegisterForDrag("LeftButton")
    
    -- Resize Handle
    f.rb = CreateFrame("Button", nil, f)
    f.rb:SetPoint("BOTTOMRIGHT", -2, 2)
    f.rb:SetSize(16, 16)
    f.rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.rb:SetScript("OnMouseDown", function() if not WGInvite.db.profile.timerLocked then f:StartSizing() end end)
    f.rb:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

    -- Drag Logic
    f:SetScript("OnDragStart", function(self) if not WGInvite.db.profile.timerLocked then self:StartMoving() end end)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    -- Right-Click Lock
    f:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            WGInvite.db.profile.timerLocked = not WGInvite.db.profile.timerLocked
            WGInvite:UpdateLockState()
        end
    end)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", 0, -8)
    f.title:SetText("WINTERGRASP")
    f.title:SetTextColor(1, 0.82, 0)

    f.time = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.time:SetPoint("CENTER", 0, 5)

    -- INTEGRATED TOGGLE BUTTON (Styled to match Glass UI)
    f.toggle = CreateFrame("Button", nil, f)
    f.toggle:SetSize(120, 20)
    f.toggle:SetPoint("BOTTOM", 0, 10)
    f.toggle:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
    f.toggle:SetBackdropColor(0, 0, 0, 0.5)
    f.toggle.text = f.toggle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.toggle.text:SetPoint("CENTER")
    
    f.toggle:SetScript("OnClick", function()
        WGInvite.db.profile.autoJoinWG = not WGInvite.db.profile.autoJoinWG
        WGInvite:UpdateLockButtonText()
    end)
    
    f:SetScript("OnSizeChanged", function(self, width, height)
        local scale = height / 85
        self.title:SetFont("Fonts\\FRIZQT__.TTF", math.max(7, 9 * scale), "OUTLINE")
        self.time:SetFont("Fonts\\FRIZQT__.TTF", math.max(11, 16 * scale), "OUTLINE")
        self.toggle:SetSize(100 * scale, 18 * scale)
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

-- [Options table remains mostly the same as v3.8, just updated version name]
local options = {
    name = "WGInvite Master Build v3.9",
    handler = WGInvite,
    type = "group",
    args = {
        -- ... (same as v3.8) ...
    }
}

-- --- 4. CORE ENGINE ---

function WGInvite:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WGInviteDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("WGInvite", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WGInvite", "WGInvite")
    
    self:RegisterChatCommand("wgi", "OpenConfig")
    self:RegisterChatCommand("wgreset", function() self.TimerFrame:ClearAllPoints(); self.TimerFrame:SetPoint("CENTER", 0, 0) end)
    
    self.TimerFrame = CreateStyledTimer()
    self:UpdateLockState()
    self:UpdateLockButtonText()
    
    local c = self.db.profile.timerColor
    self.TimerFrame:SetBackdropColor(c.r, c.g, c.b, self.db.profile.timerOpacity)
    
    if not self.db.profile.showTimerFrame then self.TimerFrame:Hide() end

    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("WGInvite", {
        type = "data source", text = "WGInvite",
        icon = "Interface\\Icons\\Ability_Warrior_OffensiveStance",
        OnClick = function() WGInvite:OpenConfig() end,
        OnTooltipShow = function(t)
            t:AddLine("|cff00ff00WGInvite Master|r")
            t:AddDoubleLine("WG Timer:", "|cffffffff"..(GetWGTimer()).."|r")
            t:AddLine(" ")
            t:AddLine("|cffeda55fLeft-Click:|r Open Settings")
            t:AddLine("|cffeda55fRight-Click Timer:|r Toggle Lock")
        end,
    })
    LibStub("LibDBIcon-1.0"):Register("WGInvite", LDB, self.db.profile.minimap)
end

function WGInvite:UpdateLockState()
    if self.db.profile.timerLocked then self.TimerFrame.rb:Hide() else self.TimerFrame.rb:Show() end
end

function WGInvite:UpdateLockButtonText()
    if self.db.profile.autoJoinWG then
        self.TimerFrame.toggle.text:SetText("Auto-Join: |cff00ff00ON|r")
    else
        self.TimerFrame.toggle.text:SetText("Auto-Join: |cffff0000OFF|r")
    end
end

function WGInvite:OnEnable()
    -- REGISTER THE SPECIFIC BATTLEFIELD MANAGER EVENT
    self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_INVITE")
    
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self:RegisterEvent("PARTY_INVITE_REQUEST")
    self:RegisterEvent("RAID_ROSTER_UPDATE", "AutoPromoteAssistants")
    self:RegisterEvent("DUEL_REQUESTED")
    self:RegisterEvent("PLAYER_DEAD")
end

-- --- 5. THE CRITICAL JOIN LOGIC (FROM AUTOJOINWG) ---
function WGInvite:BATTLEFIELD_MGR_QUEUE_INVITE()
    if self.db.profile.autoJoinWG then
        BattlefieldMgrQueueInviteResponse(1,1)
        StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE")
        StaticPopup_Hide("BFMGR_INVITED_TO_QUEUE_WARMUP")
        self:Print("|cff00ff00Auto-Joined Wintergrasp Battlefield!|r")
    end
end

-- [The rest of the functions: DoMassInvite, DoFriendsInvite, DoDisbandRaid, etc. remain here]
