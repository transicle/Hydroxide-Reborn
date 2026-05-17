local WebSocketSpyUI = {}
local Methods = import("modules/WebSocketSpy")

local Base = import("rbxassetid://11389137937").Base
local Page = Base.Body.Pages:FindFirstChild("WebSocketSpy")

if not Page then return WebSocketSpyUI end

local enabled = false
local logCount = 0
local rows = {}

local function makeButton(parent, text, size, pos)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text
    btn.Parent = parent
    return btn
end

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = Page

local toggleBtn = makeButton(header, "Enable", UDim2.new(0, 70, 0, 22), UDim2.new(0, 4, 0, 3))
local clearBtn  = makeButton(header, "Clear",  UDim2.new(0, 50, 0, 22), UDim2.new(0, 78, 0, 3))

local countLbl = Instance.new("TextLabel")
countLbl.Size = UDim2.new(0, 160, 0, 22)
countLbl.Position = UDim2.new(0, 134, 0, 3)
countLbl.BackgroundTransparency = 1
countLbl.Font = Enum.Font.SourceSans
countLbl.TextSize = 13
countLbl.TextColor3 = Color3.fromRGB(180,180,180)
countLbl.TextXAlignment = Enum.TextXAlignment.Left
countLbl.Text = "0 events"
countLbl.Parent = header

local wsNote = Instance.new("TextLabel")
wsNote.Size = UDim2.new(1, -8, 0, 18)
wsNote.Position = UDim2.new(0, 4, 0, 30)
wsNote.BackgroundTransparency = 1
wsNote.Font = Enum.Font.SourceSans
wsNote.TextSize = 11
wsNote.TextColor3 = Color3.fromRGB(140,140,140)
wsNote.TextXAlignment = Enum.TextXAlignment.Left
wsNote.Text = "Requires executor WebSocket support (e.g. Synapse X)"
wsNote.Parent = Page

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -52)
scroll.Position = UDim2.new(0, 0, 0, 52)
scroll.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = Page

local ll = Instance.new("UIListLayout")
ll.SortOrder = Enum.SortOrder.LayoutOrder
ll.Padding = UDim.new(0, 1)
ll.Parent = scroll

local kindColors = {
    connect = Color3.fromRGB(80, 200, 120),
    send    = Color3.fromRGB(100, 160, 255),
    recv    = Color3.fromRGB(255, 200, 80),
    close   = Color3.fromRGB(220, 80, 80),
}

local function addRow(entry)
    logCount = logCount + 1
    countLbl.Text = logCount .. " event" .. (logCount == 1 and "" or "s")

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    row.BorderSizePixel = 0
    row.LayoutOrder = logCount
    row.Parent = scroll

    local kindLbl = Instance.new("TextLabel")
    kindLbl.Size = UDim2.new(0, 58, 0, 16)
    kindLbl.Position = UDim2.new(0, 4, 0, 2)
    kindLbl.BackgroundTransparency = 1
    kindLbl.Font = Enum.Font.SourceSansBold
    kindLbl.TextSize = 12
    kindLbl.TextColor3 = kindColors[entry.kind] or Color3.new(1,1,1)
    kindLbl.Text = entry.kind:upper()
    kindLbl.Parent = row

    local urlLbl = Instance.new("TextLabel")
    urlLbl.Size = UDim2.new(1, -66, 0, 16)
    urlLbl.Position = UDim2.new(0, 64, 0, 2)
    urlLbl.BackgroundTransparency = 1
    urlLbl.Font = Enum.Font.SourceSans
    urlLbl.TextSize = 12
    urlLbl.TextColor3 = Color3.fromRGB(200,200,200)
    urlLbl.TextXAlignment = Enum.TextXAlignment.Left
    urlLbl.TextTruncate = Enum.TextTruncate.AtEnd
    urlLbl.Text = entry.url or "?"
    urlLbl.Parent = row

    local dataLbl = Instance.new("TextLabel")
    dataLbl.Size = UDim2.new(1, -8, 0, 12)
    dataLbl.Position = UDim2.new(0, 4, 0, 17)
    dataLbl.BackgroundTransparency = 1
    dataLbl.Font = Enum.Font.SourceSans
    dataLbl.TextSize = 10
    dataLbl.TextColor3 = Color3.fromRGB(140,140,140)
    dataLbl.TextXAlignment = Enum.TextXAlignment.Left
    dataLbl.TextTruncate = Enum.TextTruncate.AtEnd
    dataLbl.Text = entry.data and tostring(entry.data):sub(1,120) or string.format("t+%.3fs", entry.clock)
    dataLbl.Parent = row

    table.insert(rows, row)
end

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    Methods.SetEnabled(enabled)
    toggleBtn.Text = enabled and "Disable" or "Enable"
    toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(40,80,40) or Color3.fromRGB(35,35,35)
end)

clearBtn.MouseButton1Click:Connect(function()
    Methods.Clear()
    for _, row in ipairs(rows) do row:Destroy() end
    rows = {}
    logCount = 0
    countLbl.Text = "0 events"
end)

Methods.ConnectEvent(addRow)

return WebSocketSpyUI
