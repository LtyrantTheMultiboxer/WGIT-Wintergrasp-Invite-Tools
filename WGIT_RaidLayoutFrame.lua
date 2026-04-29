-- WGIT_RaidLayoutFrame.lua
-- Popup UI for managing saved raid layouts.
-- Open with the "Layouts" button on the timer frame or /wglm

local FRAME_W   = 300
local ROW_H     = 42
local SCROLL_H  = 200

-- --- FRAME CONSTRUCTION ---

local function MakeButton(parent, w, h, r, g, b, label)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(w, h)
    btn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
    })
    btn:SetBackdropColor(r, g, b, 0.88)
    btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    txt:SetPoint("CENTER")
    txt:SetText(label)
    btn.label = txt
    return btn
end

local function MakeSeparator(parent, yOffset)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT",  parent, "TOPLEFT",  10, yOffset)
    sep:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset)
    sep:SetTexture("Interface\\Buttons\\WHITE8X8")
    sep:SetVertexColor(0.25, 0.25, 0.25, 1)
end

local function BuildLayoutManagerFrame()
    local f = CreateFrame("Frame", "WGITLayoutManagerFrame", UIParent)
    f:SetSize(FRAME_W, 340)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetBackdropColor(0.04, 0.04, 0.06, 0.97)
    f:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.9)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:Hide()

    -- Title bar background
    local titleBg = f:CreateTexture(nil, "BACKGROUND")
    titleBg:SetPoint("TOPLEFT",  f, "TOPLEFT",  4, -4)
    titleBg:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    titleBg:SetHeight(26)
    titleBg:SetTexture("Interface\\Buttons\\WHITE8X8")
    titleBg:SetVertexColor(0.02, 0.10, 0.22, 1)

    -- Title text
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 12, -11)
    title:SetText("|cff66aaffRaid Layout Manager|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    MakeSeparator(f, -30)

    -- Name input label
    local inputLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    inputLabel:SetPoint("TOPLEFT", 12, -42)
    inputLabel:SetText("|cffaaaaaa Layout Name:|r")

    -- Name input box
    local nameInput = CreateFrame("EditBox", "WGITLayoutNameInput", f, "InputBoxTemplate")
    nameInput:SetSize(162, 20)
    nameInput:SetPoint("TOPLEFT", 12, -58)
    nameInput:SetAutoFocus(false)
    nameInput:SetMaxLetters(48)
    nameInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    nameInput:SetScript("OnEnterPressed", function(self)
        local name = self:GetText():match("^%s*(.-)%s*$")
        if name ~= "" then WGIT:SaveRaidLayout(name); WGIT:RefreshLayoutList() end
        self:ClearFocus()
    end)
    f.nameInput = nameInput

    -- Save button
    local saveBtn = MakeButton(f, 100, 22, 0, 0.32, 0.08, "|cff44ff44Save Layout|r")
    saveBtn:SetPoint("TOPLEFT", nameInput, "TOPRIGHT", 8, 1)
    saveBtn:SetScript("OnClick", function()
        local name = nameInput:GetText():match("^%s*(.-)%s*$")
        if name ~= "" then
            WGIT:SaveRaidLayout(name)
            WGIT:RefreshLayoutList()
        else
            WGIT:Print("Enter a layout name first.")
        end
    end)

    MakeSeparator(f, -82)

    -- Saved layouts label
    local listLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    listLabel:SetPoint("TOPLEFT", 12, -90)
    listLabel:SetText("|cff66aaffSaved Layouts|r")

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "WGITLayoutScroll", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",  f, "TOPLEFT",   8, -106)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, 8)

    -- Content frame inside scroll
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(FRAME_W - 42)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

    -- Empty state label
    local emptyLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    emptyLabel:SetPoint("TOP", 0, -18)
    emptyLabel:SetText("|cffaaaaaa No saved layouts yet.\nUse the input above to save your current raid.|r")
    emptyLabel:SetJustifyH("CENTER")
    f.emptyLabel = emptyLabel

    f.content   = content
    f.rows      = {}

    return f
end

-- --- LAYOUT LIST REFRESH ---

local layoutFrame = nil

function WGIT:RefreshLayoutList()
    if not layoutFrame or not layoutFrame:IsShown() then return end

    local content = layoutFrame.content
    local rows    = layoutFrame.rows

    for _, row in ipairs(rows) do row:Hide() end

    local names = {}
    for k in pairs(self.db.profile.savedLayouts) do table.insert(names, k) end
    table.sort(names)

    if #names == 0 then
        layoutFrame.emptyLabel:Show()
        content:SetHeight(60)
        return
    end

    layoutFrame.emptyLabel:Hide()

    for i, name in ipairs(names) do
        local layout = self.db.profile.savedLayouts[name]
        local count  = 0
        for _ in pairs(layout) do count = count + 1 end

        -- Create or reuse row frame
        local row = rows[i]
        if not row then
            row = CreateFrame("Frame", nil, content)
            row:SetSize(FRAME_W - 46, ROW_H)

            -- Row background
            row.bg = row:CreateTexture(nil, "BACKGROUND")
            row.bg:SetAllPoints()
            row.bg:SetTexture("Interface\\Buttons\\WHITE8X8")

            -- Row bottom separator
            local rowSep = row:CreateTexture(nil, "ARTWORK")
            rowSep:SetHeight(1)
            rowSep:SetPoint("BOTTOMLEFT",  row, "BOTTOMLEFT",  0, 0)
            rowSep:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
            rowSep:SetTexture("Interface\\Buttons\\WHITE8X8")
            rowSep:SetVertexColor(0.2, 0.2, 0.2, 1)

            -- Layout name
            row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.nameText:SetPoint("TOPLEFT", 6, -6)
            row.nameText:SetWidth(130)
            row.nameText:SetJustifyH("LEFT")

            -- Member count
            row.countText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.countText:SetPoint("TOPLEFT", 6, -22)

            -- Restore button
            row.restoreBtn = MakeButton(row, 68, 20, 0, 0.30, 0.08, "|cff44ff44Restore|r")
            row.restoreBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -72, -10)

            -- Delete button
            row.deleteBtn = MakeButton(row, 60, 20, 0.40, 0.04, 0.04, "|cffff5555Delete|r")
            row.deleteBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -10)

            rows[i] = row
        end

        -- Alternating row color
        if i % 2 == 0 then
            row.bg:SetVertexColor(0.06, 0.08, 0.14, 0.9)
        else
            row.bg:SetVertexColor(0.10, 0.12, 0.20, 0.9)
        end

        row.nameText:SetText("|cff66aaff" .. name .. "|r")
        row.countText:SetText("|cffaaaaaa" .. count .. " member(s)|r")

        -- Capture name for closures
        local captureName = name
        row.restoreBtn:SetScript("OnClick", function()
            WGIT:RestoreRaidLayout(captureName)
        end)
        row.deleteBtn:SetScript("OnClick", function()
            StaticPopupDialogs["WGIT_CONFIRM_DELETE"] = {
                text       = "Delete raid layout \"|cffff5555" .. captureName .. "|r\"?",
                button1    = "Delete",
                button2    = "Cancel",
                OnAccept   = function()
                    WGIT:DeleteRaidLayout(captureName)
                    WGIT:RefreshLayoutList()
                end,
                timeout    = 0,
                whileDead  = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("WGIT_CONFIRM_DELETE")
        end)

        row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
        row:Show()
    end

    content:SetHeight(#names * ROW_H + 4)
end

-- --- TOGGLE ---

function WGIT:ToggleLayoutManager()
    if not layoutFrame then
        layoutFrame = BuildLayoutManagerFrame()
    end
    if layoutFrame:IsShown() then
        layoutFrame:Hide()
    else
        layoutFrame:Show()
        self:RefreshLayoutList()
    end
end
