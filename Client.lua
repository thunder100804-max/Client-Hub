--==============================================================
-- INTREX DEVELOPER CLIENT
-- REALISTIC DEVELOPER TEST BUILD
--
-- PLACE:
-- StarterPlayer > StarterPlayerScripts
--
-- ADMIN CATEGORY: REMOVED
--
-- CATEGORIES:
-- 1. Dashboard
-- 2. Movement
-- 3. Projectiles
-- 4. Visuals
-- 5. Player
-- 6. World
-- 7. Utilities
-- 8. Performance
-- 9. Interface
--
-- Designed for YOUR Roblox experience.
--==============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
	Name = "INTREX",
	Version = "DEVELOPER BUILD",
	Shortcut = Enum.KeyCode.RightShift,
	Animation = 0.18,

	Theme = {
		Background = Color3.fromRGB(8, 9, 13),
		Panel = Color3.fromRGB(14, 15, 21),
		Panel2 = Color3.fromRGB(20, 21, 29),
		Panel3 = Color3.fromRGB(28, 29, 39),
		Text = Color3.fromRGB(245, 245, 250),
		SubText = Color3.fromRGB(145, 148, 160),
		Accent = Color3.fromRGB(125, 90, 255),
		AccentDark = Color3.fromRGB(88, 61, 190),
		Danger = Color3.fromRGB(235, 75, 90),
		Success = Color3.fromRGB(80, 220, 135),
		Stroke = Color3.fromRGB(43, 44, 55),
	}
}

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
			duration or CONFIG.Animation,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		),
		properties
	)

	tween:Play()
	return tween
end

local function Character()
	return Player.Character
end

local function Humanoid()
	local character = Character()
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function Root()
	local character = Character()
	return character and character:FindFirstChild("HumanoidRootPart")
end

--==============================================================
-- STATE
--==============================================================

local State = {
	WalkSpeed = 16,
	JumpPower = 50,

	Sprint = false,
	SprintSpeed = 28,

	Dash = false,
	DashPower = 75,
	DashCooldown = 1,

	InfiniteJump = false,

	FOV = 70,
	CameraShake = false,

	ProjectileSpeed = 140,
	ProjectileLifetime = 5,
	ProjectileGravity = 0,
	ProjectileSpread = 0,
	ProjectileSize = 0.35,

	Notifications = true,
	Animations = true,

	UIOpacity = 1,
	UIScale = 1,

	OriginalClockTime = Lighting.ClockTime,
	OriginalGravity = Workspace.Gravity,
}

local Sprinting = false
local LastDash = 0

--==============================================================
-- CLEANUP OLD UI
--==============================================================

local old = PlayerGui:FindFirstChild("INTREX_UI")

if old then
	old:Destroy()
end

--==============================================================
-- GUI
--==============================================================

local Gui = New("ScreenGui", {
	Name = "INTREX_UI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

--==============================================================
-- NOTIFICATIONS
--==============================================================

local Notifications = New("Frame", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -20, 1, -20),
	Size = UDim2.fromOffset(330, 360),
	BackgroundTransparency = 1
}, Gui)

local NotificationLayout = New("UIListLayout", {
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 8)
}, Notifications)

local function Notify(title, message, duration)
	if not State.Notifications then
		return
	end

	local card = New("Frame", {
		Size = UDim2.fromOffset(315, 68),
		BackgroundColor3 = CONFIG.Theme.Panel,
		BorderSizePixel = 0
	}, Notifications)

	Corner(card, 10)
	Stroke(card)

	New("Frame", {
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(0, 3, 1, -16),
		BackgroundColor3 = CONFIG.Theme.Accent,
		BorderSizePixel = 0
	}, card)

	New("TextLabel", {
		Position = UDim2.fromOffset(22, 9),
		Size = UDim2.new(1, -30, 0, 20),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	New("TextLabel", {
		Position = UDim2.fromOffset(22, 31),
		Size = UDim2.new(1, -30, 0, 27),
		BackgroundTransparency = 1,
		Text = message,
		TextWrapped = true,
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextColor3 = CONFIG.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	card.Position = UDim2.fromOffset(340, 0)

	Tween(card, {
		Position = UDim2.fromOffset(0, 0)
	}, .25)

	task.delay(duration or 2.5, function()
		if card.Parent then
			Tween(card, {
				Position = UDim2.fromOffset(340, 0),
				BackgroundTransparency = 1
			}, .2)

			task.wait(.25)

			if card.Parent then
				card:Destroy()
			end
		end
	end)
end

--==============================================================
-- MAIN WINDOW
--==============================================================

local Main = New("Frame", {
	AnchorPoint = Vector2.new(.5, .5),
	Position = UDim2.fromScale(.5, .52),
	Size = UDim2.fromOffset(940, 600),
	BackgroundColor3 = CONFIG.Theme.Background,
	BorderSizePixel = 0,
	Visible = false
}, Gui)

Corner(Main, 16)
Stroke(Main)

local MainScale = New("UIScale", {
	Scale = .9
}, Main)

--==============================================================
-- TOP BAR
--==============================================================

local TopBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 70),
	BackgroundColor3 = CONFIG.Theme.Panel,
	BorderSizePixel = 0
}, Main)

Corner(TopBar, 16)

New("TextLabel", {
	Position = UDim2.fromOffset(22, 12),
	Size = UDim2.fromOffset(300, 30),
	BackgroundTransparency = 1,
	Text = "INTREX",
	Font = Enum.Font.GothamBlack,
	TextSize = 25,
	TextColor3 = CONFIG.Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left
}, TopBar)

New("TextLabel", {
	Position = UDim2.fromOffset(24, 40),
	Size = UDim2.fromOffset(250, 18),
	BackgroundTransparency = 1,
	Text = CONFIG.Version,
	Font = Enum.Font.GothamMedium,
	TextSize = 9,
	TextColor3 = CONFIG.Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left
}, TopBar)

local Close = New("TextButton", {
	AnchorPoint = Vector2.new(1, .5),
	Position = UDim2.new(1, -17, .5, 0),
	Size = UDim2.fromOffset(38, 38),
	BackgroundColor3 = CONFIG.Theme.Panel3,
	BorderSizePixel = 0,
	Text = "×",
	Font = Enum.Font.GothamMedium,
	TextSize = 23,
	TextColor3 = CONFIG.Theme.SubText,
	AutoButtonColor = false
}, TopBar)

Corner(Close, 10)

--==============================================================
-- SIDEBAR
--==============================================================

local Sidebar = New("Frame", {
	Position = UDim2.fromOffset(0, 70),
	Size = UDim2.new(0, 210, 1, -70),
	BackgroundColor3 = CONFIG.Theme.Panel,
	BorderSizePixel = 0
}, Main)

local CategoryList = New("ScrollingFrame", {
	Position = UDim2.fromOffset(10, 12),
	Size = UDim2.new(1, -20, 1, -24),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 0,
	CanvasSize = UDim2.new()
}, Sidebar)

local CategoryLayout = New("UIListLayout", {
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder
}, CategoryList)

CategoryLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	CategoryList.CanvasSize = UDim2.fromOffset(
		0,
		CategoryLayout.AbsoluteContentSize.Y + 10
	)
end)

--==============================================================
-- CONTENT
--==============================================================

local Content = New("Frame", {
	Position = UDim2.fromOffset(210, 70),
	Size = UDim2.new(1, -210, 1, -70),
	BackgroundTransparency = 1
}, Main)

local PageTitle = New("TextLabel", {
	Position = UDim2.fromOffset(20, 15),
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
	Size = UDim2.new(1, -40, 0, 20),
	BackgroundTransparency = 1,
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = CONFIG.Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left
}, Content)

local Search = New("TextBox", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 14),
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
	Position = UDim2.fromOffset(20, 75),
	Size = UDim2.new(1, -40, 1, -90),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = CONFIG.Theme.Accent,
	CanvasSize = UDim2.new()
}, Content)

local PageLayout = New("UIListLayout", {
	Padding = UDim.new(0, 9),
	SortOrder = Enum.SortOrder.LayoutOrder
}, PageContainer)

PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PageContainer.CanvasSize = UDim2.fromOffset(
		0,
		PageLayout.AbsoluteContentSize.Y + 15
	)
end)

--==============================================================
-- REAL GAME FUNCTIONS
--==============================================================

local function SetWalkSpeed(value)
	State.WalkSpeed = value

	local humanoid = Humanoid()

	if humanoid then
		humanoid.WalkSpeed = Sprinting and State.SprintSpeed or value
	end

	Notify("Movement", "WalkSpeed set to " .. math.floor(value), 1.5)
end

local function SetJumpPower(value)
	State.JumpPower = value

	local humanoid = Humanoid()

	if humanoid then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = value
	end

	Notify("Movement", "JumpPower set to " .. math.floor(value), 1.5)
end

local function SetFOV(value)
	State.FOV = value

	local camera = Workspace.CurrentCamera

	if camera then
		Tween(camera, {
			FieldOfView = value
	}, .15)
	end
end

local function ToggleSprint(enabled)
	State.Sprint = enabled
	Sprinting = enabled

	local humanoid = Humanoid()

	if humanoid then
		humanoid.WalkSpeed = enabled
			and State.SprintSpeed
			or State.WalkSpeed
	end

	Notify(
		"Movement",
		enabled and "Sprint enabled." or "Sprint disabled.",
		1.5
	)
end

local function Dash()
	if os.clock() - LastDash < State.DashCooldown then
		return
	end

	local root = Root()

	if not root then
		return
	end

	LastDash = os.clock()

	root.AssemblyLinearVelocity =
		root.CFrame.LookVector * State.DashPower
		+ Vector3.new(
			0,
			root.AssemblyLinearVelocity.Y,
			0
		)
end

--==============================================================
-- REAL PROJECTILE TESTER
--==============================================================

local ProjectileFolder = Workspace:FindFirstChild("INTREX_TestProjectiles")

if not ProjectileFolder then
	ProjectileFolder = Instance.new("Folder")
	ProjectileFolder.Name = "INTREX_TestProjectiles"
	ProjectileFolder.Parent = Workspace
end

local function FireProjectile()
	local root = Root()

	if not root then
		return
	end

	local projectile = Instance.new("Part")

	projectile.Name = "INTREX_TestProjectile"
	projectile.Shape = Enum.PartType.Ball
	projectile.Size = Vector3.new(
		State.ProjectileSize,
		State.ProjectileSize,
		State.ProjectileSize
	)

	projectile.Material = Enum.Material.Neon
	projectile.CanCollide = false
	projectile.CanQuery = true
	projectile.CanTouch = true

	projectile.CFrame =
		root.CFrame * CFrame.new(0, 0, -3)

	projectile.Parent = ProjectileFolder

	local attachment = Instance.new("Attachment")
	attachment.Parent = projectile

	local velocity = Instance.new("LinearVelocity")

	velocity.Attachment0 = attachment
	velocity.MaxForce = math.huge

	local direction = root.CFrame.LookVector

	if State.ProjectileSpread > 0 then
		local randomX = math.rad(
			math.random(
				-State.ProjectileSpread * 100,
				State.ProjectileSpread * 100
			) / 100
		)

		local randomY = math.rad(
			math.random(
				-State.ProjectileSpread * 100,
				State.ProjectileSpread * 100
			) / 100
		)

		direction =
			(CFrame.lookAt(
				Vector3.zero,
				direction
			) * CFrame.Angles(randomX, randomY, 0)).LookVector
	end

	velocity.VectorVelocity =
		direction * State.ProjectileSpeed

	velocity.Parent = projectile

	local connection

	connection = projectile.Touched:Connect(function(hit)
		if not projectile.Parent then
			return
		end

		if hit:IsDescendantOf(Character()) then
			return
		end

		Notify(
			"Projectile",
			"Projectile contacted " .. hit.Name,
			1.2
		)

		if connection then
			connection:Disconnect()
		end

		projectile:Destroy()
	end)

	task.delay(State.ProjectileLifetime, function()
		if connection then
			connection:Disconnect()
		end

		if projectile.Parent then
			projectile:Destroy()
		end
	end)
end

local function ClearProjectiles()
	for _, object in ipairs(ProjectileFolder:GetChildren()) do
		object:Destroy()
	end

	Notify("Projectiles", "Test projectiles cleared.", 1.5)
end

--==============================================================
-- CONTROL FACTORY
--==============================================================

local function CreateToggle(parent, name, description, default, callback)

	local holder = New("Frame", {
		Size = UDim2.new(1, -5, 0, 58),
		BackgroundColor3 = CONFIG.Theme.Panel2,
		BorderSizePixel = 0
	}, parent)

	Corner(holder, 9)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 7),
		Size = UDim2.new(1, -90, 0, 20),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 28),
		Size = UDim2.new(1, -100, 0, 18),
		BackgroundTransparency = 1,
		Text = description,
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextColor3 = CONFIG.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local button = New("TextButton", {
		AnchorPoint = Vector2.new(1, .5),
		Position = UDim2.new(1, -13, .5, 0),
		Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = CONFIG.Theme.Panel3,
		BorderSizePixel = 0,
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

	Corner(knob, 9)

	local enabled = default == true

	local function Update()
		if enabled then
			Tween(button, {
				BackgroundColor3 = CONFIG.Theme.Accent
			})

			Tween(knob, {
				Position = UDim2.new(1, -21, 0, 3),
				BackgroundColor3 = Color3.new(1, 1, 1)
			})
		else
			Tween(button, {
				BackgroundColor3 = CONFIG.Theme.Panel3
			})

			Tween(knob, {
				Position = UDim2.fromOffset(3, 3),
				BackgroundColor3 = CONFIG.Theme.SubText
			})
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

local function CreateSlider(
	parent,
	name,
	minimum,
	maximum,
	default,
	callback
)

	local holder = New("Frame", {
		Size = UDim2.new(1, -5, 0, 70),
		BackgroundColor3 = CONFIG.Theme.Panel2,
		BorderSizePixel = 0
	}, parent)

	Corner(holder, 9)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 8),
		Size = UDim2.new(1, -80, 0, 20),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local valueLabel = New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -13, 0, 8),
		Size = UDim2.fromOffset(70, 20),
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

	Corner(bar, 3)

	local fill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = CONFIG.Theme.Accent,
		BorderSizePixel = 0
	}, bar)

	Corner(fill, 3)

	local knob = New("Frame", {
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.fromScale(0, .5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0
	}, bar)

	Corner(knob, 7)

	local dragging = false

	local function SetValue(value)
		value = math.clamp(value, minimum, maximum)

		local alpha =
			(value - minimum) /
			(maximum - minimum)

		valueLabel.Text = string.format("%.1f", value)

		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, .5, 0)

		if callback then
			callback(value)
		end
	end

	local function MouseUpdate()
		local mouseX =
			UserInputService:GetMouseLocation().X

		local left = bar.AbsolutePosition.X
		local width = bar.AbsoluteSize.X

		local alpha = math.clamp(
			(mouseX - left) / width,
			0,
			1
		)

		SetValue(
			minimum +
			(maximum - minimum) * alpha
		)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			dragging = true
			MouseUpdate()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and
			input.UserInputType ==
			Enum.UserInputType.MouseMovement then

			MouseUpdate()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			dragging = false
		end
	end)

	SetValue(default)
end

--==============================================================
-- ACTION
--==============================================================

local function CreateAction(parent, name, description, callback)

	local holder = New("Frame", {
		Size = UDim2.new(1, -5, 0, 58),
		BackgroundColor3 = CONFIG.Theme.Panel2,
		BorderSizePixel = 0
	}, parent)

	Corner(holder, 9)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 8),
		Size = UDim2.new(1, -115, 0, 20),
		BackgroundTransparency = 1,
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	New("TextLabel", {
		Position = UDim2.fromOffset(13, 29),
		Size = UDim2.new(1, -115, 0, 17),
		BackgroundTransparency = 1,
		Text = description,
		Font = Enum.Font.GothamMedium,
		TextSize = 9,
		TextColor3 = CONFIG.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local button = New("TextButton", {
		AnchorPoint = Vector2.new(1, .5),
		Position = UDim2.new(1, -12, .5, 0),
		Size = UDim2.fromOffset(82, 31),
		BackgroundColor3 = CONFIG.Theme.Accent,
		BorderSizePixel = 0,
		Text = "RUN",
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false
	}, holder)

	Corner(button, 8)

	button.MouseEnter:Connect(function()
		Tween(button, {
			BackgroundColor3 = CONFIG.Theme.AccentDark
		}, .12)
	end)

	button.MouseLeave:Connect(function()
		Tween(button, {
			BackgroundColor3 = CONFIG.Theme.Accent
		}, .12)
	end)

	button.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)
end

--==============================================================
-- CATEGORIES
--==============================================================

local Categories = {
	{
		Name = "Dashboard",
		Icon = "◆",
		Description = "Live developer diagnostics."
	},
	{
		Name = "Movement",
		Icon = "✦",
		Description = "Character movement testing."
	},
	{
		Name = "Projectiles",
		Icon = "●",
		Description = "Projectile and raycast testing."
	},
	{
		Name = "Visuals",
		Icon = "◉",
		Description = "Camera and visual testing."
	},
	{
		Name = "Player",
		Icon = "●",
		Description = "Character and player utilities."
	},
	{
		Name = "World",
		Icon = "◇",
		Description = "Environment testing."
	},
	{
		Name = "Utilities",
		Icon = "◆",
		Description = "Developer utilities."
	},
	{
		Name = "Performance",
		Icon = "▲",
		Description = "Performance diagnostics."
	},
	{
		Name = "Interface",
		Icon = "▦",
		Description = "INTREX customization."
	}
}

--==============================================================
-- CONTROL DATA
--==============================================================

local Pages = {

Movement = {
	{
		type = "slider",
		name = "Walk Speed",
		min = 8,
		max = 100,
		default = 16,
		callback = SetWalkSpeed
	},

	{
		type = "slider",
		name = "Jump Power",
		min = 20,
		max = 150,
		default = 50,
		callback = SetJumpPower
	},

	{
		type = "toggle",
		name = "Sprint",
		description = "Use the configured sprint speed.",
		callback = ToggleSprint
	},

	{
		type = "slider",
		name = "Sprint Speed",
		min = 16,
		max = 120,
		default = 28,
		callback = function(value)
			State.SprintSpeed = value

			if Sprinting then
				local humanoid = Humanoid()

				if humanoid then
					humanoid.WalkSpeed = value
				end
			end
		end
	},

	{
		type = "toggle",
		name = "Infinite Jump",
		description = "Developer movement testing.",
		callback = function(value)
			State.InfiniteJump = value
		end
	},

	{
		type = "toggle",
		name = "Dash",
		description = "Enable the dash test.",
		callback = function(value)
			State.Dash = value
		end
	},

	{
		type = "slider",
		name = "Dash Strength",
		min = 20,
		max = 200,
		default = 75,
		callback = function(value)
			State.DashPower = value
		end
	},

	{
		type = "slider",
		name = "Dash Cooldown",
		min = .1,
		max = 5,
		default = 1,
		callback = function(value)
			State.DashCooldown = value
		end
	},

	{
		type = "action",
		name = "Dash Test",
		description = "Perform one movement dash.",
		callback = Dash
	},

	{
		type = "action",
		name = "Reset Movement",
		description = "Restore normal movement.",
		callback = function()
			State.WalkSpeed = 16
			State.JumpPower = 50
			State.SprintSpeed = 28

			local humanoid = Humanoid()

			if humanoid then
				humanoid.WalkSpeed = 16
				humanoid.UseJumpPower = true
				humanoid.JumpPower = 50
			end

			Notify("Movement", "Movement reset.", 1.5)
		end
	}
},

Projectiles = {
	{
		type = "slider",
		name = "Projectile Speed",
		min = 20,
		max = 500,
		default = 140,
		callback = function(value)
			State.ProjectileSpeed = value
		end
	},

	{
		type = "slider",
		name = "Projectile Lifetime",
		min = .25,
		max = 20,
		default = 5,
		callback = function(value)
			State.ProjectileLifetime = value
		end
	},

	{
		type = "slider",
		name = "Projectile Gravity",
		min = -200,
		max = 200,
		default = 0,
		callback = function(value)
			State.ProjectileGravity = value
		end
	},

	{
		type = "slider",
		name = "Projectile Spread",
		min = 0,
		max = 30,
		default = 0,
		callback = function(value)
			State.ProjectileSpread = value
		end
	},

	{
		type = "slider",
		name = "Projectile Size",
		min = .1,
		max = 3,
		default = .35,
		callback = function(value)
			State.ProjectileSize = value
		end
	},

	{
		type = "action",
		name = "Fire Projectile",
		description = "Launch a real local test projectile.",
		callback = FireProjectile
	},

	{
		type = "action",
		name = "Clear Projectiles",
		description = "Remove all INTREX test projectiles.",
		callback = ClearProjectiles
	},

	{
		type = "action",
		name = "Projectile Burst",
		description = "Fire five test projectiles.",
		callback = function()
			for i = 1, 5 do
				FireProjectile()
				task.wait(.06)
			end
		end
	},

	{
		type = "toggle",
		name = "Projectile Testing",
		description = "Enable projectile development mode.",
		callback = function(value)
			Notify(
				"Projectiles",
				value and "Testing enabled." or "Testing disabled.",
				1.5
			)
		end
	}
},

Visuals = {
	{
		type = "slider",
		name = "Field Of View",
		min = 40,
		max = 120,
		default = 70,
		callback = SetFOV
	},

	{
		type = "slider",
		name = "Brightness",
		min = 0,
		max = 10,
		default = Lighting.Brightness,
		callback = function(value)
			Lighting.Brightness = value
		end
	},

	{
		type = "slider",
		name = "Clock Time",
		min = 0,
		max = 24,
		default = Lighting.ClockTime,
		callback = function(value)
			Lighting.ClockTime = value
		end
	},

	{
		type = "slider",
		name = "Exposure",
		min = -5,
		max = 5,
		default = Lighting.ExposureCompensation,
		callback = function(value)
			Lighting.ExposureCompensation = value
		end
	},

	{
		type = "toggle",
		name = "Camera Shake",
		description = "Enable developer camera shake testing.",
		callback = function(value)
			State.CameraShake = value
		end
	},

	{
		type = "action",
		name = "Reset Camera",
		description = "Restore the camera FOV.",
		callback = function()
			SetFOV(70)
		end
	},

	{
		type = "action",
		name = "Reset Lighting",
		description = "Restore basic lighting values.",
		callback = function()
			Lighting.Brightness = 2
			Lighting.ClockTime = State.OriginalClockTime
			Lighting.ExposureCompensation = 0

			Notify("Visuals", "Lighting reset.", 1.5)
		end
	}
},

World = {
	{
		type = "slider",
		name = "World Gravity",
		min = 0,
		max = 300,
		default = Workspace.Gravity,
		callback = function(value)
			Workspace.Gravity = value
		end
	},

	{
		type = "slider",
		name = "World Time",
		min = 0,
		max = 24,
		default = Lighting.ClockTime,
		callback = function(value)
			Lighting.ClockTime = value
		end
	},

	{
		type = "action",
		name = "Day",
		description = "Set the world to daytime.",
		callback = function()
			Lighting.ClockTime = 12
		end
	},

	{
		type = "action",
		name = "Night",
		description = "Set the world to nighttime.",
		callback = function()
			Lighting.ClockTime = 0
		end
	},

	{
		type = "action",
		name = "Reset Gravity",
		description = "Restore default Roblox gravity.",
		callback = function()
			Workspace.Gravity = 196.2
		end
	}
},

Player = {
	{
		type = "action",
		name = "Reset Character",
		description = "Reset your character.",
		callback = function()
			local humanoid = Humanoid()

			if humanoid then
				humanoid.Health = 0
			end
		end
	},

	{
		type = "action",
		name = "Respawn Test",
		description = "Run a local respawn test.",
		callback = function()
			Player:LoadCharacter()
		end
	},

	{
		type = "toggle",
		name = "Character Transparency",
		description = "Toggle local character visibility.",
		callback = function(value)
			local character = Character()

			if not character then
				return
			end

			for _, object in ipairs(character:GetDescendants()) do
				if object:IsA("BasePart") then
					object.LocalTransparencyModifier =
						value and 1 or 0
				end
			end
		end
	},

	{
		type = "slider",
		name = "Animation Speed",
		min = .1,
		max = 3,
		default = 1,
		callback = function(value)
			local humanoid = Humanoid()

			if not humanoid then
				return
			end

			for _, track in ipairs(
				humanoid:GetPlayingAnimationTracks()
			) do
				track:AdjustSpeed(value)
			end
		end
	}
},

Utilities = {
	{
		type = "action",
		name = "Show Coordinates",
		description = "Display your current position.",
		callback = function()
			local root = Root()

			if root then
				local p = root.Position

				Notify(
					"Coordinates",
					string.format(
						"X %.1f | Y %.1f | Z %.1f",
						p.X,
						p.Y,
						p.Z
					),
					3
				)
			end
		end
	},

	{
		type = "action",
		name = "Character Information",
		description = "Display character diagnostics.",
		callback = function()
			local humanoid = Humanoid()

			if humanoid then
				Notify(
					"Character",
					"Health: "
						.. math.floor(humanoid.Health)
						.. " | Speed: "
						.. math.floor(humanoid.WalkSpeed),
					3
				)
			end
		end
	},

	{
		type = "action",
		name = "Server Information",
		description = "Display server information.",
		callback = function()
			Notify(
				"Server",
				"Place: "
					.. tostring(game.PlaceId)
					.. "\nJob: "
					.. tostring(game.JobId),
				4
			)
		end
	}
},

Performance = {
	{
		type = "toggle",
		name = "Performance Monitor",
		description = "Display live client statistics.",
		callback = function(value)
			Notify(
				"Performance",
				value and "Monitor enabled." or "Monitor disabled.",
				1.5
			)
		end
	},

	{
		type = "action",
		name = "Clear Test Projectiles",
		description = "Clean projectile test objects.",
		callback = ClearProjectiles
	}
},

Interface = {
	{
		type = "slider",
		name = "UI Scale",
		min = .7,
		max = 1.4,
		default = 1,
		callback = function(value)
			State.UIScale = value
			MainScale.Scale = value
		end
	},

	{
		type = "slider",
		name = "UI Opacity",
		min = .4,
		max = 1,
		default = 1,
		callback = function(value)
			State.UIOpacity = value
			Main.BackgroundTransparency = 1 - value
		end
	},

	{
		type = "toggle",
		name = "Notifications",
		description = "Enable INTREX notifications.",
		callback = function(value)
			State.Notifications = value
		end
	},

	{
		type = "toggle",
		name = "Animations",
		description = "Enable interface animations.",
		callback = function(value)
			State.Animations = value
		end
	},

	{
		type = "action",
		name = "Reset Interface",
		description = "Restore the default interface scale.",
		callback = function()
			State.UIScale = 1
			State.UIOpacity = 1

			MainScale.Scale = 1
			Main.BackgroundTransparency = 0

			Notify("Interface", "Interface reset.", 1.5)
		end
	},

	{
		type = "action",
		name = "Kill Client",
		description = "Close INTREX locally.",
		callback = function()
			Gui:Destroy()
		end
	}
},

Dashboard = {
	{
		type = "action",
		name = "Character Status",
		description = "Show current character status.",
		callback = function()
			local humanoid = Humanoid()

			if humanoid then
				Notify(
					"Status",
					"Health "
						.. math.floor(humanoid.Health)
						.. " | Speed "
						.. math.floor(humanoid.WalkSpeed),
					3
				)
			end
		end
	},

	{
		type = "action",
		name = "Position",
		description = "Show current coordinates.",
		callback = function()
			local root = Root()

			if root then
				local p = root.Position

				Notify(
					"Position",
					string.format(
						"%.1f, %.1f, %.1f",
						p.X,
						p.Y,
						p.Z
					),
					3
				)
			end
		end
	},

	{
		type = "action",
		name = "Reset All Test Settings",
		description = "Restore movement and world defaults.",
		callback = function()
			State.WalkSpeed = 16
			State.JumpPower = 50
			State.SprintSpeed = 28
			State.DashPower = 75
			State.DashCooldown = 1
			State.ProjectileSpeed = 140
			State.ProjectileLifetime = 5
			State.ProjectileSpread = 0
			State.ProjectileSize = .35

			local humanoid = Humanoid()

			if humanoid then
				humanoid.WalkSpeed = 16
				humanoid.JumpPower = 50
			end

			Workspace.Gravity = 196.2
			Lighting.ClockTime = State.OriginalClockTime
			SetFOV(70)

			Notify(
				"Dashboard",
				"Developer settings restored.",
				2
			)
		end
	}
}

--==============================================================
-- PAGE BUILDER
--==============================================================

local CurrentCategory
local CategoryButtons = {}

local function ClearPage()
	for _, object in ipairs(PageContainer:GetChildren()) do
		if object:IsA("GuiObject") then
			object:Destroy()
		end
	end
end

local function BuildPage(category)
	ClearPage()

	CurrentCategory = category.Name

	PageTitle.Text = category.Name
	PageDescription.Text = category.Description

	local controls = Pages[category.Name] or {}

	for index, control in ipairs(controls) do
		local holder = New("Frame", {
			Size = UDim2.new(1, -5, 0, 70),
			BackgroundTransparency = 1,
			LayoutOrder = index
		}, PageContainer)

		if control.type == "slider" then
			CreateSlider(
				holder,
				control.name,
				control.min,
				control.max,
				control.default,
				control.callback
			)

		elseif control.type == "toggle" then
			CreateToggle(
				holder,
				control.name,
				control.description or
					"Developer testing control.",
				false,
				control.callback
			)

		elseif control.type == "action" then
			CreateAction(
				holder,
				control.name,
				control.description or
					"Run developer action.",
				control.callback
			)
		end
	end
end

--==============================================================
-- CATEGORY BUTTONS
--==============================================================

local function SelectCategory(category)
	CurrentCategory = category.Name

	for name, data in pairs(CategoryButtons) do
		local selected = name == category.Name

		Tween(data.Button, {
			BackgroundColor3 =
				selected
				and CONFIG.Theme.Panel3
				or CONFIG.Theme.Panel
		}, .12)

		Tween(data.Icon, {
			TextColor3 =
				selected
				and CONFIG.Theme.Accent
				or CONFIG.Theme.SubText
		}, .12)

		Tween(data.Text, {
			TextColor3 =
				selected
				and CONFIG.Theme.Text
				or CONFIG.Theme.SubText
		}, .12)

		data.Indicator.Visible = selected
	end

	BuildPage(category)
end

for index, category in ipairs(Categories) do
	local button = New("TextButton", {
		Name = category.Name,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = CONFIG.Theme.Panel,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = index
	}, CategoryList)

	Corner(button, 9)

	local indicator = New("Frame", {
		Position = UDim2.fromOffset(0, 11),
		Size = UDim2.fromOffset(3, 20),
		BackgroundColor3 = CONFIG.Theme.Accent,
		BorderSizePixel = 0,
		Visible = false
	}, button)

	Corner(indicator, 2)

	local icon = New("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.fromOffset(28, 42),
		BackgroundTransparency = 1,
		Text = category.Icon,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = CONFIG.Theme.SubText
	}, button)

	local text = New("TextLabel", {
		Position = UDim2.fromOffset(45, 0),
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = category.Name,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = CONFIG.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, button)

	CategoryButtons[category.Name] = {
		Button = button,
		Icon = icon,
		Text = text,
		Indicator = indicator
	}

	button.MouseButton1Click:Connect(function()
		SelectCategory(category)
	end)
end

--==============================================================
-- SEARCH
--==============================================================

Search:GetPropertyChangedSignal("Text"):Connect(function()
	local query = string.lower(Search.Text)

	for _, object in ipairs(PageContainer:GetChildren()) do
		if object:IsA("Frame") then
			local text = ""

			for _, descendant in ipairs(object:GetDescendants()) do
				if descendant:IsA("TextLabel") then
					text ..= " " .. descendant.Text
				end
			end

			object.Visible =
				query == ""
				or string.find(
					string.lower(text),
					query,
					1,
					true
				) ~= nil
		end
	end
end)

--==============================================================
-- LAUNCHER
--==============================================================

local Launcher = New("TextButton", {
	AnchorPoint = Vector2.new(0, .5),
	Position = UDim2.new(0, 20, .5, 0),
	Size = UDim2.fromOffset(62, 62),
	BackgroundColor3 = CONFIG.Theme.Panel,
	BorderSizePixel = 0,
	Text = "I",
	Font = Enum.Font.GothamBlack,
	TextSize = 25,
	TextColor3 = CONFIG.Theme.Text,
	AutoButtonColor = false
}, Gui)

Corner(Launcher, 18)
Stroke(Launcher)

--==============================================================
-- MENU
--==============================================================

local MenuOpen = false

local function OpenMenu()
	if MenuOpen or not Main.Parent then
		return
	end

	MenuOpen = true
	Main.Visible = true
	MainScale.Scale = .9

	Tween(MainScale, {
		Scale = State.UIScale
	}, .3)

	Tween(Launcher, {
		Rotation = 90
	}, .2)
end

local function CloseMenu()
	if not MenuOpen then
		return
	end

	MenuOpen = false

	Tween(MainScale, {
		Scale = .9
	}, .2)

	Tween(Launcher, {
		Rotation = 0
	}, .2)

	task.delay(.21, function()
		if not MenuOpen and Main.Parent then
			Main.Visible = false
		end
	end)
end

Launcher.MouseButton1Click:Connect(function()
	if MenuOpen then
		CloseMenu()
	else
		OpenMenu()
	end
end)

Close.MouseButton1Click:Connect(CloseMenu)

--==============================================================
-- MAIN WINDOW DRAGGING
--==============================================================

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState ==
				Enum.UserInputState.End then

				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and
		input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

--==============================================================
-- KEYBOARD
--==============================================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == CONFIG.Shortcut then
		if MenuOpen then
			CloseMenu()
		else
			OpenMenu()
		end
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		if State.Sprint then
			ToggleSprint(true)
		end
	end

	if input.KeyCode == Enum.KeyCode.Q then
		if State.Dash then
			Dash()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		if State.Sprint then
			ToggleSprint(false)
		end
	end
end)

--==============================================================
-- INFINITE JUMP
--==============================================================

UserInputService.JumpRequest:Connect(function()
	if not State.InfiniteJump then
		return
	end

	local humanoid = Humanoid()

	if humanoid then
		humanoid:ChangeState(
			Enum.HumanoidStateType.Jumping
		)
	end
end)

--==============================================================
-- CHARACTER RESPAWN SUPPORT
--==============================================================

Player.CharacterAdded:Connect(function()
	task.wait(.5)

	local humanoid = Humanoid()

	if humanoid then
		humanoid.WalkSpeed =
			Sprinting
			and State.SprintSpeed
			or State.WalkSpeed

		humanoid.UseJumpPower = true
		humanoid.JumpPower = State.JumpPower
	end
end)

--==============================================================
-- INITIALIZE
--==============================================================

SelectCategory(Categories[1])

print("==============================================")
print(" INTREX DEVELOPER CLIENT")
print(" Admin: REMOVED")
print(" Categories: 9")
print(" Projectile Tester: ENABLED")
print(" Movement Tester: ENABLED")
print(" Camera Controls: ENABLED")
print(" World Controls: ENABLED")
print(" Shortcut: RightShift")
print("==============================================")

task.wait(.5)
OpenMenu()

Notify(
	"INTREX",
	"Developer controls initialized.",
	3
)
