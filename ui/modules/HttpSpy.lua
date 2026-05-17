local HttpSpyUI = {}
local Methods = import("modules/HttpSpy")

if not hasMethods(Methods.RequiredMethods) then
    return HttpSpyUI
end

local MessageBox, MessageType = import("ui/controls/MessageBox")
local Base = import("rbxassetid://11389137937").Base
local Page = Base.Body.Pages:FindFirstChild("HttpSpy")

if not Page then return HttpSpyUI end

local enabled = false
local logCount = 0

-- Build UI inside the page
local function makeLabel(parent, text, size, pos, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = size
    lbl.Position = pos
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextColor3 = color or Color3.new(1,1,1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = parent
    return lbl
end

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

-- Header bar
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = Page

local toggleBtn = makeButton(header, "Enable", UDim2.new(0, 70, 0, 22), UDim2.new(0, 4, 0, 3))
local clearBtn  = makeButton(header, "Clear",  UDim2.new(0, 50, 0, 22), UDim2.new(0, 78, 0, 3))
local countLbl  = makeLabel(header, "0 requests", UDim2.new(0, 160, 0, 22), UDim2.new(0, 134, 0, 3), Color3.fromRGB(180,180,180))

-- Search bar
local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(1, -8, 0, 22)
searchBar.Position = UDim2.new(0, 4, 0, 32)
searchBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
searchBar.BorderSizePixel = 0
searchBar.Font = Enum.Font.SourceSans
searchBar.TextSize = 13
searchBar.TextColor3 = Color3.new(1,1,1)
searchBar.PlaceholderText = "Filter by URL..."
searchBar.ClearTextOnFocus = false
searchBar.Text = ""
searchBar.Parent = Page

-- Scroll list
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -58)
scroll.Position = UDim2.new(0, 0, 0, 58)
scroll.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = Page

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 1)
listLayout.Parent = scroll

local methodColors = {
    GET = Color3.fromRGB(80, 200, 120),
    POST = Color3.fromRGB(255, 160, 50),
    PUT = Color3.fromRGB(100, 160, 255),
    DELETE = Color3.fromRGB(220, 80, 80),
    PATCH = Color3.fromRGB(200, 140, 255),
}

local rows = {}

local function addRow(entry)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    row.BorderSizePixel = 0
    row.LayoutOrder = logCount
    row.Parent = scroll

    local methodClr = methodColors[entry.method] or Color3.new(1,1,1)

    local methodLbl = Instance.new("TextLabel")
    methodLbl.Size = UDim2.new(0, 52, 0, 18)
    methodLbl.Position = UDim2.new(0, 4, 0, 2)
    methodLbl.BackgroundTransparency = 1
    methodLbl.Font = Enum.Font.SourceSansBold
    methodLbl.TextSize = 12
    methodLbl.TextColor3 = methodClr
    methodLbl.Text = entry.method
    methodLbl.Parent = row

    local urlLbl = Instance.new("TextLabel")
    urlLbl.Size = UDim2.new(1, -60, 0, 18)
    urlLbl.Position = UDim2.new(0, 56, 0, 2)
    urlLbl.BackgroundTransparency = 1
    urlLbl.Font = Enum.Font.SourceSans
    urlLbl.TextSize = 12
    urlLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    urlLbl.TextXAlignment = Enum.TextXAlignment.Left
    urlLbl.TextTruncate = Enum.TextTruncate.AtEnd
    urlLbl.Text = entry.url
    urlLbl.Parent = row

    local codeLbl = Instance.new("TextLabel")
    codeLbl.Size = UDim2.new(0, 40, 0, 14)
    codeLbl.Position = UDim2.new(0, 4, 0, 20)
    codeLbl.BackgroundTransparency = 1
    codeLbl.Font = Enum.Font.SourceSansBold
    codeLbl.TextSize = 11
    codeLbl.TextColor3 = (entry.responseCode >= 200 and entry.responseCode < 300)
        and Color3.fromRGB(80,200,120) or Color3.fromRGB(220,80,80)
    codeLbl.Text = tostring(entry.responseCode)
    codeLbl.Parent = row

    local timeLbl = Instance.new("TextLabel")
    timeLbl.Size = UDim2.new(1, -48, 0, 14)
    timeLbl.Position = UDim2.new(0, 48, 0, 20)
    timeLbl.BackgroundTransparency = 1
    timeLbl.Font = Enum.Font.SourceSans
    timeLbl.TextSize = 11
    timeLbl.TextColor3 = Color3.fromRGB(120, 180, 120)
    timeLbl.TextXAlignment = Enum.TextXAlignment.Left
    timeLbl.Text = string.format("t+%.3fs", entry.clock)
    timeLbl.Parent = row

    -- Right-click to copy URL
    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            if setClipboard then setClipboard(entry.url) end
        end
    end)

    row._entry = entry
    table.insert(rows, row)
    return row
end

local function applyFilter()
    local q = searchBar.Text:lower()
    for _, row in ipairs(rows) do
        local url = row._entry and row._entry.url:lower() or ""
        row.Visible = q == "" or url:find(q, 1, true) ~= nil
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    Methods.SetEnabled(enabled)
    toggleBtn.Text = enabled and "Disable" or "Enable"
    toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(40,80,40) or Color3.fromRGB(35,35,35)
    oh.setStatus(enabled and "HttpSpy: monitoring" or "HttpSpy: idle")
end)

clearBtn.MouseButton1Click:Connect(function()
    Methods.Clear()
    for _, row in ipairs(rows) do row:Destroy() end
    rows = {}
    logCount = 0
    countLbl.Text = "0 requests"
end)

local searchTask2 = nil
searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    if searchTask2 then task.cancel(searchTask2) end
    searchTask2 = task.delay(0.15, applyFilter)
end)

Methods.ConnectEvent(function(entry)
    logCount = logCount + 1
    countLbl.Text = logCount .. " request" .. (logCount == 1 and "" or "s")
    addRow(entry)
    applyFilter()
end)

return HttpSpyUI
