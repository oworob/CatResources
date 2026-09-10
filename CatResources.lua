local addonName, addon = ...

-- load settings

local defaults = {
    visibility = "ALWAYS",
    smoothProgress = true,
    healthDisplay = "PERCENT",
    showMiniManaBar = false,
    show50Tick = true,
    showChompTick = true,
    showOverflowingPower = true,
}

local defaultPosition = {
    point = "CENTER",
    x = 0,
    y = 200,
}

addon.barTexture = "Interface\\AddOns\\" .. addonName .. "\\textures\\Atrocity"
addon.healthColor = {0.95, 0.2, 0.2, 1}
addon.resourceColors = {
    [Enum.PowerType.Mana] = {0.2, 0.35, 1, 1},
    [Enum.PowerType.Energy] = {1, 0.741, 0.231, 1},
    [Enum.PowerType.ComboPoints] = {1, 0.12, 0.13, 1},
    [Enum.PowerType.Rage] = {1, 0.2, 0.2, 1}
}

addon.frame = CreateFrame("Frame", "CatResourcesFrame", UIParent)
addon.frame:SetSize(400, 61)

local function Initialize()
    CatResourcesDB = CatResourcesDB or {}
     for key, defaultValue in pairs(defaults) do
        if CatResourcesDB[key] == nil then
            CatResourcesDB[key] = defaultValue
        end
    end
    addon.db = CatResourcesDB

    -- Edit mode
    local EditMode = LibStub("LibEQOLEditMode-1.0")
    addon.frame.editModeName = "CatResources"

    addon.db.position = addon.db.position or defaultPosition

    EditMode:AddFrame(addon.frame,
        function(frame, layoutName, point, x, y)
            frame:ClearAllPoints()
            frame:SetPoint(point, UIParent, point, x, y)
            addon.db.position.point = point
            addon.db.position.x = x
            addon.db.position.y = y
        end,
        defaultPosition
    )

    addon.frame:ClearAllPoints()
    addon.frame:SetPoint(
        addon.db.position.point,
        UIParent,
        addon.db.position.point,
        addon.db.position.x,
        addon.db.position.y
    )

    EditMode:AddFrameSettings(addon.frame, {
        {
            name = "Display",
            kind = EditMode.SettingType.Dropdown,
            default = defaults.visibility,
            values = {
                { text = "Always", value = "ALWAYS" },
                { text = "In Combat", value = "COMBAT" },
            },
            get = function()
                return addon.db.visibility
            end,
            set = function(_, value)
                addon.db.visibility = value
                addon:UpdateVisibility()
            end,
        },
        {
            name = "Health Display",
            kind = EditMode.SettingType.Dropdown,
            default = defaults.healthDisplay,
            values = {
                { text = "Percent", value = "PERCENT" },
                { text = "Value", value = "VALUE" },
                { text = "Value / Max", value = "VALUEMAX" },
            },

            get = function(layoutName)
                return addon.db.healthDisplay
            end,
            set = function(layoutName, value)
                addon.db.healthDisplay = value
                addon:UpdateHealth()
            end,
        },
        {
            name = "Show Mini Mana Bar",
            kind = EditMode.SettingType.Checkbox,
            default = defaults.showMiniManaBar,
            get = function(layoutName)
                return addon.db.showMiniManaBar
            end,
            set = function(layoutName, value)
                addon.db.showMiniManaBar = value
                addon:UpdateMiniMana()
            end,
        },
        {
            name = "Show 50 Energy Tick",
            kind = EditMode.SettingType.Checkbox,
            default = defaults.show50Tick,
            get = function(layoutName)
                return addon.db.show50Tick
            end,
            set = function(layoutName, value)
                addon.db.show50Tick = value
                addon:UpdateEnergyTick()
            end,
        },
        {
            name = "Show Chomp Tick",
            kind = EditMode.SettingType.Checkbox,
            default = defaults.showChompTick,
            get = function(layoutName)
                return addon.db.showChompTick
            end,
            set = function(layoutName, value)
                addon.db.showChompTick = value
                addon:UpdateChompTick()
            end,
        },
        {
            name = "Show Overflowing Power Bar",
            kind = EditMode.SettingType.Checkbox,
            default = defaults.showOverflowingPower,
            get = function(layoutName)
                return addon.db.showOverflowingPower
            end,
            set = function(layoutName, value)
                addon.db.showOverflowingPower = value
                addon:UpdateComboPoints()
            end,
        },
        {
            name = "Smooth Progress",
            kind = EditMode.SettingType.Checkbox,
            default = defaults.smoothProgress,
            get = function(layoutName)
                return addon.db.smoothProgress
            end,
            set = function(layoutName, value)
                addon.db.smoothProgress = value
            end,
        },
    })

    addon.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    addon.frame:RegisterEvent("UNIT_HEALTH")
    addon.frame:RegisterEvent("UNIT_MAXHEALTH")
    addon.frame:RegisterEvent("UNIT_POWER_UPDATE")
    addon.frame:RegisterEvent("UNIT_POWER_FREQUENT")
    addon.frame:RegisterEvent("UNIT_DISPLAYPOWER")
    addon.frame:RegisterEvent("UNIT_MAXPOWER")
    addon.frame:RegisterUnitEvent("UNIT_AURA", "player")
    addon.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    addon.frame:RegisterEvent("PLAYER_REGEN_DISABLED")

    addon.frame:SetScript("OnEvent", function(self, event, unit)
        if event == "PLAYER_REGEN_DISABLED" then
            if addon.db.visibility == "COMBAT" then
                addon.frame:Show()
            end
            return
        end

        if event == "PLAYER_REGEN_ENABLED" then
            if addon.db.visibility == "COMBAT" then
                addon.frame:Hide()
            end
            return
        end

        if event ~= "PLAYER_ENTERING_WORLD" and unit ~= "player" then
            return
        end

        if event == "PLAYER_ENTERING_WORLD" then
            addon:UpdateVisibility()
            addon:UpdateHealth()
            addon:UpdateResource()
            addon:UpdateResourceColor()
            addon:UpdateEnergyTick()
            addon:UpdateChompTick()
            addon:UpdateMiniMana()
            addon:UpdateComboPoints()

        elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
            addon:UpdateHealth()

        elseif event == "UNIT_DISPLAYPOWER" then
            addon:UpdateResource()
            addon:UpdateEnergyTick()
            addon:UpdateChompTick()
            addon:UpdateMiniMana()
            addon:UpdateResourceColor()
            addon:ToggleComboPointBar()

        elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
            addon:UpdateResource()
            if addon.db.showMiniManaBar then
                addon:UpdateMiniMana()
            end
            if UnitPowerType("player") == Enum.PowerType.Energy then
                addon:UpdateComboPoints()
            end

        elseif event == "UNIT_AURA" then -- berserk bar
            addon:UpdateComboPoints()
        end
    end)
end

function addon:UpdateVisibility()
    local inEditMode = EditModeManagerFrame and EditModeManagerFrame:IsShown()
    if inEditMode then
        addon.frame:Show()
    elseif addon.db.visibility == "COMBAT" then
        addon.frame:Hide()
    else
        addon.frame:Show()
    end
end

addon.frame:RegisterEvent("ADDON_LOADED")

addon.frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == addonName then
        self:UnregisterEvent("ADDON_LOADED")
        Initialize()
    end
end)

if EditModeManagerFrame then
    EditModeManagerFrame:HookScript("OnShow", function()
        addon:UpdateVisibility()
    end)
    EditModeManagerFrame:HookScript("OnHide", function()
        addon:UpdateVisibility()
    end)
end