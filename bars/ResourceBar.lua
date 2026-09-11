local _, addon = ...

local resourceBar = CreateFrame("StatusBar", nil, addon.frame)
addon.resourceBar = resourceBar
resourceBar:SetSize(200, 30)
resourceBar:SetPoint("TOPRIGHT", addon.frame, "TOPRIGHT")
resourceBar:SetStatusBarTexture(addon.barTexture)
addon:AddBackground(resourceBar)

local resourceText = resourceBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
resourceText:SetPoint("LEFT", resourceBar, "LEFT", 5, 0)
resourceText:SetTextColor(1, 1, 1, 1)
local fontPath = resourceText:GetFont()
resourceText:SetFont(fontPath, 15, "OUTLINE")

function addon:UpdateResource()
    local powerType = UnitPowerType("player")
    local power = UnitPower("player", powerType)
    local maxPower = UnitPowerMax("player", powerType)

    resourceBar:SetMinMaxValues(0, maxPower)
    resourceBar:SetValue(power, addon.db.smoothProgress and Enum.StatusBarInterpolation.ExponentialEaseOut or nil)

    if powerType == Enum.PowerType.Mana then
        resourceText:SetFormattedText(
            "%.0f%%",
            UnitPowerPercent("player", powerType, true, CurveConstants.ScaleTo100)
        )
    else
        resourceText:SetText(power)
    end
end

function addon:UpdateResourceColor()
    local powerType = UnitPowerType("player")
    local color = addon.resourceColors[powerType] or {1, 1, 1, 1}
    resourceBar:SetStatusBarColor(unpack(color))
end

-- 50 energy tick
local energyTick = resourceBar:CreateTexture(nil, "OVERLAY")
energyTick:SetColorTexture(1, 1, 1, 1)
energyTick:SetSize(1, resourceBar:GetHeight())

function addon:UpdateEnergyTick()
    local powerType = UnitPowerType("player")
    local maxPower = UnitPowerMax("player", powerType)

    if powerType ~= Enum.PowerType.Energy or not self.db.show50Tick then
        energyTick:Hide()
        return
    end

    local maxPower = UnitPowerMax("player", Enum.PowerType.Energy)
    local tickPosition = resourceBar:GetWidth() * (50 / maxPower)
    energyTick:SetPoint("CENTER", resourceBar, "LEFT", tickPosition, 0)
    energyTick:Show()
end

-- chomp tick
local CHOMP_TALENT_ID = 1244258

local chompTick = resourceBar:CreateTexture(nil, "OVERLAY")
chompTick:SetColorTexture(1, 1, 1, 1)
chompTick:SetSize(1, resourceBar:GetHeight())

function addon:UpdateChompTick()
    local powerType = UnitPowerType("player")
    if powerType ~= Enum.PowerType.Energy or not IsPlayerSpell(CHOMP_TALENT_ID) or not self.db.showChompTick then
        chompTick:Hide()
        return
    end

    chompTick:ClearAllPoints()
    chompTick:SetPoint("CENTER", resourceBar, "LEFT", resourceBar:GetWidth() * 0.3, 0)
    chompTick:Show()
end