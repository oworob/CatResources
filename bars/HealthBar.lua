local _, addon = ...

local healthBar = CreateFrame("StatusBar", nil, addon.frame)
addon.healthBar = healthBar
healthBar:SetSize(200, 30)
healthBar:SetPoint("TOPLEFT", addon.frame, "TOPLEFT")
healthBar:SetStatusBarTexture(addon.barTexture)
healthBar:SetStatusBarColor(unpack(addon.healthColor))
addon:AddBackground(healthBar)

local healthText = healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
healthText:SetPoint("LEFT", healthBar, "LEFT", 5, 0)
healthText:SetTextColor(1, 1, 1, 1)
local fontPath = healthText:GetFont()
healthText:SetFont(fontPath, 15, "OUTLINE")

local miniManaBar = CreateFrame("StatusBar", nil, addon.frame)
addon.miniManaBar = miniManaBar
miniManaBar:SetSize(200, 6)
miniManaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, 0)
miniManaBar:SetStatusBarTexture(addon.barTexture)
miniManaBar:SetStatusBarColor(unpack(addon.resourceColors[Enum.PowerType.Mana]))
addon:AddBackground(miniManaBar)

function addon:UpdateHealth()
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")

    healthBar:SetMinMaxValues(0, maxHealth)
    healthBar:SetValue(health, addon.db.smoothProgress and Enum.StatusBarInterpolation.ExponentialEaseOut or nil)

    if self.db.healthDisplay == "PERCENT" then
        healthText:SetFormattedText(
            "%.0f%%",
            UnitHealthPercent("player", true, CurveConstants.ScaleTo100)
        )
    elseif self.db.healthDisplay == "VALUE" then
        healthText:SetText(health)
    elseif self.db.healthDisplay == "VALUEMAX" then
        healthText:SetText(health .. " / " .. maxHealth)
    end
end

function addon:UpdateMiniMana()
    local primaryPowerType = UnitPowerType("player")
    local mana = UnitPower("player", 0)
    local maxMana = UnitPowerMax("player", 0)

    if primaryPowerType == 0 or not self.db.showMiniManaBar then
        miniManaBar:Hide()
        addon.healthBar:SetHeight(30)
        return
    end

    miniManaBar:Show()
    addon.healthBar:SetHeight(24)
    miniManaBar:SetMinMaxValues(0, maxMana)
    miniManaBar:SetValue(mana, addon.db.smoothProgress and Enum.StatusBarInterpolation.ExponentialEaseOut or nil)
end