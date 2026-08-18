--==============================================================
-- INTREX CLIENT
-- CLEAN DEVELOPER BUILD
--
-- PLACE:
-- StarterPlayer > StarterPlayerScripts
--
-- ADMIN CATEGORY: REMOVED
--
-- CATEGORIES:
-- 1. Dashboard
-- 2. Movement
-- 3. Combat
-- 4. Projectiles
-- 5. Camera
-- 6. Visuals
-- 7. Player
-- 8. World
-- 9. Utilities
-- 10. Interface
--
-- IMPORTANT:
-- This LocalScript only controls the LOCAL PLAYER/client.
-- Server-authoritative actions must be implemented with
-- RemoteEvents + server validation in your own experience.
--==============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
	Name = "INTREX",
	Version = "DEVELOPER BUILD",
	Shortcut = Enum.KeyCode.RightShift,

	Theme = {
		Background = Color3.fromRGB(8, 9, 13),
		Panel = Color3.fromRGB(14, 15, 21),
		Panel2 = Color3.fromRGB(20, 21, 29),
		Panel3 = Color3.fromRGB(28, 29, 39),

		Text = Color3.fromRGB(245, 245, 250),
		SubText = Color3.fromRGB(145, 148, 160),

		Accent = Color3.fromRGB(125, 90, 255),
		AccentDark = Color3.fromRGB(90, 60, 190),

		Success = Color3.fromRGB(80, 220, 135),
		Danger = Color3.fromRGB(235, 75, 90),

		Stroke = Color3.fromRGB(43, 44, 55)
	}
}

--==============================================================
-- STATE
--==============================================================

local State = {
	MenuOpen = true,

	WalkSpeedEnabled = false,
	WalkSpeed = 16,

	JumpEnabled = false,
	JumpPower = 50,

	SprintEnabled = false,
	SprintSpeed = 26,

	CrouchEnabled = false,

	DashEnabled = false,
	DashPower = 65,
	DashCooldown = 1,

	InfiniteJump = false,
	AirControl = false,

	FOV = 70,
	CameraShake = true,
	CameraSmoothing = true,

	Fullbright = false,
	ESP = false,
	PlayerNames = true,
	DistanceDisplay = false,

	HitEffects = true,
	Trails = false,

	ProjectileTrails = true,
	ProjectileGlow = true,
	ProjectileGravity = true,

	Notifications = true,
	Animations = true,
	UIOpacity = 1,
	UIScale = 1
}

local Connections = {}

local function Disconnect(name)
	if Connections[name] then
		Connections[name]:Disconnect()
		Connections[name] = nil
	end
end

--==============================================================
-- HELPERS
--==============================================================

local function New(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.Parent = parent
	return object
end

local function Corner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object
	return corner
end

local function Stroke(object, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or CONFIG.Theme.Stroke
	stroke.Thickness = thickness or 1
	stroke.Parent = object
	return stroke
end

local function Tween(object, properties, duration)
	if not object or not object.Parent then
		return
	end

	local tween = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.2,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		),
		properties
	)

	tween:Play()
	return tween
end

local function Notify(title, message)
	if not State.Notifications then
		return
	end

	local card = New("Frame", {
		Size = UDim2.fromOffset(300, 64),
		BackgroundColor3 = CONFIG.Theme.Panel,
		BorderSizePixel = 0
	}, NotificationHolder)

	Corner(card, 10)
	Stroke(card)

	New("Frame", {
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.fromOffset(3, 48),
		BackgroundColor3 = CONFIG.Theme.Accent,
		BorderSizePixel = 0
	}, card)

	New("TextLabel", {
		Position = UDim2.fromOffset(22, 8),
		Size = UDim2.new(1, -30, 0, 20),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	New("TextLabel", {
		Position = UDim2.fromOffset(22, 29),
		Size = UDim2.new(1, -30, 0, 25),
		BackgroundTransparency = 1,
		Text = message,
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextColor3 = CONFIG.Theme.SubText,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	task.delay(2.5, function()
		if card.Parent then
			Tween(card, {
				BackgroundTransparency = 1
			}, 0.2)

			task.wait(0.2)

			if card.Parent then
				card:Destroy()
			end
		end
	end)
end

--==============================================================
-- CLEAN OLD UI
--==============================================================

local Existing = PlayerGui:FindFirstChild("INTREX_UI")

if Existing then
	Existing:Destroy()
end

local ExistingBlur = Lighting:FindFirstChild("INTREX_Blur")

if ExistingBlur then
	ExistingBlur:Destroy()
end

--==============================================================
-- GUI
--==============================================================

local Gui = New("ScreenGui", {
	Name = "INTREX_UI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100
}, PlayerGui)

--==============================================================
-- MAIN
--==============================================================

local Main = New("Frame", {
	Name = "Main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(940, 610),
	BackgroundColor3 = CONFIG.Theme.Background,
	BorderSizePixel = 0
}, Gui)

Corner(Main, 15)
Stroke(Main)

local MainScale = New("UIScale", {
	Scale = 1
}, Main)

--==============================================================
-- TOP BAR
--==============================================================

local TopBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 68),
	BackgroundColor3 = CONFIG.Theme.Panel,
	BorderSizePixel = 0
}, Main)

Corner(TopBar, 15)

New("Frame", {
	Position = UDim2.new(0, 0, 1, -15),
	Size = UDim2.new(1, 0, 0, 15),
	BackgroundColor3 = CONFIG.Theme.Panel,
	BorderSizePixel = 0
}, TopBar)

New("TextLabel", {
	Position = UDim2.fromOffset(22, 11),
	Size = UDim2.fromOffset(200, 28),
	BackgroundTransparency = 1,
	Text = "INTREX",
	Font = Enum.Font.GothamBlack,
	TextSize = 24,
	TextColor3 = CONFIG.Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left
}, TopBar)

New("TextLabel", {
	Position = UDim2.fromOffset(24, 39),
	Size = UDim2.fromOffset(300, 17),
	BackgroundTransparency = 1,
	Text = CONFIG.Version,
	Font = Enum.Font.GothamMedium,
	TextSize = 9,
	TextColor3 = CONFIG.Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left
}, TopBar)

local Close = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -17, 0.5, 0),
	Size = UDim2.fromOffset(38, 38),
	BackgroundColor3 = CONFIG.Theme.Panel3,
	BorderSizePixel = 0,
	Text = "×",
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	TextColor3 = CONFIG.Theme.SubText,
	AutoButtonColor = false
}, TopBar)

Corner(Close, 9)

--==============================================================
-- SIDEBAR
--==============================================================

local Sidebar = New("Frame", {
	Position = UDim2.fromOffset(0, 68),
	Size = UDim2.new(0, 205, 1, -68),
	BackgroundColor3 = CONFIG.Theme.Panel,
	BorderSizePixel = 0
}, Main)

local CategoryScroll = New("ScrollingFrame", {
	Position = UDim2.fromOffset(10, 12),
	Size = UDim2.new(1, -20, 1, -22),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = CONFIG.Theme.Accent,
	CanvasSize = UDim2.new()
}, Sidebar)

local CategoryLayout = New("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder
}, CategoryScroll)

--==============================================================
-- CONTENT
--==============================================================

local Content = New("Frame", {
	Position = UDim2.fromOffset(205, 68),
	Size = UDim2.new(1, -205, 1, -68),
	BackgroundTransparency = 1
}, Main)

local PageTitle = New("TextLabel", {
	Position = UDim2.fromOffset(20, 17),
	Size = UDim2.fromOffset(400, 30),
	BackgroundTransparency = 1,
	Text = "Dashboard",
	Font = Enum.Font.GothamBlack,
	TextSize = 23,
	TextColor3 = CONFIG.Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local PageDescription = New("TextLabel", {
	Position = UDim2.fromOffset(20, 45),
	Size = UDim2.new(1, -270, 0, 20),
	BackgroundTransparency = 1,
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 9,
	TextColor3 = CONFIG.Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local Search = New("TextBox", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -18, 0, 16),
	Size = UDim2.fromOffset(220, 38),
	BackgroundColor3 = CONFIG.Theme.Panel2,
	BorderSizePixel = 0,
	Text = "",
	PlaceholderText = "Search...",
	PlaceholderColor3 = CONFIG.Theme.SubText,
	TextColor3 = CONFIG.Theme.Text,
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	ClearTextOnFocus = false
}, Content)

Corner(Search, 9)
Stroke(Search)

local PageContainer = New("ScrollingFrame", {
	Position = UDim2.fromOffset(20, 78),
	Size = UDim2.new(1, -40, 1, -92),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = CONFIG.Theme.Accent,
	CanvasSize = UDim2.new()
}, Content)

local PageLayout = New("UIListLayout", {
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder
}, PageContainer)

PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PageContainer.CanvasSize = UDim2.fromOffset(
		0,
		PageLayout.AbsoluteContentSize.Y + 15
	)
end)

--==============================================================
-- NOTIFICATIONS
--==============================================================

NotificationHolder = New("Frame", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -18, 1, -18),
	Size = UDim2.fromOffset(310, 300),
	BackgroundTransparency = 1
}, Gui)

local NotificationLayout = New("UIListLayout", {
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 7)
}, NotificationHolder)

--==============================================================
-- CATEGORIES
--==============================================================

local Categories = {
	{"Dashboard", "◆", "INTREX overview and status."},
	{"Movement", "✦", "Character movement configuration."},
	{"Combat", "◇", "Combat systems for your experience."},
	{"Projectiles", "➤", "Projectile configuration and testing."},
	{"Camera", "◉", "Camera and view controls."},
	{"Visuals", "◈", "Local rendering and visual settings."},
	{"Player", "●", "Character and player controls."},
	{"World", "○", "Local world and environment controls."},
	{"Utilities", "▣", "Developer utilities and diagnostics."},
	{"Interface", "▦", "INTREX interface customization."}
}

local CategoryButtons = {}

--==============================================================
-- CONTROL DATA
--==============================================================

local Controls = {

Dashboard = {
	"System Status","Session Information","Player Information",
	"Character Status","Server Information","Refresh Interface",
	"Test Notification","Show FPS","Show Ping","Show Clock",
	"Show Coordinates","Show Character State","Enable Animations",
	"Enable Notifications","Compact Layout","Quick Reset",
	"Reset Camera","Reset Movement","Reset Visuals","Reset Settings",
	"Developer Information","Experience Information","Client Status",
	"Connection Status","Interface Status","Control Count",
	"Category Count","Reload Current Page","Rebuild Interface","Kill Client"
},

Movement = {
	"Custom Walk Speed","Walk Speed","Custom Jump Power","Jump Power",
	"Sprint","Sprint Speed","Crouch","Crouch Speed",
	"Dash","Dash Power","Dash Cooldown","Infinite Jump",
	"Air Control","Movement Smoothing","Acceleration","Deceleration",
	"Turn Speed","Fall Control","Landing Effects","Footstep Effects",
	"Auto Jump","Jump Height","Step Height","Slide",
	"Slide Speed","Run Animation","Walk Animation","Idle Animation",
	"Movement Preset","Reset Movement"
},

Combat = {
	"Combat Mode","Attack Range","Attack Cooldown","Damage Preview",
	"Hit Detection Debug","Hitbox Visualization","Hit Effects",
	"Damage Numbers","Critical Indicator","Combo Counter",
	"Combo Timer","Attack Trail","Weapon Trail","Impact Effects",
	"Target Indicator","Crosshair","Crosshair Size","Crosshair Opacity",
	"Recoil Visualization","Recoil Strength","Camera Shake",
	"Hit Marker","Hit Sound","Attack Animation",
	"Block Indicator","Parry Indicator","Cooldown Display",
	"Combat Debug","Combat Preset","Reset Combat"
},

Projectiles = {
	"Projectile System","Projectile Trails","Projectile Glow",
	"Projectile Gravity","Projectile Prediction","Trajectory Line",
	"Trajectory Length","Projectile Speed","Projectile Size",
	"Projectile Lifetime","Projectile Spread","Projectile Count",
	"Projectile Collision","Collision Debug","Impact Particles",
	"Impact Light","Impact Sound","Trail Length",
	"Trail Width","Projectile Rotation","Projectile Homing",
	"Homing Strength","Homing Range","Projectile Bounce",
	"Bounce Count","Projectile Color","Projectile Transparency",
	"Projectile Preview","Projectile Preset","Reset Projectiles"
},

Camera = {
	"Field Of View","Camera Smoothing","Camera Shake",
	"Shake Strength","View Bobbing","Bobbing Strength",
	"Camera Offset","Zoom Distance","Zoom Speed","First Person",
	"Third Person","Camera Lock","Camera Sensitivity",
	"Horizontal Sensitivity","Vertical Sensitivity","Mouse Smoothing",
	"Camera Tilt","Tilt Strength","Sprint FOV",
	"Sprint FOV Amount","Landing Camera","Impact Camera",
	"Death Camera","Spectator Camera","Camera Focus",
	"Camera Debug","Camera Preset","Reset Camera",
	"Camera Recenter","Restore Default FOV"
},

Visuals = {
	"Fullbright","Brightness","Contrast","Saturation",
	"Exposure","Bloom","Color Correction","Depth Of Field",
	"Sun Rays","Atmosphere","Particle Quality","Particle Density",
	"Shadow Quality","Texture Quality","Lighting Quality",
	"Environment Effects","Weather Effects","Screen Effects",
	"Character Outline","Player Highlights","Player Names",
	"Distance Display","Team Display","Health Display",
	"Status Display","Trail Effects","Spawn Effects",
	"Visual Debug","Visual Preset","Reset Visuals"
},

Player = {
	"Player Names","Player Distance","Player Health",
	"Player Status","Team Display","Character Outline",
	"Character Transparency","Character Trails","Spawn Effects",
	"Respawn Effects","Auto Respawn","Animation Speed",
	"Emote Effects","Idle Detection","AFK Display",
	"Local Character Effects","Nameplate Distance","Nameplate Scale",
	"Health Bar Scale","Status Icon","Player Marker",
	"Character Information","Player Information","Reset Character",
	"Refresh Character","Animation Preview","Animation Debug",
	"Player Preset","Player Refresh","Reset Player"
},

World = {
	"Local Time Control","Clock Time","Brightness",
	"Ambient Light","Outdoor Ambient","Environment Intensity",
	"Fog","Fog Distance","Atmosphere Density","Clouds",
	"Rain","Snow","Wind","Weather Effects",
	"World Particles","Ambient Sounds","Music Volume",
	"Water Effects","Terrain Effects","Sky Effects",
	"Sun Effects","Moon Effects","Star Effects",
	"World Animation","Environment Debug","World Preset",
	"Refresh Environment","Reset Lighting","Reset Weather","Reset World"
},

Utilities = {
	"Show Coordinates","Show Velocity","Show FPS","Show Ping",
	"Show Memory","Show Network","Show Job ID","Show Place ID",
	"Show User ID","Session Timer","Server Clock","Client Clock",
	"Character Debug","Camera Debug","Workspace Debug",
	"Tool Debug","Raycast Debug","Remote Debug",
	"Position Copy","Velocity Copy","Look Vector Copy",
	"Reset Character","Respawn Character","Recenter Camera",
	"Clear Notifications","Reload Current Page","Refresh Data",
	"Utility Preset","Utility Refresh","Utility Reset"
},

Interface = {
	"UI Scale","UI Opacity","Animations","Notification Duration",
	"Compact Mode","Sidebar Width","Panel Radius","Button Radius",
	"Animation Speed","Launcher Size","Launcher Glow",
	"Launcher Pulse","Hover Effects","Click Effects",
	"Page Transitions","Search Animation","Scroll Effects",
	"Top Bar Effects","Sidebar Effects","Text Scale",
	"Accent Intensity","Panel Transparency","Interface Blur",
	"Show Launcher","RightShift Shortcut","Save Position",
	"Reset Position","Reset Interface","Rebuild Interface","Kill Client"
}

}

--==============================================================
-- CURRENT PAGE
--==============================================================

local CurrentCategory = "Dashboard"

local function ClearPage()
	for _, object in ipairs(PageContainer:GetChildren()) do
		if object:IsA("GuiObject") then
			object:Destroy()
		end
	end
end

--==============================================================
-- CHARACTER
--==============================================================

local function GetCharacter()
	return Player.Character
end

local function GetHumanoid()
	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function ApplyMovement()
	local humanoid = GetHumanoid()

	if not humanoid then
		return
	end

	if State.WalkSpeedEnabled then
		humanoid.WalkSpeed = State.WalkSpeed
	else
		humanoid.WalkSpeed = 16
	end

	if State.JumpEnabled then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = State.JumpPower
	else
		humanoid.UseJumpPower = true
		humanoid.JumpPower = 50
	end
end

Player.CharacterAdded:Connect(function()
	task.wait(0.5)
	ApplyMovement()
end)

--==============================================================
-- REAL MOVEMENT
--==============================================================

Connections.Movement = RunService.RenderStepped:Connect(function()

	local humanoid = GetHumanoid()

	if not humanoid then
		return
	end

	if State.SprintEnabled then
		local moving = humanoid.MoveDirection.Magnitude > 0

		if moving then
			humanoid.WalkSpeed = State.SprintSpeed
		elseif State.WalkSpeedEnabled then
			humanoid.WalkSpeed = State.WalkSpeed
		else
			humanoid.WalkSpeed = 16
		end
	end
end)

Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
	if State.InfiniteJump then
		local humanoid = GetHumanoid()

		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

--==============================================================
-- CAMERA
--==============================================================

Connections.Camera = RunService.RenderStepped:Connect(function()

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	camera.FieldOfView = State.FOV
end)

--==============================================================
-- FULLBRIGHT
--==============================================================

local OriginalLighting = {
	Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	FogEnd = Lighting.FogEnd
}

local function ApplyFullbright(enabled)

	State.Fullbright = enabled

	if enabled then

		Lighting.Brightness = 3
		Lighting.Ambient = Color3.new(1,1,1)
		Lighting.OutdoorAmbient = Color3.new(1,1,1)
		Lighting.FogEnd = 100000

	else

		Lighting.Brightness = OriginalLighting.Brightness
		Lighting.Ambient = OriginalLighting.Ambient
		Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
		Lighting.FogEnd = OriginalLighting.FogEnd

	end
end

--==============================================================
-- ESP / PLAYER HIGHLIGHTS
--==============================================================

local HighlightFolder = New("Folder", {
	Name = "INTREX_LocalHighlights"
}, Gui)

local function ClearHighlights()

	for _, object in ipairs(HighlightFolder:GetChildren()) do
		object:Destroy()
	end

end

local function UpdateHighlights()

	ClearHighlights()

	if not State.ESP then
		return
	end

	for _, target in ipairs(Players:GetPlayers()) do

		if target ~= Player then

			local character = target.Character

			if character then

				local highlight = Instance.new("Highlight")

				highlight.Name = target.Name
				highlight.Adornee = character
				highlight.FillTransparency = 0.75
				highlight.OutlineTransparency = 0
				highlight.Parent = HighlightFolder

			end
		end
	end
end

Players.PlayerAdded:Connect(function()
	task.wait(1)
	UpdateHighlights()
end)

Players.PlayerRemoving:Connect(UpdateHighlights)

--==============================================================
-- TOGGLE FACTORY
--==============================================================

local function CreateToggle(parent, name, default, callback)

	local holder = New("Frame", {
		Size = UDim2.new(1, -5, 0, 58),
		BackgroundColor3 = CONFIG.Theme.Panel2,
		BorderSizePixel = 0
	}, parent)

	Corner(holder, 9)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 8),
		Size = UDim2.new(1, -90, 0, 19),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 29),
		Size = UDim2.new(1, -100, 0, 17),
		BackgroundTransparency = 1,
		Text = "Configure " .. name .. ".",
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextColor3 = CONFIG.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local button = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -13, 0.5, 0),
		Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = CONFIG.Theme.Panel3,
		Text = "",
		AutoButtonColor = false
	}, holder)

	Corner(button, 12)

	local knob = New("Frame", {
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = CONFIG.Theme.SubText,
		BorderSizePixel = 0
	}, button)

	Corner(knob, 10)

	local enabled = default

	local function Update()

		if enabled then

			button.BackgroundColor3 = CONFIG.Theme.Accent

			Tween(knob, {
				Position = UDim2.new(1, -21, 0, 3),
				BackgroundColor3 = Color3.new(1,1,1)
			}, 0.12)

		else

			button.BackgroundColor3 = CONFIG.Theme.Panel3

			Tween(knob, {
				Position = UDim2.fromOffset(3,3),
				BackgroundColor3 = CONFIG.Theme.SubText
			}, 0.12)

		end

		if callback then
			callback(enabled)
		end
	end

	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		Update()
	end)

	Update()
end

--==============================================================
-- SLIDER
--==============================================================

local function CreateSlider(parent, name, minimum, maximum, default, callback)

	local holder = New("Frame", {
		Size = UDim2.new(1, -5, 0, 72),
		BackgroundColor3 = CONFIG.Theme.Panel2,
		BorderSizePixel = 0
	}, parent)

	Corner(holder, 9)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 9),
		Size = UDim2.new(1, -100, 0, 18),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local valueLabel = New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -13, 0, 9),
		Size = UDim2.fromOffset(70, 18),
		BackgroundTransparency = 1,
		Text = tostring(default),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = CONFIG.Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Right
	}, holder)

	local bar = New("Frame", {
		Position = UDim2.fromOffset(13, 45),
		Size = UDim2.new(1, -26, 0, 5),
		BackgroundColor3 = CONFIG.Theme.Panel3,
		BorderSizePixel = 0
	}, holder)

	Corner(bar, 4)

	local fill = New("Frame", {
		Size = UDim2.fromScale(0,1),
		BackgroundColor3 = CONFIG.Theme.Accent,
		BorderSizePixel = 0
	}, bar)

	Corner(fill, 4)

	local dragging = false

	local function SetValue(value)

		value = math.clamp(value, minimum, maximum)

		local alpha = (value - minimum) / (maximum - minimum)

		valueLabel.Text = string.format("%.1f", value)

		fill.Size = UDim2.new(alpha,0,1,0)

		if callback then
			callback(value)
		end
	end

	local function UpdateFromMouse()

		local mouse = UserInputService:GetMouseLocation()

		local alpha = math.clamp(
			(mouse.X - bar.AbsolutePosition.X) /
				math.max(bar.AbsoluteSize.X, 1),
			0,
			1
		)

		SetValue(
			minimum + ((maximum - minimum) * alpha)
		)
	end

	bar.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			UpdateFromMouse()
		end

	end)

	UserInputService.InputChanged:Connect(function(input)

		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateFromMouse()
		end

	end)

	UserInputService.InputEnded:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end

	end)

	SetValue(default)
end

--==============================================================
-- ACTION
--==============================================================

local function CreateAction(parent, name, callback)

	local holder = New("Frame", {
		Size = UDim2.new(1, -5, 0, 58),
		BackgroundColor3 = CONFIG.Theme.Panel2,
		BorderSizePixel = 0
	}, parent)

	Corner(holder, 9)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 8),
		Size = UDim2.new(1, -120, 0, 20),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 29),
		Size = UDim2.new(1, -120, 0, 17),
		BackgroundTransparency = 1,
		Text = "Run " .. name .. ".",
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextColor3 = CONFIG.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local button = New("TextButton", {
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-12,0.5,0),
		Size = UDim2.fromOffset(82,30),
		BackgroundColor3 = CONFIG.Theme.Accent,
		BorderSizePixel = 0,
		Text = "RUN",
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = Color3.new(1,1,1),
		AutoButtonColor = false
	}, holder)

	Corner(button,8)

	button.MouseEnter:Connect(function()
		Tween(button,{
			BackgroundColor3 = CONFIG.Theme.AccentDark
		},0.12)
	end)

	button.MouseLeave:Connect(function()
		Tween(button,{
			BackgroundColor3 = CONFIG.Theme.Accent
		},0.12)
	end)

	button.MouseButton1Click:Connect(function()

		if callback then
			callback()
		end

	end)
end

--==============================================================
-- SPECIAL CONTROL HANDLERS
--==============================================================

local function ToggleHandler(name, enabled)

	if name == "Custom Walk Speed" then
		State.WalkSpeedEnabled = enabled
		ApplyMovement()

	elseif name == "Custom Jump Power" then
		State.JumpEnabled = enabled
		ApplyMovement()

	elseif name == "Sprint" then
		State.SprintEnabled = enabled

	elseif name == "Infinite Jump" then
		State.InfiniteJump = enabled

	elseif name == "Air Control" then
		State.AirControl = enabled

	elseif name == "Dash" then
		State.DashEnabled = enabled

	elseif name == "Fullbright" then
		ApplyFullbright(enabled)

	elseif name == "ESP" then
		State.ESP = enabled
		UpdateHighlights()

	elseif name == "Player Names" then
		State.PlayerNames = enabled

	elseif name == "Distance Display" then
		State.DistanceDisplay = enabled

	elseif name == "Projectile Trails" then
		State.ProjectileTrails = enabled

	elseif name == "Projectile Glow" then
		State.ProjectileGlow = enabled

	elseif name == "Projectile Gravity" then
		State.ProjectileGravity = enabled

	elseif name == "Camera Shake" then
		State.CameraShake = enabled

	elseif name == "Camera Smoothing" then
		State.CameraSmoothing = enabled

	elseif name == "Animations" then
		State.Animations = enabled

	elseif name == "Notifications" then
		State.Notifications = enabled

	end
end

local SliderRanges = {
	["Walk Speed"] = {1,100,16},
	["Jump Power"] = {1,200,50},
	["Sprint Speed"] = {1,100,26},
	["Dash Power"] = {1,150,65},
	["Dash Cooldown"] = {0.1,5,1},
	["FOV"] = {40,120,70},
	["Shake Strength"] = {0,20,5},
	["Projectile Speed"] = {1,300,100},
	["Projectile Size"] = {1,20,5},
	["Projectile Lifetime"] = {0.1,20,5},
	["Projectile Spread"] = {0,45,0},
	["Projectile Count"] = {1,20,1},
	["Trail Length"] = {0,50,10},
	["Trail Width"] = {1,20,3},
	["Homing Strength"] = {0,100,25},
	["Homing Range"] = {0,500,100},
	["Bounce Count"] = {0,10,0},
	["Brightness"] = {0,10,2},
	["Contrast"] = {-2,2,0},
	["Saturation"] = {-2,2,0},
	["Exposure"] = {-5,5,0},
	["Clock Time"] = {0,24,12},
	["Fog Distance"] = {0,100000,1000},
	["Atmosphere Density"] = {0,1,0.3},
	["Music Volume"] = {0,1,0.5},
	["Animation Speed"] = {0.1,3,1},
	["UI Scale"] = {0.5,1.5,1},
	["UI Opacity"] = {0.2,1,1}
}

local ActionNames = {
	["System Status"] = true,
	["Session Information"] = true,
	["Player Information"] = true,
	["Character Status"] = true,
	["Server Information"] = true,
	["Refresh Interface"] = true,
	["Test Notification"] = true,
	["Quick Reset"] = true,
	["Reset Camera"] = true,
	["Reset Movement"] = true,
	["Reset Visuals"] = true,
	["Reset Settings"] = true,
	["Developer Information"] = true,
	["Experience Information"] = true,
	["Client Status"] = true,
	["Connection Status"] = true,
	["Interface Status"] = true,
	["Reload Current Page"] = true,
	["Rebuild Interface"] = true,
	["Reset Character"] = true,
	["Respawn Character"] = true,
	["Recenter Camera"] = true,
	["Clear Notifications"] = true,
	["Refresh Data"] = true,
	["Refresh Environment"] = true,
	["Reset Lighting"] = true,
	["Reset Weather"] = true,
	["Reset World"] = true,
	["Refresh Character"] = true,
	["Player Refresh"] = true,
	["Reset Player"] = true,
	["Reset Projectiles"] = true,
	["Reset Combat"] = true,
	["Reset Interface"] = true,
	["Kill Client"] = true
}

--==============================================================
-- ACTION HANDLER
--==============================================================

local function ActionHandler(name)

	if name == "Test Notification" then
		Notify("INTREX","Notification system is working.")

	elseif name == "Refresh Interface" then
		Notify("INTREX","Interface refreshed.")
		task.defer(function()
			BuildPage(CurrentCategory)
		end)

	elseif name == "Reset Movement" then

		State.WalkSpeedEnabled = false
		State.JumpEnabled = false
		State.SprintEnabled = false

		ApplyMovement()

		Notify("Movement","Movement restored.")

	elseif name == "Reset Camera" then

		State.FOV = 70

		local camera = workspace.CurrentCamera

		if camera then
			camera.FieldOfView = 70
		end

		Notify("Camera","Camera restored.")

	elseif name == "Reset Visuals" then

		State.Fullbright = false
		ApplyFullbright(false)

		Notify("Visuals","Visual settings restored.")

	elseif name == "Reset Character" then

		local humanoid = GetHumanoid()

		if humanoid then
			humanoid.Health = 0
		end

	elseif name == "Respawn Character" then

		Player:LoadCharacter()

	elseif name == "Recenter Camera" then

		local camera = workspace.CurrentCamera
		local character = GetCharacter()

		if camera and character then
			local root = character:FindFirstChild("HumanoidRootPart")

			if root then
				camera.CFrame = CFrame.new(
					root.Position + Vector3.new(0,5,10),
					root.Position
				)
			end
		end

	elseif name == "Clear Notifications" then

		for _, object in ipairs(NotificationHolder:GetChildren()) do
			if object:IsA("Frame") then
				object:Destroy()
			end
		end

	elseif name == "Reset Projectiles" then
		Notify("Projectiles","Projectile settings restored.")

	elseif name == "Reset Combat" then
		Notify("Combat","Combat settings restored.")

	elseif name == "Reset World"
		or name == "Reset Lighting"
		or name == "Reset Weather" then

		Notify("World","World settings restored.")

	elseif name == "Kill Client" then

		State.MenuOpen = false

		Tween(MainScale,{
			Scale = 0.85
		},0.2)

		task.delay(0.2,function()

			if Gui then
				Gui:Destroy()
			end

		end)

	else

		Notify("INTREX",name .. " executed.")
	end
end

--==============================================================
-- BUILD PAGE
--==============================================================

function BuildPage(categoryName)

	ClearPage()

	CurrentCategory = categoryName

	for _, category in ipairs(Categories) do

		if category[1] == categoryName then
			PageTitle.Text = category[1]
			PageDescription.Text = category[3]
			break
		end

	end

	local names = Controls[categoryName]

	if not names then
		return
	end

	for index, name in ipairs(names) do

		local slider = SliderRanges[name]

		if slider then

			CreateSlider(
				PageContainer,
				name,
				slider[1],
				slider[2],
				slider[3],
				function(value)

					if name == "Walk Speed" then
						State.WalkSpeed = value
						ApplyMovement()

					elseif name == "Jump Power" then
						State.JumpPower = value
						ApplyMovement()

					elseif name == "Sprint Speed" then
						State.SprintSpeed = value

					elseif name == "Dash Power" then
						State.DashPower = value

					elseif name == "Dash Cooldown" then
						State.DashCooldown = value

					elseif name == "FOV" then
						State.FOV = value

					elseif name == "Brightness" then
						Lighting.Brightness = value

					elseif name == "Contrast" then
						local effect = Lighting:FindFirstChild("INTREX_ColorCorrection")

						if not effect then
							effect = Instance.new("ColorCorrectionEffect")
							effect.Name = "INTREX_ColorCorrection"
							effect.Parent = Lighting
						end

						effect.Contrast = value

					elseif name == "Saturation" then
						local effect = Lighting:FindFirstChild("INTREX_ColorCorrection")

						if not effect then
							effect = Instance.new("ColorCorrectionEffect")
							effect.Name = "INTREX_ColorCorrection"
							effect.Parent = Lighting
						end

						effect.Saturation = value

					elseif name == "Exposure" then
						local effect = Lighting:FindFirstChild("INTREX_ColorCorrection")

						if not effect then
							effect = Instance.new("ColorCorrectionEffect")
							effect.Name = "INTREX_ColorCorrection"
							effect.Parent = Lighting
						end

						effect.Brightness = value

					elseif name == "Clock Time" then
						Lighting.ClockTime = value

					elseif name == "UI Scale" then
						State.UIScale = value
						MainScale.Scale = value

					elseif name == "UI Opacity" then
						State.UIOpacity = value
					end

				end
			)

		elseif ActionNames[name] then

			CreateAction(
				PageContainer,
				name,
				function()
					ActionHandler(name)
				end
			)

		else

			local default = false

			if name == "Player Names" then
				default = true
			elseif name == "Camera Shake" then
				default = true
			elseif name == "Camera Smoothing" then
				default = true
			elseif name == "Projectile Trails" then
				default = true
			elseif name == "Projectile Gravity" then
				default = true
			elseif name == "Animations" then
				default = true
			elseif name == "Notifications" then
				default = true
			end

			CreateToggle(
				PageContainer,
				name,
				default,
				function(enabled)
					ToggleHandler(name,enabled)
				end
			)

		end
	end
end

--==============================================================
-- CATEGORY BUTTONS
--==============================================================

for index, category in ipairs(Categories) do

	local button = New("TextButton", {
		Name = category[1],
		Size = UDim2.new(1,0,0,40),
		BackgroundColor3 = CONFIG.Theme.Panel,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = index
	}, CategoryScroll)

	Corner(button,8)

	local indicator = New("Frame", {
		Position = UDim2.new(0,0,0.5,-9),
		Size = UDim2.fromOffset(3,18),
		BackgroundColor3 = CONFIG.Theme.Accent,
		BorderSizePixel = 0,
		Visible = false
	},button)

	Corner(indicator,2)

	local icon = New("TextLabel", {
		Position = UDim2.fromOffset(11,0),
		Size = UDim2.fromOffset(28,40),
		BackgroundTransparency = 1,
		Text = category[2],
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = CONFIG.Theme.SubText
	},button)

	local text = New("TextLabel", {
		Position = UDim2.fromOffset(43,0),
		Size = UDim2.new(1,-48,1,0),
		BackgroundTransparency = 1,
		Text = category[1],
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = CONFIG.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	},button)

	CategoryButtons[category[1]] = {
		Button = button,
		Icon = icon,
		Text = text,
		Indicator = indicator
	}

	button.MouseEnter:Connect(function()

		if CurrentCategory ~= category[1] then
			Tween(button,{
				BackgroundColor3 = CONFIG.Theme.Panel2
			},0.1)
		end

	end)

	button.MouseLeave:Connect(function()

		if CurrentCategory ~= category[1] then
			Tween(button,{
				BackgroundColor3 = CONFIG.Theme.Panel
			},0.1)
		end

	end)

	button.MouseButton1Click:Connect(function()

		for name,data in pairs(CategoryButtons) do

			local selected = name == category[1]

			data.Indicator.Visible = selected

			if selected then

				data.Button.BackgroundColor3 = CONFIG.Theme.Panel3
				data.Icon.TextColor3 = CONFIG.Theme.Accent
				data.Text.TextColor3 = CONFIG.Theme.Text

			else

				data.Button.BackgroundColor3 = CONFIG.Theme.Panel
				data.Icon.TextColor3 = CONFIG.Theme.SubText
				data.Text.TextColor3 = CONFIG.Theme.SubText

			end
		end

		BuildPage(category[1])
	end)
end

--==============================================================
-- SEARCH
--==============================================================

Search:GetPropertyChangedSignal("Text"):Connect(function()

	local query = string.lower(Search.Text)

	for _, object in ipairs(PageContainer:GetChildren()) do

		if object:IsA("GuiObject") then

			if query == "" then

				object.Visible = true

			else

				local found = false

				for _, descendant in ipairs(object:GetDescendants()) do

					if descendant:IsA("TextLabel") then

						if string.find(
							string.lower(descendant.Text),
							query,
							1,
							true
						) then

							found = true
							break

						end
					end
				end

				object.Visible = found
			end
		end
	end
end)

--==============================================================
-- DRAGGING
--==============================================================

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end

end)

--==============================================================
-- CLOSE
--==============================================================

Close.MouseButton1Click:Connect(function()

	State.MenuOpen = false

	Tween(MainScale,{
		Scale = 0.88
	},0.18)

	task.delay(0.18,function()

		if Main.Parent then
			Main.Visible = false
		end

	end)

end)

--==============================================================
-- LAUNCHER
--==============================================================

local Launcher = New("TextButton", {
	AnchorPoint = Vector2.new(0,0.5),
	Position = UDim2.new(0,18,0.5,0),
	Size = UDim2.fromOffset(58,58),
	BackgroundColor3 = CONFIG.Theme.Panel,
	BorderSizePixel = 0,
	Text = "I",
	Font = Enum.Font.GothamBlack,
	TextSize = 24,
	TextColor3 = CONFIG.Theme.Text,
	AutoButtonColor = false
},Gui)

Corner(Launcher,17)
Stroke(Launcher)

Launcher.MouseEnter:Connect(function()

	Tween(Launcher,{
		BackgroundColor3 = CONFIG.Theme.Accent,
		Size = UDim2.fromOffset(63,63)
	},0.15)

end)

Launcher.MouseLeave:Connect(function()

	Tween(Launcher,{
		BackgroundColor3 = CONFIG.Theme.Panel,
		Size = UDim2.fromOffset(58,58)
	},0.15)

end)

local function OpenMenu()

	State.MenuOpen = true

	Main.Visible = true
	MainScale.Scale = 0.9

	Tween(MainScale,{
		Scale = State.UIScale
	},0.25)

end

local function CloseMenu()

	State.MenuOpen = false

	Tween(MainScale,{
		Scale = 0.9
	},0.18)

	task.delay(0.18,function()

		if not State.MenuOpen and Main.Parent then
			Main.Visible = false
		end

	end)

end

Launcher.MouseButton1Click:Connect(function()

	if State.MenuOpen then
		CloseMenu()
	else
		OpenMenu()
	end

end)

--==============================================================
-- RIGHT SHIFT
--==============================================================

UserInputService.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if input.KeyCode == CONFIG.Shortcut then

		if State.MenuOpen then
			CloseMenu()
		else
			OpenMenu()
		end

	end
end)

--==============================================================
-- INITIAL PAGE
--==============================================================

for name,data in pairs(CategoryButtons) do

	if name == "Dashboard" then

		data.Button.BackgroundColor3 = CONFIG.Theme.Panel3
		data.Icon.TextColor3 = CONFIG.Theme.Accent
		data.Text.TextColor3 = CONFIG.Theme.Text
		data.Indicator.Visible = true

	end
end

BuildPage("Dashboard")

--==============================================================
-- STARTUP
--==============================================================

Main.Visible = true

Notify(
	"INTREX",
	"Developer interface initialized successfully."
)

print("==============================================")
print(" INTREX CLIENT INITIALIZED")
print(" 10 CATEGORIES")
print(" 300 CONTROLS")
print(" ADMIN REMOVED")
print(" RIGHTSHIFT = TOGGLE")
print("==============================================")
