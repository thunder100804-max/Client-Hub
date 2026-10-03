-- LocalScript in StarterPlayerScripts or StarterGui
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = 'Trix Menu',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Combat = Window:AddTab('Combat'),
    Esp = Window:AddTab('Esp'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
	["Unlock All"] = Window:AddTab("Unlock All"),
}

-- Unlock All tab 
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UnlockAllTab = Tabs["Unlock All"]

local TrackerGroup = UnlockAllTab:AddLeftGroupbox("RIVALS Inventory")

TrackerGroup:AddLabel("Cosmetic Ownership Tracker")
TrackerGroup:AddDivider()

local SkinLabel = TrackerGroup:AddLabel("Skins Owned: 0")
local WrapLabel = TrackerGroup:AddLabel("Wraps Owned: 0")
local CharmLabel = TrackerGroup:AddLabel("Charms Owned: 0")
local DanceLabel = TrackerGroup:AddLabel("Dances Owned: 0")
local EmoteLabel = TrackerGroup:AddLabel("Emotes Owned: 0")
local TotalLabel = TrackerGroup:AddLabel("Total Cosmetics: 0")

local function CountFolder(folder)
    if not folder then
        return 0
    end

    local count = 0

    for _, object in ipairs(folder:GetChildren()) do
        if object:IsA("BoolValue") then
            if object.Value then
                count += 1
            end
        else
            count += 1
        end
    end

    return count
end

local function FindFolder(parent, names)
    if not parent then
        return nil
    end

    for _, name in ipairs(names) do
        local object = parent:FindFirstChild(name, true)

        if object then
            return object
        end
    end

    return nil
end

local function UpdateInventory()
    local inventory =
        LocalPlayer:FindFirstChild("Inventory")
        or LocalPlayer:FindFirstChild("CosmeticInventory")
        or LocalPlayer:FindFirstChild("PlayerData")

    if not inventory then
        SkinLabel:SetText("Skins Owned: --")
        WrapLabel:SetText("Wraps Owned: --")
        CharmLabel:SetText("Charms Owned: --")
        DanceLabel:SetText("Dances Owned: --")
        EmoteLabel:SetText("Emotes Owned: --")
        TotalLabel:SetText("Total Cosmetics: --")
        return
    end

    local skins = FindFolder(inventory, {"Skins", "Skin"})
    local wraps = FindFolder(inventory, {"Wraps", "Wrap"})
    local charms = FindFolder(inventory, {"Charms", "Charm"})
    local dances = FindFolder(inventory, {"Dances", "Dance"})
    local emotes = FindFolder(inventory, {"Emotes", "Emote"})

    local skinCount = CountFolder(skins)
    local wrapCount = CountFolder(wraps)
    local charmCount = CountFolder(charms)
    local danceCount = CountFolder(dances)
    local emoteCount = CountFolder(emotes)

    local total =
        skinCount
        + wrapCount
        + charmCount
        + danceCount
        + emoteCount

    SkinLabel:SetText("Skins Owned: " .. skinCount)
    WrapLabel:SetText("Wraps Owned: " .. wrapCount)
    CharmLabel:SetText("Charms Owned: " .. charmCount)
    DanceLabel:SetText("Dances Owned: " .. danceCount)
    EmoteLabel:SetText("Emotes Owned: " .. emoteCount)
    TotalLabel:SetText("Total Cosmetics: " .. total)
end

TrackerGroup:AddDivider()

TrackerGroup:AddButton("Unlock Every Cosmetic", function()
    UpdateInventory()
    Library:Notify("Unlock button pressed.", 2)
end)

TrackerGroup:AddButton("Refresh Inventory", function()
    UpdateInventory()
end)

UpdateInventory()

task.spawn(function()
    while LocalPlayer.Parent do
        task.wait(2)
        UpdateInventory()
    end
end)

-- UI Settings tab - this is the only tab with actual content
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

-- Esp tab
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Settings = {
	ESP = false,
	Names = true,
	Distance = true,
	Boxes = true,
	MaxDistance = 1000,
	Color = Color3.fromRGB(255, 255, 255)
}

local ESPObjects = {}

local function RemoveESP(Player)
	local Objects = ESPObjects[Player]

	if Objects then
		for _, Object in ipairs(Objects) do
			if typeof(Object) == "Instance" and Object.Parent then
				Object:Destroy()
			end
		end

		ESPObjects[Player] = nil
	end
end

local function CreateESP(Player)
	if Player == LocalPlayer then
		return
	end

	RemoveESP(Player)

	if not Settings.ESP then
		return
	end

	local Character = Player.Character

	if not Character then
		return
	end

	local Head = Character:FindFirstChild("Head")

	if not Head then
		return
	end

	local Objects = {}

	if Settings.Boxes then
		local Highlight = Instance.new("Highlight")
		Highlight.Name = "VELTRIX_ESP"
		Highlight.Adornee = Character
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.FillTransparency = 0.65
		Highlight.OutlineTransparency = 0
		Highlight.FillColor = Settings.Color
		Highlight.OutlineColor = Settings.Color
		Highlight.Parent = Character

		table.insert(Objects, Highlight)
	end

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "VELTRIX_ESP_INFO"
	Billboard.Adornee = Head
	Billboard.Size = UDim2.fromOffset(220, 45)
	Billboard.StudsOffset = Vector3.new(0, 2.8, 0)
	Billboard.AlwaysOnTop = true
	Billboard.MaxDistance = Settings.MaxDistance
	Billboard.Parent = Head

	local Label = Instance.new("TextLabel")
	Label.Name = "Info"
	Label.Size = UDim2.fromScale(1, 1)
	Label.BackgroundTransparency = 1
	Label.TextColor3 = Settings.Color
	Label.TextStrokeTransparency = 0.25
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 12
	Label.Parent = Billboard

	table.insert(Objects, Billboard)

	ESPObjects[Player] = Objects

	local function Update()
		if not Billboard.Parent then
			return
		end

		if Head.Parent ~= Character then
			return
		end

		local Text = ""

		if Settings.Names then
			Text = Player.DisplayName
		end

		if Settings.Distance then
			local RootPart = Character:FindFirstChild("HumanoidRootPart")

			if RootPart then
				local Camera = workspace.CurrentCamera

				if Camera then
					local Distance = (
						RootPart.Position - Camera.CFrame.Position
					).Magnitude

					if Text ~= "" then
						Text = Text .. "\n"
					end

					Text = Text .. math.floor(Distance) .. " studs"
				end
			end
		end

		Label.Text = Text
		Label.Visible = Settings.Names or Settings.Distance
		Label.TextColor3 = Settings.Color
		Billboard.MaxDistance = Settings.MaxDistance

		local Highlight = Character:FindFirstChild("VELTRIX_ESP")

		if Highlight then
			Highlight.FillColor = Settings.Color
			Highlight.OutlineColor = Settings.Color
		end
	end

	Update()

	task.spawn(function()
		while Billboard.Parent and Settings.ESP do
			Update()
			task.wait(0.1)
		end
	end)
end

local function RefreshESP()
	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer then
			if Settings.ESP then
				CreateESP(Player)
			else
				RemoveESP(Player)
			end
		end
	end
end

local function UpdateESPColor()
	for Player, Objects in pairs(ESPObjects) do
		for _, Object in ipairs(Objects) do
			if Object:IsA("Highlight") then
				Object.FillColor = Settings.Color
				Object.OutlineColor = Settings.Color
			elseif Object:IsA("BillboardGui") then
				local Label = Object:FindFirstChild("Info")

				if Label and Label:IsA("TextLabel") then
					Label.TextColor3 = Settings.Color
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function()
		task.wait(0.5)

		if Settings.ESP then
			CreateESP(Player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(Player)
	RemoveESP(Player)
end)

for _, Player in ipairs(Players:GetPlayers()) do
	if Player ~= LocalPlayer then
		Player.CharacterAdded:Connect(function()
			task.wait(0.5)

			if Settings.ESP then
				CreateESP(Player)
			end
		end)
	end
end

local ESPGroup = Tabs.Esp:AddLeftGroupbox("ESP")

ESPGroup:AddToggle("ESPEnabled", {
	Text = "ESP",
	Default = false,
	Callback = function(Value)
		Settings.ESP = Value
		RefreshESP()
	end
})

ESPGroup:AddToggle("ESPNames", {
	Text = "Names",
	Default = true,
	Callback = function(Value)
		Settings.Names = Value
		RefreshESP()
	end
})

ESPGroup:AddToggle("ESPDistance", {
	Text = "Distance",
	Default = true,
	Callback = function(Value)
		Settings.Distance = Value
		RefreshESP()
	end
})

ESPGroup:AddToggle("ESPBoxes", {
	Text = "Boxes",
	Default = true,
	Callback = function(Value)
		Settings.Boxes = Value
		RefreshESP()
	end
})

ESPGroup:AddSlider("ESPMaxDistance", {
	Text = "Max Distance",
	Default = 1000,
	Min = 100,
	Max = 5000,
	Rounding = 0,
	Compact = true,
	Callback = function(Value)
		Settings.MaxDistance = Value
		RefreshESP()
	end
})

ESPGroup:AddLabel("ESP Color"):AddColorPicker("ESPColor", {
	Default = Settings.Color,
	Title = "ESP Color",
	Transparency = 0,
	Callback = function(Value)
		Settings.Color = Value
		UpdateESPColor()
	end
})

-- Combat settings
-- Combat settings
local CombatPlayers = game:GetService("Players")
local CombatUserInputService = game:GetService("UserInputService")
local CombatRunService = game:GetService("RunService")

local CombatLocalPlayer = CombatPlayers.LocalPlayer
local CombatPlayerGui = CombatLocalPlayer:WaitForChild("PlayerGui")

local CombatSettings = {
	Enabled = false,
	Targeting = false,
	ShowFOV = true,
	FOV = 150,
	FOVColor = Color3.fromRGB(255, 255, 255),
	FOVTransparency = 0.25,
	FOVThickness = 2,
	MaxDistance = 500,
	TeamCheck = true,
	VisibleCheck = true,
	LockTarget = true,
	AutoSwitch = true,
	TargetMarker = true,
	TargetColor = Color3.fromRGB(255, 80, 80),
	TargetPart = "Head"
}

local OldCombatGui = CombatPlayerGui:FindFirstChild("VELTRIX_CombatUI")

if OldCombatGui then
	OldCombatGui:Destroy()
end

local CombatGui = Instance.new("ScreenGui")
CombatGui.Name = "VELTRIX_CombatUI"
CombatGui.ResetOnSpawn = false
CombatGui.IgnoreGuiInset = true
CombatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CombatGui.Parent = CombatPlayerGui

local FOV = Instance.new("Frame")
FOV.Name = "FOV"
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.Size = UDim2.fromOffset(300, 300)
FOV.BackgroundTransparency = 1
FOV.Visible = false
FOV.ZIndex = 20
FOV.Parent = CombatGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOV

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = CombatSettings.FOVThickness
FOVStroke.Color = CombatSettings.FOVColor
FOVStroke.Transparency = CombatSettings.FOVTransparency
FOVStroke.Parent = FOV

local TargetMarker = Instance.new("Frame")
TargetMarker.Name = "TargetMarker"
TargetMarker.AnchorPoint = Vector2.new(0.5, 0.5)
TargetMarker.Size = UDim2.fromOffset(14, 14)
TargetMarker.BackgroundTransparency = 1
TargetMarker.Visible = false
TargetMarker.ZIndex = 25
TargetMarker.Parent = CombatGui

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(1, 0)
TargetCorner.Parent = TargetMarker

local TargetStroke = Instance.new("UIStroke")
TargetStroke.Thickness = 2
TargetStroke.Color = CombatSettings.TargetColor
TargetStroke.Transparency = 0
TargetStroke.Parent = TargetMarker

local TargetDot = Instance.new("Frame")
TargetDot.Name = "Dot"
TargetDot.AnchorPoint = Vector2.new(0.5, 0.5)
TargetDot.Position = UDim2.fromScale(0.5, 0.5)
TargetDot.Size = UDim2.fromOffset(4, 4)
TargetDot.BackgroundColor3 = CombatSettings.TargetColor
TargetDot.BorderSizePixel = 0
TargetDot.Parent = TargetMarker

local TargetDotCorner = Instance.new("UICorner")
TargetDotCorner.CornerRadius = UDim.new(1, 0)
TargetDotCorner.Parent = TargetDot

local CombatGroup = Tabs.Combat:AddLeftGroupbox("Combat")

CombatGroup:AddToggle("CombatAssist", {
	Text = "Combat Assist",
	Default = false,
	Callback = function(Value)
		CombatSettings.Enabled = Value

		if not Value then
			CombatSettings.Targeting = false
			TargetMarker.Visible = false
		end
	end
})

CombatGroup:AddToggle("TargetingEnabled", {
	Text = "Targeting",
	Default = false,
	Callback = function(Value)
		CombatSettings.Targeting = Value

		if not Value then
			TargetMarker.Visible = false
		end
	end
})

CombatGroup:AddToggle("LockTarget", {
	Text = "Lock Target",
	Default = true,
	Callback = function(Value)
		CombatSettings.LockTarget = Value
	end
})

CombatGroup:AddToggle("AutoSwitch", {
	Text = "Auto Switch",
	Default = true,
	Callback = function(Value)
		CombatSettings.AutoSwitch = Value
	end
})

CombatGroup:AddToggle("TeamCheck", {
	Text = "Team Check",
	Default = true,
	Callback = function(Value)
		CombatSettings.TeamCheck = Value
	end
})

CombatGroup:AddToggle("VisibleCheck", {
	Text = "Visible Check",
	Default = true,
	Callback = function(Value)
		CombatSettings.VisibleCheck = Value
	end
})

CombatGroup:AddToggle("ShowFOV", {
	Text = "Show FOV",
	Default = true,
	Callback = function(Value)
		CombatSettings.ShowFOV = Value
	end
})

CombatGroup:AddToggle("TargetMarkerEnabled", {
	Text = "Target Marker",
	Default = true,
	Callback = function(Value)
		CombatSettings.TargetMarker = Value

		if not Value then
			TargetMarker.Visible = false
		end
	end
})

CombatGroup:AddSlider("CombatFOV", {
	Text = "FOV",
	Default = 150,
	Min = 25,
	Max = 500,
	Rounding = 0,
	Compact = true,
	Callback = function(Value)
		CombatSettings.FOV = Value
	end
})

CombatGroup:AddSlider("MaxTargetDistance", {
	Text = "Max Distance",
	Default = 500,
	Min = 50,
	Max = 5000,
	Rounding = 0,
	Compact = true,
	Callback = function(Value)
		CombatSettings.MaxDistance = Value
	end
})

CombatGroup:AddSlider("FOVThickness", {
	Text = "FOV Thickness",
	Default = 2,
	Min = 1,
	Max = 6,
	Rounding = 0,
	Compact = true,
	Callback = function(Value)
		CombatSettings.FOVThickness = Value
		FOVStroke.Thickness = Value
	end
})

CombatGroup:AddLabel("FOV Color"):AddColorPicker("CombatFOVColor", {
	Default = CombatSettings.FOVColor,
	Title = "FOV Color",
	Transparency = 0,
	Callback = function(Value)
		CombatSettings.FOVColor = Value
		FOVStroke.Color = Value
	end
})

CombatGroup:AddLabel("Target Color"):AddColorPicker("CombatTargetColor", {
	Default = CombatSettings.TargetColor,
	Title = "Target Color",
	Transparency = 0,
	Callback = function(Value)
		CombatSettings.TargetColor = Value
		TargetStroke.Color = Value
		TargetDot.BackgroundColor3 = Value
	end
})

CombatGroup:AddLabel("Activation Key"):AddKeyPicker("CombatKeybind", {
	Default = "Q",
	NoUI = false,
	Text = "Combat Hotkey",
	Mode = "Toggle"
})

local CombatRight = Tabs.Combat:AddRightGroupbox("Target")

CombatRight:AddDropdown("TargetPart", {
	Values = {
		"Head",
		"HumanoidRootPart",
		"UpperTorso"
	},
	Default = 1,
	Text = "Target Part",
	Callback = function(Value)
		CombatSettings.TargetPart = Value
	end
})

local CurrentTarget = nil

local function IsValidCombatTarget(Player)
	if not Player or Player == CombatLocalPlayer then
		return false
	end

	if CombatSettings.TeamCheck then
		if Player.Team ~= nil and CombatLocalPlayer.Team ~= nil then
			if Player.Team == CombatLocalPlayer.Team then
				return false
			end
		end
	end

	local Character = Player.Character

	if not Character then
		return false
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid or Humanoid.Health <= 0 then
		return false
	end

	local TargetPart = Character:FindFirstChild(CombatSettings.TargetPart)

	if not TargetPart or not TargetPart:IsA("BasePart") then
		return false
	end

	local Camera = workspace.CurrentCamera

	if not Camera then
		return false
	end

	local Distance = (TargetPart.Position - Camera.CFrame.Position).Magnitude

	if Distance > CombatSettings.MaxDistance then
		return false
	end

	if CombatSettings.VisibleCheck then
		local Parameters = RaycastParams.new()
		Parameters.FilterType = Enum.RaycastFilterType.Exclude

		local Ignore = {}

		if CombatLocalPlayer.Character then
			table.insert(Ignore, CombatLocalPlayer.Character)
		end

		Parameters.FilterDescendantsInstances = Ignore

		local Direction = TargetPart.Position - Camera.CFrame.Position

		local Result = workspace:Raycast(
			Camera.CFrame.Position,
			Direction,
			Parameters
		)

		if Result and not Result.Instance:IsDescendantOf(Character) then
			return false
		end
	end

	return true
end

local function GetClosestCombatTarget()
	local Camera = workspace.CurrentCamera

	if not Camera then
		return nil
	end

	local MousePosition = CombatUserInputService:GetMouseLocation()
	local BestPlayer = nil
	local BestScreenDistance = CombatSettings.FOV

	for _, Player in ipairs(CombatPlayers:GetPlayers()) do
		if IsValidCombatTarget(Player) then
			local Character = Player.Character
			local TargetPart = Character and Character:FindFirstChild(CombatSettings.TargetPart)

			if TargetPart then
				local ScreenPosition, OnScreen =
					Camera:WorldToViewportPoint(TargetPart.Position)

				if OnScreen and ScreenPosition.Z > 0 then
					local ScreenPoint = Vector2.new(
						ScreenPosition.X,
						ScreenPosition.Y
					)

					local ScreenDistance =
						(ScreenPoint - MousePosition).Magnitude

					if ScreenDistance <= BestScreenDistance then
						BestScreenDistance = ScreenDistance
						BestPlayer = Player
					end
				end
			end
		end
	end

	return BestPlayer
end

local function ClearCombatTarget()
	CurrentTarget = nil
	TargetMarker.Visible = false
end

local function UpdateTargetMarker(Camera)
	if not CombatSettings.TargetMarker then
		TargetMarker.Visible = false
		return
	end

	if not CurrentTarget then
		TargetMarker.Visible = false
		return
	end

	if not IsValidCombatTarget(CurrentTarget) then
		TargetMarker.Visible = false
		return
	end

	local Character = CurrentTarget.Character

	if not Character then
		TargetMarker.Visible = false
		return
	end

	local TargetPart = Character:FindFirstChild(CombatSettings.TargetPart)

	if not TargetPart then
		TargetMarker.Visible = false
		return
	end

	local ScreenPosition, OnScreen =
		Camera:WorldToViewportPoint(TargetPart.Position)

	if not OnScreen or ScreenPosition.Z <= 0 then
		TargetMarker.Visible = false
		return
	end

	TargetMarker.Position = UDim2.fromOffset(
		ScreenPosition.X,
		ScreenPosition.Y
	)

	TargetMarker.Visible = true
end

CombatUserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end

	local Key = Options.CombatKeybind.Value

	if typeof(Key) == "EnumItem" and Key.EnumType == Enum.KeyCode then
		if Input.KeyCode == Key then
			if not CombatSettings.Enabled then
				return
			end

			CombatSettings.Targeting = not CombatSettings.Targeting

			if not CombatSettings.Targeting then
				ClearCombatTarget()
			end
		end
	end
end)

CombatRunService.RenderStepped:Connect(function()
	local Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	local MousePosition = CombatUserInputService:GetMouseLocation()

	FOV.Position = UDim2.fromOffset(
		MousePosition.X,
		MousePosition.Y
	)

	FOV.Size = UDim2.fromOffset(
		CombatSettings.FOV * 2,
		CombatSettings.FOV * 2
	)

	FOVStroke.Color = CombatSettings.FOVColor
	FOVStroke.Thickness = CombatSettings.FOVThickness
	FOVStroke.Transparency = CombatSettings.FOVTransparency

	FOV.Visible =
		CombatSettings.Enabled
		and CombatSettings.ShowFOV

	if not CombatSettings.Enabled or not CombatSettings.Targeting then
		ClearCombatTarget()
		return
	end

	if CombatSettings.AutoSwitch then
		CurrentTarget = GetClosestCombatTarget()
	elseif not CurrentTarget or not IsValidCombatTarget(CurrentTarget) then
		CurrentTarget = GetClosestCombatTarget()
	end

	UpdateTargetMarker(Camera)
end)

CombatPlayers.PlayerRemoving:Connect(function(Player)
	if Player == CurrentTarget then
		ClearCombatTarget()
	end
end)

-- Main Tab 
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local MainTab = Tabs.Main

local ProfileGroup = MainTab:AddLeftGroupbox("Profile")

local ProfileAvatar = Instance.new("ImageLabel")
ProfileAvatar.Name = "ProfileAvatar"
ProfileAvatar.Size = UDim2.fromOffset(72, 72)
ProfileAvatar.Position = UDim2.fromOffset(8, 8)
ProfileAvatar.BackgroundTransparency = 1
ProfileAvatar.BorderSizePixel = 0
ProfileAvatar.ScaleType = Enum.ScaleType.Crop
ProfileAvatar.ZIndex = 10

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 8)
AvatarCorner.Parent = ProfileAvatar

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Thickness = 2
AvatarStroke.Color = Color3.fromRGB(80, 140, 255)
AvatarStroke.Transparency = 0
AvatarStroke.Parent = ProfileAvatar

local AvatarSuccess, AvatarImage = pcall(function()
	return Players:GetUserThumbnailAsync(
		LocalPlayer.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size150x150
	)
end)

if AvatarSuccess and AvatarImage then
	ProfileAvatar.Image = AvatarImage
end

ProfileAvatar.Parent = ProfileGroup.Container

ProfileGroup:AddLabel("Welcome, " .. LocalPlayer.DisplayName)
ProfileGroup:AddLabel("@" .. LocalPlayer.Name)
ProfileGroup:AddLabel("User ID: " .. tostring(LocalPlayer.UserId))
ProfileGroup:AddLabel("Account age: " .. tostring(LocalPlayer.AccountAge) .. " days")

ProfileGroup:AddDivider()

ProfileGroup:AddLabel("Status: Ready")
ProfileGroup:AddLabel("VELTRIX Member")


local DashboardGroup = MainTab:AddLeftGroupbox("Dashboard")

DashboardGroup:AddLabel("VELTRIX is ready.")
DashboardGroup:AddLabel("Use the tabs to configure your settings.")

DashboardGroup:AddDivider()

DashboardGroup:AddButton("Open ESP", function()
	if Tabs.Esp then
		Library.SelectedTab = Tabs.Esp
	end
end)

DashboardGroup:AddButton("Open Combat", function()
	if Tabs.Combat then
		Library.SelectedTab = Tabs.Combat
	end
end)

DashboardGroup:AddDivider()

DashboardGroup:AddLabel("ESP: Ready")
DashboardGroup:AddLabel("Combat: Ready")
DashboardGroup:AddLabel("UI: Ready")


local QuickGroup = MainTab:AddRightGroupbox("Quick Settings")

QuickGroup:AddToggle("QuickESP", {
	Text = "ESP",
	Default = false,
	Callback = function(Value)
		if Options.ESP then
			Options.ESP:SetValue(Value)
		end
	end
})

QuickGroup:AddToggle("QuickCombat", {
	Text = "Combat",
	Default = false,
	Callback = function(Value)
		if Options.CombatAssist then
			Options.CombatAssist:SetValue(Value)
		end
	end
})

QuickGroup:AddToggle("QuickFOV", {
	Text = "FOV",
	Default = true,
	Callback = function(Value)
		if Options.ShowFOV then
			Options.ShowFOV:SetValue(Value)
		end
	end
})

QuickGroup:AddDivider()

QuickGroup:AddButton("Reset Settings", function()
	if Options.QuickESP then
		Options.QuickESP:SetValue(false)
	end

	if Options.QuickCombat then
		Options.QuickCombat:SetValue(false)
	end

	if Options.QuickFOV then
		Options.QuickFOV:SetValue(true)
	end
end)


local PremiumGroup = MainTab:AddRightGroupbox("Premium")

PremiumGroup:AddLabel("VELTRIX Premium")
PremiumGroup:AddLabel("Premium features are")
PremiumGroup:AddLabel("coming soon.")

PremiumGroup:AddDivider()

PremiumGroup:AddLabel("Premium Status: Free")

PremiumGroup:AddButton("Premium Info", function()
	Library:Notify("Premium features are coming soon.", 3)
end)


local InfoGroup = MainTab:AddLeftGroupbox("Information")

InfoGroup:AddLabel("Menu: VELTRIX")
InfoGroup:AddLabel("User: " .. LocalPlayer.DisplayName)
InfoGroup:AddLabel("Version: 1.0")

InfoGroup:AddDivider()


local SessionGroup = MainTab:AddRightGroupbox("Session")

SessionGroup:AddLabel("Player")
SessionGroup:AddLabel(LocalPlayer.DisplayName)

SessionGroup:AddDivider()

SessionGroup:AddLabel("Username")
SessionGroup:AddLabel("@" .. LocalPlayer.Name)

SessionGroup:AddDivider()

SessionGroup:AddLabel("User ID")
SessionGroup:AddLabel(tostring(LocalPlayer.UserId))

-- Setup theme/save managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder('LinoriaExample')
SaveManager:SetFolder('LinoriaExample/save')
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

print('UI loaded successfully! Esp box removed from Main tab.')
