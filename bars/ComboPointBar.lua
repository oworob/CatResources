local addonName, addon = ...

local comboPointBar = CreateFrame("StatusBar", nil, addon.frame)
addon.comboPointBar = comboPointBar
comboPointBar:SetSize(400, 30)
comboPointBar:SetPoint("BOTTOM", addon.frame, "BOTTOM")
comboPointBar:SetStatusBarTexture(addon.barTexture)
comboPointBar:SetStatusBarColor(unpack(addon.resourceColors[Enum.PowerType.ComboPoints]))
addon:AddBackground(comboPointBar)

for index = 1, 4 do
    local tick = comboPointBar:CreateTexture(nil, "OVERLAY")
    tick:SetColorTexture(1, 1, 1, 1)
    tick:SetSize(1, comboPointBar:GetHeight())
    tick:SetPoint("CENTER", comboPointBar, "LEFT", comboPointBar:GetWidth() * (index / 5), 0)
end

-- Overflowing Power Bar
local berserkBar = CreateFrame("StatusBar", nil, addon.frame)
addon.berserkBar = berserkBar
berserkBar:SetSize(240, 30)
berserkBar:SetPoint("BOTTOM", comboPointBar, "BOTTOM", 0, -31)
berserkBar:SetStatusBarTexture(addon.barTexture)
berserkBar:SetStatusBarColor(unpack(addon.resourceColors[Enum.PowerType.ComboPoints]))
berserkBar:SetMinMaxValues(0, 3)
addon:AddBackground(berserkBar)
berserkBar:Hide()

for index = 1, 2 do
    local tick = berserkBar:CreateTexture(nil, "OVERLAY")
    tick:SetColorTexture(1, 1, 1, 1)
    tick:SetSize(1, berserkBar:GetHeight())
    tick:SetPoint("CENTER", berserkBar, "LEFT", berserkBar:GetWidth() * (index / 3), 0)
end

local OVERFLOWING_POWER_ID = 405189

function addon:UpdateComboPoints()
    local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    comboPointBar:SetMinMaxValues(0, maxComboPoints)
    comboPointBar:SetValue(comboPoints, addon.db.smoothProgress and Enum.StatusBarInterpolation.ExponentialEaseOut or nil)

    if not addon.db.showOverflowingPower then
        berserkBar:Hide()
        return
    end

    local overflowingPowerAura = C_UnitAuras.GetPlayerAuraBySpellID(OVERFLOWING_POWER_ID)
    if not overflowingPowerAura or not overflowingPowerAura.applications then
        berserkBar:Hide()
        return
    end
    berserkBar:SetValue(overflowingPowerAura.applications or 0, addon.db.smoothProgress and Enum.StatusBarInterpolation.ExponentialEaseOut or nil)
    berserkBar:Show()
end

function addon:ToggleComboPointBar()
    local powerType = UnitPowerType("player")
    if powerType == Enum.PowerType.Energy then
        comboPointBar:Show()
    else
        comboPointBar:Hide()
    end
end