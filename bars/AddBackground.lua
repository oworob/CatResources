local _, addon = ...

function addon:AddBackground(bar)
    local background = bar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.05, 0.05, 0.05, 0.6)

    return background
end