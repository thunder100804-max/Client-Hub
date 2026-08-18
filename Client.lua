--==============================================================
-- INTREX DEVELOPER CLIENT
-- Roblox Studio LocalScript
--
-- Designed for testing YOUR OWN Roblox experience.
--
-- FEATURES
-- • Global feature search
-- • Animated UI
-- • Draggable window
-- • Resizable window
-- • RightShift menu toggle
-- • Notification system + sound
-- • Movement controls
-- • Player utilities
-- • Visual controls
-- • ESP/debug visualization
-- • World controls
-- • Utility tools
-- • Teleport utilities
-- • Local effects
-- • Settings
-- • Configuration reset
-- • Debug tools
--
-- COMBAT CATEGORY: REMOVED
--==============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
	WindowWidth = 650,
	WindowHeight = 450,

	MinWidth = 500,
	MaxWidth = 900,

	MinHeight = 350,
	MaxHeight = 700,

	DefaultWalkSpeed = 16,
	DefaultJumpPower = 50,
	DefaultFOV = 70,

	MinSpeed = 0,
	MaxSpeed = 150,

	MinJump = 0,
	MaxJump = 200,

	MinFOV = 40,
	MaxFOV = 120,

	MinFlySpeed = 10,
	MaxFlySpeed = 250,

	NotificationDuration = 2.5,

	MenuKey = Enum.KeyCode.RightShift,

	NotificationSoundId =
		"rbxasset://sounds/electronicpingshort.wav",
}

--==============================================================
-- COLORS
--==============================================================

local C = {
	Background = Color3.fromRGB(9, 11, 15),
	Sidebar = Color3.fromRGB(13, 16, 21),
	Panel = Color3.fromRGB(18, 22, 28),
	Panel2 = Color3.fromRGB(24, 29, 36),

	Accent = Color3.fromRGB(45, 174, 239),
	AccentDark = Color3.fromRGB(29, 117, 171),

	Text = Color3.fromRGB(245, 247, 250),
	SubText = Color3.fromRGB(143, 151, 164),

	Off = Color3.fromRGB(62, 68, 78),
	Red = Color3.fromRGB(230, 70, 70),

	SliderBackground = Color3.fromRGB(38, 43, 51),
}

--==============================================================
-- CLEAN PREVIOUS CLIENT
--==============================================================

local OldGui = PlayerGui:FindFirstChild("IntrexClient")

if OldGui then
	OldGui:Destroy()
end

--==============================================================
-- STATE
--==============================================================

local State = {
	WindowVisible = true,

	WalkSpeed = CONFIG.DefaultWalkSpeed,
	JumpPower = CONFIG.DefaultJumpPower,
	FOV = CONFIG.DefaultFOV,

	Fly = false,
	FlySpeed = 70,

	InfiniteJump = false,
	Noclip = false,
	AutoSprint = false,

	Spin = false,

	ThirdPerson = false,

	Fullbright = false,
	NoFog = false,

	Crosshair = false,
	Trails = false,
	RainbowCharacter = false,

	Coordinates = false,
	Performance = false,

	PlayerESP = false,
	NameESP = false,
	DistanceESP = false,
	HealthESP = false,

	NotificationSound = true,
	NotificationVolume = 0.5,

	Animations = true,

	UITransparency = 0,
	UIScale = 1,

	SavedPosition = nil,

	SelectedCategory = "Movement",
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

--==============================================================
-- HELPERS
--==============================================================

local function Corner(object, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = object
	return c
end

local function AddStroke(object, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = object
	return s
end

local function Tween(object, properties, duration)
	if not State.Animations then
		for property, value in pairs(properties) do
			object[property] = value
		end
		return
	end

	local animation = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.15,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		),
		properties
	)

	animation:Play()

	return animation
end

local function GetCharacter()
	return LocalPlayer.Character
end

local function GetHumanoid()
	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

--==============================================================
-- MAIN WINDOW
--==============================================================

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.fromScale(0.5, 0.5)
Window.Size = UDim2.fromOffset(
	CONFIG.WindowWidth,
	CONFIG.WindowHeight
)
Window.BackgroundColor3 = C.Background
Window.BackgroundTransparency = State.UITransparency
Window.BorderSizePixel = 0
Window.Parent = Gui

Corner(Window, 12)
AddStroke(Window, Color3.fromRGB(60, 68, 80), 1, 0.2)

--==============================================================
-- TOP BAR
--==============================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = C.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = Window

Corner(TopBar, 12)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(16, 7)
Title.Size = UDim2.fromOffset(250, 20)
Title.Text = "INTREX"
Title.TextColor3 = C.Text
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.fromOffset(16, 27)
SubTitle.Size = UDim2.fromOffset(300, 15)
SubTitle.Text = "DEVELOPER CLIENT  •  LOCAL TESTING"
SubTitle.TextColor3 = C.Accent
SubTitle.TextSize = 8
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30, 30)
Close.Position = UDim2.new(1, -39, 0, 11)
Close.BackgroundColor3 = C.Panel2
Close.Text = "×"
Close.TextColor3 = C.SubText
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = TopBar

Corner(Close, 8)

Close.MouseEnter:Connect(function()
	Tween(Close, {
		BackgroundColor3 = C.Red,
		TextColor3 = C.Text,
	}, 0.1)
end)

Close.MouseLeave:Connect(function()
	Tween(Close, {
		BackgroundColor3 = C.Panel2,
		TextColor3 = C.SubText,
	}, 0.1)
end)

Close.MouseButton1Click:Connect(function()
	State.WindowVisible = false
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

UserInputService.InputChanged:Connect(function(input)

	if not Dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local Delta = input.Position - DragStart

	Window.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)
end)

--==============================================================
-- SIDEBAR
--==============================================================

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(0, 52)
Sidebar.Size = UDim2.new(0, 155, 1, -52)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Window

local CategoryScroll = Instance.new("ScrollingFrame")
CategoryScroll.Position = UDim2.fromOffset(8, 8)
CategoryScroll.Size = UDim2.new(1, -16, 1, -16)
CategoryScroll.BackgroundTransparency = 1
CategoryScroll.BorderSizePixel = 0
CategoryScroll.ScrollBarThickness = 2
CategoryScroll.ScrollBarImageColor3 = C.Accent
CategoryScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CategoryScroll.Parent = Sidebar

local CategoryLayout = Instance.new("UIListLayout")
CategoryLayout.Padding = UDim.new(0, 4)
CategoryLayout.Parent = CategoryScroll

--==============================================================
-- CONTENT
--==============================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(155, 52)
Content.Size = UDim2.new(1, -155, 1, -52)
Content.BackgroundColor3 = C.Background
Content.BorderSizePixel = 0
Content.Parent = Window

local PageTitle = Instance.new("TextLabel")
PageTitle.BackgroundTransparency = 1
PageTitle.Position = UDim2.fromOffset(18, 10)
PageTitle.Size = UDim2.new(1, -250, 0, 25)
PageTitle.Text = "Movement"
PageTitle.TextColor3 = C.Text
PageTitle.TextSize = 18
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

local PageDescription = Instance.new("TextLabel")
PageDescription.BackgroundTransparency = 1
PageDescription.Position = UDim2.fromOffset(18, 34)
PageDescription.Size = UDim2.new(1, -36, 0, 17)
PageDescription.Text = "Movement and character controls"
PageDescription.TextColor3 = C.SubText
PageDescription.TextSize = 9
PageDescription.Font = Enum.Font.Gotham
PageDescription.TextXAlignment = Enum.TextXAlignment.Left
PageDescription.Parent = Content

--==============================================================
-- SEARCH
--==============================================================

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "FeatureSearch"
SearchBox.Position = UDim2.new(1, -205, 0, 13)
SearchBox.Size = UDim2.fromOffset(185, 30)
SearchBox.BackgroundColor3 = C.Panel
SearchBox.TextColor3 = C.Text
SearchBox.PlaceholderColor3 = C.SubText
SearchBox.PlaceholderText = "Search features..."
SearchBox.Text = ""
SearchBox.TextSize = 9
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Content

Corner(SearchBox, 8)
AddStroke(SearchBox, C.Panel2, 1, 0)

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0, 10)
SearchPadding.PaddingRight = UDim.new(0, 10)
SearchPadding.Parent = SearchBox

--==============================================================
-- OPTIONS
--==============================================================

local Options = Instance.new("ScrollingFrame")
Options.Position = UDim2.fromOffset(14, 60)
Options.Size = UDim2.new(1, -28, 1, -70)
Options.BackgroundTransparency = 1
Options.BorderSizePixel = 0
Options.ScrollBarThickness = 3
Options.ScrollBarImageColor3 = C.Accent
Options.AutomaticCanvasSize = Enum.AutomaticSize.Y
Options.Parent = Content

local OptionsLayout = Instance.new("UIListLayout")
OptionsLayout.Padding = UDim.new(0, 7)
OptionsLayout.Parent = Options

--==============================================================
-- NOTIFICATION SYSTEM
--==============================================================

local NotificationHolder = Instance.new("Frame")
NotificationHolder.AnchorPoint = Vector2.new(1, 0)
NotificationHolder.Position = UDim2.new(1, -15, 0, 15)
NotificationHolder.Size = UDim2.fromOffset(280, 350)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = Gui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0, 6)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.Parent = NotificationHolder

local NotificationSound = Instance.new("Sound")
NotificationSound.Name = "IntrexNotificationSound"
NotificationSound.SoundId = CONFIG.NotificationSoundId
NotificationSound.Volume = State.NotificationVolume
NotificationSound.Parent = SoundService

local function Notify(message)

	if State.NotificationSound then
		NotificationSound.Volume = State.NotificationVolume
		NotificationSound:Play()
	end

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.fromOffset(260, 42)
	Frame.BackgroundColor3 = C.Panel
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0
	Frame.Parent = NotificationHolder

	Corner(Frame, 8)
	AddStroke(Frame, C.Accent, 1, 0.5)

	local Bar = Instance.new("Frame")
	Bar.Size = UDim2.fromOffset(3, 26)
	Bar.Position = UDim2.fromOffset(7, 8)
	Bar.BackgroundColor3 = C.Accent
	Bar.BorderSizePixel = 0
	Bar.Parent = Frame

	Corner(Bar, 3)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(17, 0)
	Label.Size = UDim2.new(1, -25, 1, 0)
	Label.Text = message
	Label.TextColor3 = C.Text
	Label.TextSize = 9
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	Tween(Frame, {
		BackgroundTransparency = 0.05,
	}, 0.15)

	task.delay(CONFIG.NotificationDuration, function()

		if not Frame.Parent then
			return
		end

		Tween(Frame, {
			BackgroundTransparency = 1,
		}, 0.2)

		Tween(Label, {
			TextTransparency = 1,
		}, 0.2)

		task.wait(0.25)

		if Frame.Parent then
			Frame:Destroy()
		end
	end)
end

--==============================================================
-- UI COMPONENTS
--==============================================================

local function CreateToggle(name, description, default, callback)

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1, -2, 0, 56)
	Holder.BackgroundColor3 = C.Panel
	Holder.BorderSizePixel = 0
	Holder.Parent = Options

	Corner(Holder, 8)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(12, 7)
	Label.Size = UDim2.new(1, -110, 0, 18)
	Label.Text = name
	Label.TextColor3 = C.Text
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local Desc = Instance.new("TextLabel")
	Desc.BackgroundTransparency = 1
	Desc.Position = UDim2.fromOffset(12, 27)
	Desc.Size = UDim2.new(1, -110, 0, 15)
	Desc.Text = description or ""
	Desc.TextColor3 = C.SubText
	Desc.TextSize = 8
	Desc.Font = Enum.Font.Gotham
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.Parent = Holder

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.fromOffset(58, 27)
	Button.Position = UDim2.new(1, -70, 0.5, -13)
	Button.BackgroundColor3 = default and C.Accent or C.Off
	Button.Text = default and "ON" or "OFF"
	Button.TextColor3 = Color3.new(1, 1, 1)
	Button.TextSize = 9
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false
	Button.Parent = Holder

	Corner(Button, 7)

	local Enabled = default or false

	local function Update(value)

		Enabled = value

		Button.Text = Enabled and "ON" or "OFF"

		Tween(Button, {
			BackgroundColor3 = Enabled and C.Accent or C.Off,
		}, 0.12)

		if callback then
			callback(Enabled)
		end
	end

	Button.MouseButton1Click:Connect(function()
		Update(not Enabled)
	end)

	return Holder, Update
end

local function CreateSlider(
	name,
	description,
	minimum,
	maximum,
	default,
	callback
)

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1, -2, 0, 74)
	Holder.BackgroundColor3 = C.Panel
	Holder.BorderSizePixel = 0
	Holder.Parent = Options

	Corner(Holder, 8)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(12, 7)
	Label.Size = UDim2.new(1, -80, 0, 18)
	Label.Text = name
	Label.TextColor3 = C.Text
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local Value = Instance.new("TextLabel")
	Value.BackgroundTransparency = 1
	Value.Position = UDim2.new(1, -65, 0, 7)
	Value.Size = UDim2.fromOffset(52, 18)
	Value.Text = tostring(default)
	Value.TextColor3 = C.Accent
	Value.TextSize = 10
	Value.Font = Enum.Font.GothamBold
	Value.TextXAlignment = Enum.TextXAlignment.Right
	Value.Parent = Holder

	local Desc = Instance.new("TextLabel")
	Desc.BackgroundTransparency = 1
	Desc.Position = UDim2.fromOffset(12, 26)
	Desc.Size = UDim2.new(1, -24, 0, 13)
	Desc.Text = description or ""
	Desc.TextColor3 = C.SubText
	Desc.TextSize = 8
	Desc.Font = Enum.Font.Gotham
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.Parent = Holder

	local Bar = Instance.new("Frame")
	Bar.Position = UDim2.fromOffset(12, 51)
	Bar.Size = UDim2.new(1, -24, 0, 6)
	Bar.BackgroundColor3 = C.SliderBackground
	Bar.BorderSizePixel = 0
	Bar.Parent = Holder

	Corner(Bar, 5)

	local Percent =
		math.clamp(
			(default - minimum)
				/ math.max(maximum - minimum, 1),
			0,
			1
		)

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new(Percent, 0, 1, 0)
	Fill.BackgroundColor3 = C.Accent
	Fill.BorderSizePixel = 0
	Fill.Parent = Bar

	Corner(Fill, 5)

	local Knob = Instance.new("Frame")
	Knob.AnchorPoint = Vector2.new(0.5, 0.5)
	Knob.Position = UDim2.new(Percent, 0, 0.5, 0)
	Knob.Size = UDim2.fromOffset(12, 12)
	Knob.BackgroundColor3 = C.Text
	Knob.BorderSizePixel = 0
	Knob.Parent = Bar

	Corner(Knob, 20)

	local Hitbox = Instance.new("TextButton")
	Hitbox.BackgroundTransparency = 1
	Hitbox.Size = UDim2.new(1, 12, 1, 24)
	Hitbox.Position = UDim2.fromOffset(-6, -12)
	Hitbox.Text = ""
	Hitbox.Parent = Bar

	local Sliding = false

	local function SetValue(value)

		value = math.clamp(value, minimum, maximum)
		value = math.floor(value + 0.5)

		local percent =
			(value - minimum)
				/ math.max(maximum - minimum, 1)

		Value.Text = tostring(value)

		Tween(Fill, {
			Size = UDim2.new(percent, 0, 1, 0),
		}, 0.06)

		Tween(Knob, {
			Position =
				UDim2.new(percent, 0, 0.5, 0),
		}, 0.06)

		if callback then
			callback(value)
		end
	end

	local function FromInput(input)

		if Bar.AbsoluteSize.X <= 0 then
			return
		end

		local percent =
			math.clamp(
				(input.Position.X
					- Bar.AbsolutePosition.X)
					/ Bar.AbsoluteSize.X,
				0,
				1
			)

		SetValue(
			minimum
				+ (maximum - minimum)
				* percent
		)
	end

	Hitbox.InputBegan:Connect(function(input)

		if input.UserInputType
			== Enum.UserInputType.MouseButton1
			or input.UserInputType
			== Enum.UserInputType.Touch then

			Sliding = true
			FromInput(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)

		if not Sliding then
			return
		end

		if input.UserInputType
			== Enum.UserInputType.MouseMovement
			or input.UserInputType
			== Enum.UserInputType.Touch then

			FromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)

		if input.UserInputType
			== Enum.UserInputType.MouseButton1
			or input.UserInputType
			== Enum.UserInputType.Touch then

			Sliding = false
		end
	end)

	return Holder, SetValue
end

local function CreateAction(name, description, callback)

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1, -2, 0, 56)
	Holder.BackgroundColor3 = C.Panel
	Holder.BorderSizePixel = 0
	Holder.Parent = Options

	Corner(Holder, 8)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(12, 7)
	Label.Size = UDim2.new(1, -115, 0, 18)
	Label.Text = name
	Label.TextColor3 = C.Text
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local Desc = Instance.new("TextLabel")
	Desc.BackgroundTransparency = 1
	Desc.Position = UDim2.fromOffset(12, 27)
	Desc.Size = UDim2.new(1, -115, 0, 15)
	Desc.Text = description or ""
	Desc.TextColor3 = C.SubText
	Desc.TextSize = 8
	Desc.Font = Enum.Font.Gotham
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.Parent = Holder

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.fromOffset(68, 27)
	Button.Position = UDim2.new(1, -80, 0.5, -13)
	Button.BackgroundColor3 = C.AccentDark
	Button.Text = "RUN"
	Button.TextColor3 = C.Text
	Button.TextSize = 9
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false
	Button.Parent = Holder

	Corner(Button, 7)

	Button.MouseEnter:Connect(function()
		Tween(Button, {
			BackgroundColor3 = C.Accent,
		}, 0.1)
	end)

	Button.MouseLeave:Connect(function()
		Tween(Button, {
			BackgroundColor3 = C.AccentDark,
		}, 0.1)
	end)

	Button.MouseButton1Click:Connect(function()

		if callback then
			callback()
		end
	end)

	return Holder
end

--==============================================================
-- MOVEMENT FUNCTIONS
--==============================================================

local function ApplySpeed(value)

	State.WalkSpeed = value

	local humanoid = GetHumanoid()

	if humanoid then
		humanoid.WalkSpeed = value
	end
end

local function ApplyJump(value)

	State.JumpPower = value

	local humanoid = GetHumanoid()

	if humanoid then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = value
	end
end

--==============================================================
-- INFINITE JUMP
--==============================================================

UserInputService.JumpRequest:Connect(function()

	if not State.InfiniteJump then
		return
	end

	local humanoid = GetHumanoid()

	if humanoid then
		humanoid:ChangeState(
			Enum.HumanoidStateType.Jumping
		)
	end
end)

--==============================================================
-- FLY
--==============================================================

local FlyConnection

local function StopFly()

	State.Fly = false

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	local root = GetRoot()

	if root then

		local velocity =
			root:FindFirstChild("IntrexFlyVelocity")

		if velocity then
			velocity:Destroy()
		end
	end
end

local function StartFly()

	StopFly()

	State.Fly = true

	FlyConnection =
		RunService.RenderStepped:Connect(function()

			if not State.Fly then
				return
			end

			local root = GetRoot()
			local camera = Workspace.CurrentCamera

			if not root or not camera then
				return
			end

			local velocity =
				root:FindFirstChild(
					"IntrexFlyVelocity"
				)

			if not velocity then

				velocity =
					Instance.new("BodyVelocity")

				velocity.Name =
					"IntrexFlyVelocity"

				velocity.MaxForce =
					Vector3.new(
						math.huge,
						math.huge,
						math.huge
					)

				velocity.Parent = root
			end

			local direction = Vector3.zero
			local cameraCF = camera.CFrame

			if UserInputService:IsKeyDown(
				Enum.KeyCode.W
			) then
				direction += cameraCF.LookVector
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.S
			) then
				direction -= cameraCF.LookVector
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.A
			) then
				direction -= cameraCF.RightVector
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.D
			) then
				direction += cameraCF.RightVector
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.Space
			) then
				direction += Vector3.yAxis
			end

			if UserInputService:IsKeyDown(
				Enum.KeyCode.LeftControl
			) then
				direction -= Vector3.yAxis
			end

			if direction.Magnitude > 0 then
				direction = direction.Unit
			end

			velocity.Velocity =
				direction * State.FlySpeed
		end)
end

--==============================================================
-- ESP
--==============================================================

local ESPObjects = {}

local function RemoveESP(player)

	local data = ESPObjects[player]

	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end

	if data.Billboard then
		data.Billboard:Destroy()
	end

	if data.Connection then
		data.Connection:Disconnect()
	end

	ESPObjects[player] = nil
end

local function AddESP(player)

	if player == LocalPlayer then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	RemoveESP(player)

	local highlight

	if State.PlayerESP then

		highlight = Instance.new("Highlight")
		highlight.Name = "IntrexPlayerDebug"
		highlight.Adornee = character
		highlight.FillColor = C.Accent
		highlight.OutlineColor = C.Text
		highlight.FillTransparency = 0.78
		highlight.OutlineTransparency = 0
		highlight.Parent = character
	end

	local billboard
	local connection

	if State.NameESP
		or State.DistanceESP
		or State.HealthESP then

		local head =
			character:FindFirstChild("Head")

		if head then

			billboard =
				Instance.new("BillboardGui")

			billboard.Name =
				"IntrexPlayerInfo"

			billboard.Adornee = head
			billboard.Size =
				UDim2.fromOffset(220, 55)

			billboard.StudsOffset =
				Vector3.new(0, 3, 0)

			billboard.AlwaysOnTop = true
			billboard.Parent = character

			local text =
				Instance.new("TextLabel")

			text.BackgroundTransparency = 1
			text.Size = UDim2.fromScale(1, 1)
			text.TextColor3 = C.Text
			text.TextStrokeTransparency = 0.45
			text.TextSize = 10
			text.Font = Enum.Font.GothamBold
			text.Parent = billboard

			connection =
				RunService.RenderStepped:Connect(
					function()

						if not billboard.Parent then
							if connection then
								connection:Disconnect()
							end
							return
						end

						local pieces = {}

						if State.NameESP then
							table.insert(
								pieces,
								player.DisplayName
							)
						end

						if State.DistanceESP then

							local mine = GetRoot()

							local their =
								character:
								FindFirstChild(
									"HumanoidRootPart"
								)

							if mine and their then

								table.insert(
									pieces,
									math.floor(
										(
											mine.Position
											- their.Position
										).Magnitude
									) .. " studs"
								)
							end
						end

						if State.HealthESP then

							local humanoid =
								character:
								FindFirstChildOfClass(
									"Humanoid"
								)

							if humanoid then

								table.insert(
									pieces,
									math.floor(
										humanoid.Health
									)
									.. "/"
									.. math.floor(
										humanoid.MaxHealth
									)
								)
							end
						end

						text.Text =
							table.concat(
								pieces,
								"  •  "
							)
					end
				)
		end
	end

	ESPObjects[player] = {
		Highlight = highlight,
		Billboard = billboard,
		Connection = connection,
	}
end

local function RefreshESP()

	for player in pairs(ESPObjects) do
		RemoveESP(player)
	end

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if player ~= LocalPlayer then
			AddESP(player)
		end
	end
end

--==============================================================
-- CROSSHAIR
--==============================================================

local Crosshair = Instance.new("Frame")
Crosshair.Name = "IntrexCrosshair"
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)
Crosshair.Size = UDim2.fromOffset(26, 26)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = false
Crosshair.Parent = Gui

local function MakeCrosshairLine(size, position)

	local line = Instance.new("Frame")
	line.Size = size
	line.Position = position
	line.BackgroundColor3 = C.Accent
	line.BorderSizePixel = 0
	line.Parent = Crosshair
end

MakeCrosshairLine(
	UDim2.fromOffset(2, 8),
	UDim2.fromOffset(12, 0)
)

MakeCrosshairLine(
	UDim2.fromOffset(2, 8),
	UDim2.fromOffset(12, 18)
)

MakeCrosshairLine(
	UDim2.fromOffset(8, 2),
	UDim2.fromOffset(0, 12)
)

MakeCrosshairLine(
	UDim2.fromOffset(8, 2),
	UDim2.fromOffset(18, 12)
)

--==============================================================
-- COORDINATES
--==============================================================

local CoordinatesLabel = Instance.new("TextLabel")
CoordinatesLabel.AnchorPoint = Vector2.new(0, 1)
CoordinatesLabel.Position =
	UDim2.new(0, 15, 1, -15)

CoordinatesLabel.Size =
	UDim2.fromOffset(270, 24)

CoordinatesLabel.BackgroundColor3 = C.Panel
CoordinatesLabel.TextColor3 = C.Text
CoordinatesLabel.TextSize = 10
CoordinatesLabel.Font = Enum.Font.Code
CoordinatesLabel.TextXAlignment =
	Enum.TextXAlignment.Left

CoordinatesLabel.Visible = false
CoordinatesLabel.Parent = Gui

Corner(CoordinatesLabel, 6)

--==============================================================
-- PERFORMANCE DISPLAY
--==============================================================

local PerformanceLabel = Instance.new("TextLabel")
PerformanceLabel.AnchorPoint =
	Vector2.new(1, 1)

PerformanceLabel.Position =
	UDim2.new(1, -15, 1, -15)

PerformanceLabel.Size =
	UDim2.fromOffset(210, 55)

PerformanceLabel.BackgroundColor3 = C.Panel
PerformanceLabel.TextColor3 = C.Text
PerformanceLabel.TextSize = 9
PerformanceLabel.Font = Enum.Font.Code
PerformanceLabel.TextXAlignment =
	Enum.TextXAlignment.Left

PerformanceLabel.TextYAlignment =
	Enum.TextYAlignment.Center

PerformanceLabel.Visible = false
PerformanceLabel.Parent = Gui

Corner(PerformanceLabel, 7)

--==============================================================
-- TRAILS
--==============================================================

local function SetTrail(enabled)

	State.Trails = enabled

	local root = GetRoot()

	if not root then
		return
	end

	for _, object in ipairs(
		root:GetChildren()
	) do

		if object.Name == "IntrexTrail"
			or object.Name == "IntrexTrailA0"
			or object.Name == "IntrexTrailA1" then

			object:Destroy()
		end
	end

	if not enabled then
		return
	end

	local a0 = Instance.new("Attachment")
	a0.Name = "IntrexTrailA0"
	a0.Position = Vector3.new(-1, 0, 0)
	a0.Parent = root

	local a1 = Instance.new("Attachment")
	a1.Name = "IntrexTrailA1"
	a1.Position = Vector3.new(1, 0, 0)
	a1.Parent = root

	local trail = Instance.new("Trail")
	trail.Name = "IntrexTrail"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.5
	trail.Color =
		ColorSequence.new(C.Accent)

	trail.Parent = root
end

--==============================================================
-- FULLBRIGHT
--==============================================================

local OriginalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	ExposureCompensation =
		Lighting.ExposureCompensation,
}

local function SetFullbright(enabled)

	State.Fullbright = enabled

	if enabled then

		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.ExposureCompensation = 0

	else

		Lighting.Brightness =
			OriginalLighting.Brightness

		Lighting.ClockTime =
			OriginalLighting.ClockTime

		Lighting.FogEnd =
			OriginalLighting.FogEnd

		Lighting.GlobalShadows =
			OriginalLighting.GlobalShadows

		Lighting.ExposureCompensation =
			OriginalLighting.ExposureCompensation
	end
end

--==============================================================
-- CATEGORIES
-- COMBAT INTENTIONALLY REMOVED
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

local CategoryButtons = {}

--==============================================================
-- CATEGORY DESCRIPTIONS
--==============================================================

local Descriptions = {
	Movement = "Character movement and camera controls",
	Player = "Character and player utilities",
	Visuals = "Camera, lighting and visual effects",
	["ESP / Debug"] = "Local debugging visualizations",
	World = "Local world and lighting controls",
	Utility = "Developer utilities and diagnostics",
	Teleport = "Position and movement testing",
	["Trolling / Effects"] = "Local visual effect testing",
	Settings = "Client interface settings",
	Config = "Reset and configuration controls",
	Debug = "Developer diagnostic tools",
}

--==============================================================
-- CLEAR PAGE
--==============================================================

local function ClearPage()

	for _, object in ipairs(
		Options:GetChildren()
	) do

		if object:IsA("GuiObject") then
			object:Destroy()
		end
	end
end

--==============================================================
-- RESET FUNCTIONS
--==============================================================

local function ResetMovement()

	ApplySpeed(
		CONFIG.DefaultWalkSpeed
	)

	ApplyJump(
		CONFIG.DefaultJumpPower
	)

	State.FlySpeed = 70
	State.FOV = CONFIG.DefaultFOV

	local camera = Workspace.CurrentCamera

	if camera then
		camera.FieldOfView =
			CONFIG.DefaultFOV
	end
end

local function DisableFeatures()

	StopFly()

	State.InfiniteJump = false
	State.Noclip = false
	State.AutoSprint = false
	State.Spin = false
	State.RainbowCharacter = false

	Crosshair.Visible = false
	CoordinatesLabel.Visible = false
	PerformanceLabel.Visible = false

	State.Crosshair = false
	State.Coordinates = false
	State.Performance = false

	SetTrail(false)

	for player in pairs(ESPObjects) do
		RemoveESP(player)
	end

	State.PlayerESP = false
	State.NameESP = false
	State.DistanceESP = false
	State.HealthESP = false

	Notify("All active features disabled")
end

--==============================================================
-- CATEGORY LOADER
--==============================================================

local function LoadCategory(category)

	State.SelectedCategory = category

	PageTitle.Text = category
	PageDescription.Text =
		Descriptions[category] or
		(category .. " controls")

	ClearPage()

	--============================================================
	-- MOVEMENT
	--============================================================

	if category == "Movement" then

		CreateSlider(
			"Walk Speed",
			"Adjust your local Humanoid movement speed",
			CONFIG.MinSpeed,
			CONFIG.MaxSpeed,
			State.WalkSpeed,
			ApplySpeed
		)

		CreateSlider(
			"Jump Power",
			"Adjust your local jump strength",
			CONFIG.MinJump,
			CONFIG.MaxJump,
			State.JumpPower,
			ApplyJump
		)

		CreateSlider(
			"Fly Speed",
			"Movement speed while developer fly is active",
			CONFIG.MinFlySpeed,
			CONFIG.MaxFlySpeed,
			State.FlySpeed,
			function(v)
				State.FlySpeed = v
			end
		)

		CreateToggle(
			"Fly",
			"WASD + Space/Ctrl developer movement",
			State.Fly,
			function(v)

				if v then
					StartFly()
					Notify("Developer fly enabled")
				else
					StopFly()
					Notify("Developer fly disabled")
				end
			end
		)

		CreateToggle(
			"Infinite Jump",
			"Allow repeated local jump requests",
			State.InfiniteJump,
			function(v)
				State.InfiniteJump = v
			end
		)

		CreateToggle(
			"Noclip",
			"Disable local character collisions for map testing",
			State.Noclip,
			function(v)
				State.Noclip = v
			end
		)

		CreateToggle(
			"Auto Sprint",
			"Apply your configured speed while moving",
			State.AutoSprint,
			function(v)
				State.AutoSprint = v
			end
		)

		CreateToggle(
			"Spin",
			"Continuously rotate your character",
			State.Spin,
			function(v)
				State.Spin = v
			end
		)

		CreateSlider(
			"Camera FOV",
			"Adjust the local camera field of view",
			CONFIG.MinFOV,
			CONFIG.MaxFOV,
			State.FOV,
			function(v)

				State.FOV = v

				local camera =
					Workspace.CurrentCamera

				if camera then
					camera.FieldOfView = v
				end
			end
		)

		CreateAction(
			"Reset Movement",
			"Restore default movement settings",
			function()
				ResetMovement()
				Notify("Movement reset")
			end
		)

	--============================================================
	-- PLAYER
	--============================================================

	elseif category == "Player" then

		CreateToggle(
			"Third Person",
			"Switch to an extended third-person camera distance",
			State.ThirdPerson,
			function(v)

				State.ThirdPerson = v

				if v then

					LocalPlayer.CameraMode =
						Enum.CameraMode.Classic

					LocalPlayer.CameraMinZoomDistance = 8
					LocalPlayer.CameraMaxZoomDistance = 20

				else

					LocalPlayer.CameraMinZoomDistance = 0.5
					LocalPlayer.CameraMaxZoomDistance = 400
				end
			end
		)

		CreateToggle(
			"Coordinates",
			"Show your current world coordinates",
			State.Coordinates,
			function(v)

				State.Coordinates = v
				CoordinatesLabel.Visible = v
			end
		)

		CreateAction(
			"Reset Character",
			"Reset your current character",
			function()

				local humanoid = GetHumanoid()

				if humanoid then
					humanoid.Health = 0
					Notify("Character reset")
				end
			end
		)

		CreateAction(
			"Respawn Character",
			"Request a new local character",
			function()

				LocalPlayer:LoadCharacter()
				Notify("Respawn requested")
			end
		)

		CreateAction(
			"Character Information",
			"Print character information to Output",
			function()

				local character = GetCharacter()
				local humanoid = GetHumanoid()
				local root = GetRoot()

				print("========== INTREX PLAYER ==========")
				print("Player:", LocalPlayer.Name)
				print("DisplayName:", LocalPlayer.DisplayName)
				print("Character:", character)
				print("Humanoid:", humanoid)
				print("Root:", root)

				if humanoid then
					print("Health:", humanoid.Health)
					print("MaxHealth:", humanoid.MaxHealth)
					print("WalkSpeed:", humanoid.WalkSpeed)
					print("JumpPower:", humanoid.JumpPower)
					print("State:", humanoid:GetState())
				end

				print("====================================")

				Notify("Player information printed")
			end
		)

		CreateAction(
			"Save Position",
			"Save your current position",
			function()

				local root = GetRoot()

				if root then

					State.SavedPosition =
						root.CFrame

					Notify("Position saved")
				else
					Notify("No root part")
				end
			end
		)

		CreateAction(
			"Return To Saved",
			"Return to your saved position",
			function()

				local root = GetRoot()

				if root and State.SavedPosition then

					root.CFrame =
						State.SavedPosition

					Notify("Returned to saved position")
				else
					Notify("No saved position")
				end
			end
		)

	--============================================================
	-- VISUALS
	--============================================================

	elseif category == "Visuals" then

		CreateSlider(
			"Field Of View",
			"Local camera FOV",
			CONFIG.MinFOV,
			CONFIG.MaxFOV,
			State.FOV,
			function(v)

				State.FOV = v

				local camera =
					Workspace.CurrentCamera

				if camera then
					camera.FieldOfView = v
				end
			end
		)

		CreateToggle(
			"Fullbright",
			"Increase local lighting visibility",
			State.Fullbright,
			SetFullbright
		)

		CreateToggle(
			"No Fog",
			"Extend local fog distance",
			State.NoFog,
			function(v)

				State.NoFog = v

				if v then
					Lighting.FogEnd = 100000
				else
					Lighting.FogEnd =
						OriginalLighting.FogEnd
				end
			end
		)

		CreateToggle(
			"Crosshair",
			"Display a local center crosshair",
			State.Crosshair,
			function(v)

				State.Crosshair = v
				Crosshair.Visible = v
			end
		)

		CreateToggle(
			"Character Trail",
			"Create a local trail effect",
			State.Trails,
			SetTrail
		)

		CreateToggle(
			"Rainbow Character",
			"Cycle local character colors",
			State.RainbowCharacter,
			function(v)
				State.RainbowCharacter = v
			end
		)

		CreateAction(
			"Reset Camera",
			"Restore the default camera FOV",
			function()

				State.FOV =
					CONFIG.DefaultFOV

				local camera =
					Workspace.CurrentCamera

				if camera then
					camera.FieldOfView =
						CONFIG.DefaultFOV
				end

				Notify("Camera reset")
			end
		)

	--============================================================
	-- ESP / DEBUG
	--============================================================

	elseif category == "ESP / Debug" then

		CreateToggle(
			"Player Highlight",
			"Highlight other players for Studio testing",
			State.PlayerESP,
			function(v)

				State.PlayerESP = v
				RefreshESP()
			end
		)

		CreateToggle(
			"Name Labels",
			"Display player names",
			State.NameESP,
			function(v)

				State.NameESP = v
				RefreshESP()
			end
		)

		CreateToggle(
			"Distance Labels",
			"Display distance from your character",
			State.DistanceESP,
			function(v)

				State.DistanceESP = v
				RefreshESP()
			end
		)

		CreateToggle(
			"Health Labels",
			"Display Humanoid health",
			State.HealthESP,
			function(v)

				State.HealthESP = v
				RefreshESP()
			end
		)

		CreateAction(
			"Refresh ESP",
			"Rebuild all active debug visualizations",
			function()
				RefreshESP()
				Notify("ESP refreshed")
			end
		)

		CreateAction(
			"Clear ESP",
			"Remove all INTREX player visualizations",
			function()

				for player in pairs(ESPObjects) do
					RemoveESP(player)
				end

				Notify("ESP cleared")
			end
		)

		CreateAction(
			"Workspace Object Count",
			"Count objects currently in Workspace",
			function()

				local count = 0

				for _ in Workspace:GetDescendants() do
					count += 1
				end

				print(
					"INTREX Workspace objects:",
					count
				)

				Notify(
					"Workspace objects: "
					.. count
				)
			end
		)

	--============================================================
	-- WORLD
	--============================================================

	elseif category == "World" then

		CreateSlider(
			"Clock Time",
			"Change local Lighting clock time",
			0,
			24,
			math.floor(Lighting.ClockTime),
			function(v)
				Lighting.ClockTime = v
			end
		)

		CreateSlider(
			"Brightness",
			"Change local Lighting brightness",
			0,
			10,
			math.floor(Lighting.Brightness),
			function(v)
				Lighting.Brightness = v
			end
		)

		CreateSlider(
			"Fog Distance",
			"Change local fog end distance",
			0,
			100000,
			math.floor(Lighting.FogEnd),
			function(v)
				Lighting.FogEnd = v
			end
		)

		CreateToggle(
			"Global Shadows",
			"Toggle local global shadows",
			Lighting.GlobalShadows,
			function(v)
				Lighting.GlobalShadows = v
			end
		)

		CreateSlider(
			"Exposure",
			"Change local exposure compensation",
			-5,
			5,
			math.floor(
				Lighting.ExposureCompensation
			),
			function(v)
				Lighting.ExposureCompensation = v
			end
		)

		CreateAction(
			"Reset Lighting",
			"Restore saved Lighting values",
			function()

				Lighting.Brightness =
					OriginalLighting.Brightness

				Lighting.ClockTime =
					OriginalLighting.ClockTime

				Lighting.FogEnd =
					OriginalLighting.FogEnd

				Lighting.GlobalShadows =
					OriginalLighting.GlobalShadows

				Lighting.ExposureCompensation =
					OriginalLighting.ExposureCompensation

				Notify("Lighting restored")
			end
		)

	--============================================================
	-- UTILITY
	--============================================================

	elseif category == "Utility" then

		CreateToggle(
			"Performance Monitor",
			"Display FPS and basic runtime information",
			State.Performance,
			function(v)

				State.Performance = v
				PerformanceLabel.Visible = v
			end
		)

		CreateToggle(
			"Notification Sound",
			"Play a sound whenever a notification appears",
			State.NotificationSound,
			function(v)
				State.NotificationSound = v
			end
		)

		CreateSlider(
			"Notification Volume",
			"Notification sound volume",
			0,
			100,
			State.NotificationVolume * 100,
			function(v)
				State.NotificationVolume =
					v / 100
			end
		)

		CreateAction(
			"Notification Test",
			"Test the INTREX notification system",
			function()
				Notify("Notification system working!")
			end
		)

		CreateAction(
			"Print Position",
			"Print your current position to Output",
			function()

				local root = GetRoot()

				if root then

					print(
						"INTREX POSITION:",
						root.Position
					)

					Notify("Position printed")
				end
			end
		)

		CreateAction(
			"Print Velocity",
			"Print your current velocity",
			function()

				local root = GetRoot()

				if root then

					print(
						"INTREX VELOCITY:",
						root.AssemblyLinearVelocity
					)

					Notify("Velocity printed")
				end
			end
		)

		CreateAction(
			"Character Scanner",
			"Scan character descendants",
			function()

				local character = GetCharacter()

				if not character then
					Notify("No character")
					return
				end

				local count = 0

				for _, object in ipairs(
					character:GetDescendants()
				) do
					count += 1
					print(
						"[INTREX]",
						object:GetFullName()
					)
				end

				Notify(
					"Scanned "
					.. count
					.. " objects"
				)
			end
		)

		CreateAction(
			"Clear Intrex Effects",
			"Remove objects created by INTREX",
			function()

				local root = GetRoot()

				if root then

					for _, object in ipairs(
						root:GetChildren()
					) do

						if object.Name:match(
							"^Intrex"
						) then

							object:Destroy()
						end
					end
				end

				Notify("INTREX effects cleared")
			end
		)

	--============================================================
	-- TELEPORT
	--============================================================

	elseif category == "Teleport" then

		CreateAction(
			"Save Position",
			"Save your current CFrame",
			function()

				local root = GetRoot()

				if root then
					State.SavedPosition =
						root.CFrame

					Notify("Position saved")
				end
			end
		)

		CreateAction(
			"Return To Saved",
			"Teleport back to saved position",
			function()

				local root = GetRoot()

				if root
					and State.SavedPosition then

					root.CFrame =
						State.SavedPosition

					Notify("Returned")
				else
					Notify("No saved position")
				end
			end
		)

		CreateAction(
			"Teleport To Spawn",
			"Find and move to a SpawnLocation",
			function()

				local root = GetRoot()

				if not root then
					return
				end

				local spawn =
					Workspace:
					FindFirstChildWhichIsA(
						"SpawnLocation",
						true
					)

				if spawn then

					root.CFrame =
						spawn.CFrame
						* CFrame.new(0, 4, 0)

					Notify("Teleported to spawn")
				else
					Notify("No SpawnLocation found")
				end
			end
		)

		CreateAction(
			"Teleport Up",
			"Move 20 studs upward",
			function()

				local root = GetRoot()

				if root then
					root.CFrame =
						root.CFrame
						* CFrame.new(0, 20, 0)
				end
			end
		)

		CreateAction(
			"Teleport Down",
			"Move 20 studs downward",
			function()

				local root = GetRoot()

				if root then
					root.CFrame =
						root.CFrame
						* CFrame.new(0, -20, 0)
				end
			end
		)

		CreateAction(
			"Teleport Forward",
			"Move 20 studs forward",
			function()

				local root = GetRoot()

				if root then

					root.CFrame =
						root.CFrame
						* CFrame.new(0, 0, -20)
				end
			end
		)

		CreateAction(
			"Teleport Backward",
			"Move 20 studs backward",
			function()

				local root = GetRoot()

				if root then

					root.CFrame =
						root.CFrame
						* CFrame.new(0, 0, 20)
				end
			end
		)

		CreateAction(
			"Teleport Origin",
			"Move to world origin",
			function()

				local root = GetRoot()

				if root then
					root.CFrame =
						CFrame.new(0, 10, 0)

					Notify("Moved to origin")
				end
			end
		)

	--============================================================
	-- TROLLING / EFFECTS
	--============================================================

	elseif category == "Trolling / Effects" then

		CreateToggle(
			"Character Spin",
			"Rotate your local character",
			State.Spin,
			function(v)
				State.Spin = v
			end
		)

		CreateToggle(
			"Rainbow Character",
			"Cycle local character colors",
			State.RainbowCharacter,
			function(v)
				State.RainbowCharacter = v
			end
		)

		CreateToggle(
			"Character Trail",
			"Add a local trail",
			State.Trails,
			SetTrail
		)

		CreateAction(
			"Particle Burst",
			"Create a temporary local particle effect",
			function()

				local root = GetRoot()

				if not root then
					return
				end

				local emitter =
					Instance.new(
						"ParticleEmitter"
					)

				emitter.Name =
					"IntrexParticleBurst"

				emitter.Texture =
					"rbxasset://textures/particles/sparkles_main.dds"

				emitter.Rate = 120

				emitter.Lifetime =
					NumberRange.new(
						0.4,
						0.8
					)

				emitter.Speed =
					NumberRange.new(
						8,
						15
					)

				emitter.SpreadAngle =
					Vector2.new(
						180,
						180
					)

				emitter.Parent = root

				task.delay(1.5, function()

					if emitter.Parent then
						emitter:Destroy()
					end
				end)

				Notify("Particle burst created")
			end
		)

		CreateAction(
			"FOV Pulse",
			"Quickly animate camera FOV",
			function()

				local camera =
					Workspace.CurrentCamera

				if not camera then
					return
				end

				local original =
					camera.FieldOfView

				Tween(
					camera,
					{
						FieldOfView =
							math.min(
								original + 20,
								CONFIG.MaxFOV
							),
					},
					0.12
				)

				task.delay(0.12, function()

					Tween(
						camera,
						{
							FieldOfView =
								original,
						},
						0.18
					)
				end)
			end
		)

		CreateAction(
			"Clear Effects",
			"Remove local INTREX effects",
			function()

				SetTrail(false)

				local root = GetRoot()

				if root then

					for _, object in ipairs(
						root:GetChildren()
					) do

						if object.Name:match(
							"^Intrex"
						) then

							object:Destroy()
						end
					end
				end

				Notify("Effects cleared")
			end
		)

	--============================================================
	-- SETTINGS
	--============================================================

	elseif category == "Settings" then

		CreateToggle(
			"UI Animations",
			"Enable interface animations",
			State.Animations,
			function(v)
				State.Animations = v
			end
		)

		CreateSlider(
			"UI Scale",
			"Adjust overall interface scale",
			80,
			130,
			State.UIScale * 100,
			function(v)

				State.UIScale =
					v / 100

				Window.Size =
					UDim2.fromOffset(
						CONFIG.WindowWidth
							* State.UIScale,
						CONFIG.WindowHeight
							* State.UIScale
					)
			end
		)

		CreateSlider(
			"UI Transparency",
			"Adjust window transparency",
			0,
			70,
			State.UITransparency * 100,
			function(v)

				State.UITransparency =
					v / 100

				Window.BackgroundTransparency =
					State.UITransparency
			end
		)

		CreateAction(
			"Reset UI Size",
			"Restore the default window dimensions",
			function()

				State.UIScale = 1

				Window.Size =
					UDim2.fromOffset(
						CONFIG.WindowWidth,
						CONFIG.WindowHeight
					)

				Notify("UI size restored")
			end
		)

		CreateAction(
			"Hide Menu",
			"Hide the menu; press RightShift to reopen",
			function()

				State.WindowVisible = false
				Window.Visible = false
			end
		)

	--============================================================
	-- CONFIG
	--============================================================

	elseif category == "Config" then

		CreateAction(
			"Reset Movement",
			"Restore speed, jump and FOV",
			function()

				ResetMovement()
				Notify("Movement restored")
			end
		)

		CreateAction(
			"Disable Everything",
			"Turn off active INTREX features",
			function()

				DisableFeatures()
			end
		)

		CreateAction(
			"Reset Visuals",
			"Disable local visual modifications",
			function()

				SetFullbright(false)

				State.NoFog = false
				State.Crosshair = false
				State.RainbowCharacter = false

				Crosshair.Visible = false

				Lighting.FogEnd =
					OriginalLighting.FogEnd

				Notify("Visuals restored")
			end
		)

		CreateAction(
			"Reset Lighting",
			"Restore original lighting values",
			function()

				Lighting.Brightness =
					OriginalLighting.Brightness

				Lighting.ClockTime =
					OriginalLighting.ClockTime

				Lighting.FogEnd =
					OriginalLighting.FogEnd

				Lighting.GlobalShadows =
					OriginalLighting.GlobalShadows

				Lighting.ExposureCompensation =
					OriginalLighting.ExposureCompensation

				Notify("Lighting restored")
			end
		)

		CreateAction(
			"Clear ESP",
			"Remove every ESP visualization",
			function()

				for player in pairs(
					ESPObjects
				) do
					RemoveESP(player)
				end

				State.PlayerESP = false
				State.NameESP = false
				State.DistanceESP = false
				State.HealthESP = false

				Notify("ESP cleared")
			end
		)

		CreateAction(
			"Clear Saved Position",
			"Delete saved teleport position",
			function()

				State.SavedPosition = nil

				Notify("Saved position cleared")
			end
		)

	--============================================================
	-- DEBUG
	--============================================================

	elseif category == "Debug" then

		CreateAction(
			"Character Debug",
			"Print detailed character information",
			function()

				local character = GetCharacter()
				local humanoid = GetHumanoid()
				local root = GetRoot()

				print("========== INTREX DEBUG ==========")
				print("Player:", LocalPlayer)
				print("Character:", character)
				print("Humanoid:", humanoid)
				print("Root:", root)

				if humanoid then
					print("Health:", humanoid.Health)
					print("MaxHealth:", humanoid.MaxHealth)
					print("WalkSpeed:", humanoid.WalkSpeed)
					print("JumpPower:", humanoid.JumpPower)
					print("State:", humanoid:GetState())
				end

				if root then
					print("Position:", root.Position)
					print(
						"Velocity:",
						root.AssemblyLinearVelocity
					)
				end

				print("==================================")

				Notify("Character debug printed")
			end
		)

		CreateAction(
			"Camera Debug",
			"Print camera information",
			function()

				local camera =
					Workspace.CurrentCamera

				if camera then

					print("===== CAMERA =====")
					print("Camera:", camera)
					print("FOV:", camera.FieldOfView)
					print("Position:", camera.CFrame.Position)
					print("LookVector:", camera.CFrame.LookVector)
					print("==================")

					Notify("Camera debug printed")
				end
			end
		)

		CreateAction(
			"Lighting Debug",
			"Print Lighting information",
			function()

				print("===== LIGHTING =====")
				print("Brightness:", Lighting.Brightness)
				print("ClockTime:", Lighting.ClockTime)
				print("FogEnd:", Lighting.FogEnd)
				print("GlobalShadows:", Lighting.GlobalShadows)
				print(
					"Exposure:",
					Lighting.ExposureCompensation
				)
				print("====================")

				Notify("Lighting debug printed")
			end
		)

		CreateAction(
			"Workspace Scan",
			"Count Workspace descendants",
			function()

				local count = 0

				for _ in Workspace:GetDescendants() do
					count += 1
				end

				print(
					"INTREX Workspace Descendants:",
					count
				)

				Notify(
					"Workspace: "
					.. count
					.. " objects"
				)
			end
		)

		CreateAction(
			"Player List",
			"Print players currently in the server",
			function()

				print("===== PLAYERS =====")

				for _, player in ipairs(
					Players:GetPlayers()
				) do

					print(
						player.Name,
						"|",
						player.DisplayName
					)
				end

				print("===================")

				Notify("Player list printed")
			end
		)

		CreateAction(
			"INTREX State",
			"Print current client state",
			function()

				print("======= INTREX STATE =======")

				for key, value in pairs(State) do
					print(key, "=", value)
				end

				print("============================")

				Notify("State printed")
			end
		)

		CreateAction(
			"Full Debug Report",
			"Print a complete developer report",
			function()

				print("")
				print("================================")
				print("       INTREX DEBUG REPORT")
				print("================================")
				print("Player:", LocalPlayer.Name)
				print("PlaceId:", game.PlaceId)
				print("JobId:", game.JobId)
				print("Players:", #Players:GetPlayers())
				print(
					"Workspace objects:",
					#Workspace:GetDescendants()
				)
				print(
					"Lighting Brightness:",
					Lighting.Brightness
				)
				print(
					"Lighting Clock:",
					Lighting.ClockTime
				)

				local camera =
					Workspace.CurrentCamera

				if camera then
					print(
						"Camera FOV:",
						camera.FieldOfView
					)
				end

				local root = GetRoot()

				if root then
					print(
						"Character Position:",
						root.Position
					)
				end

				print("================================")
				print("          END REPORT")
				print("================================")
				print("")

				Notify("Full debug report printed")
			end
		)
	end
end

--==============================================================
-- SEARCH SYSTEM
--==============================================================

local SearchResults = {}

local function SearchFeatures(query)

	query = string.lower(query or "")

	for _, object in ipairs(SearchResults) do

		if object and object.Parent then
			object:Destroy()
		end
	end

	SearchResults = {}

	if query == "" then
		LoadCategory(State.SelectedCategory)
		return
	end

	ClearPage()

	PageTitle.Text = "Search"
	PageDescription.Text =
		"Matching INTREX developer features"

	for _, category in ipairs(Categories) do

		-- Create a temporary page to inspect names.
		-- Instead of duplicating callbacks, search through
		-- known feature names.

	end

	local SearchEntries = {

		{"Walk Speed", "Movement"},
		{"Jump Power", "Movement"},
		{"Fly Speed", "Movement"},
		{"Fly", "Movement"},
		{"Infinite Jump", "Movement"},
		{"Noclip", "Movement"},
		{"Auto Sprint", "Movement"},
		{"Spin", "Movement"},
		{"Camera FOV", "Movement"},
		{"Third Person", "Player"},
		{"Coordinates", "Player"},
		{"Reset Character", "Player"},
		{"Respawn Character", "Player"},
		{"Character Information", "Player"},
		{"Save Position", "Player"},
		{"Return To Saved", "Player"},
		{"Field Of View", "Visuals"},
		{"Fullbright", "Visuals"},
		{"No Fog", "Visuals"},
		{"Crosshair", "Visuals"},
		{"Character Trail", "Visuals"},
		{"Rainbow Character", "Visuals"},
		{"Player Highlight", "ESP / Debug"},
		{"Name Labels", "ESP / Debug"},
		{"Distance Labels", "ESP / Debug"},
		{"Health Labels", "ESP / Debug"},
		{"Refresh ESP", "ESP / Debug"},
		{"Clear ESP", "ESP / Debug"},
		{"Workspace Object Count", "ESP / Debug"},
		{"Clock Time", "World"},
		{"Brightness", "World"},
		{"Fog Distance", "World"},
		{"Global Shadows", "World"},
		{"Exposure", "World"},
		{"Reset Lighting", "World"},
		{"Performance Monitor", "Utility"},
		{"Notification Sound", "Utility"},
		{"Notification Volume", "Utility"},
		{"Notification Test", "Utility"},
		{"Print Position", "Utility"},
		{"Print Velocity", "Utility"},
		{"Character Scanner", "Utility"},
		{"Clear Intrex Effects", "Utility"},
		{"Teleport To Spawn", "Teleport"},
		{"Teleport Up", "Teleport"},
		{"Teleport Down", "Teleport"},
		{"Teleport Forward", "Teleport"},
		{"Teleport Backward", "Teleport"},
		{"Teleport Origin", "Teleport"},
		{"Character Spin", "Trolling / Effects"},
		{"Particle Burst", "Trolling / Effects"},
		{"FOV Pulse", "Trolling / Effects"},
		{"Clear Effects", "Trolling / Effects"},
		{"UI Animations", "Settings"},
		{"UI Scale", "Settings"},
		{"UI Transparency", "Settings"},
		{"Reset UI Size", "Settings"},
		{"Hide Menu", "Settings"},
		{"Reset Movement", "Config"},
		{"Disable Everything", "Config"},
		{"Reset Visuals", "Config"},
		{"Clear Saved Position", "Config"},
		{"Character Debug", "Debug"},
		{"Camera Debug", "Debug"},
		{"Lighting Debug", "Debug"},
		{"Workspace Scan", "Debug"},
		{"Player List", "Debug"},
		{"INTREX State", "Debug"},
		{"Full Debug Report", "Debug"},
	}

	local matches = 0

	for _, entry in ipairs(SearchEntries) do

		local name = entry[1]
		local category = entry[2]

		if string.find(
			string.lower(name),
			query,
			1,
			true
		) then

			matches += 1

			local holder = Instance.new("Frame")
			holder.Size =
				UDim2.new(1, -2, 0, 56)

			holder.BackgroundColor3 = C.Panel
			holder.BorderSizePixel = 0
			holder.Parent = Options

			Corner(holder, 8)

			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.Position =
				UDim2.fromOffset(12, 7)

			label.Size =
				UDim2.new(1, -130, 0, 18)

			label.Text = name
			label.TextColor3 = C.Text
			label.TextSize = 11
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment =
				Enum.TextXAlignment.Left
			label.Parent = holder

			local categoryLabel =
				Instance.new("TextLabel")

			categoryLabel.BackgroundTransparency = 1
			categoryLabel.Position =
				UDim2.fromOffset(12, 28)

			categoryLabel.Size =
				UDim2.new(1, -130, 0, 14)

			categoryLabel.Text =
				"Category: " .. category

			categoryLabel.TextColor3 =
				C.SubText

			categoryLabel.TextSize = 8
			categoryLabel.Font = Enum.Font.Gotham
			categoryLabel.TextXAlignment =
				Enum.TextXAlignment.Left

			categoryLabel.Parent = holder

			local button =
				Instance.new("TextButton")

			button.Size =
				UDim2.fromOffset(70, 27)

			button.Position =
				UDim2.new(1, -82, 0.5, -13)

			button.BackgroundColor3 =
				C.AccentDark

			button.Text = "OPEN"
			button.TextColor3 = C.Text
			button.TextSize = 9
			button.Font = Enum.Font.GothamBold
			button.AutoButtonColor = false
			button.Parent = holder

			Corner(button, 7)

			button.MouseButton1Click:Connect(function()

				SearchBox.Text = ""

				LoadCategory(category)

				Notify(
					"Opened "
					.. category
				)
			end)

			table.insert(
				SearchResults,
				holder
			)
		end
	end

	if matches == 0 then

		local empty =
			Instance.new("TextLabel")

		empty.Size =
			UDim2.new(1, -2, 0, 60)

		empty.BackgroundTransparency = 1
		empty.Text =
			'No features found for "' ..
			query ..
			'"'

		empty.TextColor3 = C.SubText
		empty.TextSize = 11
		empty.Font = Enum.Font.GothamMedium
		empty.Parent = Options

		table.insert(
			SearchResults,
			empty
		)
	end
end

SearchBox:GetPropertyChangedSignal(
	"Text"
):Connect(function()

	SearchFeatures(SearchBox.Text)
end)

--==============================================================
-- CATEGORY BUTTONS
--==============================================================

for index, category in ipairs(Categories) do

	local Button = Instance.new("TextButton")

	Button.Name = category
	Button.Size =
		UDim2.new(1, 0, 0, 30)

	Button.BackgroundColor3 = C.Sidebar
	Button.Text = category
	Button.TextColor3 = C.SubText
	Button.TextSize = 9
	Button.Font = Enum.Font.GothamBold
	Button.TextXAlignment =
		Enum.TextXAlignment.Left

	Button.AutoButtonColor = false
	Button.LayoutOrder = index
	Button.Parent = CategoryScroll

	Corner(Button, 6)

	local Padding =
		Instance.new("UIPadding")

	Padding.PaddingLeft =
		UDim.new(0, 10)

	Padding.Parent = Button

	CategoryButtons[category] = Button

	Button.MouseEnter:Connect(function()

		if State.SelectedCategory ~= category then

			Tween(Button, {
				BackgroundColor3 = C.Panel2,
				TextColor3 = C.Text,
			}, 0.1)
		end
	end)

	Button.MouseLeave:Connect(function()

		if State.SelectedCategory ~= category then

			Tween(Button, {
				BackgroundColor3 = C.Sidebar,
				TextColor3 = C.SubText,
			}, 0.1)
		end
	end)

	Button.MouseButton1Click:Connect(function()

		for _, other in pairs(
			CategoryButtons
		) do

			Tween(other, {
				BackgroundColor3 = C.Sidebar,
				TextColor3 = C.SubText,
			}, 0.08)
		end

		Tween(Button, {
			BackgroundColor3 = C.AccentDark,
			TextColor3 = C.Text,
		}, 0.12)

		SearchBox.Text = ""

		LoadCategory(category)
	end)
end

--==============================================================
-- NOCLIP LOOP
--==============================================================

RunService.Stepped:Connect(function()

	if not State.Noclip then
		return
	end

	local character = GetCharacter()

	if not character then
		return
	end

	for _, object in ipairs(
		character:GetDescendants()
	) do

		if object:IsA("BasePart") then
			object.CanCollide = false
		end
	end
end)

--==============================================================
-- SPIN LOOP
--==============================================================

RunService.RenderStepped:Connect(function(delta)

	if not State.Spin then
		return
	end

	local root = GetRoot()

	if root then

		root.CFrame =
			root.CFrame
			* CFrame.Angles(
				0,
				math.rad(180) * delta,
				0
			)
	end
end)

--==============================================================
-- RAINBOW LOOP
--==============================================================

local RainbowTime = 0

RunService.RenderStepped:Connect(function(delta)

	if not State.RainbowCharacter then
		return
	end

	RainbowTime += delta

	local hue =
		(RainbowTime * 0.25) % 1

	local character = GetCharacter()

	if not character then
		return
	end

	for _, object in ipairs(
		character:GetDescendants()
	) do

		if object:IsA("BasePart")
			and object.Name ~= "HumanoidRootPart" then

			object.Color =
				Color3.fromHSV(
					hue,
					0.8,
					1
				)
		end
	end
end)

--==============================================================
-- AUTO SPRINT
--==============================================================

RunService.RenderStepped:Connect(function()

	if not State.AutoSprint then
		return
	end

	local humanoid = GetHumanoid()

	if humanoid
		and humanoid.MoveDirection.Magnitude > 0 then

		humanoid.WalkSpeed =
			State.WalkSpeed
	end
end)

--==============================================================
-- COORDINATES UPDATE
--==============================================================

RunService.RenderStepped:Connect(function()

	if not State.Coordinates then
		return
	end

	local root = GetRoot()

	if root then

		local p = root.Position

		CoordinatesLabel.Text =
			string.format(
				"  X %.1f    Y %.1f    Z %.1f",
				p.X,
				p.Y,
				p.Z
			)
	end
end)

--==============================================================
-- PERFORMANCE UPDATE
--==============================================================

local LastPerformanceTime = os.clock()
local FrameCount = 0

RunService.RenderStepped:Connect(function()

	FrameCount += 1

	local now = os.clock()

	if now - LastPerformanceTime >= 1 then

		local fps = FrameCount

		FrameCount = 0
		LastPerformanceTime = now

		if State.Performance then

			local root = GetRoot()

			local positionText = "N/A"

			if root then
				positionText =
					string.format(
						"%.0f, %.0f, %.0f",
						root.Position.X,
						root.Position.Y,
						root.Position.Z
					)
			end

			PerformanceLabel.Text =
				"  FPS: "
				.. fps
				.. "\n  Players: "
				.. #Players:GetPlayers()
				.. "\n  Position: "
				.. positionText
		end
	end
end)

--==============================================================
-- PLAYER CONNECTIONS
--==============================================================

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function()

		task.wait(0.5)

		if State.PlayerESP
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

for _, player in ipairs(
	Players:GetPlayers()
) do

	if player ~= LocalPlayer then

		player.CharacterAdded:Connect(function()

			task.wait(0.5)

			if State.PlayerESP
				or State.NameESP
				or State.DistanceESP
				or State.HealthESP then

				AddESP(player)
			end
		end)
	end
end

--==============================================================
-- CHARACTER RESPAWN
--==============================================================

LocalPlayer.CharacterAdded:Connect(function(character)

	task.wait(0.5)

	local humanoid =
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	if humanoid then

		humanoid.UseJumpPower = true
		humanoid.WalkSpeed =
			State.WalkSpeed
		humanoid.JumpPower =
			State.JumpPower
	end

	if State.Trails then
		SetTrail(true)
	end

	if State.Fly then
		StartFly()
	end

	if State.PlayerESP
		or State.NameESP
		or State.DistanceESP
		or State.HealthESP then

		RefreshESP()
	end
end)

--==============================================================
-- OPEN BUTTON
--==============================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenIntrex"
OpenButton.AnchorPoint =
	Vector2.new(0, 0.5)

OpenButton.Position =
	UDim2.new(0, 15, 0.5, 0)

OpenButton.Size =
	UDim2.fromOffset(44, 44)

OpenButton.BackgroundColor3 =
	C.Background

OpenButton.Text = "I"
OpenButton.TextColor3 =
	C.Accent

OpenButton.TextSize = 19
OpenButton.Font =
	Enum.Font.GothamBold

OpenButton.AutoButtonColor = false
OpenButton.Parent = Gui

Corner(OpenButton, 12)
AddStroke(OpenButton, C.Accent, 1, 0.3)

OpenButton.MouseEnter:Connect(function()

	Tween(OpenButton, {
		BackgroundColor3 = C.Panel2,
	}, 0.1)
end)

OpenButton.MouseLeave:Connect(function()

	Tween(OpenButton, {
		BackgroundColor3 = C.Background,
	}, 0.1)
end)

OpenButton.MouseButton1Click:Connect(function()

	State.WindowVisible =
		not State.WindowVisible

	Window.Visible =
		State.WindowVisible

	if State.WindowVisible then

		Tween(Window, {
			Size =
				UDim2.fromOffset(
					CONFIG.WindowWidth,
					CONFIG.WindowHeight
				),
		}, 0.18)
	end
end)

--==============================================================
-- KEYBIND
--==============================================================

UserInputService.InputBegan:Connect(
	function(input, processed)

		if processed then
			return
		end

		if input.KeyCode ==
			CONFIG.MenuKey then

			State.WindowVisible =
				not State.WindowVisible

			Window.Visible =
				State.WindowVisible
		end
	end
)

--==============================================================
-- INITIALIZE
--==============================================================

LoadCategory("Movement")

for category, button in pairs(
	CategoryButtons
) do

	if category == "Movement" then

		button.BackgroundColor3 =
			C.AccentDark

		button.TextColor3 =
			C.Text
	end
end

Notify("INTREX Developer Client Ready")
Notify("RightShift toggles the menu")

--==============================================================
-- END
--==============================================================
