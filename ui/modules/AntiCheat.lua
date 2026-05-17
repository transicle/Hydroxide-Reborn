local AntiCheatUI = {}
local Methods = import("modules/AntiCheat")

local Base = import("rbxassetid://11389137937").Base
local Page = Base.Body.Pages:FindFirstChild("AntiCheat")

if not Page then return AntiCheatUI end

local data = Methods.Data

-- Status banner
local banner = Instance.new("Frame")
banner.Size = UDim2.new(1, 0, 0, 48)
banner.BackgroundColor3 = data.Disabled
    and Color3.fromRGB(30, 70, 30)
    or  Color3.fromRGB(70, 30, 30)
banner.BorderSizePixel = 0
banner.Parent = Page

local statusIcon = Instance.new("TextLabel")
statusIcon.Size = UDim2.new(0, 28, 0, 28)
statusIcon.Position = UDim2.new(0, 8, 0, 10)
statusIcon.BackgroundTransparency = 1
statusIcon.Font = Enum.Font.SourceSansBold
statusIcon.TextSize = 22
statusIcon.TextColor3 = data.Disabled and Color3.fromRGB(80,220,80) or Color3.fromRGB(220,80,80)
statusIcon.Text = data.Disabled and "✓" or "✗"
statusIcon.Parent = banner

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -48, 0, 24)
statusLbl.Position = UDim2.new(0, 40, 0, 4)
statusLbl.BackgroundTransparency = 1
statusLbl.Font = Enum.Font.SourceSansBold
statusLbl.TextSize = 15
statusLbl.TextColor3 = Color3.new(1,1,1)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Text = data.Disabled
    and ("Anticheat Bypassed: " .. data.Name)
    or  "No Anticheat Detected"
statusLbl.Parent = banner

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1, -48, 0, 16)
subLbl.Position = UDim2.new(0, 40, 0, 26)
subLbl.BackgroundTransparency = 1
subLbl.Font = Enum.Font.SourceSans
subLbl.TextSize = 12
subLbl.TextColor3 = Color3.fromRGB(180,180,180)
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.Text = data.Disabled
    and "Detection threads closed and detection functions hooked."
    or  "Bypass runs automatically when a supported anticheat is detected."
subLbl.Parent = banner

-- Bypass list header
local listHeader = Instance.new("TextLabel")
listHeader.Size = UDim2.new(1, -8, 0, 20)
listHeader.Position = UDim2.new(0, 4, 0, 52)
listHeader.BackgroundTransparency = 1
listHeader.Font = Enum.Font.SourceSansBold
listHeader.TextSize = 13
listHeader.TextColor3 = Color3.fromRGB(160,160,160)
listHeader.TextXAlignment = Enum.TextXAlignment.Left
listHeader.Text = "Registered Bypasses"
listHeader.Parent = Page

-- List all registered bypasses
local allBypasses = {}
for _, b in ipairs(Methods.Bypasses) do table.insert(allBypasses, b) end
if Methods.DedicatedBypass then table.insert(allBypasses, Methods.DedicatedBypass) end

local yOff = 76
for _, bypass in ipairs(allBypasses) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 32)
    row.Position = UDim2.new(0, 4, 0, yOff)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    row.BorderSizePixel = 0
    row.Parent = Page

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0, 120, 0, 20)
    nameLbl.Position = UDim2.new(0, 6, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.SourceSansBold
    nameLbl.TextSize = 13
    nameLbl.TextColor3 = Color3.new(1,1,1)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Text = bypass.Name or "Unknown"
    nameLbl.Parent = row

    local scopeLbl = Instance.new("TextLabel")
    scopeLbl.Size = UDim2.new(0, 80, 0, 20)
    scopeLbl.Position = UDim2.new(0, 130, 0, 6)
    scopeLbl.BackgroundTransparency = 1
    scopeLbl.Font = Enum.Font.SourceSans
    scopeLbl.TextSize = 12
    scopeLbl.TextColor3 = Color3.fromRGB(140,140,140)
    scopeLbl.TextXAlignment = Enum.TextXAlignment.Left
    scopeLbl.Text = "Game: " .. tostring(bypass.Game)
    scopeLbl.Parent = row

    local activeLbl = Instance.new("TextLabel")
    activeLbl.Size = UDim2.new(0, 60, 0, 20)
    activeLbl.Position = UDim2.new(1, -64, 0, 6)
    activeLbl.BackgroundTransparency = 1
    activeLbl.Font = Enum.Font.SourceSansBold
    activeLbl.TextSize = 12
    activeLbl.TextColor3 = (data.Disabled and data.Name == bypass.Name)
        and Color3.fromRGB(80,220,80) or Color3.fromRGB(140,140,140)
    activeLbl.Text = (data.Disabled and data.Name == bypass.Name) and "ACTIVE" or "STANDBY"
    activeLbl.Parent = row

    yOff = yOff + 36
end

return AntiCheatUI
