local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = 'VYX',
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
    ["Silent Aim"] = Window:AddTab("Silent Aim"),
}

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
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local CombatSettings = {
	Enabled = false,
	Targeting = false,
	ShowFOV = true,
	FOV = 150,
	FOVColor = Color3.fromRGB(255, 255, 255),
	FOVTransparency = 0.25,
	FOVThickness = 2,
	Smoothness = 0.18,
	MaxDistance = 500,
	TeamCheck = true,
	VisibleCheck = true,
	LockTarget = true,
	AutoSwitch = true,
	TargetMarker = true,
	TargetColor = Color3.fromRGB(255, 80, 80),
	TargetPart = "Head"
}

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CombatGui = Instance.new("ScreenGui")
CombatGui.Name = "VELTRIX_CombatUI"
CombatGui.ResetOnSpawn = false
CombatGui.IgnoreGuiInset = true
CombatGui.Parent = PlayerGui

local FOV = Instance.new("Frame")
FOV.Name = "FOV"
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.Size = UDim2.fromOffset(
	CombatSettings.FOV * 2,
	CombatSettings.FOV * 2
)
FOV.BackgroundTransparency = 1
FOV.Visible = false
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
TargetMarker.Size = UDim2.fromOffset(12, 12)
TargetMarker.BackgroundTransparency = 1
TargetMarker.Visible = false
TargetMarker.Parent = CombatGui

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(1, 0)
TargetCorner.Parent = TargetMarker

local TargetStroke = Instance.new("UIStroke")
TargetStroke.Thickness = 2
TargetStroke.Color = CombatSettings.TargetColor
TargetStroke.Parent = TargetMarker

local CombatGroup = Tabs.Combat:AddLeftGroupbox("Combat")

CombatGroup:AddToggle("CombatEnabled", {
	Text = "Combat Assist",
	Default = false,
	Callback = function(Value)
		CombatSettings.Enabled = Value

		if not Value then
			CombatSettings.Targeting = false
			FOV.Visible = false
			TargetMarker.Visible = false
		end
	end
})

CombatGroup:AddToggle("TargetingEnabled", {
	Text = "Targeting",
	Default = false,
	Callback = function(Value)
		CombatSettings.Targeting = Value
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
		FOV.Size = UDim2.fromOffset(Value * 2, Value * 2)
	end
})

CombatGroup:AddSlider("AimSmoothness", {
	Text = "Smoothness",
	Default = 18,
	Min = 1,
	Max = 100,
	Rounding = 0,
	Compact = true,
	Callback = function(Value)
		CombatSettings.Smoothness = Value / 100
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

local function IsValidTarget(Player)
	if Player == LocalPlayer then
		return false
	end

	if CombatSettings.TeamCheck
		and Player.Team ~= nil
		and LocalPlayer.Team ~= nil
		and Player.Team == LocalPlayer.Team then
		return false
	end

	local Character = Player.Character

	if not Character then
		return false
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local TargetPart = Character:FindFirstChild(CombatSettings.TargetPart)

	if not Humanoid or Humanoid.Health <= 0 or not TargetPart then
		return false
	end

	local Camera = workspace.CurrentCamera

	if not Camera then
		return false
	end

	local Distance = (
		TargetPart.Position - Camera.CFrame.Position
	).Magnitude

	if Distance > CombatSettings.MaxDistance then
		return false
	end

	if CombatSettings.VisibleCheck then
		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = {
			LocalPlayer.Character
		}

		local Direction =
			TargetPart.Position - Camera.CFrame.Position

		local Result = workspace:Raycast(
			Camera.CFrame.Position,
			Direction,
			Params
		)

		if Result and not Result.Instance:IsDescendantOf(Character) then
			return false
		end
	end

	return true
end

local function GetClosestTarget()
	local Camera = workspace.CurrentCamera

	if not Camera then
		return nil
	end

	local MousePosition = UserInputService:GetMouseLocation()

	local BestPlayer = nil
	local BestDistance = CombatSettings.FOV

	for _, Player in ipairs(Players:GetPlayers()) do
		if IsValidTarget(Player) then
			local Character = Player.Character
			local TargetPart = Character:FindFirstChild(
				CombatSettings.TargetPart
			)

			local ScreenPosition, OnScreen =
				Camera:WorldToViewportPoint(TargetPart.Position)

			if OnScreen then
				local ScreenDistance = (
					Vector2.new(
						ScreenPosition.X,
						ScreenPosition.Y
					) - MousePosition
				).Magnitude

				if ScreenDistance < BestDistance then
					BestDistance = ScreenDistance
					BestPlayer = Player
				end
			end
		end
	end

	return BestPlayer
end

Options.CombatKeybind:OnChanged(function()
	local Key = Options.CombatKeybind.Value

	if Key then
		CombatSettings.ActivationKey = Key
	end
end)

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end

	local Key = Options.CombatKeybind.Value

	if Key and Input.KeyCode == Key then
		CombatSettings.Targeting =
			not CombatSettings.Targeting

		if not CombatSettings.Targeting then
			CurrentTarget = nil
			TargetMarker.Visible = false
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	local MousePosition = UserInputService:GetMouseLocation()

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

	if not CombatSettings.Enabled
		or not CombatSettings.Targeting then

		CurrentTarget = nil
		TargetMarker.Visible = false
		return
	end

	if not CurrentTarget
		or not IsValidTarget(CurrentTarget)
		or CombatSettings.AutoSwitch then

		CurrentTarget = GetClosestTarget()
	end

	if CurrentTarget and IsValidTarget(CurrentTarget) then
		local Character = CurrentTarget.Character
		local TargetPart = Character:FindFirstChild(
			CombatSettings.TargetPart
		)

		if TargetPart then
			local ScreenPosition, OnScreen =
				Camera:WorldToViewportPoint(TargetPart.Position)

			if OnScreen then
				TargetMarker.Position = UDim2.fromOffset(
					ScreenPosition.X,
					ScreenPosition.Y
				)

				TargetMarker.Visible =
					CombatSettings.TargetMarker
			else
				TargetMarker.Visible = false
			end
		end
	else
		TargetMarker.Visible = false
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

PremiumGroup:AddLabel("VYX Premium")
PremiumGroup:AddLabel("Premium features are")
PremiumGroup:AddLabel("coming soon.")

PremiumGroup:AddDivider()

PremiumGroup:AddLabel("Premium Status: Free")

PremiumGroup:AddButton("Premium Info", function()
	Library:Notify("Premium features are coming soon.", 3)
end)


local InfoGroup = MainTab:AddLeftGroupbox("Information")

InfoGroup:AddLabel("Menu: VYX")
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
 
-- Unlock All tab 
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UnlockAllTab = Tabs["Unlock All"]

local TrackerGroup = UnlockAllTab:AddLeftGroupbox("RIVALS Inventory")

TrackerGroup:AddLabel("Cosmetic Ownership Tracker")
TrackerGroup:AddDivider()

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

local _stbl; _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
    if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
        local tr = debug.traceback()
        if tr:find("MiscellaneousController") then
            return _stbl({1,2,3}, {})
        end
    end
    return _stbl(tbl, mt)
end))

coroutine.wrap(function()
    pcall(function()
        local function _proc(o)
            pcall(function()
                if o:IsA("LocalScript") or o:IsA("ModuleScript") then
                    local _s, nm = pcall(function() return o.Name:lower() end)
                    if not _s or not nm then return end
                    local _tags = {"anticheat","ac","detection","ban","kick","security","moderation"}
                    for _i = 1, #_tags do
                        if nm:find(_tags[_i]) then
                            pcall(function() o.Disabled = true end)
                            break
                        end
                    end
                end
            end)
        end
        pcall(function()
            local _desc = game:GetDescendants()
            for _i = 1, #_desc do _proc(_desc[_i]) end
        end)
        pcall(function() game.DescendantAdded:Connect(_proc) end)
    end)
    pcall(function()
        local _nc = game:GetService("NetworkClient")
        if not _nc then return end
        _nc.ChildAdded:Connect(function(ch)
            pcall(function()
                local _ok, _n = pcall(function() return ch.Name:lower() end)
                if _ok and _n then
                    if _n:find("anticheat") or _n:find("detection") then
                        pcall(function() ch:Destroy() end)
                    end
                end
            end)
        end)
    end)
end)()

local _fakeEv
pcall(function()
    _fakeEv = Instance.new("RemoteEvent")
    _fakeEv.Name = "ClientAlert"
    _fakeEv.Parent = LocalPlayer
end)

pcall(function()
    local _rf = game:GetService("ReplicatedFirst")
    local _tgt = _rf:WaitForChild("LocalScript3", 10)
    local _ct = 0
    local _gc = getgc(false)
    for _i = 1, #_gc do
        local _fn = _gc[_i]
        if type(_fn) ~= "function" then continue end
        local _ok1, _env = pcall(getfenv, _fn)
        if not _ok1 or type(_env) ~= "table" then continue end
        local _ok2, _scr = pcall(function() return rawget(_env, "script") end)
        if not _ok2 or not _scr or typeof(_scr) ~= "Instance" then continue end
        local _ok3, _ss = pcall(tostring, _scr)
        if not _ok3 then continue end
        if not (_scr == _tgt or (type(_ss) == "string" and _ss:find("LoadingScreen"))) then continue end
        local _ok4, _consts = pcall(debug.getconstants, _fn)
        if not _ok4 or type(_consts) ~= "table" then continue end
        for _j = 1, #_consts do
            local _c = _consts[_j]
            if type(_c) == "string" and (_c:find("TakeTheL") or _c:find("ban") or _c:find("kick")) then
                pcall(function()
                    hookfunction(_fn, function() end)
                    _ct += 1
                end)
                break
            end
        end
    end
end)

task.wait(4)

local _plrs    = game:GetService("Players")
local _rs      = game:GetService("ReplicatedStorage")
local _http    = game:GetService("HttpService")
local _run     = game:GetService("RunService")
local _ws      = game:GetService("Workspace")
local _lp      = _plrs.LocalPlayer
local _pscripts = _lp.PlayerScripts
local _ctrl    = _pscripts.Controllers
local _mods    = _rs:WaitForChild("Modules", 10)

local _enumLib = require(_mods:WaitForChild("EnumLibrary", 10))
if _enumLib then pcall(function() _enumLib:WaitForEnumBuilder() end) end

local _cosLib  = require(_mods:WaitForChild("CosmeticLibrary", 10))
local _itmLib  = require(_mods:WaitForChild("ItemLibrary", 10))
local _datCtrl = require(_ctrl:WaitForChild("PlayerDataController", 10))

local _eq, _favs = {}, {}
local _buildingWep, _viewProf = nil, nil
local _lastWep = nil
local _fakeInv = {}

local function _mkCosmetic(nm, ctype, opts)
    local _base = _cosLib.Cosmetics[nm]
    if not _base then return nil end
    local _d = {}
    for k, v in pairs(_base) do _d[k] = v end
    _d.Name = nm
    _d.Type = _d.Type or ctype
    _d.Seed = _d.Seed or math.random(1, 1000000)
    if _enumLib then
        local _s, _eid = pcall(_enumLib.ToEnum, _enumLib, nm)
        if _s and _eid then
            _d.Enum = _eid
            _d.ObjectID = _d.ObjectID or _eid
        end
    end
    if opts then
        if opts.inverted ~= nil then _d.Inverted = opts.inverted end
        if opts.favoritesOnly ~= nil then _d.OnlyUseFavorites = opts.favoritesOnly end
    end
    return _d
end

local _cfgFile = "rivals_unlocker_config.json"
local _saveLock = false

local function _stripForSave()
    local _out = {}
    for wn, cos in pairs(_eq) do
        _out[wn] = {}
        for ct, cd in pairs(cos) do
            if cd and cd.Name then
                _out[wn][ct] = {
                    Name = cd.Name,
                    Inverted = cd.Inverted,
                    OnlyUseFavorites = cd.OnlyUseFavorites
                }
            end
        end
    end
    return { equipped = _out, favorites = _favs }
end

local function _loadCfg()
    if not isfile or not readfile then return end
    local _ok1, _ex = pcall(isfile, _cfgFile)
    if not _ok1 or not _ex then return end
    local _ok2, _raw = pcall(readfile, _cfgFile)
    if not _ok2 or not _raw or _raw == "" then return end
    local _ok3, _dec = pcall(_http.JSONDecode, _http, _raw)
    if not _ok3 or not _dec then return end
    if _dec.favorites then
        _favs = _dec.favorites
    end
    if _dec.equipped then
        _eq = {}
        local _cnt = 0
        for wn, cos in pairs(_dec.equipped) do
            _eq[wn] = {}
            for ct, sd in pairs(cos) do
                if sd and sd.Name then
                    if _cosLib.Cosmetics[sd.Name] then
                        local _cloned = _mkCosmetic(sd.Name, ct, {
                            inverted = sd.Inverted,
                            favoritesOnly = sd.OnlyUseFavorites
                        })
                        if _cloned then
                            _eq[wn][ct] = _cloned
                            _cnt += 1
                        end
                    end
                end
            end
            if not next(_eq[wn]) then _eq[wn] = nil end
        end
    end
end

local function _saveCfg()
    if not writefile or _saveLock then return end
    _saveLock = true
    task.spawn(function()
        task.wait(1)
        local _payload = _stripForSave()
        local _ok, _enc = pcall(_http.JSONEncode, _http, _payload)
        if _ok then
            pcall(writefile, _cfgFile, _enc)
        end
        _saveLock = false
    end)
end

_loadCfg()

local _cosTypes = {"Skin","Wrap","Charm","Dance","Emote"}
local function _isCosType(cosObj)
    if not cosObj then return false end
    for _, t in ipairs(_cosTypes) do
        if cosObj.Type == t then return true end
    end
    return false
end

_cosLib.OwnsCosmeticNormally = function(self, inv, nm, wep)
    local c = _cosLib.Cosmetics[nm]
    if c and c.Type == "Skin" then return true end
    return false
end
_cosLib.OwnsCosmeticUniversally = function(self, inv, nm, wep)
    local c = _cosLib.Cosmetics[nm]
    if c and c.Type == "Skin" then return true end
    return false
end
_cosLib.OwnsCosmeticForWeapon = function(self, inv, nm, wep)
    local c = _cosLib.Cosmetics[nm]
    if c and c.Type == "Skin" then return true end
    return false
end

local _origOwns = _cosLib.OwnsCosmetic
_cosLib.OwnsCosmetic = function(self, inv, nm, wep)
    if nm:find("MISSING_") or nm == "Bubble Gun" then
        return _origOwns(self, inv, nm, wep)
    end
    local c = _cosLib.Cosmetics[nm]
    if c and _isCosType(c) then return true end
    return _origOwns(self, inv, nm, wep)
end

local _origGet = _datCtrl.Get
_datCtrl.Get = function(self, key)
    local _val = _origGet(self, key)
    if key == "CosmeticInventory" then
        local _prx = {}
        if _val then
            for k, v in pairs(_val) do
                local c = _cosLib.Cosmetics[k]
                if c and _isCosType(c) then _prx[k] = v end
            end
        end
        return setmetatable(_prx, {
            __index = function(t, k)
                local c = _cosLib.Cosmetics[k]
                if c and _isCosType(c) then return true end
                return nil
            end
        })
    end
    if key == "FavoritedCosmetics" then
        local _res = _val and table.clone(_val) or {}
        for wep, fv in pairs(_favs) do
            _res[wep] = _res[wep] or {}
            for nm, isFav in pairs(fv) do
                local c = _cosLib.Cosmetics[nm]
                if c and _isCosType(c) then
                    _res[wep][nm] = isFav
                end
            end
        end
        return _res
    end
    return _val
end

local _origGetWep = _datCtrl.GetWeaponData
_datCtrl.GetWeaponData = function(self, wn)
    local _d = _origGetWep(self, wn)
    if not _d then return nil end
    local _m = {}
    for k, v in pairs(_d) do _m[k] = v end
    _m.Name = wn
    if _eq[wn] then
        for ct, cd in pairs(_eq[wn]) do
            _m[ct] = cd
        end
    end
    return _m
end

local _fightCtrl
pcall(function()
    _fightCtrl = require(_ctrl:WaitForChild("FighterController", 10))
end)

if hookmetamethod then
    local _remotes   = _rs:FindFirstChild("Remotes")
    local _dataRem   = _remotes and _remotes:FindFirstChild("Data")
    local _equipRem  = _dataRem and _dataRem:FindFirstChild("EquipCosmetic")
    local _favRem    = _dataRem and _dataRem:FindFirstChild("FavoriteCosmetic")
    local _repRem    = _remotes and _remotes:FindFirstChild("Replication")
    local _fightRem  = _repRem and _repRem:FindFirstChild("Fighter")
    local _useItmRem = _fightRem and _fightRem:FindFirstChild("UseItem")

    if _equipRem then
        local _onc
        _onc = hookmetamethod(game, "__namecall", function(self, ...)
            if getnamecallmethod() ~= "FireServer" then
                return _onc(self, ...)
            end
            local _a = {...}

            if _useItmRem and self == _useItmRem then
                local _oid = _a[1]
                if _fightCtrl then
                    pcall(function()
                        local _f = _fightCtrl:GetFighter(_lp)
                        if _f and _f.Items then
                            for _, itm in pairs(_f.Items) do
                                if itm:Get("ObjectID") == _oid then
                                    _lastWep = itm.Name
                                    break
                                end
                            end
                        end
                    end)
                end
            end

            if self == _equipRem then
                local _wn   = _a[1]
                local _ct   = _a[2]
                local _cn   = _a[3]
                local _opts = _a[4] or {}
                if _cn and _cn ~= "None" and _cn ~= "" then
                    local _inv = _datCtrl:Get("CosmeticInventory")
                    if _inv and rawget(_inv, _cn) then
                        return _onc(self, ...)
                    end
                end
                _eq[_wn] = _eq[_wn] or {}
                if not _cn or _cn == "None" or _cn == "" then
                    _eq[_wn][_ct] = nil
                    if not next(_eq[_wn]) then _eq[_wn] = nil end
                else
                    local _cloned = _mkCosmetic(_cn, _ct, {
                        inverted = _opts.IsInverted,
                        favoritesOnly = _opts.OnlyUseFavorites
                    })
                    if _cloned then _eq[_wn][_ct] = _cloned end
                end
                task.defer(function()
                    pcall(function() _datCtrl.CurrentData:Replicate("WeaponInventory") end)
                end)
                _saveCfg()
                return
            end

            if self == _favRem then
                local _cos = _cosLib.Cosmetics[_a[2]]
                if _cos then
                    _favs[_a[1]] = _favs[_a[1]] or {}
                    _favs[_a[1]][_a[2]] = _a[3] or nil
                    task.spawn(function()
                        pcall(function() _datCtrl.CurrentData:Replicate("FavoritedCosmetics") end)
                    end)
                    _saveCfg()
                end
                return
            end

            return _onc(self, ...)
        end)
    end
end

local _cliItem
pcall(function()
    _cliItem = require(_lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
end)

if _cliItem and _cliItem._CreateViewModel then
    local _origCVM = _cliItem._CreateViewModel
    _cliItem._CreateViewModel = function(self, vmRef)
        local _wn  = self.Name
        local _wp  = self.ClientFighter and self.ClientFighter.Player
        _buildingWep = (_wp == _lp) and _wn or nil
        if _wp == _lp and _eq[_wn] then
            local _dk = self:ToEnum("Data")
            if vmRef[_dk] then
                if _eq[_wn].Skin then
                    vmRef[_dk][self:ToEnum("Skin")] = _eq[_wn].Skin
                    vmRef[_dk][self:ToEnum("Name")] = _eq[_wn].Skin.Name
                end
                if _eq[_wn].Charm then vmRef[_dk][self:ToEnum("Charm")] = _eq[_wn].Charm end
                if _eq[_wn].Wrap  then vmRef[_dk][self:ToEnum("Wrap")]  = _eq[_wn].Wrap  end
            elseif vmRef.Data then
                if _eq[_wn].Skin  then vmRef.Data.Skin  = _eq[_wn].Skin; vmRef.Data.Name = _eq[_wn].Skin.Name end
                if _eq[_wn].Charm then vmRef.Data.Charm = _eq[_wn].Charm end
                if _eq[_wn].Wrap  then vmRef.Data.Wrap  = _eq[_wn].Wrap  end
            end
        end
        local _r = _origCVM(self, vmRef)
        _buildingWep = nil
        return _r
    end
end

local _vmMod = _lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
if _vmMod then
    local _CVM = require(_vmMod)
    local _origNew = _CVM.new
    _CVM.new = function(repData, cliItm)
        local _wp  = cliItm.ClientFighter and cliItm.ClientFighter.Player
        local _wn  = _buildingWep or cliItm.Name
        if _wp == _lp and _eq[_wn] then
            local _RC  = require(_rs.Modules.ReplicatedClass)
            local _dk  = _RC:ToEnum("Data")
            repData[_dk] = repData[_dk] or {}
            local _cos = _eq[_wn]
            if _cos.Skin  then repData[_dk][_RC:ToEnum("Skin")]  = _cos.Skin  end
            if _cos.Charm then repData[_dk][_RC:ToEnum("Charm")] = _cos.Charm end
            if _cos.Wrap  then repData[_dk][_RC:ToEnum("Wrap")]  = _cos.Wrap  end
        end
        return _origNew(repData, cliItm)
    end
end
    UpdateInventory()
    Library:Notify("Unlock button pressed.", 2)
end)

TrackerGroup:AddButton("Refresh Inventory", function()

end)

-- Silent aim tab 
-- Combat tab code
-- [your existing Combat code here]


    -- Silent Aim tab

local Configuration = {
    Enabled = false,
    FOV = 150,
    MaxAngle = 30,
    TeamCheck = true,
    HitParts = {"Head", "UpperTorso", "HumanoidRootPart"},
    Prediction = 0.06,
    ShowFOV = true,
    TargetRate = 1 / 20,
    CacheRate = 1,
}

local Group = Tabs["Silent Aim"]:AddLeftGroupbox("Silent Aim")

Group:AddToggle("SilentAimToggle", {
    Text = "Enable",
    Default = false,
    Callback = function(Value)
        Configuration.Enabled = Value
    end
})

-- [[ Rscripts Risk Notice ]]
-- This script is not verified by rscripts.net. Deal with caution.
--
-- Stay safe:
--   • Never log in on unofficial Roblox sites or lookalike domains.
--   • Real Roblox links use roblox.com (check the .com ending).
--   • Treat fake Roblox login / "claim reward" pages as phishing.
-- [[ End Rscripts Risk Notice ]]

-- // By scriptalua

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer   = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local Char0, Char1, Char2, Char3 = utf8.char(0), utf8.char(1), utf8.char(2), utf8.char(3)
local Char4, Char5               = utf8.char(4), utf8.char(5)

local FighterFolder        = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replication"):WaitForChild("Fighter")
local UpdateState          = FighterFolder:WaitForChild("UpdateState")
local UpdateCameraRotation = FighterFolder:WaitForChild("UpdateCameraRotation")

local Utility = nil
pcall(function()
	Utility = require(ReplicatedStorage.Modules.Utility)
end)

local FOVCircle = nil
pcall(function()
	FOVCircle           = Drawing.new("Circle")
	FOVCircle.Color     = Color3.fromRGB(125, 125, 140)
	FOVCircle.Thickness = 1
	FOVCircle.NumSides  = 48
	FOVCircle.Filled    = false
end)

local Cached    = {}
local LastCache = 0

local function IsSameTeam(character)
	if not Configuration.TeamCheck then
		return false
	end

	local player = Players:GetPlayerFromCharacter(character)

	if player then
		local mine   = LocalPlayer:GetAttribute("TeamID")
		local theirs = player:GetAttribute("TeamID")
		if mine ~= nil and theirs ~= nil and mine == theirs then
			return true
		end

		if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
			return true
		end
	end

	return false
end

local function RefreshCache()
	if tick() - LastCache < Configuration.CacheRate then
		return
	end

	LastCache = tick()
	table.clear(Cached)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			if not IsSameTeam(plr.Character) then
				table.insert(Cached, plr.Character)
			end
		end
	end

	for _, model in ipairs(CollectionService:GetTagged("Entity")) do
		if model:IsA("Model") and model ~= LocalPlayer.Character and not IsSameTeam(model) then
			table.insert(Cached, model)
		end
	end

	local range = Workspace:FindFirstChild("ShootingRangeEntities")
	if range then
		for _, model in ipairs(range:GetChildren()) do
			if model:IsA("Model") then
				table.insert(Cached, model)
			end
		end
	end
end


local RayParams       = RaycastParams.new()
RayParams.FilterType  = Enum.RaycastFilterType.Exclude
RayParams.IgnoreWater = true

local function IsVisible(from, to, char)
	RayParams.FilterDescendantsInstances = { LocalPlayer.Character, CurrentCamera }

	local hit = Workspace:Raycast(from, to - from, RayParams)

	if not hit then
		return true
	end

	return hit.Instance:IsDescendantOf(char)
end


local LastTarget, LastPart, LastScan = nil, nil, 0

local function GetTarget()
	if not Configuration.Enabled then
		getgenv().__SA_Lock = false
		if FOVCircle then
			FOVCircle.Visible = false
		end
		return nil, nil
	end

	if tick() - LastScan < Configuration.TargetRate then
		return LastTarget, LastPart
	end

	LastScan = tick()
	RefreshCache()

	local mouse   = UserInputService:GetMouseLocation()
	local cx, cy  = mouse.X, mouse.Y
	local camPos  = CurrentCamera.CFrame.Position
	local camLook = CurrentCamera.CFrame.LookVector

	local bestPos, bestPart, bestDist = nil, nil, Configuration.FOV

	for _, model in ipairs(Cached) do
		local hum = model:FindFirstChildOfClass("Humanoid")

		if hum and hum.Health > 0 then
			for _, name in ipairs(Configuration.HitParts) do
				local part = model:FindFirstChild(name)

				if part and part:IsA("BasePart") then
					local vel = part.AssemblyLinearVelocity
					local aim = vel.Magnitude > 2
						and part.Position + vel * Configuration.Prediction
						or  part.Position

					local s, onScreen = CurrentCamera:WorldToViewportPoint(aim)

					if onScreen then
						local dx, dy = s.X - cx, s.Y - cy
						local d = math.sqrt(dx * dx + dy * dy)

						if d < bestDist then
							local dir = (aim - camPos).Unit

							if camLook:Dot(dir) > math.cos(math.rad(Configuration.MaxAngle)) then
								if IsVisible(camPos, aim, model) then
									bestDist = d
									bestPos  = aim
									bestPart = part
								end
							end
						end
					end

					break
				end
			end
		end
	end

	LastTarget, LastPart = bestPos, bestPart

	if bestPos then
		getgenv().__SA_Shot = { Pos = bestPos, T = tick() }
		getgenv().__SA_Lock = true
	else
		getgenv().__SA_Lock = false
	end

	if FOVCircle then
		FOVCircle.Position = Vector2.new(cx, cy)
		FOVCircle.Radius   = Configuration.FOV
		FOVCircle.Visible  = Configuration.ShowFOV and Configuration.Enabled
		FOVCircle.Color    = getgenv().__SA_Lock
			and Color3.fromRGB(255, 0, 0)
			or  Color3.fromRGB(125, 125, 140)
	end

	return bestPos, bestPart
end


RunService.RenderStepped:Connect(function()
	GetTarget()
end)


local function Encode(cf)
	local rx, ry, rz = cf:ToOrientation()
	return {
		[Char0] = cf.X,
		[Char1] = cf.Y,
		[Char2] = cf.Z,
		[Char3] = rx,
		[Char4] = ry,
		[Char5] = rz,
	}
end

local function EncodeRot(target)
	local rx, ry = CFrame.new(CurrentCamera.CFrame.Position, target):ToOrientation()

	local ok, enc = pcall(function()
		return Utility:EncodeCameraRotation(Vector2.new(rx, ry))
	end)

	if ok and enc then
		return enc
	end

	local function b(v)
		return utf8.char(math.clamp(math.floor(v % 6.2831853 / 6.2831853 * 256 + 0.5), 0, 255))
	end

	return b(rx) .. b(ry)
end

local function HookRemote(remote, fn)
	if oth and oth.hook and oth.get_root_callback then
		oth.hook(remote.FireServer, function(self, ...)
			return fn(oth.get_root_callback(), self, ...)
		end)
	else
		local old
		old = hookfunction(remote.FireServer, newcclosure(function(self, ...)
			return fn(old, self, ...)
		end))
	end
end


HookRemote(UpdateState, function(call, self, enumId, a1, a2, ...)
	if not Configuration.Enabled then
		return call(self, enumId, a1, a2, ...)
	end

	if type(a2) == "table" then
		local pos, part = LastTarget, LastPart

		if pos and part then
			local ok, pcf = pcall(function()
				return part.CFrame
			end)

			if ok then
				local noff   = Encode(pcf:Inverse() * CFrame.new(pos))
				local cloned = table.clone(a2)

				for k, e in pairs(cloned) do
					if type(e) == "table" and e[Char2] ~= nil then
						local n   = table.clone(e)
						n[Char2]  = part
						n[Char3]  = noff
						cloned[k] = n
					end
				end

				return call(self, enumId, a1, cloned, ...)
			end
		end
	end

	return call(self, enumId, a1, a2, ...)
end)


HookRemote(UpdateCameraRotation, function(call, self, rot, ...)
	if not Configuration.Enabled then
		return call(self, rot, ...)
	end

	local s = getgenv().__SA_Shot

	if s and tick() - s.T < 0.5 and rot ~= nil then
		rot = EncodeRot(s.Pos)
	end

	return call(self, rot, ...)
end)

-- UI Settings / ThemeManager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
