local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Interface = import("rbxassetid://11389137937")

if oh.Cache["ui/main"] then
	return Interface
end

-- Change title from "Hydroxide c.1" to "[REBORN] Hydroxide c.2"
for _, desc in ipairs(Interface:GetDescendants()) do
	if desc:IsA("TextLabel") or desc:IsA("TextButton") then
		if desc.Text:find("Hydroxide") then
			desc.Text = desc.Text:gsub("Hydroxide c%.1", "[REBORN] Hydroxide c.2")
								   :gsub("^Hydroxide$", "[REBORN] Hydroxide c.2")
		end
	end
end

-- Create new tabs and blank pages BEFORE TabSelector initialises its click handlers
do
	local Tabs  = Interface.Base.Tabs.Container
	local Pages = Interface.Base.Body.Pages

	local function addTab(name, iconId)
		if Tabs:FindFirstChild(name) then return end
		local template = Tabs:FindFirstChildWhichIsA("ImageButton")
		if not template then return end
		local btn = template:Clone()
		btn.Name = name
		btn.Icon.Image = iconId
		btn.ImageColor3 = Color3.fromRGB(20, 20, 20)
		btn.Icon.ImageColor3 = Color3.fromRGB(127, 127, 127)
		btn.Parent = Tabs
	end

	local function addPage(name)
		if Pages:FindFirstChild(name) then return end
		local page = Instance.new("Frame")
		page.Name = name
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.Parent = Pages
	end

	-- Explorer: script-like icon; HttpSpy: cloud icon; WebSocketSpy: function icon
	addTab("Explorer",      "rbxassetid://4800244808")
	addTab("HttpSpy",       "rbxassetid://7072706620")
	addTab("WebSocketSpy",  "rbxassetid://4666593447")

	addPage("Explorer")
	addPage("HttpSpy")
	addPage("WebSocketSpy")

	-- Convert sidebar tab container to ScrollingFrame so all tabs are reachable
	local sf = Instance.new("ScrollingFrame")
	sf.Name                = Tabs.Name
	sf.Size                = Tabs.Size
	sf.Position            = Tabs.Position
	sf.BackgroundColor3    = Tabs.BackgroundColor3
	sf.BackgroundTransparency = Tabs.BackgroundTransparency
	sf.BorderSizePixel     = 0
	sf.ScrollBarThickness  = 2
	sf.ScrollingDirection  = Enum.ScrollingDirection.Y
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.CanvasSize          = UDim2.new(0, 0, 0, 0)
	sf.Parent              = Tabs.Parent

	for _, child in ipairs(Tabs:GetChildren()) do
		child.Parent = sf
	end
	Tabs:Destroy()
end

import("ui/controls/TabSelector")
local MessageBox, MessageType = import("ui/controls/MessageBox")

local RemoteSpy
local ClosureSpy
local ScriptScanner
local ModuleScanner
local UpvalueScanner
local ConstantScanner
local ExplorerUI
local HttpSpyUI
local WebSocketSpyUI
xpcall(function()
	RemoteSpy = import("ui/modules/RemoteSpy")
	ClosureSpy = import("ui/modules/ClosureSpy")
	ScriptScanner = import("ui/modules/ScriptScanner")
	ModuleScanner = import("ui/modules/ModuleScanner")
	UpvalueScanner = import("ui/modules/UpvalueScanner")
	ConstantScanner = import("ui/modules/ConstantScanner")
	ExplorerUI = import("ui/modules/Explorer")
	HttpSpyUI = import("ui/modules/HttpSpy")
	WebSocketSpyUI = import("ui/modules/WebSocketSpy")
end, function(err)
	local message
	if err:find("valid member") then
		message = "The UI has updated, please rejoin and restart. If you get this message more than once, screenshot this message and report it in the Hydroxide server.\n\n" .. err
	else
		message = "Report this error in Hydroxide's server:\n\n" .. err
	end

	MessageBox.Show("An error has occurred", message, MessageType.OK, function()
		Interface:Destroy() 
	end)
end)

local constants = {
	opened = UDim2.new(0.5, -325, 0.5, -175),
	closed = UDim2.new(0.5, -325, 0, -400),
	reveal = UDim2.new(0.5, -15, 0, 20),
	conceal = UDim2.new(0.5, -15, 0, -75)
}

local Open = Interface.Open
local Base = Interface.Base
local Drag = Base.Drag
local Status = Base.Status
local Collapse = Drag.Collapse

function oh.setStatus(text)
	Status.Text = '• Status: ' .. text
end

function oh.getStatus()
	return Status.Text:gsub('• Status: ', '')
end

local dragging
local dragStart
local startPos

Drag.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local dragEnded 

		dragging = true
		dragStart = input.Position
		startPos = Base.Position

		dragEnded = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				dragEnded:Disconnect()
			end
		end)
	end
end)

oh.Events.Drag = UserInput.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		local delta = input.Position - dragStart
		Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

Open.MouseButton1Click:Connect(function()
	Open:TweenPosition(constants.conceal, "Out", "Quad", 0.15)
	Base:TweenPosition(constants.opened, "Out", "Quad", 0.15)
end)

Collapse.MouseButton1Click:Connect(function()
	Base:TweenPosition(constants.closed, "Out", "Quad", 0.15)
	Open:TweenPosition(constants.reveal, "Out", "Quad", 0.15)
end)

Interface.Name = HttpService:GenerateGUID(false)
if getHui then
	Interface.Parent = getHui()
else
	if protectgui then
		protectgui(Interface)
	elseif gethui then
		Interface.Parent = gethui()
	end

	Interface.Parent = CoreGui
end

return Interface
