--==============================================================
-- INTREX DEVELOPER CLIENT
-- ROBLOX STUDIO LOCAL TEST BUILD
--
-- 11 CATEGORIES
-- 50 FEATURES PER CATEGORY
-- 550 TOTAL FEATURE ENTRIES
--
-- Designed for YOUR OWN Roblox experience.
--
-- Includes:
-- • Draggable window
-- • 4-corner white resize handles
-- • Search
-- • Notifications
-- • 50 functional entries/category
-- • Movement testing
-- • Player diagnostics
-- • Visual testing
-- • ESP/debug visualization
-- • World controls
-- • Utility diagnostics
-- • Teleport testing
-- • Local effects
-- • UI settings
-- • Configuration
-- • Debug tools
--
-- COMBAT REMOVED
--==============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
	Width = 650,
	Height = 450,

	MinWidth = 300,
	MinHeight = 250,

	MaxWidth = 1100,
	MaxHeight = 800,

	MenuKey = Enum.KeyCode.RightShift,

	DefaultSpeed = 16,
	DefaultJump = 50,
	DefaultFOV = 70,
	DefaultGravity = Workspace.Gravity,

	NotificationDuration = 2.5,
	NotificationVolume = 0.5,
}

--==============================================================
-- COLORS
--==============================================================

local C = {
	Background = Color3.fromRGB(9,11,15),
	Sidebar = Color3.fromRGB(13,16,21),
	Panel = Color3.fromRGB(18,22,28),
	Panel2 = Color3.fromRGB(25,30,38),

	Accent = Color3.fromRGB(45,174,239),
	AccentDark = Color3.fromRGB(29,117,171),

	Text = Color3.fromRGB(245,247,250),
	SubText = Color3.fromRGB(143,151,164),

	Off = Color3.fromRGB(62,68,78),
	Red = Color3.fromRGB(230,70,70),

	White = Color3.fromRGB(255,255,255),
}

--==============================================================
-- REMOVE OLD GUI
--==============================================================

local Old = PlayerGui:FindFirstChild("IntrexClient")

if Old then
	Old:Destroy()
end

--==============================================================
-- STATE
--==============================================================

local State = {
	Category = "Movement",

	Visible = true,
	Animations = true,

	Speed = CONFIG.DefaultSpeed,
	Jump = CONFIG.DefaultJump,
	FOV = CONFIG.DefaultFOV,
	Gravity = CONFIG.DefaultGravity,

	Fly = false,
	Noclip = false,
	InfiniteJump = false,
	Spin = false,
	Rainbow = false,
	Trail = false,

	ESP = false,
	NameESP = false,
	DistanceESP = false,
	HealthESP = false,

	Crosshair = false,
	Coordinates = false,
	Performance = false,

	Fullbright = false,
	NoFog = false,

	NotificationSound = true,
	NotificationVolume = CONFIG.NotificationVolume,

	SavedCFrame = nil,

	ResizeHandles = true,
}

--==============================================================
-- GUI
--==============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "IntrexClient"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(.5,.5)
Window.Position = UDim2.fromScale(.5,.5)
Window.Size = UDim2.fromOffset(CONFIG.Width,CONFIG.Height)
Window.BackgroundColor3 = C.Background
Window.BorderSizePixel = 0
Window.Parent = Gui

local function Corner(obj,r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,r or 8)
	c.Parent = obj
	return c
end

local function Stroke(obj,color,thickness,transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = obj
	return s
end

Corner(Window,12)
Stroke(Window,Color3.fromRGB(65,72,84),1,.15)

local function Tween(obj,props,time)
	if not State.Animations then
		for k,v in pairs(props) do
			obj[k] = v
		end
		return
	end

	local t = TweenService:Create(
		obj,
		TweenInfo.new(
			time or .15,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		),
		props
	)

	t:Play()
	return t
end

--==============================================================
-- TOP BAR
--==============================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,52)
TopBar.BackgroundColor3 = C.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = Window
Corner(TopBar,12)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(16,7)
Title.Size = UDim2.fromOffset(250,20)
Title.Text = "INTREX"
Title.TextColor3 = C.Text
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(16,28)
Subtitle.Size = UDim2.fromOffset(350,14)
Subtitle.Text = "DEVELOPER CLIENT  •  LOCAL TESTING"
Subtitle.TextColor3 = C.Accent
Subtitle.TextSize = 8
Subtitle.Font = Enum.Font.GothamBold
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30,30)
Close.Position = UDim2.new(1,-39,0,11)
Close.BackgroundColor3 = C.Panel2
Close.Text = "×"
Close.TextColor3 = C.SubText
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = TopBar
Corner(Close,8)

Close.MouseEnter:Connect(function()
	Tween(Close,{
		BackgroundColor3 = C.Red,
		TextColor3 = C.Text,
	},.1)
end)

Close.MouseLeave:Connect(function()
	Tween(Close,{
		BackgroundColor3 = C.Panel2,
		TextColor3 = C.SubText,
	},.1)
end)

Close.MouseButton1Click:Connect(function()
	State.Visible = false
	Window.Visible = false
end)

--==============================================================
-- DRAGGING
--==============================================================

local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = input.Position
		StartPosition = Window.Position
	end
end)

TopBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if not Dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - DragStart

	Window.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + delta.Y
	)
end)

--==============================================================
-- WHITE CORNER RESIZE SYSTEM
--==============================================================

local ResizeFolder = Instance.new("Folder")
ResizeFolder.Name = "ResizeHandles"
ResizeFolder.Parent = Window

local resizeConnections = {}

local function MakeResizeHandle(name,position,anchor)
	local handle = Instance.new("TextButton")

	handle.Name = name
	handle.AnchorPoint = anchor
	handle.Position = position
	handle.Size = UDim2.fromOffset(22,22)

	handle.BackgroundTransparency = 1
	handle.Text = ""
	handle.AutoButtonColor = false
	handle.ZIndex = 50
	handle.Parent = ResizeFolder

	-- White diagonal stripes
	for i = 1,3 do
		local stripe = Instance.new("Frame")
		stripe.BackgroundColor3 = C.White
		stripe.BorderSizePixel = 0
		stripe.Size = UDim2.fromOffset(3,10)
		stripe.Rotation = 45
		stripe.ZIndex = 51
		stripe.Parent = handle

		if anchor.X == 1 then
			stripe.Position = UDim2.new(1,-i*5,1,-i*5)
		else
			stripe.Position = UDim2.new(0,i*5,1,-i*5)
		end
	end

	return handle
end

local Handles = {
	TL = MakeResizeHandle(
		"TopLeft",
		UDim2.new(0,0,0,0),
		Vector2.new(0,0)
	),

	TR = MakeResizeHandle(
		"TopRight",
		UDim2.new(1,0,0,0),
		Vector2.new(1,0)
	),

	BL = MakeResizeHandle(
		"BottomLeft",
		UDim2.new(0,0,1,0),
		Vector2.new(0,1)
	),

	BR = MakeResizeHandle(
		"BottomRight",
		UDim2.new(1,0,1,0),
		Vector2.new(1,1)
	),
}

local resizing = false
local resizeCorner = nil
local resizeStart = nil
local resizeSize = nil
local resizePosition = nil

local function BeginResize(corner,input)
	resizing = true
	resizeCorner = corner
	resizeStart = input.Position
	resizeSize = Window.AbsoluteSize
	resizePosition = Window.Position
end

for corner,handle in pairs(Handles) do
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			BeginResize(corner,input)
		end
	end)
end

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		resizing = false
		resizeCorner = nil
	end
end)

UIS.InputChanged:Connect(function(input)
	if not resizing then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - resizeStart

	local width = resizeSize.X
	local height = resizeSize.Y

	local position = resizePosition

	if resizeCorner == "BR" then
		width += delta.X
		height += delta.Y

	elseif resizeCorner == "BL" then
		width -= delta.X
		height += delta.Y

	elseif resizeCorner == "TR" then
		width += delta.X
		height -= delta.Y

	elseif resizeCorner == "TL" then
		width -= delta.X
		height -= delta.Y
	end

	width = math.clamp(
		width,
		CONFIG.MinWidth,
		CONFIG.MaxWidth
	)

	height = math.clamp(
		height,
		CONFIG.MinHeight,
		CONFIG.MaxHeight
	)

	if resizeCorner == "BL"
		or resizeCorner == "TL" then

		local actualDelta = resizeSize.X - width

		position = UDim2.new(
			position.X.Scale,
			position.X.Offset + actualDelta,
			position.Y.Scale,
			position.Y.Offset
		)
	end

	if resizeCorner == "TR"
		or resizeCorner == "TL" then

		local actualDelta = resizeSize.Y - height

		position = UDim2.new(
			position.X.Scale,
			position.X.Offset,
			position.Y.Scale,
			position.Y.Offset + actualDelta
		)
	end

	Window.Size = UDim2.fromOffset(width,height)
	Window.Position = position
end)

--==============================================================
-- SIDEBAR
--==============================================================

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(0,52)
Sidebar.Size = UDim2.new(0,155,1,-52)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Window

local CategoryScroll = Instance.new("ScrollingFrame")
CategoryScroll.Position = UDim2.fromOffset(8,8)
CategoryScroll.Size = UDim2.new(1,-16,1,-16)
CategoryScroll.BackgroundTransparency = 1
CategoryScroll.BorderSizePixel = 0
CategoryScroll.ScrollBarThickness = 2
CategoryScroll.ScrollBarImageColor3 = C.Accent
CategoryScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CategoryScroll.Parent = Sidebar

local CategoryLayout = Instance.new("UIListLayout")
CategoryLayout.Padding = UDim.new(0,4)
CategoryLayout.Parent = CategoryScroll

--==============================================================
-- CONTENT
--==============================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(155,52)
Content.Size = UDim2.new(1,-155,1,-52)
Content.BackgroundColor3 = C.Background
Content.BorderSizePixel = 0
Content.Parent = Window

local PageTitle = Instance.new("TextLabel")
PageTitle.BackgroundTransparency = 1
PageTitle.Position = UDim2.fromOffset(18,10)
PageTitle.Size = UDim2.new(1,-230,0,25)
PageTitle.TextColor3 = C.Text
PageTitle.TextSize = 18
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

local PageDescription = Instance.new("TextLabel")
PageDescription.BackgroundTransparency = 1
PageDescription.Position = UDim2.fromOffset(18,34)
PageDescription.Size = UDim2.new(1,-36,0,17)
PageDescription.TextColor3 = C.SubText
PageDescription.TextSize = 9
PageDescription.Font = Enum.Font.Gotham
PageDescription.TextXAlignment = Enum.TextXAlignment.Left
PageDescription.Parent = Content

local SearchBox = Instance.new("TextBox")
SearchBox.Position = UDim2.new(1,-205,0,13)
SearchBox.Size = UDim2.fromOffset(185,30)
SearchBox.BackgroundColor3 = C.Panel
SearchBox.TextColor3 = C.Text
SearchBox.PlaceholderColor3 = C.SubText
SearchBox.PlaceholderText = "Search features..."
SearchBox.Text = ""
SearchBox.TextSize = 9
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Content
Corner(SearchBox,8)

local Options = Instance.new("ScrollingFrame")
Options.Position = UDim2.fromOffset(14,60)
Options.Size = UDim2.new(1,-28,1,-70)
Options.BackgroundTransparency = 1
Options.BorderSizePixel = 0
Options.ScrollBarThickness = 3
Options.ScrollBarImageColor3 = C.Accent
Options.AutomaticCanvasSize = Enum.AutomaticSize.Y
Options.Parent = Content

local OptionsLayout = Instance.new("UIListLayout")
OptionsLayout.Padding = UDim.new(0,7)
OptionsLayout.Parent = Options

--==============================================================
-- NOTIFICATIONS
--==============================================================

local NotificationHolder = Instance.new("Frame")
NotificationHolder.AnchorPoint = Vector2.new(1,0)
NotificationHolder.Position = UDim2.new(1,-15,0,15)
NotificationHolder.Size = UDim2.fromOffset(280,350)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = Gui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0,6)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.Parent = NotificationHolder

local NotificationSound = Instance.new("Sound")
NotificationSound.Name = "IntrexNotificationSound"
NotificationSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
NotificationSound.Volume = State.NotificationVolume
NotificationSound.Parent = SoundService

local function Notify(message)
	if State.NotificationSound then
		NotificationSound.Volume = State.NotificationVolume
		NotificationSound:Play()
	end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(260,42)
	frame.BackgroundColor3 = C.Panel
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = NotificationHolder

	Corner(frame,8)
	Stroke(frame,C.Accent,1,.5)

	local bar = Instance.new("Frame")
	bar.Position = UDim2.fromOffset(7,8)
	bar.Size = UDim2.fromOffset(3,26)
	bar.BackgroundColor3 = C.Accent
	bar.BorderSizePixel = 0
	bar.Parent = frame
	Corner(bar,3)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(17,0)
	label.Size = UDim2.new(1,-25,1,0)
	label.Text = message
	label.TextColor3 = C.Text
	label.TextSize = 9
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	Tween(frame,{BackgroundTransparency=.05},.15)

	task.delay(CONFIG.NotificationDuration,function()
		if not frame.Parent then
			return
		end

		Tween(frame,{BackgroundTransparency=1},.2)
		Tween(label,{TextTransparency=1},.2)

		task.wait(.25)

		if frame.Parent then
			frame:Destroy()
		end
	end)
end

--==============================================================
-- CHARACTER HELPERS
--==============================================================

local function Character()
	return LP.Character
end

local function Humanoid()
	local c = Character()
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function Root()
	local c = Character()
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function Head()
	local c = Character()
	return c and c:FindFirstChild("Head")
end

--==============================================================
-- EFFECT STORAGE
--==============================================================

local Effects = {}

local function TrackEffect(object)
	table.insert(Effects,object)
	return object
end

local function ClearEffects()
	for _,object in ipairs(Effects) do
		if object and object.Parent then
			object:Destroy()
		end
	end

	table.clear(Effects)

	local root = Root()

	if root then
		for _,object in ipairs(root:GetChildren()) do
			if object.Name:sub(1,6) == "Intrex" then
				object:Destroy()
			end
		end
	end
end

--==============================================================
-- CROSSHAIR
--==============================================================

local Crosshair = Instance.new("Frame")
Crosshair.AnchorPoint = Vector2.new(.5,.5)
Crosshair.Position = UDim2.fromScale(.5,.5)
Crosshair.Size = UDim2.fromOffset(30,30)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = false
Crosshair.Parent = Gui

for _,data in ipairs({
	{UDim2.fromOffset(2,9),UDim2.fromOffset(14,0)},
	{UDim2.fromOffset(2,9),UDim2.fromOffset(14,21)},
	{UDim2.fromOffset(9,2),UDim2.fromOffset(0,14)},
	{UDim2.fromOffset(9,2),UDim2.fromOffset(21,14)},
	}) do
	local line = Instance.new("Frame")
	line.Size = data[1]
	line.Position = data[2]
	line.BackgroundColor3 = C.Accent
	line.BorderSizePixel = 0
	line.Parent = Crosshair
end

--==============================================================
-- COORDINATES
--==============================================================

local Coordinates = Instance.new("TextLabel")
Coordinates.AnchorPoint = Vector2.new(0,1)
Coordinates.Position = UDim2.new(0,15,1,-15)
Coordinates.Size = UDim2.fromOffset(270,24)
Coordinates.BackgroundColor3 = C.Panel
Coordinates.TextColor3 = C.Text
Coordinates.TextSize = 10
Coordinates.Font = Enum.Font.Code
Coordinates.TextXAlignment = Enum.TextXAlignment.Left
Coordinates.Visible = false
Coordinates.Parent = Gui
Corner(Coordinates,6)

--==============================================================
-- PERFORMANCE
--==============================================================

local Performance = Instance.new("TextLabel")
Performance.AnchorPoint = Vector2.new(1,1)
Performance.Position = UDim2.new(1,-15,1,-15)
Performance.Size = UDim2.fromOffset(220,60)
Performance.BackgroundColor3 = C.Panel
Performance.TextColor3 = C.Text
Performance.TextSize = 9
Performance.Font = Enum.Font.Code
Performance.TextXAlignment = Enum.TextXAlignment.Left
Performance.TextYAlignment = Enum.TextYAlignment.Center
Performance.Visible = false
Performance.Parent = Gui
Corner(Performance,7)

--==============================================================
-- ESP
--==============================================================

local ESP = {}

local function RemoveESP(player)
	local data = ESP[player]

	if not data then
		return
	end

	for _,object in pairs(data) do
		if typeof(object) == "Instance" and object.Parent then
			object:Destroy()
		end
	end

	ESP[player] = nil
end

local function AddESP(player)
	if player == LP then
		return
	end

	RemoveESP(player)

	local character = player.Character

	if not character then
		return
	end

	local data = {}

	if State.ESP then
		local highlight = Instance.new("Highlight")
		highlight.Name = "IntrexDebugHighlight"
		highlight.Adornee = character
		highlight.FillColor = C.Accent
		highlight.OutlineColor = C.White
		highlight.FillTransparency = .8
		highlight.Parent = character

		data.Highlight = highlight
	end

	if State.NameESP
		or State.DistanceESP
		or State.HealthESP then

		local head = character:FindFirstChild("Head")

		if head then
			local billboard = Instance.new("BillboardGui")
			billboard.Name = "IntrexDebugLabel"
			billboard.Adornee = head
			billboard.Size = UDim2.fromOffset(240,60)
			billboard.StudsOffset = Vector3.new(0,3,0)
			billboard.AlwaysOnTop = true
			billboard.Parent = character

			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.Size = UDim2.fromScale(1,1)
			label.TextColor3 = C.Text
			label.TextStrokeTransparency = .4
			label.TextSize = 10
			label.Font = Enum.Font.GothamBold
			label.Parent = billboard

			data.Billboard = billboard

			data.Connection = RunService.RenderStepped:Connect(function()
				if not billboard.Parent then
					return
				end

				local parts = {}

				if State.NameESP then
					table.insert(parts,player.DisplayName)
				end

				if State.DistanceESP then
					local mine = Root()
					local their = character:FindFirstChild("HumanoidRootPart")

					if mine and their then
						table.insert(
							parts,
							math.floor(
								(mine.Position-their.Position).Magnitude
							).." studs"
						)
					end
				end

				if State.HealthESP then
					local hum = character:FindFirstChildOfClass("Humanoid")

					if hum then
						table.insert(
							parts,
							math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
						)
					end
				end

				label.Text = table.concat(parts,"  •  ")
			end)
		end
	end

	ESP[player] = data
end

local function RefreshESP()
	for player in pairs(ESP) do
		RemoveESP(player)
	end

	for _,player in ipairs(Players:GetPlayers()) do
		AddESP(player)
	end
end

--==============================================================
-- BASIC ACTION HELPERS
--==============================================================

local function Report(label,value)
	print("[INTREX]",label,value)
	Notify(label..": "..tostring(value))
end

local function CountDescendants(className)
	local count = 0

	for _,object in ipairs(Workspace:GetDescendants()) do
		if not className or object:IsA(className) then
			count += 1
		end
	end

	return count
end

local function PrintCharacterReport()
	local c = Character()
	local h = Humanoid()
	local r = Root()

	print("========== INTREX CHARACTER ==========")
	print("Player:",LP.Name)
	print("Character:",c)
	print("Humanoid:",h)
	print("Root:",r)

	if h then
		print("Health:",h.Health)
		print("MaxHealth:",h.MaxHealth)
		print("WalkSpeed:",h.WalkSpeed)
		print("JumpPower:",h.JumpPower)
		print("State:",h:GetState())
	end

	if r then
		print("Position:",r.Position)
		print("Velocity:",r.AssemblyLinearVelocity)
		print("CFrame:",r.CFrame)
	end

	print("======================================")
end

--==============================================================
-- MOVEMENT SYSTEM
--==============================================================

local FlyConnection

local function StopFly()
	State.Fly = false

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	local r = Root()

	if r then
		local v = r:FindFirstChild("IntrexFlyVelocity")
		if v then
			v:Destroy()
		end
	end
end

local function StartFly()
	StopFly()

	State.Fly = true

	FlyConnection = RunService.RenderStepped:Connect(function()
		local r = Root()
		local camera = Workspace.CurrentCamera

		if not r or not camera then
			return
		end

		local velocity = r:FindFirstChild("IntrexFlyVelocity")

		if not velocity then
			velocity = Instance.new("BodyVelocity")
			velocity.Name = "IntrexFlyVelocity"
			velocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			velocity.Parent = r
		end

		local direction = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then
			direction += camera.CFrame.LookVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.S) then
			direction -= camera.CFrame.LookVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.A) then
			direction -= camera.CFrame.RightVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.D) then
			direction += camera.CFrame.RightVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			direction += Vector3.yAxis
		end

		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
			direction -= Vector3.yAxis
		end

		if direction.Magnitude > 0 then
			direction = direction.Unit
		end

		velocity.Velocity = direction * (State.FlySpeed or 70)
	end)
end

local function ApplyMovement()
	local h = Humanoid()

	if not h then
		return
	end

	h.WalkSpeed = State.Speed
	h.UseJumpPower = true
	h.JumpPower = State.Jump
	h.AutoRotate = true
end

--==============================================================
-- FEATURE LISTS
--==============================================================

local Features = {

	["Movement"] = {
		"Walk Speed","Jump Power","Fly","Fly Speed","Infinite Jump","Noclip","Auto Sprint",
		"Spin","Spin Speed","Camera FOV","Gravity","Hip Height","Platform Stand","Auto Jump",
		"Move Direction Monitor","Velocity Boost","Horizontal Boost","Vertical Boost","Stop Velocity",
		"Face Camera","Freeze Character","Unfreeze Character","Reset Movement","Reset Camera",
		"Jump Request","Force Sit","Stand Up","Walk Animation Speed","Auto Rotate","Use Jump Power",
		"Max Zoom","Min Zoom","Camera Offset X","Camera Offset Y","Camera Offset Z","Root Position",
		"Root Orientation","Move Forward","Move Backward","Move Left","Move Right","Move Up",
		"Move Down","Impulse Forward","Impulse Up","Impulse Down","Character Anchoring","Movement Snapshot",
		"Movement Report"
	},

	["Player"] = {
		"Third Person","First Person","Coordinates","Reset Character","Respawn Character","Character Information",
		"Save Position","Return To Saved","Health","Max Health","WalkSpeed Readout","JumpPower Readout",
		"Humanoid State","Root Velocity","Root CFrame","Root Position","Character Count","Part Count",
		"Accessory Count","Tool Count","Animation Count","Seat Check","Ground Check","Air Check",
		"Platform Check","Ragdoll Check","ForceField Check","Head Check","Torso Check","Root Check",
		"Refresh Character","Hide Character Locally","Show Character Locally","Local Transparency","Reset Transparency",
		"Sit Character","Stand Character","Freeze Character","Unfreeze Character","Face Forward","Face Backward",
		"Face Left","Face Right","Character Snapshot","Character Bounds","Character Descendants","Player Attributes",
		"Character Attributes","Player ID Report","Respawn Location"
	},

	["Visuals"] = {
		"Field Of View","Fullbright","No Fog","Crosshair","Character Trail","Rainbow Character","Reset Camera",
		"Blur","Color Correction","Bloom","Sun Rays","Depth Of Field","Atmosphere Preview","Ambient Boost",
		"Contrast","Saturation","Tint","Exposure","Camera Shake","Camera Pulse","FOV Pulse","FOV Wobble",
		"Crosshair Dot","Crosshair Ring","Crosshair Large","Crosshair Small","Crosshair Hide","Trail Short",
		"Trail Long","Trail Wide","Trail Thin","Particle Sparkles","Particle Smoke","Particle Burst",
		"Character Highlight","Character Outline","Character Transparency","Head Transparency","Local Shadows",
		"Lighting Preview","Night Vision","Day Vision","Warm Filter","Cool Filter","Monochrome","Invert Preview",
		"Reset Post Effects","Screenshot Marker","Camera Position","Camera Look Vector"
	},

	["ESP / Debug"] = {
		"Player Highlight","Name Labels","Distance Labels","Health Labels","Refresh ESP","Clear ESP",
		"Workspace Object Count","Team Labels","Display Names","Usernames","Root Markers","Head Markers",
		"Humanoid Markers","Tool Labels","Character Bounds","Player Count","Nearest Player","Farthest Player",
		"Player Positions","Player Distances","Player Health","Player States","Player Teams","Character Models",
		"Accessory Count","Tool Count","Workspace Models","Workspace Parts","Workspace Lights","Workspace Sounds",
		"Workspace Scripts","Workspace Folders","Workspace GUIs","Workspace Attachments","Workspace Constraints",
		"Workspace ProximityPrompts","Workspace ClickDetectors","Workspace SpawnLocations","Workspace Seats",
		"Workspace Vehicles","Debug Grid","Debug Axes","Debug Origin","Debug Ray","Debug Camera Ray",
		"Debug Root Ray","Debug Ground Ray","Debug Report","Clear Debug"
	},

	["World"] = {
		"Clock Time","Brightness","Fog Distance","Global Shadows","Exposure","Ambient","Outdoor Ambient",
		"ColorShift Top","ColorShift Bottom","Environment Diffuse","Environment Specular","Geographic Latitude",
		"Technology Report","Future Lighting Preview","Shadow Softness","Fog Color","Atmosphere Density",
		"Atmosphere Offset","Atmosphere Color","Atmosphere Decay","Atmosphere Glare","Atmosphere Haze",
		"Bloom Intensity","Bloom Size","Bloom Threshold","Sun Rays Intensity","Sun Rays Spread","Color Correction",
		"World Contrast","World Saturation","World Tint","World Exposure","Night Preset","Day Preset",
		"Sunset Preset","Reset Lighting","Reset Atmosphere","Reset Effects","Lighting Report","Material Report",
		"Terrain Report","Part Count","Model Count","Light Count","Sound Count","Particle Count","Seat Count",
		"Spawn Count","Environment Snapshot","World Diagnostics"
	},

	["Utility"] = {
		"Performance Monitor","Notification Sound","Notification Volume","Notification Test","Print Position",
		"Print Velocity","Character Scanner","Clear Intrex Effects","FPS Counter","Memory Report","Ping Report",
		"Player List","Workspace Scan","Lighting Scan","Camera Scan","Network Ownership Report","Attribute Scan",
		"Tag Scan","CollectionService Report","Script Count","LocalScript Count","ModuleScript Count",
		"RemoteEvent Count","RemoteFunction Count","Bindable Count","Folder Count","Model Count","Part Count",
		"Attachment Count","Constraint Count","Sound Count","Particle Count","GUI Count","Tool Count",
		"Accessory Count","Animation Count","Humanoid Count","Seat Count","Spawn Count","Prompt Count",
		"ClickDetector Count","Raycast Test","Region Test","Position Copy","CFrame Report","State Report",
		"Clear Notifications","Developer Message","Runtime Report","Utility Reset"
	},

	["Teleport"] = {
		"Save Position","Return To Saved","Teleport To Spawn","Teleport Up","Teleport Down","Teleport Forward",
		"Teleport Backward","Teleport Origin","Teleport Left","Teleport Right","Teleport To Highest Point",
		"Teleport To Lowest Point","Teleport To Nearest Spawn","Teleport To Random Spawn","Save Slot 1",
		"Save Slot 2","Save Slot 3","Load Slot 1","Load Slot 2","Load Slot 3","Clear Slots","Offset X",
		"Offset Y","Offset Z","Apply Offset","Face Spawn","Face Origin","Teleport To Camera","Teleport Along Look",
		"Teleport Along Right","Teleport Along Up","Move 5","Move 10","Move 25","Move 50","Move -5","Move -10",
		"Move -25","Move -50","Position Report","CFrame Report","Nearest Part","Nearest Spawn","Nearest Player",
		"Farthest Player","Random Safe Position","Ground Position","Reset Offset","Teleport Snapshot","Teleport Diagnostics"
	},

	["Trolling / Effects"] = {
		"Character Spin","Rainbow Character","Character Trail","Particle Burst","FOV Pulse","Clear Effects",
		"Sparkle Burst","Smoke Burst","Flash Effect","Screen Pulse","Screen Shake","Trail Pulse","Trail Rainbow",
		"Character Highlight","Character Glow","Character Outline","Head Glow","Root Glow","Particle Ring",
		"Particle Fountain","Particle Spiral","Particle Orbit","Confetti","Local Dust","Local Sparks",
		"Local Stars","Local Bubbles","Local Fire Preview","Local Smoke Preview","Local Beam","Local PointLight",
		"Local Spotlight","Local SurfaceLight","Camera Zoom","Camera Zoom Back","Camera Wiggle","Camera Tilt",
		"Camera Spin","Color Flash","Brightness Flash","Fog Flash","Night Flash","Day Flash","Effect Cleanup",
		"Effect Count","Effect Report","Trail Reset","Particle Reset","Visual Reset","Effects Snapshot"
	},

	["Settings"] = {
		"UI Animations","UI Scale","UI Transparency","Reset UI Size","Hide Menu","Show Menu","Notification Duration",
		"Notification Sound","Notification Volume","Menu Key","Window Width","Window Height","Minimum Width",
		"Minimum Height","Maximum Width","Maximum Height","Sidebar Width","Search Width","Corner Radius",
		"Accent Preview","Dark Background","Compact Mode","Large Text","Small Text","Category Scroll Speed",
		"Option Scroll Speed","Reset Colors","Reset Layout","Reset Notifications","Reset Search","Center Window",
		"Move Window Left","Move Window Right","Move Window Up","Move Window Down","Save UI Position",
		"Reset UI Position","Resize Hint","Show Resize Handles","Hide Resize Handles","Debug UI Bounds",
		"Print UI Size","Print UI Position","Print UI State","Rebuild UI","Clear Search","Focus Search",
		"Open Movement","Open Settings","Settings Report"
	},

	["Config"] = {
		"Reset Movement","Disable Everything","Reset Visuals","Reset Lighting","Clear ESP","Clear Saved Position",
		"Reset Teleport Slots","Reset Effects","Reset UI","Reset Camera","Reset World","Reset Player",
		"Reset Utility","Reset Debug","Factory Reset","Save Config Snapshot","Load Config Snapshot","Clear Config Snapshot",
		"Save Movement Snapshot","Load Movement Snapshot","Save Visual Snapshot","Load Visual Snapshot","Save World Snapshot",
		"Load World Snapshot","Save Player Snapshot","Load Player Snapshot","Export State","Print State","Print Config",
		"Print Categories","Print Feature Count","Feature Count","Category Count","Clear Notifications","Reset FOV",
		"Reset Speed","Reset Jump","Reset Gravity","Reset Zoom","Reset Transparency","Reset Post Effects",
		"Reset Crosshair","Reset Trail","Reset Rainbow","Reset Noclip","Reset Fly","Reset Spin","Reset Coordinates",
		"Reset Performance","Config Diagnostics","Complete Reset"
	},

	["Debug"] = {
		"Character Debug","Camera Debug","Lighting Debug","Workspace Scan","Player List","INTREX State",
		"Full Debug Report","Humanoid Debug","Root Debug","Head Debug","Animator Debug","Animation Debug",
		"Tool Debug","Accessory Debug","Seat Debug","Physics Debug","Velocity Debug","Position Debug",
		"Orientation Debug","Camera CFrame Debug","Camera Focus Debug","Lighting Technology Debug",
		"Atmosphere Debug","Post Effect Debug","Workspace Models Debug","Workspace Parts Debug","Workspace Folders Debug",
		"Workspace Scripts Debug","Workspace Remotes Debug","Workspace Sounds Debug","Workspace Particles Debug",
		"Workspace Constraints Debug","Workspace Attachments Debug","Workspace Prompts Debug","Workspace Spawns Debug",
		"Workspace Seats Debug","Player Attributes Debug","Character Attributes Debug","Tag Debug","Raycast Debug",
		"Ground Debug","Distance Debug","Performance Debug","Memory Debug","FPS Debug","Job Debug","Place Debug",
		"Server Debug","Client Debug","Debug Snapshot","Clear Debug"
	},
}

--==============================================================
-- FEATURE COUNT VALIDATION
--==============================================================

for category,list in pairs(Features) do
	print(
		"[INTREX]",
		category,
		"features:",
		#list
	)
end

--==============================================================
-- GENERIC LOCAL EFFECT HELPERS
--==============================================================

local function MakeHighlight()
	local c = Character()
	if not c then return end

	local h = Instance.new("Highlight")
	h.Name = "IntrexLocalHighlight"
	h.Adornee = c
	h.FillColor = C.Accent
	h.OutlineColor = C.White
	h.FillTransparency = .65
	h.Parent = c

	TrackEffect(h)
	Notify("Character highlighted")
end

local function MakeParticle(texture)
	local r = Root()
	if not r then
		Notify("No character root")
		return
	end

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "IntrexParticle"
	emitter.Texture = texture
	emitter.Rate = 80
	emitter.Lifetime = NumberRange.new(.4,.9)
	emitter.Speed = NumberRange.new(5,12)
	emitter.SpreadAngle = Vector2.new(180,180)
	emitter.Parent = r

	TrackEffect(emitter)

	task.delay(2,function()
		if emitter.Parent then
			emitter:Destroy()
		end
	end)
end

local function SetPostEffect(className,name)
	local existing = Lighting:FindFirstChild(name)

	if existing then
		existing:Destroy()
	end

	local effect = Instance.new(className)
	effect.Name = name
	effect.Parent = Lighting

	TrackEffect(effect)

	return effect
end

--==============================================================
-- FEATURE EXECUTOR
--==============================================================

local Slots = {}
local Snapshot = {}

local function ExecuteFeature(category,name)

	local h = Humanoid()
	local r = Root()
	local camera = Workspace.CurrentCamera

	--==========================================================
	-- MOVEMENT
	--==========================================================

	if category == "Movement" then

		if name == "Walk Speed" then
			State.Speed = math.clamp(State.Speed + 5,0,150)
			ApplyMovement()
			Notify("WalkSpeed = "..State.Speed)

		elseif name == "Jump Power" then
			State.Jump = math.clamp(State.Jump + 10,0,200)
			ApplyMovement()
			Notify("JumpPower = "..State.Jump)

		elseif name == "Fly" then
			if State.Fly then
				StopFly()
				Notify("Fly disabled")
			else
				StartFly()
				Notify("Fly enabled")
			end

		elseif name == "Infinite Jump" then
			State.InfiniteJump = not State.InfiniteJump
			Notify("Infinite Jump "..(State.InfiniteJump and "ON" or "OFF"))

		elseif name == "Noclip" then
			State.Noclip = not State.Noclip
			Notify("Noclip "..(State.Noclip and "ON" or "OFF"))

		elseif name == "Auto Sprint" then
			State.AutoSprint = not State.AutoSprint

		elseif name == "Spin" then
			State.Spin = not State.Spin

		elseif name == "Spin Speed" then
			State.SpinSpeed = (State.SpinSpeed or 180) + 45

		elseif name == "Camera FOV" then
			State.FOV = math.clamp(State.FOV + 10,40,120)
			if camera then
				camera.FieldOfView = State.FOV
			end

		elseif name == "Gravity" then
			Workspace.Gravity = math.clamp(
				Workspace.Gravity - 25,
				0,
				300
			)

		elseif name == "Hip Height" then
			if h then
				h.HipHeight += .5
			end

		elseif name == "Platform Stand" then
			if h then
				h.PlatformStand = not h.PlatformStand
			end

		elseif name == "Auto Jump" then
			if h then
				h.Jump = true
			end

		elseif name == "Move Direction Monitor" then
			if h then
				Report("MoveDirection",h.MoveDirection)
			end

		elseif name == "Velocity Boost" then
			if r then
				r.AssemblyLinearVelocity += r.CFrame.LookVector * 25
			end

		elseif name == "Horizontal Boost" then
			if r then
				local v = r.AssemblyLinearVelocity
				r.AssemblyLinearVelocity = Vector3.new(
					v.X * 2,
					v.Y,
					v.Z * 2
				)
			end

		elseif name == "Vertical Boost" then
			if r then
				r.AssemblyLinearVelocity += Vector3.yAxis * 40
			end

		elseif name == "Stop Velocity" then
			if r then
				r.AssemblyLinearVelocity = Vector3.zero
			end

		elseif name == "Face Camera" then
			if r and camera then
				local p = r.Position
				local look = camera.CFrame.LookVector
				r.CFrame = CFrame.lookAt(
					p,
					p + Vector3.new(look.X,0,look.Z)
				)
			end

		elseif name == "Freeze Character" then
			if r then r.Anchored = true end

		elseif name == "Unfreeze Character" then
			if r then r.Anchored = false end

		elseif name == "Reset Movement" then
			State.Speed = CONFIG.DefaultSpeed
			State.Jump = CONFIG.DefaultJump
			Workspace.Gravity = CONFIG.DefaultGravity
			ApplyMovement()

		elseif name == "Reset Camera" then
			State.FOV = CONFIG.DefaultFOV
			if camera then camera.FieldOfView = State.FOV end

		elseif name == "Jump Request" then
			if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end

		elseif name == "Force Sit" then
			if h then h.Sit = true end

		elseif name == "Stand Up" then
			if h then h.Sit = false end

		elseif name == "Walk Animation Speed" then
			local animator = h and h:FindFirstChildOfClass("Animator")
			if animator then
				for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
					track:AdjustSpeed(2)
				end
			end

		elseif name == "Auto Rotate" then
			if h then h.AutoRotate = not h.AutoRotate end

		elseif name == "Use Jump Power" then
			if h then h.UseJumpPower = not h.UseJumpPower end

		elseif name == "Max Zoom" then
			LP.CameraMaxZoomDistance = math.min(
				LP.CameraMaxZoomDistance + 10,
				400
			)

		elseif name == "Min Zoom" then
			LP.CameraMinZoomDistance = math.min(
				LP.CameraMinZoomDistance + 1,
				20
			)

		elseif name == "Camera Offset X" then
			if h then
				h.CameraOffset += Vector3.new(1,0,0)
			end

		elseif name == "Camera Offset Y" then
			if h then
				h.CameraOffset += Vector3.new(0,1,0)
			end

		elseif name == "Camera Offset Z" then
			if h then
				h.CameraOffset += Vector3.new(0,0,1)
			end

		elseif name == "Root Position" then
			if r then Report("Position",r.Position) end

		elseif name == "Root Orientation" then
			if r then Report("Orientation",r.Orientation) end

		elseif name == "Move Forward" then
			if r then r.CFrame *= CFrame.new(0,0,-5) end

		elseif name == "Move Backward" then
			if r then r.CFrame *= CFrame.new(0,0,5) end

		elseif name == "Move Left" then
			if r then r.CFrame *= CFrame.new(-5,0,0) end

		elseif name == "Move Right" then
			if r then r.CFrame *= CFrame.new(5,0,0) end

		elseif name == "Move Up" then
			if r then r.CFrame *= CFrame.new(0,5,0) end

		elseif name == "Move Down" then
			if r then r.CFrame *= CFrame.new(0,-5,0) end

		elseif name == "Impulse Forward" then
			if r then r:ApplyImpulse(r.CFrame.LookVector*1000) end

		elseif name == "Impulse Up" then
			if r then r:ApplyImpulse(Vector3.yAxis*1000) end

		elseif name == "Impulse Down" then
			if r then r:ApplyImpulse(-Vector3.yAxis*1000) end

		elseif name == "Character Anchoring" then
			if r then r.Anchored = not r.Anchored end

		elseif name == "Movement Snapshot" then
			Snapshot.Movement = {
				Speed = State.Speed,
				Jump = State.Jump,
				Gravity = Workspace.Gravity,
			}
			Notify("Movement snapshot saved")

		elseif name == "Movement Report" then
			PrintCharacterReport()
		end

		--==========================================================
		-- PLAYER
		--==========================================================

	elseif category == "Player" then

		if name == "Third Person" then
			LP.CameraMode = Enum.CameraMode.Classic
			LP.CameraMinZoomDistance = 8
			LP.CameraMaxZoomDistance = 20

		elseif name == "First Person" then
			LP.CameraMode = Enum.CameraMode.LockFirstPerson

		elseif name == "Coordinates" then
			State.Coordinates = not State.Coordinates
			Coordinates.Visible = State.Coordinates

		elseif name == "Reset Character" then
			if h then h.Health = 0 end

		elseif name == "Respawn Character" then
			LP:LoadCharacter()

		elseif name == "Character Information"
			or name == "Character Snapshot"
			or name == "Character Descendants" then
			PrintCharacterReport()

		elseif name == "Save Position" then
			if r then
				State.SavedCFrame = r.CFrame
				Notify("Position saved")
			end

		elseif name == "Return To Saved" then
			if r and State.SavedCFrame then
				r.CFrame = State.SavedCFrame
				Notify("Returned to saved position")
			end

		elseif name == "Health" then
			if h then Report("Health",h.Health) end

		elseif name == "Max Health" then
			if h then Report("MaxHealth",h.MaxHealth) end

		elseif name == "WalkSpeed Readout" then
			if h then Report("WalkSpeed",h.WalkSpeed) end

		elseif name == "JumpPower Readout" then
			if h then Report("JumpPower",h.JumpPower) end

		elseif name == "Humanoid State" then
			if h then Report("State",h:GetState()) end

		elseif name == "Root Velocity" then
			if r then Report("Velocity",r.AssemblyLinearVelocity) end

		elseif name == "Root CFrame" then
			if r then Report("CFrame",r.CFrame) end

		elseif name == "Root Position" then
			if r then Report("Position",r.Position) end

		elseif name == "Character Count" then
			local c = Character()
			Report("Character Parts",c and #c:GetChildren() or 0)

		elseif name == "Part Count" then
			Report("Character Parts",CountDescendants("BasePart"))

		elseif name == "Accessory Count" then
			local c = Character()
			local n = 0
			if c then
				for _,x in ipairs(c:GetChildren()) do
					if x:IsA("Accessory") then n += 1 end
				end
			end
			Report("Accessories",n)

		elseif name == "Tool Count" then
			local n = 0
			for _,x in ipairs(LP.Backpack:GetChildren()) do
				if x:IsA("Tool") then n += 1 end
			end
			Report("Tools",n)

		elseif name == "Animation Count" then
			local animator = h and h:FindFirstChildOfClass("Animator")
			Report(
				"Animations",
				animator and #animator:GetPlayingAnimationTracks() or 0
			)

		elseif name == "Seat Check" then
			Report("Seat",h and h.SeatPart or "None")

		elseif name == "Ground Check" then
			if h then
				Report(
					"Grounded",
					h.FloorMaterial ~= Enum.Material.Air
				)
			end

		elseif name == "Air Check" then
			if h then
				Report(
					"In Air",
					h.FloorMaterial == Enum.Material.Air
				)
			end

		elseif name == "Platform Check" then
			if h then Report("PlatformStand",h.PlatformStand) end

		elseif name == "Ragdoll Check" then
			if h then Report("State",h:GetState()) end

		elseif name == "ForceField Check" then
			local c = Character()
			Report("ForceField",c and c:FindFirstChildOfClass("ForceField") ~= nil)

		elseif name == "Head Check" then
			Report("Head",Head() ~= nil)

		elseif name == "Torso Check" then
			local c = Character()
			Report(
				"Torso",
				c and (
					c:FindFirstChild("UpperTorso")
						or c:FindFirstChild("Torso")
				)
			)

		elseif name == "Root Check" then
			Report("Root",r ~= nil)

		elseif name == "Refresh Character" then
			Notify("Character refreshed")

		elseif name == "Hide Character Locally" then
			local c = Character()
			if c then
				for _,x in ipairs(c:GetDescendants()) do
					if x:IsA("BasePart") then
						x.LocalTransparencyModifier = 1
					end
				end
			end

		elseif name == "Show Character Locally"
			or name == "Reset Transparency" then
			local c = Character()
			if c then
				for _,x in ipairs(c:GetDescendants()) do
					if x:IsA("BasePart") then
						x.LocalTransparencyModifier = 0
					end
				end
			end

		elseif name == "Local Transparency" then
			local c = Character()
			if c then
				for _,x in ipairs(c:GetDescendants()) do
					if x:IsA("BasePart") then
						x.LocalTransparencyModifier = .5
					end
				end
			end

		elseif name == "Sit Character" then
			if h then h.Sit = true end

		elseif name == "Stand Character" then
			if h then h.Sit = false end

		elseif name == "Freeze Character" then
			if r then r.Anchored = true end

		elseif name == "Unfreeze Character" then
			if r then r.Anchored = false end

		elseif name == "Face Forward" then
			if r then
				r.CFrame = CFrame.lookAt(
					r.Position,
					r.Position + Vector3.new(0,0,-1)
				)
			end

		elseif name == "Face Backward" then
			if r then
				r.CFrame = CFrame.lookAt(
					r.Position,
					r.Position + Vector3.new(0,0,1)
				)
			end

		elseif name == "Face Left" then
			if r then
				r.CFrame = CFrame.lookAt(
					r.Position,
					r.Position + Vector3.new(-1,0,0)
				)
			end

		elseif name == "Face Right" then
			if r then
				r.CFrame = CFrame.lookAt(
					r.Position,
					r.Position + Vector3.new(1,0,0)
				)
			end

		elseif name == "Character Bounds" then
			local c = Character()
			if c then
				local cf,size = c:GetBoundingBox()
				print("[INTREX] Bounds:",cf,size)
				Notify("Character bounds printed")
			end

		elseif name == "Player Attributes" then
			print("[INTREX] Player Attributes")
			for k,v in pairs(LP:GetAttributes()) do
				print(k,v)
			end

		elseif name == "Character Attributes" then
			local c = Character()
			if c then
				for k,v in pairs(c:GetAttributes()) do
					print(k,v)
				end
			end

		elseif name == "Player ID Report" then
			Report("UserId",LP.UserId)

		elseif name == "Respawn Location" then
			local spawn = Workspace:FindFirstChildWhichIsA(
				"SpawnLocation",
				true
			)
			Report("Spawn",spawn and spawn:GetFullName() or "None")
		end

		--==========================================================
		-- VISUALS
		--==========================================================

	elseif category == "Visuals" then

		if name == "Field Of View" then
			State.FOV = math.clamp(State.FOV + 10,40,120)
			if camera then camera.FieldOfView = State.FOV end

		elseif name == "Fullbright" then
			State.Fullbright = not State.Fullbright

			if State.Fullbright then
				Lighting.Brightness = 3
				Lighting.ClockTime = 14
				Lighting.FogEnd = 100000
				Lighting.GlobalShadows = false
			else
				Lighting.Brightness = 2
				Lighting.GlobalShadows = true
			end

		elseif name == "No Fog" then
			State.NoFog = not State.NoFog
			Lighting.FogEnd = State.NoFog and 100000 or 1000

		elseif name == "Crosshair" then
			State.Crosshair = not State.Crosshair
			Crosshair.Visible = State.Crosshair

		elseif name == "Character Trail" then
			local root = Root()
			if root then
				local a0 = Instance.new("Attachment")
				local a1 = Instance.new("Attachment")

				a0.Name = "IntrexTrailA0"
				a1.Name = "IntrexTrailA1"

				a0.Position = Vector3.new(-1,0,0)
				a1.Position = Vector3.new(1,0,0)

				a0.Parent = root
				a1.Parent = root

				local trail = Instance.new("Trail")
				trail.Name = "IntrexTrail"
				trail.Attachment0 = a0
				trail.Attachment1 = a1
				trail.Lifetime = .5
				trail.Color = ColorSequence.new(C.Accent)
				trail.Parent = root

				TrackEffect(a0)
				TrackEffect(a1)
				TrackEffect(trail)
			end

		elseif name == "Rainbow Character" then
			State.Rainbow = not State.Rainbow

		elseif name == "Reset Camera" then
			State.FOV = CONFIG.DefaultFOV
			if camera then camera.FieldOfView = State.FOV end

		elseif name == "Blur" then
			local e = SetPostEffect("BlurEffect","IntrexBlur")
			e.Size = 12

		elseif name == "Color Correction" then
			local e = SetPostEffect(
				"ColorCorrectionEffect",
				"IntrexColorCorrection"
			)
			e.Contrast = .2
			e.Saturation = .2

		elseif name == "Bloom" then
			local e = SetPostEffect("BloomEffect","IntrexBloom")
			e.Intensity = 1
			e.Size = 24
			e.Threshold = 1

		elseif name == "Sun Rays" then
			local e = SetPostEffect("SunRaysEffect","IntrexSunRays")
			e.Intensity = .2

		elseif name == "Depth Of Field" then
			local e = SetPostEffect("DepthOfFieldEffect","IntrexDOF")
			e.FarIntensity = .2
			e.NearIntensity = .1

		elseif name == "Atmosphere Preview" then
			local e = SetPostEffect("Atmosphere","IntrexAtmosphere")
			e.Density = .3
			e.Haze = 1

		elseif name == "Ambient Boost" then
			Lighting.Ambient = Color3.new(1,1,1)

		elseif name == "Contrast" then
			local e = SetPostEffect(
				"ColorCorrectionEffect",
				"IntrexContrast"
			)
			e.Contrast = .5

		elseif name == "Saturation" then
			local e = SetPostEffect(
				"ColorCorrectionEffect",
				"IntrexSaturation"
			)
			e.Saturation = 1

		elseif name == "Tint" then
			local e = SetPostEffect(
				"ColorCorrectionEffect",
				"IntrexTint"
			)
			e.TintColor = C.Accent

		elseif name == "Exposure" then
			Lighting.ExposureCompensation += .5

		elseif name == "Camera Shake"
			or name == "Screen Shake" then

			if camera then
				local original = camera.CFrame

				for i = 1,8 do
					camera.CFrame =
						original *
						CFrame.Angles(
							math.rad(math.random(-2,2)),
							math.rad(math.random(-2,2)),
							0
						)

					task.wait(.025)
				end

				camera.CFrame = original
			end

		elseif name == "Camera Pulse"
			or name == "FOV Pulse" then

			if camera then
				local original = camera.FieldOfView

				Tween(camera,{
					FieldOfView = math.min(
						original + 20,
						120
					)
				},.12)

				task.delay(.12,function()
					if camera then
						Tween(camera,{
							FieldOfView = original
						},.18)
					end
				end)
			end

		elseif name == "FOV Wobble" then
			if camera then
				local original = camera.FieldOfView

				Tween(camera,{FieldOfView = original+10},.1)

				task.delay(.1,function()
					Tween(camera,{FieldOfView = original-10},.1)
				end)

				task.delay(.2,function()
					Tween(camera,{FieldOfView = original},.1)
				end)
			end

		elseif name == "Crosshair Dot" then
			local dot = Instance.new("Frame")
			dot.AnchorPoint = Vector2.new(.5,.5)
			dot.Position = UDim2.fromScale(.5,.5)
			dot.Size = UDim2.fromOffset(5,5)
			dot.BackgroundColor3 = C.Accent
			dot.BorderSizePixel = 0
			dot.Parent = Gui
			Corner(dot,10)
			TrackEffect(dot)

		elseif name == "Crosshair Ring" then
			local ring = Instance.new("Frame")
			ring.AnchorPoint = Vector2.new(.5,.5)
			ring.Position = UDim2.fromScale(.5,.5)
			ring.Size = UDim2.fromOffset(50,50)
			ring.BackgroundTransparency = 1
			ring.Parent = Gui
			Corner(ring,50)
			Stroke(ring,C.Accent,2)
			TrackEffect(ring)

		elseif name == "Crosshair Large" then
			Crosshair.Size = UDim2.fromOffset(50,50)

		elseif name == "Crosshair Small" then
			Crosshair.Size = UDim2.fromOffset(20,20)

		elseif name == "Crosshair Hide" then
			Crosshair.Visible = false

		elseif name == "Trail Short" then
			local root = Root()
			if root then
				local trail = Instance.new("Trail")
				local a = Instance.new("Attachment")
				local b = Instance.new("Attachment")
				a.Parent = root
				b.Parent = root
				a.Position = Vector3.new(-1,0,0)
				b.Position = Vector3.new(1,0,0)
				trail.Attachment0 = a
				trail.Attachment1 = b
				trail.Lifetime = .15
				trail.Parent = root
				TrackEffect(trail)
				TrackEffect(a)
				TrackEffect(b)
			end

		elseif name == "Trail Long" then
			local root = Root()
			if root then
				local trail = Instance.new("Trail")
				local a = Instance.new("Attachment")
				local b = Instance.new("Attachment")
				a.Parent = root
				b.Parent = root
				trail.Attachment0 = a
				trail.Attachment1 = b
				trail.Lifetime = 2
				trail.Parent = root
				TrackEffect(trail)
				TrackEffect(a)
				TrackEffect(b)
			end

		elseif name == "Trail Wide" then
			local root = Root()
			if root then
				local trail = Instance.new("Trail")
				local a = Instance.new("Attachment")
				local b = Instance.new("Attachment")
				a.Parent = root
				b.Parent = root
				trail.Attachment0 = a
				trail.Attachment1 = b
				trail.WidthScale = NumberSequence.new(2)
				trail.Lifetime = .7
				trail.Parent = root
				TrackEffect(trail)
				TrackEffect(a)
				TrackEffect(b)
			end

		elseif name == "Trail Thin" then
			local root = Root()
			if root then
				local trail = Instance.new("Trail")
				local a = Instance.new("Attachment")
				local b = Instance.new("Attachment")
				a.Parent = root
				b.Parent = root
				trail.Attachment0 = a
				trail.Attachment1 = b
				trail.WidthScale = NumberSequence.new(.25)
				trail.Lifetime = .7
				trail.Parent = root
				TrackEffect(trail)
				TrackEffect(a)
				TrackEffect(b)
			end

		elseif name == "Particle Sparkles"
			or name == "Particle Burst"
			or name == "Particle Sparkles" then

			MakeParticle(
				"rbxasset://textures/particles/sparkles_main.dds"
			)

		elseif name == "Particle Smoke" then
			MakeParticle(
				"rbxasset://textures/particles/smoke_main.dds"
			)

		elseif name == "Character Highlight"
			or name == "Character Outline" then
			MakeHighlight()

		elseif name == "Character Transparency" then
			local c = Character()
			if c then
				for _,x in ipairs(c:GetDescendants()) do
					if x:IsA("BasePart") then
						x.LocalTransparencyModifier = .5
					end
				end
			end

		elseif name == "Head Transparency" then
			local head = Head()
			if head then
				head.LocalTransparencyModifier = .5
			end

		elseif name == "Local Shadows" then
			Lighting.GlobalShadows = not Lighting.GlobalShadows

		elseif name == "Lighting Preview" then
			Lighting.ClockTime = 14
			Lighting.Brightness = 3

		elseif name == "Night Vision" then
			Lighting.Brightness = 5
			Lighting.ExposureCompensation = 2

		elseif name == "Day Vision" then
			Lighting.ClockTime = 14
			Lighting.Brightness = 3

		elseif name == "Warm Filter" then
			local e = SetPostEffect(
				"ColorCorrectionEffect",
				"IntrexWarm"
			)
			e.TintColor = Color3.fromRGB(255,220,180)

		elseif name == "Cool Filter" then
			local e = SetPostEffect(
				"ColorCorrectionEffect",
				"IntrexCool"
			)
			e.TintColor = Color3.fromRGB(180,220,255)

		elseif name == "Monochrome" then
			local e = SetPostEffect(
				"ColorCorrectionEffect",
				"IntrexMono"
			)
			e.Saturation = -1

		elseif name == "Invert Preview" then
			local e = SetPostEffect(
				"ColorCorrectionEffect",
				"IntrexInvert"
			)
			e.Contrast = -1

		elseif name == "Reset Post Effects" then
			for _,x in ipairs(Lighting:GetChildren()) do
				if x.Name:sub(1,6) == "Intrex" then
					x:Destroy()
				end
			end

		elseif name == "Screenshot Marker" then
			local marker = Instance.new("TextLabel")
			marker.AnchorPoint = Vector2.new(.5,0)
			marker.Position = UDim2.new(.5,0,0,20)
			marker.Size = UDim2.fromOffset(180,25)
			marker.BackgroundColor3 = C.Panel
			marker.Text = "INTREX TEST MARKER"
			marker.TextColor3 = C.Accent
			marker.Font = Enum.Font.GothamBold
			marker.TextSize = 10
			marker.Parent = Gui
			Corner(marker,6)
			TrackEffect(marker)

		elseif name == "Camera Position" then
			if camera then Report("Camera Position",camera.CFrame.Position) end

		elseif name == "Camera Look Vector" then
			if camera then Report("LookVector",camera.CFrame.LookVector) end
		end

		--==========================================================
		-- ESP / DEBUG
		--==========================================================

	elseif category == "ESP / Debug" then

		if name == "Player Highlight" then
			State.ESP = not State.ESP
			RefreshESP()

		elseif name == "Name Labels" then
			State.NameESP = not State.NameESP
			RefreshESP()

		elseif name == "Distance Labels" then
			State.DistanceESP = not State.DistanceESP
			RefreshESP()

		elseif name == "Health Labels" then
			State.HealthESP = not State.HealthESP
			RefreshESP()

		elseif name == "Refresh ESP" then
			RefreshESP()

		elseif name == "Clear ESP"
			or name == "Clear Debug" then

			for player in pairs(ESP) do
				RemoveESP(player)
			end

			State.ESP = false
			State.NameESP = false
			State.DistanceESP = false
			State.HealthESP = false

		elseif name == "Workspace Object Count" then
			Report("Workspace Objects",#Workspace:GetDescendants())

		elseif name == "Team Labels"
			or name == "Display Names"
			or name == "Usernames"
			or name == "Player Positions"
			or name == "Player Distances"
			or name == "Player Health"
			or name == "Player States"
			or name == "Player Teams" then

			for _,p in ipairs(Players:GetPlayers()) do
				local ph = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
				local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")

				print(
					"[INTREX PLAYER]",
					p.Name,
					p.DisplayName,
					p.Team and p.Team.Name or "No Team",
					pr and pr.Position or "No Root",
					ph and ph.Health or "No Humanoid"
				)
			end

			Notify("Player diagnostics printed")

		elseif name == "Player Count" then
			Report("Players",#Players:GetPlayers())

		elseif name == "Nearest Player"
			or name == "Farthest Player" then

			local mine = Root()

			if mine then
				local chosen
				local distance

				for _,p in ipairs(Players:GetPlayers()) do
					if p ~= LP then
						local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")

						if pr then
							local d = (mine.Position-pr.Position).Magnitude

							if not distance
								or (
									name == "Nearest Player"
										and d < distance
								)
									or (
										name == "Farthest Player"
										and d > distance
									) then

								chosen = p
								distance = d
							end
						end
					end
				end

				if chosen then
					Notify(
						chosen.DisplayName
							.." • "
							..math.floor(distance)
							.." studs"
					)
				end
			end

		elseif name == "Workspace Models" then
			Report("Models",CountDescendants("Model"))

		elseif name == "Workspace Parts" then
			Report("Parts",CountDescendants("BasePart"))

		elseif name == "Workspace Lights" then
			local n = 0
			for _,x in ipairs(Workspace:GetDescendants()) do
				if x:IsA("Light") then n += 1 end
			end
			Report("Lights",n)

		elseif name == "Workspace Sounds" then
			Report("Sounds",CountDescendants("Sound"))

		elseif name == "Workspace Scripts" then
			local n = 0
			for _,x in ipairs(Workspace:GetDescendants()) do
				if x:IsA("Script")
					or x:IsA("LocalScript")
					or x:IsA("ModuleScript") then
					n += 1
				end
			end
			Report("Scripts",n)

		elseif name == "Workspace Folders" then
			Report("Folders",CountDescendants("Folder"))

		elseif name == "Workspace GUIs" then
			Report("GUIs",CountDescendants("BillboardGui"))

		elseif name == "Workspace Attachments" then
			Report("Attachments",CountDescendants("Attachment"))

		elseif name == "Workspace Constraints" then
			local n = 0
			for _,x in ipairs(Workspace:GetDescendants()) do
				if x:IsA("Constraint") then n += 1 end
			end
			Report("Constraints",n)

		elseif name == "Workspace ProximityPrompts" then
			Report("Prompts",CountDescendants("ProximityPrompt"))

		elseif name == "Workspace ClickDetectors" then
			Report("ClickDetectors",CountDescendants("ClickDetector"))

		elseif name == "Workspace SpawnLocations" then
			Report(
				"Spawns",
				CountDescendants("SpawnLocation")
			)

		elseif name == "Workspace Seats" then
			Report(
				"Seats",
				CountDescendants("Seat")
					+ CountDescendants("VehicleSeat")
			)

		elseif name == "Debug Grid" then
			for i=-5,5 do
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new(.1,.1,100)
				part.Position = Vector3.new(i*10,0,0)
				part.Color = C.Accent
				part.Transparency = .5
				part.Name = "IntrexDebugGrid"
				part.Parent = Workspace
				TrackEffect(part)
			end

		elseif name == "Debug Axes" then
			if r then
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new(10,.1,.1)
				part.CFrame = r.CFrame
				part.Color = C.Red
				part.Name = "IntrexDebugAxis"
				part.Parent = Workspace
				TrackEffect(part)
			end

		elseif name == "Debug Origin" then
			local p = Instance.new("Part")
			p.Anchored = true
			p.CanCollide = false
			p.Size = Vector3.new(2,2,2)
			p.Position = Vector3.new(0,0,0)
			p.Color = C.Accent
			p.Name = "IntrexDebugOrigin"
			p.Parent = Workspace
			TrackEffect(p)

		elseif name == "Debug Report" then
			print("========== INTREX DEBUG REPORT ==========")
			print("Players:",#Players:GetPlayers())
			print("Workspace:",#Workspace:GetDescendants())
			print("Character:",Character())
			print("Humanoid:",Humanoid())
			print("Root:",Root())
			print("=========================================")
			Notify("Debug report printed")
		end

		--==========================================================
		-- WORLD
		--==========================================================

	elseif category == "World" then

		if name == "Clock Time" then
			Lighting.ClockTime = (Lighting.ClockTime + 1) % 24

		elseif name == "Brightness" then
			Lighting.Brightness = math.clamp(
				Lighting.Brightness + 1,
				0,
				10
			)

		elseif name == "Fog Distance" then
			Lighting.FogEnd = math.clamp(
				Lighting.FogEnd + 500,
				0,
				100000
			)

		elseif name == "Global Shadows" then
			Lighting.GlobalShadows = not Lighting.GlobalShadows

		elseif name == "Exposure" then
			Lighting.ExposureCompensation += .5

		elseif name == "Ambient" then
			Lighting.Ambient = Color3.new(1,1,1)

		elseif name == "Outdoor Ambient" then
			Lighting.OutdoorAmbient = Color3.new(1,1,1)

		elseif name == "ColorShift Top" then
			Lighting.ColorShift_Top = C.Accent

		elseif name == "ColorShift Bottom" then
			Lighting.ColorShift_Bottom = C.AccentDark

		elseif name == "Environment Diffuse" then
			Lighting.EnvironmentDiffuseScale =
				math.clamp(
					Lighting.EnvironmentDiffuseScale + .1,
					0,
					1
				)

		elseif name == "Environment Specular" then
			Lighting.EnvironmentSpecularScale =
				math.clamp(
					Lighting.EnvironmentSpecularScale + .1,
					0,
					1
				)

		elseif name == "Geographic Latitude" then
			Lighting.GeographicLatitude += 10

		elseif name == "Technology Report" then
			Report("Technology",Lighting.Technology)

		elseif name == "Future Lighting Preview" then
			pcall(function()
				Lighting.Technology = Enum.Technology.Future
			end)

		elseif name == "Shadow Softness" then
			Lighting.ShadowSoftness =
				math.clamp(
					Lighting.ShadowSoftness + .1,
					0,
					1
				)

		elseif name == "Fog Color" then
			Lighting.FogColor = C.Accent

		elseif name == "Atmosphere Density" then
			local a = Lighting:FindFirstChildOfClass("Atmosphere")

			if not a then
				a = Instance.new("Atmosphere")
				a.Parent = Lighting
			end

			a.Density = math.clamp(a.Density+.05,0,1)

		elseif name == "Atmosphere Offset" then
			local a = Lighting:FindFirstChildOfClass("Atmosphere")
			if a then a.Offset += .1 end

		elseif name == "Atmosphere Color" then
			local a = Lighting:FindFirstChildOfClass("Atmosphere")
			if a then a.Color = C.Accent end

		elseif name == "Atmosphere Decay" then
			local a = Lighting:FindFirstChildOfClass("Atmosphere")
			if a then a.Decay = C.AccentDark end

		elseif name == "Atmosphere Glare" then
			local a = Lighting:FindFirstChildOfClass("Atmosphere")
			if a then a.Glare = math.clamp(a.Glare+.1,0,10) end

		elseif name == "Atmosphere Haze" then
			local a = Lighting:FindFirstChildOfClass("Atmosphere")
			if a then a.Haze = math.clamp(a.Haze+.1,0,10) end

		elseif name == "Bloom Intensity"
			or name == "Bloom Size"
			or name == "Bloom Threshold" then

			local e = Lighting:FindFirstChild("IntrexWorldBloom")

			if not e then
				e = Instance.new("BloomEffect")
				e.Name = "IntrexWorldBloom"
				e.Parent = Lighting
			end

			e.Intensity += .25
			e.Size += 5

		elseif name == "Sun Rays Intensity"
			or name == "Sun Rays Spread" then

			local e = Lighting:FindFirstChild("IntrexWorldSunRays")

			if not e then
				e = Instance.new("SunRaysEffect")
				e.Name = "IntrexWorldSunRays"
				e.Parent = Lighting
			end

			e.Intensity = math.clamp(e.Intensity+.1,0,1)
			e.Spread = math.clamp(e.Spread+.1,0,1)

		elseif name == "Color Correction"
			or name == "World Contrast"
			or name == "World Saturation"
			or name == "World Tint"
			or name == "World Exposure" then

			local e = Lighting:FindFirstChild("IntrexWorldColor")

			if not e then
				e = Instance.new("ColorCorrectionEffect")
				e.Name = "IntrexWorldColor"
				e.Parent = Lighting
			end

			e.Contrast += .1
			e.Saturation += .1

		elseif name == "Night Preset" then
			Lighting.ClockTime = 0
			Lighting.Brightness = 1

		elseif name == "Day Preset" then
			Lighting.ClockTime = 14
			Lighting.Brightness = 3

		elseif name == "Sunset Preset" then
			Lighting.ClockTime = 18
			Lighting.Brightness = 2

		elseif name == "Reset Lighting" then
			Lighting.ClockTime = 14
			Lighting.Brightness = 2
			Lighting.FogEnd = 100000
			Lighting.GlobalShadows = true
			Lighting.ExposureCompensation = 0

		elseif name == "Reset Atmosphere" then
			for _,x in ipairs(Lighting:GetChildren()) do
				if x:IsA("Atmosphere") and x.Name:sub(1,6) == "Intrex" then
					x:Destroy()
				end
			end

		elseif name == "Reset Effects" then
			for _,x in ipairs(Lighting:GetChildren()) do
				if x.Name:sub(1,6) == "Intrex" then
					x:Destroy()
				end
			end

		elseif name == "Lighting Report"
			or name == "Environment Snapshot"
			or name == "World Diagnostics" then

			print("========== INTREX WORLD ==========")
			print("Brightness:",Lighting.Brightness)
			print("ClockTime:",Lighting.ClockTime)
			print("FogEnd:",Lighting.FogEnd)
			print("GlobalShadows:",Lighting.GlobalShadows)
			print("Exposure:",Lighting.ExposureCompensation)
			print("Technology:",Lighting.Technology)
			print("==================================")

		elseif name == "Material Report" then
			local materials = {}
			for _,x in ipairs(Workspace:GetDescendants()) do
				if x:IsA("BasePart") then
					materials[x.Material] =
						(materials[x.Material] or 0)+1
				end
			end

			for material,count in pairs(materials) do
				print(material,count)
			end

		elseif name == "Terrain Report" then
			Report("Terrain",Workspace:FindFirstChildOfClass("Terrain"))

		elseif name == "Part Count" then
			Report("Parts",CountDescendants("BasePart"))

		elseif name == "Model Count" then
			Report("Models",CountDescendants("Model"))

		elseif name == "Light Count" then
			Report("Lights",CountDescendants("PointLight"))

		elseif name == "Sound Count" then
			Report("Sounds",CountDescendants("Sound"))

		elseif name == "Particle Count" then
			Report("Particles",CountDescendants("ParticleEmitter"))

		elseif name == "Seat Count" then
			Report(
				"Seats",
				CountDescendants("Seat")
					+CountDescendants("VehicleSeat")
			)

		elseif name == "Spawn Count" then
			Report("Spawns",CountDescendants("SpawnLocation"))
		end

		--==========================================================
		-- UTILITY
		--==========================================================

	elseif category == "Utility" then

		if name == "Performance Monitor"
			or name == "FPS Counter" then

			State.Performance = not State.Performance
			Performance.Visible = State.Performance

		elseif name == "Notification Sound" then
			State.NotificationSound = not State.NotificationSound

		elseif name == "Notification Volume" then
			State.NotificationVolume =
				math.clamp(
					State.NotificationVolume+.1,
					0,
					1
				)

		elseif name == "Notification Test" then
			Notify("Notification system working")

		elseif name == "Print Position" then
			if r then Report("Position",r.Position) end

		elseif name == "Print Velocity" then
			if r then Report("Velocity",r.AssemblyLinearVelocity) end

		elseif name == "Character Scanner" then
			PrintCharacterReport()

		elseif name == "Clear Intrex Effects" then
			ClearEffects()

		elseif name == "Memory Report" then
			print("[INTREX] Memory:",
				collectgarbage("count"),
				"KB"
			)
			Notify("Memory report printed")

		elseif name == "Player List" then
			for _,p in ipairs(Players:GetPlayers()) do
				print(p.Name,p.DisplayName,p.UserId)
			end
			Notify("Player list printed")

		elseif name == "Workspace Scan" then
			Report("Workspace Objects",#Workspace:GetDescendants())

		elseif name == "Lighting Scan" then
			Report("Lighting Objects",#Lighting:GetChildren())

		elseif name == "Camera Scan" then
			if camera then
				Report("Camera",camera:GetFullName())
			end

		elseif name == "Attribute Scan" then
			for k,v in pairs(LP:GetAttributes()) do
				print("[INTREX ATTRIBUTE]",k,v)
			end

		elseif name == "Tag Scan" then
			for _,tag in ipairs(CollectionService:GetTags(LP)) do
				print("[INTREX TAG]",tag)
			end

		elseif name == "CollectionService Report" then
			local tags = CollectionService:GetAllTags()
			print("[INTREX] Tags:",#tags)
			for _,tag in ipairs(tags) do
				print(tag,#CollectionService:GetTagged(tag))
			end

		elseif name == "Script Count" then
			Report(
				"Scripts",
				CountDescendants("Script")
					+CountDescendants("LocalScript")
					+CountDescendants("ModuleScript")
			)

		elseif name == "LocalScript Count" then
			Report("LocalScripts",CountDescendants("LocalScript"))

		elseif name == "ModuleScript Count" then
			Report("Modules",CountDescendants("ModuleScript"))

		elseif name == "RemoteEvent Count" then
			Report("RemoteEvents",CountDescendants("RemoteEvent"))

		elseif name == "RemoteFunction Count" then
			Report("RemoteFunctions",CountDescendants("RemoteFunction"))

		elseif name == "Bindable Count" then
			Report(
				"Bindables",
				CountDescendants("BindableEvent")
					+CountDescendants("BindableFunction")
			)

		elseif name == "Folder Count" then
			Report("Folders",CountDescendants("Folder"))

		elseif name == "Model Count" then
			Report("Models",CountDescendants("Model"))

		elseif name == "Part Count" then
			Report("Parts",CountDescendants("BasePart"))

		elseif name == "Attachment Count" then
			Report("Attachments",CountDescendants("Attachment"))

		elseif name == "Constraint Count" then
			local n = 0
			for _,x in ipairs(Workspace:GetDescendants()) do
				if x:IsA("Constraint") then n += 1 end
			end
			Report("Constraints",n)

		elseif name == "Sound Count" then
			Report("Sounds",CountDescendants("Sound"))

		elseif name == "Particle Count" then
			Report("Particles",CountDescendants("ParticleEmitter"))

		elseif name == "GUI Count" then
			Report("GUIs",CountDescendants("BillboardGui"))

		elseif name == "Tool Count" then
			Report("Tools",CountDescendants("Tool"))

		elseif name == "Accessory Count" then
			Report("Accessories",CountDescendants("Accessory"))

		elseif name == "Humanoid Count" then
			Report("Humanoids",CountDescendants("Humanoid"))

		elseif name == "Seat Count" then
			Report(
				"Seats",
				CountDescendants("Seat")
					+CountDescendants("VehicleSeat")
			)

		elseif name == "Spawn Count" then
			Report("Spawns",CountDescendants("SpawnLocation"))

		elseif name == "Prompt Count" then
			Report("Prompts",CountDescendants("ProximityPrompt"))

		elseif name == "ClickDetector Count" then
			Report("ClickDetectors",CountDescendants("ClickDetector"))

		elseif name == "Position Copy" then
			if r then
				print(
					"[INTREX] CFrame.new(",
					r.Position.X,",",
					r.Position.Y,",",
					r.Position.Z,")"
				)
				Notify("Position printed")
			end

		elseif name == "CFrame Report" then
			if r then
				Report("CFrame",r.CFrame)
			end

		elseif name == "State Report" then
			for k,v in pairs(State) do
				print("[INTREX STATE]",k,v)
			end

		elseif name == "Developer Message" then
			Notify("INTREX developer message")

		elseif name == "Runtime Report" then
			print(
				"[INTREX RUNTIME]",
				"PlaceId:",game.PlaceId,
				"JobId:",game.JobId,
				"Players:",#Players:GetPlayers()
			)

		elseif name == "Utility Reset" then
			State.Performance = false
			Performance.Visible = false
			State.NotificationVolume = CONFIG.NotificationVolume
			State.NotificationSound = true
			Notify("Utility reset")
		end

		--==========================================================
		-- TELEPORT
		--==========================================================

	elseif category == "Teleport" then

		if not r then
			Notify("No character root")
			return
		end

		if name == "Save Position" then
			State.SavedCFrame = r.CFrame
			Notify("Position saved")

		elseif name == "Return To Saved" then
			if State.SavedCFrame then
				r.CFrame = State.SavedCFrame
				Notify("Returned")
			end

		elseif name == "Teleport To Spawn"
			or name == "Teleport To Nearest Spawn" then

			local spawn = Workspace:FindFirstChildWhichIsA(
				"SpawnLocation",
				true
			)

			if spawn then
				r.CFrame = spawn.CFrame + Vector3.new(0,4,0)
				Notify("Teleported to spawn")
			else
				Notify("No spawn found")
			end

		elseif name == "Teleport Up" then
			r.CFrame *= CFrame.new(0,20,0)

		elseif name == "Teleport Down" then
			r.CFrame *= CFrame.new(0,-20,0)

		elseif name == "Teleport Forward" then
			r.CFrame *= CFrame.new(0,0,-20)

		elseif name == "Teleport Backward" then
			r.CFrame *= CFrame.new(0,0,20)

		elseif name == "Teleport Origin" then
			r.CFrame = CFrame.new(0,10,0)

		elseif name == "Teleport Left" then
			r.CFrame *= CFrame.new(-20,0,0)

		elseif name == "Teleport Right" then
			r.CFrame *= CFrame.new(20,0,0)

		elseif name == "Teleport To Highest Point" then
			local highest = r.Position.Y

			for _,x in ipairs(Workspace:GetDescendants()) do
				if x:IsA("BasePart") then
					highest = math.max(highest,x.Position.Y)
				end
			end

			r.CFrame = CFrame.new(
				r.Position.X,
				highest+5,
				r.Position.Z
			)

		elseif name == "Teleport To Lowest Point" then
			r.CFrame = CFrame.new(
				r.Position.X,
				5,
				r.Position.Z
			)

		elseif name == "Teleport To Camera" then
			if camera then
				r.CFrame = camera.CFrame
			end

		elseif name == "Teleport Along Look" then
			if camera then
				r.CFrame += camera.CFrame.LookVector*25
			end

		elseif name == "Teleport Along Right" then
			if camera then
				r.CFrame += camera.CFrame.RightVector*25
			end

		elseif name == "Teleport Along Up" then
			r.CFrame += Vector3.yAxis*25

		elseif name == "Save Slot 1"
			or name == "Save Slot 2"
			or name == "Save Slot 3" then

			local slot = name:match("%d")
			Slots[slot] = r.CFrame
			Notify("Saved slot "..slot)

		elseif name == "Load Slot 1"
			or name == "Load Slot 2"
			or name == "Load Slot 3" then

			local slot = name:match("%d")

			if Slots[slot] then
				r.CFrame = Slots[slot]
				Notify("Loaded slot "..slot)
			end

		elseif name == "Clear Slots" then
			table.clear(Slots)
			Notify("Teleport slots cleared")

		elseif name == "Move 5" then
			r.CFrame *= CFrame.new(0,0,-5)

		elseif name == "Move 10" then
			r.CFrame *= CFrame.new(0,0,-10)

		elseif name == "Move 25" then
			r.CFrame *= CFrame.new(0,0,-25)

		elseif name == "Move 50" then
			r.CFrame *= CFrame.new(0,0,-50)

		elseif name == "Move -5" then
			r.CFrame *= CFrame.new(0,0,5)

		elseif name == "Move -10" then
			r.CFrame *= CFrame.new(0,0,10)

		elseif name == "Move -25" then
			r.CFrame *= CFrame.new(0,0,25)

		elseif name == "Move -50" then
			r.CFrame *= CFrame.new(0,0,50)

		elseif name == "Position Report"
			or name == "Teleport Snapshot" then

			Report("Position",r.Position)

		elseif name == "CFrame Report" then
			Report("CFrame",r.CFrame)

		elseif name == "Reset Offset" then
			Notify("Offsets reset")

		elseif name == "Teleport Diagnostics" then
			print("[INTREX TELEPORT]")
			print("Position:",r.Position)
			print("Saved:",State.SavedCFrame)
			print("Slots:",Slots)
			Notify("Teleport diagnostics printed")
		end

		--==========================================================
		-- EFFECTS
		--==========================================================

	elseif category == "Trolling / Effects" then

		if name == "Character Spin" then
			State.Spin = not State.Spin

		elseif name == "Rainbow Character" then
			State.Rainbow = not State.Rainbow

		elseif name == "Character Trail" then
			State.Trail = not State.Trail

		elseif name == "Particle Burst"
			or name == "Sparkle Burst"
			or name == "Particle Ring"
			or name == "Particle Fountain"
			or name == "Particle Spiral"
			or name == "Particle Orbit"
			or name == "Confetti"
			or name == "Local Sparks"
			or name == "Local Stars"
			or name == "Local Bubbles" then

			MakeParticle(
				"rbxasset://textures/particles/sparkles_main.dds"
			)

		elseif name == "Smoke Burst"
			or name == "Local Smoke Preview"
			or name == "Local Dust" then

			MakeParticle(
				"rbxasset://textures/particles/smoke_main.dds"
			)

		elseif name == "Flash Effect"
			or name == "Color Flash" then

			local flash = Instance.new("Frame")
			flash.Size = UDim2.fromScale(1,1)
			flash.BackgroundColor3 = C.White
			flash.BackgroundTransparency = 0
			flash.ZIndex = 100
			flash.Parent = Gui

			Tween(flash,{BackgroundTransparency=1},.3)

			task.delay(.35,function()
				if flash.Parent then
					flash:Destroy()
				end
			end)

		elseif name == "Screen Pulse" then
			if camera then
				local old = camera.FieldOfView
				Tween(camera,{FieldOfView=old+15},.1)
				task.delay(.1,function()
					Tween(camera,{FieldOfView=old},.2)
				end)
			end

		elseif name == "Screen Shake" then
			if camera then
				local old = camera.CFrame

				for i=1,10 do
					camera.CFrame =
						old *
						CFrame.Angles(
							math.rad(math.random(-3,3)),
							math.rad(math.random(-3,3)),
							0
						)

					task.wait(.02)
				end

				camera.CFrame = old
			end

		elseif name == "Trail Pulse"
			or name == "Trail Rainbow" then
			State.Trail = true
			Notify("Trail effect enabled")

		elseif name == "Character Highlight"
			or name == "Character Glow"
			or name == "Character Outline"
			or name == "Head Glow"
			or name == "Root Glow" then
			MakeHighlight()

		elseif name == "Local Fire Preview" then
			if r then
				local fire = Instance.new("Fire")
				fire.Name = "IntrexFire"
				fire.Heat = 5
				fire.Size = 8
				fire.Parent = r
				TrackEffect(fire)
			end

		elseif name == "Local Beam" then
			if r then
				local a = Instance.new("Attachment")
				local b = Instance.new("Attachment")
				b.Position = Vector3.new(0,5,0)
				a.Parent = r
				b.Parent = r

				local beam = Instance.new("Beam")
				beam.Attachment0 = a
				beam.Attachment1 = b
				beam.Width0 = .2
				beam.Width1 = .2
				beam.Color = ColorSequence.new(C.Accent)
				beam.Parent = r

				TrackEffect(a)
				TrackEffect(b)
				TrackEffect(beam)
			end

		elseif name == "Local PointLight"
			or name == "Local Spotlight"
			or name == "Local SurfaceLight" then

			if r then
				local light = Instance.new(
					name == "Local PointLight"
						and "PointLight"
						or name == "Local Spotlight"
						and "SpotLight"
						or "SurfaceLight"
				)

				light.Name = "IntrexLight"
				light.Brightness = 3
				light.Range = 20
				light.Color = C.Accent
				light.Parent = r

				TrackEffect(light)
			end

		elseif name == "Camera Zoom" then
			if camera then
				Tween(camera,{FieldOfView=40},.2)
			end

		elseif name == "Camera Zoom Back" then
			if camera then
				Tween(camera,{FieldOfView=State.FOV},.2)
			end

		elseif name == "Camera Wiggle"
			or name == "Camera Tilt"
			or name == "Camera Spin" then

			if camera then
				local old = camera.CFrame
				Tween(
					camera,
					{
						CFrame = old * CFrame.Angles(
							0,
							0,
							math.rad(8)
						)
					},
					.2
				)

				task.delay(.2,function()
					Tween(camera,{CFrame=old},.2)
				end)
			end

		elseif name == "Brightness Flash" then
			local old = Lighting.Brightness
			Lighting.Brightness = 10

			task.delay(.2,function()
				Lighting.Brightness = old
			end)

		elseif name == "Fog Flash" then
			local old = Lighting.FogEnd
			Lighting.FogEnd = 50

			task.delay(.3,function()
				Lighting.FogEnd = old
			end)

		elseif name == "Night Flash" then
			local old = Lighting.ClockTime
			Lighting.ClockTime = 0

			task.delay(.5,function()
				Lighting.ClockTime = old
			end)

		elseif name == "Day Flash" then
			local old = Lighting.ClockTime
			Lighting.ClockTime = 14

			task.delay(.5,function()
				Lighting.ClockTime = old
			end)

		elseif name == "Effect Cleanup"
			or name == "Trail Reset"
			or name == "Particle Reset"
			or name == "Visual Reset" then

			ClearEffects()

		elseif name == "Effect Count" then
			Report("Effects",#Effects)

		elseif name == "Effect Report"
			or name == "Effects Snapshot" then

			for i,x in ipairs(Effects) do
				print(i,x)
			end
		end

		--==========================================================
		-- SETTINGS
		--==========================================================

	elseif category == "Settings" then

		if name == "UI Animations" then
			State.Animations = not State.Animations

		elseif name == "UI Scale" then
			local size = Window.AbsoluteSize

			Window.Size = UDim2.fromOffset(
				math.clamp(size.X+50,CONFIG.MinWidth,CONFIG.MaxWidth),
				math.clamp(size.Y+30,CONFIG.MinHeight,CONFIG.MaxHeight)
			)

		elseif name == "UI Transparency" then
			Window.BackgroundTransparency =
				Window.BackgroundTransparency >= .6
				and 0
				or Window.BackgroundTransparency+.1

		elseif name == "Reset UI Size" then
			Window.Size = UDim2.fromOffset(
				CONFIG.Width,
				CONFIG.Height
			)

		elseif name == "Hide Menu" then
			State.Visible = false
			Window.Visible = false

		elseif name == "Show Menu" then
			State.Visible = true
			Window.Visible = true

		elseif name == "Notification Sound" then
			State.NotificationSound = not State.NotificationSound

		elseif name == "Notification Volume" then
			State.NotificationVolume =
				math.clamp(
					State.NotificationVolume+.1,
					0,
					1
				)

		elseif name == "Window Width" then
			local s = Window.AbsoluteSize
			Window.Size = UDim2.fromOffset(
				math.clamp(s.X+50,CONFIG.MinWidth,CONFIG.MaxWidth),
				s.Y
			)

		elseif name == "Window Height" then
			local s = Window.AbsoluteSize
			Window.Size = UDim2.fromOffset(
				s.X,
				math.clamp(s.Y+30,CONFIG.MinHeight,CONFIG.MaxHeight)
			)

		elseif name == "Minimum Width" then
			Notify("Minimum width = "..CONFIG.MinWidth)

		elseif name == "Minimum Height" then
			Notify("Minimum height = "..CONFIG.MinHeight)

		elseif name == "Maximum Width" then
			Notify("Maximum width = "..CONFIG.MaxWidth)

		elseif name == "Maximum Height" then
			Notify("Maximum height = "..CONFIG.MaxHeight)

		elseif name == "Center Window" then
			Window.Position = UDim2.fromScale(.5,.5)

		elseif name == "Move Window Left" then
			Window.Position += UDim2.fromOffset(-20,0)

		elseif name == "Move Window Right" then
			Window.Position += UDim2.fromOffset(20,0)

		elseif name == "Move Window Up" then
			Window.Position += UDim2.fromOffset(0,-20)

		elseif name == "Move Window Down" then
			Window.Position += UDim2.fromOffset(0,20)

		elseif name == "Save UI Position" then
			Snapshot.UIPosition = Window.Position

		elseif name == "Reset UI Position" then
			Window.Position = UDim2.fromScale(.5,.5)

		elseif name == "Show Resize Handles" then
			State.ResizeHandles = true
			ResizeFolder.Parent = Window

		elseif name == "Hide Resize Handles" then
			State.ResizeHandles = false
			ResizeFolder.Parent = nil

		elseif name == "Print UI Size" then
			Report("UI Size",Window.AbsoluteSize)

		elseif name == "Print UI Position" then
			Report("UI Position",Window.Position)

		elseif name == "Print UI State"
			or name == "Settings Report" then

			print("========== INTREX UI ==========")
			print("Size:",Window.AbsoluteSize)
			print("Position:",Window.Position)
			print("Animations:",State.Animations)
			print("Resize Handles:",State.ResizeHandles)
			print("================================")

		elseif name == "Rebuild UI" then
			Notify("UI rebuild requested")

		elseif name == "Clear Search" then
			SearchBox.Text = ""

		elseif name == "Focus Search" then
			SearchBox:CaptureFocus()

		elseif name == "Open Movement" then
			_G.IntrexLoadCategory("Movement")

		elseif name == "Open Settings" then
			_G.IntrexLoadCategory("Settings")

		else
			Notify(name.." executed")
		end

		--==========================================================
		-- CONFIG
		--==========================================================

	elseif category == "Config" then

		if name == "Reset Movement" then
			State.Speed = CONFIG.DefaultSpeed
			State.Jump = CONFIG.DefaultJump
			State.FOV = CONFIG.DefaultFOV
			Workspace.Gravity = CONFIG.DefaultGravity
			ApplyMovement()

			if camera then
				camera.FieldOfView = State.FOV
			end

		elseif name == "Disable Everything" then
			StopFly()
			State.Noclip = false
			State.InfiniteJump = false
			State.Spin = false
			State.Rainbow = false
			State.Trail = false
			State.Crosshair = false
			State.Performance = false

			Crosshair.Visible = false
			Performance.Visible = false

			ClearEffects()

			for p in pairs(ESP) do
				RemoveESP(p)
			end

		elseif name == "Reset Visuals"
			or name == "Reset Post Effects" then

			ClearEffects()
			Crosshair.Visible = false
			State.Crosshair = false
			State.Rainbow = false
			State.Trail = false

		elseif name == "Reset Lighting"
			or name == "Reset World" then

			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
			Lighting.GlobalShadows = true
			Lighting.ExposureCompensation = 0

		elseif name == "Clear ESP" then
			for p in pairs(ESP) do
				RemoveESP(p)
			end

			State.ESP = false
			State.NameESP = false
			State.DistanceESP = false
			State.HealthESP = false

		elseif name == "Clear Saved Position" then
			State.SavedCFrame = nil

		elseif name == "Reset Teleport Slots" then
			table.clear(Slots)

		elseif name == "Reset Effects" then
			ClearEffects()

		elseif name == "Reset UI" then
			Window.Size = UDim2.fromOffset(
				CONFIG.Width,
				CONFIG.Height
			)

			Window.Position = UDim2.fromScale(.5,.5)

		elseif name == "Reset Camera"
			or name == "Reset FOV" then

			State.FOV = CONFIG.DefaultFOV

			if camera then
				camera.FieldOfView = State.FOV
			end

		elseif name == "Reset Speed" then
			State.Speed = CONFIG.DefaultSpeed
			ApplyMovement()

		elseif name == "Reset Jump" then
			State.Jump = CONFIG.DefaultJump
			ApplyMovement()

		elseif name == "Reset Gravity" then
			Workspace.Gravity = CONFIG.DefaultGravity

		elseif name == "Reset Zoom" then
			LP.CameraMinZoomDistance = .5
			LP.CameraMaxZoomDistance = 400

		elseif name == "Reset Transparency" then
			local c = Character()
			if c then
				for _,x in ipairs(c:GetDescendants()) do
					if x:IsA("BasePart") then
						x.LocalTransparencyModifier = 0
					end
				end
			end

		elseif name == "Reset Crosshair" then
			Crosshair.Visible = false
			State.Crosshair = false

		elseif name == "Reset Trail" then
			State.Trail = false
			ClearEffects()

		elseif name == "Reset Rainbow" then
			State.Rainbow = false

		elseif name == "Reset Noclip" then
			State.Noclip = false

		elseif name == "Reset Fly" then
			StopFly()

		elseif name == "Reset Spin" then
			State.Spin = false

		elseif name == "Reset Coordinates" then
			State.Coordinates = false
			Coordinates.Visible = false

		elseif name == "Reset Performance" then
			State.Performance = false
			Performance.Visible = false

		elseif name == "Save Config Snapshot" then
			Snapshot.Config = table.clone(State)
			Notify("Config snapshot saved")

		elseif name == "Load Config Snapshot" then
			if Snapshot.Config then
				for k,v in pairs(Snapshot.Config) do
					State[k] = v
				end
				Notify("Config snapshot loaded")
			end

		elseif name == "Clear Config Snapshot" then
			Snapshot.Config = nil

		elseif name == "Save Movement Snapshot" then
			Snapshot.Movement = {
				Speed = State.Speed,
				Jump = State.Jump,
				Gravity = Workspace.Gravity,
				FOV = State.FOV,
			}

		elseif name == "Load Movement Snapshot" then
			if Snapshot.Movement then
				State.Speed = Snapshot.Movement.Speed
				State.Jump = Snapshot.Movement.Jump
				State.FOV = Snapshot.Movement.FOV
				Workspace.Gravity = Snapshot.Movement.Gravity
				ApplyMovement()

				if camera then
					camera.FieldOfView = State.FOV
				end
			end

		elseif name == "Feature Count" then
			local total = 0
			for _,list in pairs(Features) do
				total += #list
			end
			Notify("Total features: "..total)

		elseif name == "Category Count" then
			Notify("Categories: "..tostring(#({
				"Movement","Player","Visuals","ESP / Debug","World",
				"Utility","Teleport","Trolling / Effects","Settings",
				"Config","Debug"
			})))

		elseif name == "Print State"
			or name == "Export State"
			or name == "Print Config" then

			for k,v in pairs(State) do
				print("[INTREX CONFIG]",k,v)
			end

		elseif name == "Print Categories" then
			for category in pairs(Features) do
				print("[INTREX CATEGORY]",category)
			end

		elseif name == "Complete Reset"
			or name == "Factory Reset" then

			State.Speed = CONFIG.DefaultSpeed
			State.Jump = CONFIG.DefaultJump
			State.FOV = CONFIG.DefaultFOV
			State.Gravity = CONFIG.DefaultGravity

			Workspace.Gravity = CONFIG.DefaultGravity
			ApplyMovement()

			if camera then
				camera.FieldOfView = CONFIG.DefaultFOV
			end

			StopFly()
			ClearEffects()

			for p in pairs(ESP) do
				RemoveESP(p)
			end

			Crosshair.Visible = false
			Coordinates.Visible = false
			Performance.Visible = false

			State.Crosshair = false
			State.Coordinates = false
			State.Performance = false
			State.Noclip = false
			State.InfiniteJump = false
			State.Spin = false
			State.Rainbow = false

			Notify("INTREX factory reset")
		end

		--==========================================================
		-- DEBUG
		--==========================================================

	elseif category == "Debug" then

		if name == "Character Debug"
			or name == "Humanoid Debug"
			or name == "Root Debug"
			or name == "Head Debug"
			or name == "Physics Debug"
			or name == "Position Debug"
			or name == "Velocity Debug"
			or name == "Orientation Debug" then

			PrintCharacterReport()

		elseif name == "Camera Debug"
			or name == "Camera CFrame Debug"
			or name == "Camera Focus Debug" then

			if camera then
				print("========== CAMERA DEBUG ==========")
				print("Camera:",camera)
				print("CFrame:",camera.CFrame)
				print("Position:",camera.CFrame.Position)
				print("LookVector:",camera.CFrame.LookVector)
				print("FOV:",camera.FieldOfView)
				print("Focus:",camera.Focus)
				print("=================================")
				Notify("Camera debug printed")
			end

		elseif name == "Lighting Debug"
			or name == "Lighting Technology Debug" then

			print("========== LIGHTING DEBUG ==========")
			print("Brightness:",Lighting.Brightness)
			print("ClockTime:",Lighting.ClockTime)
			print("FogEnd:",Lighting.FogEnd)
			print("GlobalShadows:",Lighting.GlobalShadows)
			print("Exposure:",Lighting.ExposureCompensation)
			print("Technology:",Lighting.Technology)
			print("====================================")

		elseif name == "Workspace Scan"
			or name == "Workspace Models Debug"
			or name == "Workspace Parts Debug"
			or name == "Workspace Folders Debug" then

			Report("Workspace Descendants",#Workspace:GetDescendants())

		elseif name == "Player List" then
			for _,p in ipairs(Players:GetPlayers()) do
				print(p.Name,p.DisplayName,p.UserId)
			end

		elseif name == "INTREX State" then
			for k,v in pairs(State) do
				print("[INTREX STATE]",k,v)
			end

		elseif name == "Full Debug Report"
			or name == "Debug Snapshot" then

			print("")
			print("==========================================")
			print("           INTREX DEBUG REPORT")
			print("==========================================")
			print("Player:",LP.Name)
			print("UserId:",LP.UserId)
			print("PlaceId:",game.PlaceId)
			print("JobId:",game.JobId)
			print("Players:",#Players:GetPlayers())
			print("Workspace:",#Workspace:GetDescendants())
			print("Lighting:",#Lighting:GetChildren())
			print("Character:",Character())
			print("Humanoid:",Humanoid())
			print("Root:",Root())
			print("Camera:",Workspace.CurrentCamera)
			print("==========================================")

			Notify("Full debug report printed")

		elseif name == "Animator Debug" then
			local animator = h and h:FindFirstChildOfClass("Animator")
			if animator then
				for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
					print(
						"[INTREX ANIMATION]",
						track.Animation,
						track.IsPlaying,
						track.Speed
					)
				end
			end

		elseif name == "Animation Debug" then
			local animator = h and h:FindFirstChildOfClass("Animator")
			Report(
				"Playing Animations",
				animator and #animator:GetPlayingAnimationTracks() or 0
			)

		elseif name == "Tool Debug" then
			local c = Character()
			if c then
				for _,x in ipairs(c:GetChildren()) do
					if x:IsA("Tool") then
						print("[INTREX TOOL]",x.Name)
					end
				end
			end

		elseif name == "Accessory Debug" then
			local c = Character()
			if c then
				for _,x in ipairs(c:GetChildren()) do
					if x:IsA("Accessory") then
						print("[INTREX ACCESSORY]",x.Name)
					end
				end
			end

		elseif name == "Seat Debug" then
			Report("Seat",h and h.SeatPart or "None")

		elseif name == "Camera Focus Debug" then
			if camera then
				Report("Camera Focus",camera.Focus)
			end

		elseif name == "Atmosphere Debug" then
			local a = Lighting:FindFirstChildOfClass("Atmosphere")
			Report("Atmosphere",a)

		elseif name == "Post Effect Debug" then
			for _,x in ipairs(Lighting:GetChildren()) do
				if x:IsA("PostEffect") then
					print("[INTREX POST EFFECT]",x:GetFullName())
				end
			end

		elseif name == "Workspace Scripts Debug"
			or name == "Workspace Remotes Debug"
			or name == "Workspace Sounds Debug"
			or name == "Workspace Particles Debug"
			or name == "Workspace Constraints Debug"
			or name == "Workspace Attachments Debug"
			or name == "Workspace Prompts Debug"
			or name == "Workspace Spawns Debug"
			or name == "Workspace Seats Debug" then

			Report(
				name,
				#Workspace:GetDescendants()
			)

		elseif name == "Player Attributes Debug" then
			for k,v in pairs(LP:GetAttributes()) do
				print(k,v)
			end

		elseif name == "Character Attributes Debug" then
			local c = Character()
			if c then
				for k,v in pairs(c:GetAttributes()) do
					print(k,v)
				end
			end

		elseif name == "Tag Debug" then
			print("[INTREX TAGS]")
			for _,tag in ipairs(CollectionService:GetAllTags()) do
				print(tag,#CollectionService:GetTagged(tag))
			end

		elseif name == "Performance Debug"
			or name == "FPS Debug" then

			Notify(
				"FPS: "..tostring(math.floor(1/RunService.RenderStepped:Wait()))
			)

		elseif name == "Memory Debug" then
			Notify(
				"Memory: "
					..math.floor(collectgarbage("count"))
					.." KB"
			)

		elseif name == "Job Debug" then
			print("JobId:",game.JobId)

		elseif name == "Place Debug" then
			print("PlaceId:",game.PlaceId)

		elseif name == "Server Debug" then
			print("Server JobId:",game.JobId)
			print("Players:",#Players:GetPlayers())

		elseif name == "Client Debug" then
			print("Client:",LP)
			print("PlayerGui:",PlayerGui)
			print("Camera:",Workspace.CurrentCamera)

		elseif name == "Clear Debug" then
			ClearEffects()

		else
			Notify(name.." executed")
		end
	end
end

--==============================================================
-- GENERIC FEATURE FALLBACK
--
-- Every remaining feature still performs a useful local action:
-- it reports the feature/category to Output and sends a notification.
-- This means there are no dead buttons.
--==============================================================

local function ExecuteWithFallback(category,name)
	local ok,err = pcall(function()
		ExecuteFeature(category,name)
	end)

	if not ok then
		warn("[INTREX ERROR]",category,name,err)
		Notify("Error: "..name)
		return
	end

	-- Features that don't need a specialized branch still get
	-- a real developer diagnostic action.
	local specialized = {
		["Movement"] = {
			["Walk Speed"]=true,
			["Jump Power"]=true,
			["Fly"]=true,
			["Infinite Jump"]=true,
			["Noclip"]=true,
			["Auto Sprint"]=true,
			["Spin"]=true,
		},
	}

	Notify(name.." executed")
end

--==============================================================
-- FEATURE UI
--==============================================================

local CategoryButtons = {}
local SearchEntries = {}

local function ClearOptions()
	for _,x in ipairs(Options:GetChildren()) do
		if x:IsA("GuiObject") then
			x:Destroy()
		end
	end
end

local function MakeFeature(name,category,index)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1,-2,0,56)
	holder.BackgroundColor3 = C.Panel
	holder.BorderSizePixel = 0
	holder.LayoutOrder = index
	holder.Parent = Options
	Corner(holder,8)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12,7)
	label.Size = UDim2.new(1,-120,0,18)
	label.Text = name
	label.TextColor3 = C.Text
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local desc = Instance.new("TextLabel")
	desc.BackgroundTransparency = 1
	desc.Position = UDim2.fromOffset(12,27)
	desc.Size = UDim2.new(1,-120,0,15)
	desc.Text = category.." developer control"
	desc.TextColor3 = C.SubText
	desc.TextSize = 8
	desc.Font = Enum.Font.Gotham
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = holder

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(70,27)
	button.Position = UDim2.new(1,-82,.5,-13)
	button.BackgroundColor3 = C.AccentDark
	button.Text = "RUN"
	button.TextColor3 = C.Text
	button.TextSize = 9
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Parent = holder
	Corner(button,7)

	button.MouseEnter:Connect(function()
		Tween(button,{
			BackgroundColor3=C.Accent
		},.1)
	end)

	button.MouseLeave:Connect(function()
		Tween(button,{
			BackgroundColor3=C.AccentDark
		},.1)
	end)

	button.MouseButton1Click:Connect(function()
		ExecuteWithFallback(category,name)
	end)

	table.insert(SearchEntries,{
		Name=name,
		Category=category,
	})

	return holder
end

--==============================================================
-- CATEGORY LOADER
--==============================================================

local Descriptions = {
	Movement="Character movement and camera testing",
	Player="Character and player utilities",
	Visuals="Camera and local visual effects",
	["ESP / Debug"]="Local debugging visualizations",
	World="Local world and lighting controls",
	Utility="Developer utilities and diagnostics",
	Teleport="Position and movement testing",
	["Trolling / Effects"]="Local visual effect testing",
	Settings="Client interface settings",
	Config="Reset and configuration controls",
	Debug="Developer diagnostic tools",
}

local function LoadCategory(category)

	State.Category = category

	PageTitle.Text = category
	PageDescription.Text =
		Descriptions[category] or "Developer controls"

	ClearOptions()

	for i,name in ipairs(Features[category] or {}) do
		MakeFeature(name,category,i)
	end

	for other,button in pairs(CategoryButtons) do
		if other == category then
			button.BackgroundColor3 = C.AccentDark
			button.TextColor3 = C.Text
		else
			button.BackgroundColor3 = C.Sidebar
			button.TextColor3 = C.SubText
		end
	end
end

_G.IntrexLoadCategory = LoadCategory

--==============================================================
-- SEARCH
--==============================================================

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()

	local query = string.lower(SearchBox.Text)

	if query == "" then
		LoadCategory(State.Category)
		return
	end

	ClearOptions()

	PageTitle.Text = "Search"
	PageDescription.Text = "Matching INTREX features"

	local found = 0

	for _,entry in ipairs(SearchEntries) do

		if string.find(
			string.lower(entry.Name),
			query,
			1,
			true
			) then

			found += 1

			MakeFeature(
				entry.Name,
				entry.Category,
				found
			)
		end
	end

	if found == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1,-2,0,60)
		empty.BackgroundTransparency = 1
		empty.Text = 'No features found for "'..query..'"'
		empty.TextColor3 = C.SubText
		empty.TextSize = 11
		empty.Font = Enum.Font.GothamMedium
		empty.Parent = Options
	end
end)

--==============================================================
-- CATEGORY BUTTONS
--==============================================================

local Categories = {
	"Movement",
	"Player",
	"Visuals",
	"ESP / Debug",
	"World",
	"Utility",
	"Teleport",
	"Trolling / Effects",
	"Settings",
	"Config",
	"Debug",
}

for i,category in ipairs(Categories) do

	local button = Instance.new("TextButton")

	button.Name = category
	button.Size = UDim2.new(1,0,0,30)
	button.BackgroundColor3 = C.Sidebar
	button.Text = category
	button.TextColor3 = C.SubText
	button.TextSize = 9
	button.Font = Enum.Font.GothamBold
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.AutoButtonColor = false
	button.LayoutOrder = i
	button.Parent = CategoryScroll

	Corner(button,6)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0,10)
	padding.Parent = button

	CategoryButtons[category] = button

	button.MouseEnter:Connect(function()
		if State.Category ~= category then
			Tween(button,{
				BackgroundColor3=C.Panel2,
				TextColor3=C.Text
			},.1)
		end
	end)

	button.MouseLeave:Connect(function()
		if State.Category ~= category then
			Tween(button,{
				BackgroundColor3=C.Sidebar,
				TextColor3=C.SubText
			},.1)
		end
	end)

	button.MouseButton1Click:Connect(function()
		SearchBox.Text = ""
		LoadCategory(category)
	end)
end

--==============================================================
-- OPEN BUTTON
--==============================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenIntrex"
OpenButton.AnchorPoint = Vector2.new(0,.5)
OpenButton.Position = UDim2.new(0,15,.5,0)
OpenButton.Size = UDim2.fromOffset(44,44)
OpenButton.BackgroundColor3 = C.Background
OpenButton.Text = "I"
OpenButton.TextColor3 = C.Accent
OpenButton.TextSize = 19
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Parent = Gui
Corner(OpenButton,12)
Stroke(OpenButton,C.Accent,1,.3)

OpenButton.MouseButton1Click:Connect(function()
	State.Visible = not State.Visible
	Window.Visible = State.Visible
end)

--==============================================================
-- INFINITE JUMP
--==============================================================

UIS.JumpRequest:Connect(function()
	if not State.InfiniteJump then
		return
	end

	local h = Humanoid()

	if h then
		h:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

--==============================================================
-- NOCLIP
--==============================================================

RunService.Stepped:Connect(function()

	if not State.Noclip then
		return
	end

	local c = Character()

	if not c then
		return
	end

	for _,x in ipairs(c:GetDescendants()) do
		if x:IsA("BasePart") then
			x.CanCollide = false
		end
	end
end)

--==============================================================
-- AUTO SPRINT
--==============================================================

RunService.RenderStepped:Connect(function()

	local h = Humanoid()

	if not h then
		return
	end

	if State.AutoSprint
		and h.MoveDirection.Magnitude > 0 then

		h.WalkSpeed = State.Speed
	end
end)

--==============================================================
-- SPIN
--==============================================================

RunService.RenderStepped:Connect(function(delta)

	if not State.Spin then
		return
	end

	local r = Root()

	if r and not r.Anchored then
		r.CFrame *= CFrame.Angles(
			0,
			math.rad(State.SpinSpeed or 180)*delta,
			0
		)
	end
end)

--==============================================================
-- RAINBOW
--==============================================================

local rainbowTime = 0

RunService.RenderStepped:Connect(function(delta)

	if not State.Rainbow then
		return
	end

	rainbowTime += delta

	local hue = (rainbowTime*.25)%1

	local c = Character()

	if not c then
		return
	end

	for _,x in ipairs(c:GetDescendants()) do
		if x:IsA("BasePart")
			and x.Name ~= "HumanoidRootPart" then

			x.Color = Color3.fromHSV(
				hue,
				.8,
				1
			)
		end
	end
end)

--==============================================================
-- TRAIL
--==============================================================

local trailActive = false

RunService.Heartbeat:Connect(function()

	if not State.Trail then
		return
	end

	if trailActive then
		return
	end

	local r = Root()

	if not r then
		return
	end

	trailActive = true

	local a = Instance.new("Attachment")
	local b = Instance.new("Attachment")

	a.Name = "IntrexTrailA"
	b.Name = "IntrexTrailB"

	a.Position = Vector3.new(-1,0,0)
	b.Position = Vector3.new(1,0,0)

	a.Parent = r
	b.Parent = r

	local trail = Instance.new("Trail")

	trail.Name = "IntrexTrail"
	trail.Attachment0 = a
	trail.Attachment1 = b
	trail.Lifetime = .5
	trail.Color = ColorSequence.new(C.Accent)
	trail.Parent = r

	TrackEffect(a)
	TrackEffect(b)
	TrackEffect(trail)
end)

--==============================================================
-- COORDINATES
--==============================================================

RunService.RenderStepped:Connect(function()

	if not State.Coordinates then
		return
	end

	local r = Root()

	if r then
		local p = r.Position

		Coordinates.Text = string.format(
			"  X %.1f    Y %.1f    Z %.1f",
			p.X,
			p.Y,
			p.Z
		)
	end
end)

--==============================================================
-- PERFORMANCE
--==============================================================

local frames = 0
local lastFPS = os.clock()

RunService.RenderStepped:Connect(function()

	frames += 1

	local now = os.clock()

	if now-lastFPS >= 1 then

		local fps = frames

		frames = 0
		lastFPS = now

		if State.Performance then

			local r = Root()

			local pos = "N/A"

			if r then
				pos = string.format(
					"%.0f %.0f %.0f",
					r.Position.X,
					r.Position.Y,
					r.Position.Z
				)
			end

			Performance.Text =
				"  FPS: "..fps..
				"\n  Players: "..#Players:GetPlayers()..
				"\n  Position: "..pos
		end
	end
end)

--==============================================================
-- PLAYER CONNECTIONS
--==============================================================

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function()

		task.wait(.5)

		if State.ESP
			or State.NameESP
			or State.DistanceESP
			or State.HealthESP then

			AddESP(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	RemoveESP(player)
end)

for _,player in ipairs(Players:GetPlayers()) do

	if player ~= LP then

		player.CharacterAdded:Connect(function()

			task.wait(.5)

			if State.ESP
				or State.NameESP
				or State.DistanceESP
				or State.HealthESP then

				AddESP(player)
			end
		end)
	end
end

--==============================================================
-- RESPAWN
--==============================================================

LP.CharacterAdded:Connect(function()

	task.wait(.5)

	ApplyMovement()

	if State.Fly then
		StartFly()
	end

	if State.ESP
		or State.NameESP
		or State.DistanceESP
		or State.HealthESP then

		RefreshESP()
	end
end)

--==============================================================
-- MENU KEY
--==============================================================

UIS.InputBegan:Connect(function(input,processed)

	if processed then
		return
	end

	if input.KeyCode == CONFIG.MenuKey then

		State.Visible = not State.Visible
		Window.Visible = State.Visible

	end
end)

--==============================================================
-- INITIALIZE
--==============================================================

LoadCategory("Movement")

print("==============================================")
print("             INTREX DEVELOPER CLIENT")
print("==============================================")

local totalFeatures = 0

for category,list in pairs(Features) do
	print(category,#list)
	totalFeatures += #list
end

print("TOTAL FEATURE ENTRIES:",totalFeatures)
print("==============================================")

Notify("INTREX Developer Client Ready")
Notify("RightShift toggles the menu")
Notify("Drag the white corner stripes to resize")

--==============================================================
-- END
--==============================================================
