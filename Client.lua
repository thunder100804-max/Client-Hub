--==============================================================
-- INTREX CLIENT - DEVELOPER TEST BUILD
-- LocalScript
-- StarterPlayer > StarterPlayerScripts
--
-- Persistent developer lock-on version
--
-- RMB:
--   Acquire one target
--   Keep that target locked
--   Release when RMB is released
--
-- Weapon systems in your own experience can use:
--   GetLockedAimPosition()
--==============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
	WindowWidth = 560,
	WindowHeight = 390,

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
	MaxFlySpeed = 200,

	MinLockStrength = 0,
	MaxLockStrength = 100,

	MinAimFOV = 5,
	MaxAimFOV = 300,
}

--==============================================================
-- COLORS
--==============================================================

local C = {
	Background = Color3.fromRGB(10, 12, 16),
	Sidebar = Color3.fromRGB(14, 17, 22),
	Panel = Color3.fromRGB(19, 23, 29),
	Panel2 = Color3.fromRGB(24, 29, 36),

	Accent = Color3.fromRGB(48, 174, 239),
	AccentDark = Color3.fromRGB(30, 121, 177),

	Text = Color3.fromRGB(245, 247, 250),
	SubText = Color3.fromRGB(140, 148, 160),

	Off = Color3.fromRGB(65, 70, 80),
	Red = Color3.fromRGB(235, 70, 70),

	SliderBackground = Color3.fromRGB(38, 43, 51),
}

--==============================================================
-- CLEAN OLD GUI
--==============================================================

local old = PlayerGui:FindFirstChild("IntrexClient")

if old then
	old:Destroy()
end

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

local function Stroke(object, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = object
	return s
end

local function Tween(object, properties, duration)
	local t = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.15,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		),
		properties
	)

	t:Play()
	return t
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
-- STATE
--==============================================================

local State = {
	WalkSpeed = CONFIG.DefaultWalkSpeed,
	JumpPower = CONFIG.DefaultJumpPower,
	FOV = CONFIG.DefaultFOV,

	InfiniteJump = false,
	Noclip = false,
	Fullbright = false,
	NoFog = false,
	Spin = false,

	ThirdPerson = false,

	PlayerESP = false,
	NameESP = false,
	DistanceESP = false,
	HealthESP = false,

	Crosshair = false,
	Trails = false,
	RainbowCharacter = false,
	Coordinates = false,
	Performance = false,

	AutoSprint = false,

	Fly = false,
	FlySpeed = 70,

	-- Target tester
	PlayerTargetTester = false,
	AimStrength = 100,
	AimFOV = 45,
	AimHold = false,
	TeamCheck = true,
	LineOfSight = true,

	SelectedPlayer = nil,
	LockedTarget = nil,
}

local ESPObjects = {}
local OriginalLighting = {}

local SelectedCategory = "Movement"

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
Window.BorderSizePixel = 0
Window.Parent = Gui

Corner(Window, 12)
Stroke(Window, Color3.fromRGB(55, 63, 75), 1, 0.2)

--==============================================================
-- TOP BAR
--==============================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = C.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = Window

Corner(TopBar, 12)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(16, 7)
Title.Size = UDim2.fromOffset(160, 20)
Title.Text = "INTREX"
Title.TextColor3 = C.Text
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.fromOffset(16, 26)
SubTitle.Size = UDim2.fromOffset(220, 14)
SubTitle.Text = "DEVELOPER CLIENT  •  LOCAL"
SubTitle.TextColor3 = C.Accent
SubTitle.TextSize = 8
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30, 30)
Close.Position = UDim2.new(1, -38, 0, 9)
Close.BackgroundColor3 = C.Panel2
Close.Text = "×"
Close.TextColor3 = C.SubText
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = TopBar

Corner(Close, 8)

--==============================================================
-- DRAG
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

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
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

Close.MouseButton1Click:Connect(function()
	Window.Visible = false
end)

--==============================================================
-- SIDEBAR
--==============================================================

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(0, 48)
Sidebar.Size = UDim2.new(0, 142, 1, -48)
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
Content.Position = UDim2.fromOffset(142, 48)
Content.Size = UDim2.new(1, -142, 1, -48)
Content.BackgroundColor3 = C.Background
Content.BorderSizePixel = 0
Content.Parent = Window

local PageTitle = Instance.new("TextLabel")
PageTitle.BackgroundTransparency = 1
PageTitle.Position = UDim2.fromOffset(18, 13)
PageTitle.Size = UDim2.new(1, -36, 0, 24)
PageTitle.Text = "Movement"
PageTitle.TextColor3 = C.Text
PageTitle.TextSize = 18
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

local PageDescription = Instance.new("TextLabel")
PageDescription.BackgroundTransparency = 1
PageDescription.Position = UDim2.fromOffset(18, 37)
PageDescription.Size = UDim2.new(1, -36, 0, 17)
PageDescription.Text = "Character movement controls"
PageDescription.TextColor3 = C.SubText
PageDescription.TextSize = 9
PageDescription.Font = Enum.Font.Gotham
PageDescription.TextXAlignment = Enum.TextXAlignment.Left
PageDescription.Parent = Content

local Options = Instance.new("ScrollingFrame")
Options.Position = UDim2.fromOffset(14, 62)
Options.Size = UDim2.new(1, -28, 1, -72)
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
-- NOTIFICATIONS
--==============================================================

local NotificationHolder = Instance.new("Frame")
NotificationHolder.AnchorPoint = Vector2.new(1, 0)
NotificationHolder.Position = UDim2.new(1, -15, 0, 15)
NotificationHolder.Size = UDim2.fromOffset(250, 250)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = Gui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0, 5)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.Parent = NotificationHolder

local function Notify(message)

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.fromOffset(235, 38)
	Frame.BackgroundColor3 = C.Panel
	Frame.BackgroundTransparency = 1
	Frame.Parent = NotificationHolder

	Corner(Frame, 8)
	Stroke(Frame, C.Accent, 1, 0.45)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(10, 0)
	Label.Size = UDim2.new(1, -20, 1, 0)
	Label.Text = message
	Label.TextColor3 = C.Text
	Label.TextSize = 10
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame

	Tween(Frame, {
		BackgroundTransparency = 0.05
	}, 0.15)

	task.delay(2.5, function()

		if not Frame.Parent then
			return
		end

		Tween(Frame, {
			BackgroundTransparency = 1
		}, 0.2)

		Tween(Label, {
			TextTransparency = 1
		}, 0.2)

		task.wait(0.25)

		if Frame.Parent then
			Frame:Destroy()
		end
	end)
end

--==============================================================
-- TOGGLE
--==============================================================

local function CreateToggle(name, description, default, callback)

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1, -2, 0, 54)
	Holder.BackgroundColor3 = C.Panel
	Holder.BorderSizePixel = 0
	Holder.Parent = Options

	Corner(Holder, 8)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(12, 7)
	Label.Size = UDim2.new(1, -105, 0, 17)
	Label.Text = name
	Label.TextColor3 = C.Text
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local Desc = Instance.new("TextLabel")
	Desc.BackgroundTransparency = 1
	Desc.Position = UDim2.fromOffset(12, 26)
	Desc.Size = UDim2.new(1, -105, 0, 15)
	Desc.Text = description or ""
	Desc.TextColor3 = C.SubText
	Desc.TextSize = 8
	Desc.Font = Enum.Font.Gotham
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.Parent = Holder

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.fromOffset(56, 26)
	Button.Position = UDim2.new(1, -68, 0.5, -13)
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
			BackgroundColor3 = Enabled and C.Accent or C.Off
		}, 0.15)

		if callback then
			callback(Enabled)
		end
	end

	Button.MouseButton1Click:Connect(function()
		Update(not Enabled)
	end)

	return Holder, Update
end

--==============================================================
-- SLIDER
--==============================================================

local function CreateSlider(name, description, min, max, default, callback)

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1, -2, 0, 72)
	Holder.BackgroundColor3 = C.Panel
	Holder.BorderSizePixel = 0
	Holder.Parent = Options

	Corner(Holder, 8)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(12, 7)
	Label.Size = UDim2.new(1, -80, 0, 17)
	Label.Text = name
	Label.TextColor3 = C.Text
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local Value = Instance.new("TextLabel")
	Value.BackgroundTransparency = 1
	Value.Position = UDim2.new(1, -62, 0, 7)
	Value.Size = UDim2.fromOffset(50, 17)
	Value.Text = tostring(default)
	Value.TextColor3 = C.Accent
	Value.TextSize = 10
	Value.Font = Enum.Font.GothamBold
	Value.TextXAlignment = Enum.TextXAlignment.Right
	Value.Parent = Holder

	local Desc = Instance.new("TextLabel")
	Desc.BackgroundTransparency = 1
	Desc.Position = UDim2.fromOffset(12, 25)
	Desc.Size = UDim2.new(1, -24, 0, 13)
	Desc.Text = description or ""
	Desc.TextColor3 = C.SubText
	Desc.TextSize = 8
	Desc.Font = Enum.Font.Gotham
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.Parent = Holder

	local Bar = Instance.new("Frame")
	Bar.Position = UDim2.fromOffset(12, 50)
	Bar.Size = UDim2.new(1, -24, 0, 6)
	Bar.BackgroundColor3 = C.SliderBackground
	Bar.BorderSizePixel = 0
	Bar.Parent = Holder

	Corner(Bar, 5)

	local initialPercent =
		(default - min) / math.max(max - min, 1)

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new(initialPercent, 0, 1, 0)
	Fill.BackgroundColor3 = C.Accent
	Fill.BorderSizePixel = 0
	Fill.Parent = Bar

	Corner(Fill, 5)

	local Knob = Instance.new("Frame")
	Knob.AnchorPoint = Vector2.new(0.5, 0.5)
	Knob.Position = UDim2.new(initialPercent, 0, 0.5, 0)
	Knob.Size = UDim2.fromOffset(12, 12)
	Knob.BackgroundColor3 = C.Text
	Knob.BorderSizePixel = 0
	Knob.Parent = Bar

	Corner(Knob, 20)

	local Hitbox = Instance.new("TextButton")
	Hitbox.BackgroundTransparency = 1
	Hitbox.Size = UDim2.new(1, 10, 1, 20)
	Hitbox.Position = UDim2.fromOffset(-5, -10)
	Hitbox.Text = ""
	Hitbox.AutoButtonColor = false
	Hitbox.Parent = Bar

	local Sliding = false

	local function SetValue(value)

		value = math.clamp(value, min, max)
		value = math.floor(value + 0.5)

		local Percent =
			(value - min) / math.max(max - min, 1)

		Value.Text = tostring(value)

		Tween(Fill, {
			Size = UDim2.new(Percent, 0, 1, 0)
		}, 0.08)

		Tween(Knob, {
			Position = UDim2.new(Percent, 0, 0.5, 0)
		}, 0.08)

		if callback then
			callback(value)
		end
	end

	local function FromInput(input)

		if Bar.AbsoluteSize.X <= 0 then
			return
		end

		local relative =
			math.clamp(
				(input.Position.X - Bar.AbsolutePosition.X)
				/ Bar.AbsoluteSize.X,
				0,
				1
			)

		SetValue(
			min + ((max - min) * relative)
		)
	end

	Hitbox.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			Sliding = true
			FromInput(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)

		if not Sliding then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			FromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			Sliding = false
		end
	end)

	return Holder, SetValue
end

--==============================================================
-- ACTION
--==============================================================

local function CreateAction(name, description, callback)

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1, -2, 0, 54)
	Holder.BackgroundColor3 = C.Panel
	Holder.BorderSizePixel = 0
	Holder.Parent = Options

	Corner(Holder, 8)

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(12, 7)
	Label.Size = UDim2.new(1, -110, 0, 17)
	Label.Text = name
	Label.TextColor3 = C.Text
	Label.TextSize = 11
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local Desc = Instance.new("TextLabel")
	Desc.BackgroundTransparency = 1
	Desc.Position = UDim2.fromOffset(12, 26)
	Desc.Size = UDim2.new(1, -110, 0, 15)
	Desc.Text = description or ""
	Desc.TextColor3 = C.SubText
	Desc.TextSize = 8
	Desc.Font = Enum.Font.Gotham
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.Parent = Holder

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.fromOffset(62, 26)
	Button.Position = UDim2.new(1, -74, 0.5, -13)
	Button.BackgroundColor3 = C.AccentDark
	Button.Text = "RUN"
	Button.TextColor3 = C.Text
	Button.TextSize = 9
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false
	Button.Parent = Holder

	Corner(Button, 7)

	Button.MouseButton1Click:Connect(function()

		if callback then
			callback()
		end
	end)

	return Holder
end

--==============================================================
-- MOVEMENT
--==============================================================

local function ApplySpeed(value)

	State.WalkSpeed = value

	local hum = GetHumanoid()

	if hum then
		hum.WalkSpeed = value
	end
end

local function ApplyJump(value)

	State.JumpPower = value

	local hum = GetHumanoid()

	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = value
	end
end

UserInputService.JumpRequest:Connect(function()

	if not State.InfiniteJump then
		return
	end

	local hum = GetHumanoid()

	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
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

			if not root then
				return
			end

			local velocity =
				root:FindFirstChild("IntrexFlyVelocity")

			if not velocity then

				velocity = Instance.new("BodyVelocity")
				velocity.Name = "IntrexFlyVelocity"
				velocity.MaxForce = Vector3.new(
					math.huge,
					math.huge,
					math.huge
				)

				velocity.Parent = root
			end

			local direction = Vector3.zero
			local camera = workspace.CurrentCamera

			if not camera then
				return
			end

			local cameraCF = camera.CFrame

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				direction += cameraCF.LookVector
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				direction -= cameraCF.LookVector
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				direction -= cameraCF.RightVector
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				direction += cameraCF.RightVector
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				direction += Vector3.yAxis
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
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
-- TARGET VALIDATION
--==============================================================

local function IsValidPlayer(player)

	if not player then
		return false
	end

	if player == LocalPlayer then
		return false
	end

	local character = player.Character

	if not character then
		return false
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	local head =
		character:FindFirstChild("Head")

	if not humanoid or not head then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	if State.TeamCheck then

		if LocalPlayer.Team ~= nil
			and player.Team ~= nil
			and LocalPlayer.Team == player.Team then

			return false
		end
	end

	return true
end

--==============================================================
-- LINE OF SIGHT
--==============================================================

local function HasLineOfSight(player)

	if not State.LineOfSight then
		return true
	end

	local character = GetCharacter()

	if not character then
		return false
	end

	local targetCharacter = player.Character

	if not targetCharacter then
		return false
	end

	local head = targetCharacter:FindFirstChild("Head")

	if not head then
		return false
	end

	local camera = workspace.CurrentCamera

	if not camera then
		return false
	end

	local origin = camera.CFrame.Position
	local direction = head.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {
		character
	}

	local result = workspace:Raycast(
		origin,
		direction,
		params
	)

	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(
		targetCharacter
	)
end

--==============================================================
-- FIND CLOSEST TARGET
--==============================================================

local function GetClosestPlayer()

	local camera = workspace.CurrentCamera

	if not camera then
		return nil
	end

	local viewport = camera.ViewportSize

	local center = Vector2.new(
		viewport.X / 2,
		viewport.Y / 2
	)

	local closest = nil
	local closestDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do

		if IsValidPlayer(player)
			and HasLineOfSight(player) then

			local character = player.Character
			local head = character and character:FindFirstChild("Head")

			if head then

				local screenPosition, visible =
					camera:WorldToViewportPoint(
						head.Position
					)

				if visible and screenPosition.Z > 0 then

					local point = Vector2.new(
						screenPosition.X,
						screenPosition.Y
					)

					local distance =
						(point - center).Magnitude

					if distance <= State.AimFOV
						and distance < closestDistance then

						closestDistance = distance
						closest = player
					end
				end
			end
		end
	end

	return closest
end

--==============================================================
-- PERSISTENT LOCK
--==============================================================

local function ClearLockedTarget()

	State.LockedTarget = nil
	State.SelectedPlayer = nil
end

local function AcquireLockedTarget()

	if not State.PlayerTargetTester then
		return nil
	end

	local target = GetClosestPlayer()

	if target then
		State.LockedTarget = target
		State.SelectedPlayer = target
	end

	return target
end

--==============================================================
-- PUBLIC LOCKED AIM POSITION
--==============================================================
-- Weapon systems in your own experience can call:
--
-- local position = GetLockedAimPosition()
--
-- It returns the locked player's Head position.
--==============================================================

function GetLockedAimPosition()

	local target = State.LockedTarget

	if not IsValidPlayer(target) then
		return nil
	end

	local character = target.Character

	if not character then
		return nil
	end

	local head = character:FindFirstChild("Head")

	if not head then
		return nil
	end

	return head.Position
end

--==============================================================
-- LOCKED PLAYER
--==============================================================

function GetLockedPlayer()
	return State.LockedTarget
end

--==============================================================
-- LOCK UPDATE
--==============================================================

RunService:BindToRenderStep(
	"IntrexPersistentLock",
	Enum.RenderPriority.Camera.Value + 1,
	function()

		if not State.PlayerTargetTester then
			return
		end

		if not State.AimHold then
			return
		end

		local camera = workspace.CurrentCamera

		if not camera then
			return
		end

		-- IMPORTANT:
		-- We only acquire a target when we don't already
		-- have one. This prevents target switching.
		if not IsValidPlayer(State.LockedTarget) then

			local target = AcquireLockedTarget()

			if not target then
				return
			end

			Notify(
				"LOCKED: "
				.. target.DisplayName
			)
		end

		local target = State.LockedTarget

		if not IsValidPlayer(target) then
			ClearLockedTarget()
			return
		end

		if State.LineOfSight
			and not HasLineOfSight(target) then

			ClearLockedTarget()
			Notify("Target lost")
			return
		end

		local character = target.Character

		if not character then
			ClearLockedTarget()
			return
		end

		local head = character:FindFirstChild("Head")

		if not head then
			ClearLockedTarget()
			return
		end

		local desired =
			CFrame.lookAt(
				camera.CFrame.Position,
				head.Position
			)

		local strength =
			math.clamp(
				State.AimStrength / 100,
				0,
				1
			)

		-- At 100%, use direct tracking.
		-- Lower values smoothly interpolate.
		if strength >= 0.99 then

			camera.CFrame = desired

		else

			camera.CFrame =
				camera.CFrame:Lerp(
					desired,
					strength
				)
		end
	end
)

--==============================================================
-- RMB
--==============================================================

UserInputService.InputBegan:Connect(function(
	input,
	processed
)

	if processed then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseButton2 then

		State.AimHold = true

		-- Acquire exactly once when RMB starts.
		if State.PlayerTargetTester then

			ClearLockedTarget()

			local target =
				AcquireLockedTarget()

			if target then

				Notify(
					"Target locked: "
					.. target.DisplayName
				)

			else
				Notify("No valid target")
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton2 then

		State.AimHold = false

		ClearLockedTarget()
	end
end)

--==============================================================
-- ESP
--==============================================================

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

	local Highlight

	if State.PlayerESP then

		Highlight = Instance.new("Highlight")
		Highlight.Name = "IntrexESP"
		Highlight.Adornee = character
		Highlight.FillColor = C.Accent
		Highlight.OutlineColor = Color3.new(1, 1, 1)
		Highlight.FillTransparency = 0.72
		Highlight.OutlineTransparency = 0
		Highlight.Parent = character
	end

	local Billboard
	local connection

	if State.NameESP
		or State.DistanceESP
		or State.HealthESP then

		local head = character:FindFirstChild("Head")

		if head then

			Billboard = Instance.new("BillboardGui")
			Billboard.Name = "IntrexInfo"
			Billboard.Adornee = head
			Billboard.Size = UDim2.fromOffset(200, 50)
			Billboard.StudsOffset = Vector3.new(0, 2.8, 0)
			Billboard.AlwaysOnTop = true
			Billboard.Parent = character

			local Text = Instance.new("TextLabel")
			Text.BackgroundTransparency = 1
			Text.Size = UDim2.fromScale(1, 1)
			Text.TextColor3 = Color3.new(1, 1, 1)
			Text.TextStrokeTransparency = 0.5
			Text.TextSize = 11
			Text.Font = Enum.Font.GothamBold
			Text.Parent = Billboard

			connection =
				RunService.RenderStepped:Connect(function()

					if not Billboard.Parent then

						if connection then
							connection:Disconnect()
						end

						return
					end

					local parts = {}

					if State.NameESP then
						table.insert(
							parts,
							player.DisplayName
						)
					end

					if State.DistanceESP then

						local mine = GetRoot()

						local their =
							character:FindFirstChild(
								"HumanoidRootPart"
							)

						if mine and their then

							table.insert(
								parts,
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

						local hum =
							character:FindFirstChildOfClass(
								"Humanoid"
							)

						if hum then

							table.insert(
								parts,
								math.floor(hum.Health)
								.. "/"
								.. math.floor(hum.MaxHealth)
							)
						end
					end

					Text.Text =
						table.concat(
							parts,
							"  •  "
						)
				end)
		end
	end

	ESPObjects[player] = {
		Highlight = Highlight,
		Billboard = Billboard,
		Connection = connection,
	}
end

local function RefreshESP()

	for player in pairs(ESPObjects) do
		RemoveESP(player)
	end

	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then
			AddESP(player)
		end
	end
end

--==============================================================
-- CROSSHAIR
--==============================================================

local Crosshair = Instance.new("Frame")
Crosshair.Name = "Crosshair"
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)
Crosshair.Size = UDim2.fromOffset(24, 24)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = false
Crosshair.Parent = Gui

local function CrossLine(size, position)

	local line = Instance.new("Frame")
	line.Size = size
	line.Position = position
	line.BackgroundColor3 = C.Accent
	line.BorderSizePixel = 0
	line.Parent = Crosshair
end

CrossLine(
	UDim2.fromOffset(2, 8),
	UDim2.fromOffset(11, 0)
)

CrossLine(
	UDim2.fromOffset(2, 8),
	UDim2.fromOffset(11, 16)
)

CrossLine(
	UDim2.fromOffset(8, 2),
	UDim2.fromOffset(0, 11)
)

CrossLine(
	UDim2.fromOffset(8, 2),
	UDim2.fromOffset(16, 11)
)

--==============================================================
-- TRAILS
--==============================================================

local function SetTrail(enabled)

	State.Trails = enabled

	local root = GetRoot()

	if not root then
		return
	end

	for _, object in ipairs(root:GetChildren()) do

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
	trail.Color = ColorSequence.new(C.Accent)
	trail.Parent = root
end

--==============================================================
-- FULLBRIGHT
--==============================================================

local function SetFullbright(enabled)

	State.Fullbright = enabled

	if enabled then

		OriginalLighting.Brightness =
			Lighting.Brightness

		OriginalLighting.ClockTime =
			Lighting.ClockTime

		OriginalLighting.FogEnd =
			Lighting.FogEnd

		OriginalLighting.GlobalShadows =
			Lighting.GlobalShadows

		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false

	else

		for property, value in pairs(OriginalLighting) do

			pcall(function()
				Lighting[property] = value
			end)
		end
	end
end

--==============================================================
-- COORDINATES
--==============================================================

local CoordinatesLabel = Instance.new("TextLabel")
CoordinatesLabel.AnchorPoint = Vector2.new(0, 1)
CoordinatesLabel.Position = UDim2.new(0, 15, 1, -15)
CoordinatesLabel.Size = UDim2.fromOffset(260, 22)
CoordinatesLabel.BackgroundColor3 = C.Panel
CoordinatesLabel.TextColor3 = C.Text
CoordinatesLabel.TextSize = 10
CoordinatesLabel.Font = Enum.Font.Code
CoordinatesLabel.TextXAlignment = Enum.TextXAlignment.Left
CoordinatesLabel.Visible = false
CoordinatesLabel.Parent = Gui

Corner(CoordinatesLabel, 6)

RunService.RenderStepped:Connect(function()

	if not State.Coordinates then
		return
	end

	local root = GetRoot()

	if root then

		local p = root.Position

		CoordinatesLabel.Text =
			string.format(
				"X %.1f   Y %.1f   Z %.1f",
				p.X,
				p.Y,
				p.Z
			)
	end
end)

--==============================================================
-- CATEGORIES
--==============================================================

local Categories = {
	"Combat",
	"Movement",
	"Player",
	"Visuals",
	"ESP",
	"World",
	"Utility",
	"Trolling",
	"Teleport",
	"Misc",
	"Settings",
	"Config",
	"Debug",
}

local CategoryButtons = {}

--==============================================================
-- CLEAR PAGE
--==============================================================

local function ClearPage()

	for _, object in ipairs(Options:GetChildren()) do

		if object:IsA("GuiObject") then
			object:Destroy()
		end
	end
end

--==============================================================
-- CATEGORY LOADER
--==============================================================

local function LoadCategory(category)

	SelectedCategory = category

	PageTitle.Text = category
	PageDescription.Text = category .. " controls"

	ClearPage()

	--============================================================
	-- COMBAT
	--============================================================

	if category == "Combat" then

		CreateToggle(
			"Persistent Player Lock",
			"RMB acquires one target and keeps that target",
			State.PlayerTargetTester,
			function(v)

				State.PlayerTargetTester = v

				if not v then
					State.AimHold = false
					ClearLockedTarget()
				end

				Notify(
					v
					and "Persistent lock enabled"
					or "Persistent lock disabled"
				)
			end
		)

		CreateSlider(
			"Lock Strength",
			"100 = direct head tracking",
			CONFIG.MinLockStrength,
			CONFIG.MaxLockStrength,
			State.AimStrength,
			function(v)
				State.AimStrength = v
			end
		)

		CreateSlider(
			"Target FOV",
			"Screen radius used when acquiring a target",
			CONFIG.MinAimFOV,
			CONFIG.MaxAimFOV,
			State.AimFOV,
			function(v)
				State.AimFOV = v
			end
		)

		CreateToggle(
			"Line Of Sight",
			"Ignore players behind objects",
			State.LineOfSight,
			function(v)
				State.LineOfSight = v
			end
		)

		CreateToggle(
			"Team Check",
			"Ignore players on your team",
			State.TeamCheck,
			function(v)
				State.TeamCheck = v
			end
		)

		CreateAction(
			"Nearest Player",
			"Manually acquire the nearest valid target",
			function()

				local target =
					GetClosestPlayer()

				if target then

					State.LockedTarget = target
					State.SelectedPlayer = target

					Notify(
						"Locked: "
						.. target.DisplayName
					)

				else
					Notify("No valid player found")
				end
			end
		)

		CreateAction(
			"Clear Target",
			"Release the current locked target",
			function()

				ClearLockedTarget()

				Notify("Target cleared")
			end
		)

		CreateAction(
			"Target Status",
			"Show the currently locked player",
			function()

				if IsValidPlayer(State.LockedTarget) then

					Notify(
						"Locked: "
						.. State.LockedTarget.DisplayName
					)

				else
					Notify("No target locked")
				end
			end
		)

	--============================================================
	-- MOVEMENT
	--============================================================

	elseif category == "Movement" then

		CreateSlider(
			"Walk Speed",
			"Change character movement speed",
			CONFIG.MinSpeed,
			CONFIG.MaxSpeed,
			State.WalkSpeed,
			ApplySpeed
		)

		CreateSlider(
			"Jump Power",
			"Change character jump strength",
			CONFIG.MinJump,
			CONFIG.MaxJump,
			State.JumpPower,
			ApplyJump
		)

		CreateSlider(
			"Fly Speed",
			"Movement speed while flying",
			CONFIG.MinFlySpeed,
			CONFIG.MaxFlySpeed,
			State.FlySpeed,
			function(v)
				State.FlySpeed = v
			end
		)

		CreateToggle(
			"Fly",
			"WASD + Space/Ctrl",
			State.Fly,
			function(v)

				if v then
					StartFly()
					Notify("Fly enabled")
				else
					StopFly()
					Notify("Fly disabled")
				end
			end
		)

		CreateSlider(
			"Field Of View",
			"Change local camera FOV",
			CONFIG.MinFOV,
			CONFIG.MaxFOV,
			State.FOV,
			function(v)

				State.FOV = v

				local camera =
					workspace.CurrentCamera

				if camera then
					camera.FieldOfView = v
				end
			end
		)

		CreateToggle(
			"Infinite Jump",
			"Jump while airborne",
			State.InfiniteJump,
			function(v)
				State.InfiniteJump = v
			end
		)

		CreateToggle(
			"Noclip",
			"Disable local character collisions",
			State.Noclip,
			function(v)
				State.Noclip = v
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

	--============================================================
	-- PLAYER
	--============================================================

	elseif category == "Player" then

		CreateToggle(
			"Third Person",
			"Switch camera distance",
			State.ThirdPerson,
			function(enabled)

				State.ThirdPerson = enabled

				if enabled then

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
			"Display current coordinates",
			State.Coordinates,
			function(v)

				State.Coordinates = v
				CoordinatesLabel.Visible = v
			end
		)

		CreateAction(
			"Reset Character",
			"Reset your character",
			function()

				local hum = GetHumanoid()

				if hum then
					hum.Health = 0
				end
			end
		)

		CreateAction(
			"Respawn",
			"Reload your character",
			function()
				LocalPlayer:LoadCharacter()
			end
		)

	--============================================================
	-- VISUALS
	--============================================================

	elseif category == "Visuals" then

		CreateToggle(
			"Fullbright",
			"Brighten local lighting",
			State.Fullbright,
			SetFullbright
		)

		CreateToggle(
			"No Fog",
			"Remove local fog",
			State.NoFog,
			function(v)

				State.NoFog = v

				if v then
					Lighting.FogEnd = 100000
				else
					Lighting.FogEnd =
						OriginalLighting.FogEnd
						or 100000
				end
			end
		)

		CreateToggle(
			"Crosshair",
			"Show a local crosshair",
			State.Crosshair,
			function(v)

				State.Crosshair = v
				Crosshair.Visible = v
			end
		)

		CreateToggle(
			"Character Trail",
			"Create a trail behind your character",
			State.Trails,
			SetTrail
		)

		CreateToggle(
			"Rainbow Character",
			"Cycle character colors",
			State.RainbowCharacter,
			function(v)
				State.RainbowCharacter = v
			end
		)

	--============================================================
	-- ESP
	--============================================================

	elseif category == "ESP" then

		CreateToggle(
			"Player ESP",
			"Highlight other players",
			State.PlayerESP,
			function(v)

				State.PlayerESP = v
				RefreshESP()
			end
		)

		CreateToggle(
			"Name ESP",
			"Display player names",
			State.NameESP,
			function(v)

				State.NameESP = v
				RefreshESP()
			end
		)

		CreateToggle(
			"Distance ESP",
			"Display distance",
			State.DistanceESP,
			function(v)

				State.DistanceESP = v
				RefreshESP()
			end
		)

		CreateToggle(
			"Health ESP",
			"Display player health",
			State.HealthESP,
			function(v)

				State.HealthESP = v
				RefreshESP()
			end
		)

	--============================================================
	-- WORLD
	--============================================================

	elseif category == "World" then

		CreateSlider(
			"Clock Time",
			"Change local time",
			0,
			24,
			math.floor(Lighting.ClockTime),
			function(v)
				Lighting.ClockTime = v
			end
		)

		CreateSlider(
			"Brightness",
			"Adjust local brightness",
			0,
			10,
			math.floor(Lighting.Brightness),
			function(v)
				Lighting.Brightness = v
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

	--============================================================
	-- UTILITY
	--============================================================

	elseif category == "Utility" then

		CreateToggle(
			"Performance Monitor",
			"Display basic performance information",
			State.Performance,
			function(v)

				State.Performance = v

				Notify(
					v
					and "Performance enabled"
					or "Performance disabled"
				)
			end
		)

		CreateAction(
			"Print Position",
			"Print your position to Output",
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
			"Notification Test",
			"Test notification system",
			function()
				Notify("INTREX notification test")
			end
		)

	--============================================================
	-- TROLLING
	--============================================================

	elseif category == "Trolling" then

		CreateToggle(
			"Spin",
			"Spin your character",
			State.Spin,
			function(v)
				State.Spin = v
			end
		)

		CreateAction(
			"Particle Burst",
			"Create a local particle burst",
			function()

				local root = GetRoot()

				if not root then
					return
				end

				local emitter =
					Instance.new("ParticleEmitter")

				emitter.Texture =
					"rbxasset://textures/particles/sparkles_main.dds"

				emitter.Rate = 100

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
			end
		)

	--============================================================
	-- TELEPORT
	--============================================================

	elseif category == "Teleport" then

		CreateAction(
			"Teleport To Spawn",
			"Move to SpawnLocation",
			function()

				local root = GetRoot()

				if not root then
					return
				end

				local spawn =
					workspace:FindFirstChildWhichIsA(
						"SpawnLocation",
						true
					)

				if spawn then

					root.CFrame =
						spawn.CFrame
						* CFrame.new(0, 4, 0)

					Notify("Teleported to spawn")

				else
					Notify("No spawn found")
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
						* CFrame.new(
							0,
							20,
							0
						)
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
						* CFrame.new(
							0,
							-20,
							0
						)
				end
			end
		)

	--============================================================
	-- MISC
	--============================================================

	elseif category == "Misc" then

		CreateToggle(
			"Trails",
			"Character trail",
			State.Trails,
			SetTrail
		)

		CreateAction(
			"Clear Intrex Effects",
			"Remove Intrex effects",
			function()

				local root = GetRoot()

				if root then

					for _, object in ipairs(
						root:GetChildren()
					) do

						if object.Name:match("^Intrex") then
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
			"Compact Mode",
			"Use a smaller window",
			false,
			function(enabled)

				if enabled then

					Tween(
						Window,
						{
							Size =
								UDim2.fromOffset(
									500,
									350
								)
						},
						0.2
					)

				else

					Tween(
						Window,
						{
							Size =
								UDim2.fromOffset(
									CONFIG.WindowWidth,
									CONFIG.WindowHeight
								)
						},
						0.2
					)
				end
			end
		)

		CreateAction(
			"Reset Camera",
			"Restore default FOV",
			function()

				State.FOV =
					CONFIG.DefaultFOV

				local camera =
					workspace.CurrentCamera

				if camera then
					camera.FieldOfView =
						CONFIG.DefaultFOV
				end

				Notify("Camera reset")
			end
		)

	--============================================================
	-- CONFIG
	--============================================================

	elseif category == "Config" then

		CreateAction(
			"Reset Movement",
			"Reset movement values",
			function()

				ApplySpeed(
					CONFIG.DefaultWalkSpeed
				)

				ApplyJump(
					CONFIG.DefaultJumpPower
				)

				State.FlySpeed = 70
				State.FOV = CONFIG.DefaultFOV

				local camera =
					workspace.CurrentCamera

				if camera then
					camera.FieldOfView =
						CONFIG.DefaultFOV
				end

				Notify("Movement reset")
			end
		)

		CreateAction(
			"Disable Features",
			"Disable tester and movement features",
			function()

				StopFly()

				State.PlayerTargetTester = false
				State.AimHold = false

				ClearLockedTarget()

				State.Noclip = false
				State.InfiniteJump = false
				State.Spin = false

				Notify("Features disabled")
			end
		)

		CreateAction(
			"Clear Target",
			"Clear selected player",
			function()

				ClearLockedTarget()

				Notify("Target cleared")
			end
		)

	--============================================================
	-- DEBUG
	--============================================================

	elseif category == "Debug" then

		CreateAction(
			"Character Debug",
			"Print character information",
			function()

				local character = GetCharacter()
				local humanoid = GetHumanoid()
				local root = GetRoot()

				print("========== INTREX ==========")
				print("Character:", character)
				print("Humanoid:", humanoid)
				print("Root:", root)

				if humanoid then

					print(
						"WalkSpeed:",
						humanoid.WalkSpeed
					)

					print(
						"JumpPower:",
						humanoid.JumpPower
					)

					print(
						"Health:",
						humanoid.Health
					)
				end

				print(
					"Selected Player:",
					State.SelectedPlayer
				)

				print(
					"Locked Target:",
					State.LockedTarget
				)

				print("=============================")

				Notify("Debug printed")
			end
		)

		CreateAction(
			"Lighting Debug",
			"Print lighting information",
			function()

				print(
					"Brightness:",
					Lighting.Brightness
				)

				print(
					"ClockTime:",
					Lighting.ClockTime
				)

				print(
					"FogEnd:",
					Lighting.FogEnd
				)

				print(
					"GlobalShadows:",
					Lighting.GlobalShadows
				)

				Notify("Lighting printed")
			end
		)
	end
end

--==============================================================
-- CATEGORY BUTTONS
--==============================================================

for index, category in ipairs(Categories) do

	local Button = Instance.new("TextButton")

	Button.Name = category
	Button.Size = UDim2.new(1, 0, 0, 28)
	Button.BackgroundColor3 = C.Sidebar
	Button.Text = category
	Button.TextColor3 = C.SubText
	Button.TextSize = 9
	Button.Font = Enum.Font.GothamBold
	Button.TextXAlignment = Enum.TextXAlignment.Left
	Button.AutoButtonColor = false
	Button.LayoutOrder = index
	Button.Parent = CategoryScroll

	Corner(Button, 6)

	local Padding = Instance.new("UIPadding")
	Padding.PaddingLeft = UDim.new(0, 10)
	Padding.Parent = Button

	CategoryButtons[category] = Button

	Button.MouseEnter:Connect(function()

		if SelectedCategory ~= category then

			Tween(
				Button,
				{
					BackgroundColor3 = C.Panel2,
					TextColor3 = C.Text
				},
				0.1
			)
		end
	end)

	Button.MouseLeave:Connect(function()

		if SelectedCategory ~= category then

			Tween(
				Button,
				{
					BackgroundColor3 = C.Sidebar,
					TextColor3 = C.SubText
				},
				0.1
			)
		end
	end)

	Button.MouseButton1Click:Connect(function()

		for _, other in pairs(CategoryButtons) do

			Tween(
				other,
				{
					BackgroundColor3 = C.Sidebar,
					TextColor3 = C.SubText
				},
				0.08
			)
		end

		Tween(
			Button,
			{
				BackgroundColor3 = C.AccentDark,
				TextColor3 = C.Text
			},
			0.12
		)

		LoadCategory(category)
	end)
end

--==============================================================
-- NOCLIP
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
-- SPIN
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
-- RAINBOW
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

	if State.SelectedPlayer == player
		or State.LockedTarget == player then

		ClearLockedTarget()

		if State.AimHold then
			Notify("Locked target left")
		end
	end

	RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do

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
-- RESPAWN
--==============================================================

LocalPlayer.CharacterAdded:Connect(function(character)

	task.wait(0.5)

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

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
OpenButton.AnchorPoint = Vector2.new(0, 0.5)
OpenButton.Position = UDim2.new(0, 15, 0.5, 0)
OpenButton.Size = UDim2.fromOffset(42, 42)
OpenButton.BackgroundColor3 = C.Background
OpenButton.Text = "I"
OpenButton.TextColor3 = C.Accent
OpenButton.TextSize = 19
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Parent = Gui

Corner(OpenButton, 12)

Stroke(
	OpenButton,
	C.Accent,
	1,
	0.3
)

OpenButton.MouseButton1Click:Connect(function()

	Window.Visible =
		not Window.Visible

	if Window.Visible then

		Window.Size =
			UDim2.fromOffset(
				500,
				350
			)

		Tween(
			Window,
			{
				Size =
					UDim2.fromOffset(
						CONFIG.WindowWidth,
						CONFIG.WindowHeight
					)
			},
			0.18
		)
	end
end)

--==============================================================
-- INITIALIZE
--==============================================================

LoadCategory("Movement")

Tween(
	CategoryButtons["Movement"],
	{
		BackgroundColor3 = C.AccentDark,
		TextColor3 = C.Text
	},
	0.12
)

Notify("INTREX DEVELOPER CLIENT READY")
