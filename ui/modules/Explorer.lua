local Explorer = {}
local Methods = import("modules/Explorer")

local Base = import("rbxassetid://11389137937").Base
local Page = Base.Body.Pages:FindFirstChild("Explorer")

if not Page then return Explorer end

local expanded = {}
local rowCount = 0

-- Scroll area
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -30)
scroll.Position = UDim2.new(0, 0, 0, 30)
scroll.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = Page

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 0)
listLayout.Parent = scroll

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = Page

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 70, 0, 22)
refreshBtn.Position = UDim2.new(0, 4, 0, 3)
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
refreshBtn.BorderSizePixel = 0
refreshBtn.Font = Enum.Font.SourceSansBold
refreshBtn.TextSize = 13
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.Text = "Refresh"
refreshBtn.Parent = header

local pathLbl = Instance.new("TextLabel")
pathLbl.Size = UDim2.new(1, -84, 0, 22)
pathLbl.Position = UDim2.new(0, 82, 0, 3)
pathLbl.BackgroundTransparency = 1
pathLbl.Font = Enum.Font.SourceSans
pathLbl.TextSize = 12
pathLbl.TextColor3 = Color3.fromRGB(140,140,140)
pathLbl.TextXAlignment = Enum.TextXAlignment.Left
pathLbl.TextTruncate = Enum.TextTruncate.AtEnd
pathLbl.Text = "Click an instance to copy its path"
pathLbl.Parent = header

local classColors = {
    Workspace         = Color3.fromRGB(100, 200, 255),
    LocalScript       = Color3.fromRGB(80, 200, 120),
    Script            = Color3.fromRGB(80, 200, 120),
    ModuleScript      = Color3.fromRGB(200, 200, 80),
    RemoteEvent       = Color3.fromRGB(255, 160, 80),
    RemoteFunction    = Color3.fromRGB(255, 140, 60),
    BindableEvent     = Color3.fromRGB(200, 130, 200),
    BindableFunction  = Color3.fromRGB(180, 110, 180),
    Frame             = Color3.fromRGB(180, 180, 200),
    ScreenGui         = Color3.fromRGB(160, 160, 220),
    Part              = Color3.fromRGB(160, 200, 160),
    Model             = Color3.fromRGB(220, 180, 120),
    Folder            = Color3.fromRGB(180, 160, 100),
}

local function getColor(className)
    return classColors[className] or Color3.fromRGB(200,200,200)
end

local function clearList()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    rowCount = 0
    expanded = {}
end

local function addRow(instance, depth, after)
    rowCount = rowCount + 1
    local order = rowCount

    local row = Instance.new("Frame")
    row.Name = tostring(instance)
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundColor3 = (depth % 2 == 0) and Color3.fromRGB(22,22,22) or Color3.fromRGB(26,26,26)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = scroll
    row._instance = instance
    row._depth = depth

    local indent = depth * 12

    local children = Methods.GetChildren(instance)
    local hasChildren = #children > 0

    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0, 14, 0, 14)
    expandBtn.Position = UDim2.new(0, indent + 2, 0, 4)
    expandBtn.BackgroundTransparency = 1
    expandBtn.Font = Enum.Font.SourceSansBold
    expandBtn.TextSize = 12
    expandBtn.TextColor3 = Color3.fromRGB(160,160,160)
    expandBtn.Text = hasChildren and "▶" or " "
    expandBtn.Parent = row

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -(indent + 20), 0, 22)
    nameLbl.Position = UDim2.new(0, indent + 18, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.SourceSans
    nameLbl.TextSize = 13
    nameLbl.TextColor3 = getColor(instance.ClassName)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Text = instance.Name .. "  [" .. instance.ClassName .. "]"
    nameLbl.Parent = row

    -- Click to copy path
    nameLbl.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local path = getInstancePath(instance)
            pathLbl.Text = path
            if setClipboard then setClipboard(path) end
        end
    end)

    if not hasChildren then return row end

    -- Expand/collapse
    local isExpanded = false
    local childRows = {}

    expandBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        expandBtn.Text = isExpanded and "▼" or "▶"

        if isExpanded then
            local insertAfter = row.LayoutOrder
            for _, child in ipairs(children) do
                local childRow = addRow(child, depth + 1)
                childRow.LayoutOrder = insertAfter + 0.001
                insertAfter = childRow.LayoutOrder
                table.insert(childRows, childRow)
            end
        else
            for _, r in ipairs(childRows) do
                r:Destroy()
            end
            childRows = {}
        end
    end)

    return row
end

local function buildTree()
    clearList()
    local services = Methods.GetServices()
    for _, service in ipairs(services) do
        addRow(service, 0)
    end
end

refreshBtn.MouseButton1Click:Connect(buildTree)
buildTree()

return Explorer
