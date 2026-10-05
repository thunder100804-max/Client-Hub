-- VYX v5.1 — Combat Organised + Neon Purple
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library       = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager  = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager   = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox             = false
Library.ShowToggleFrameInKeybinds = true

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local Stats             = game:GetService("Stats")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- Neon purple theme colors
local NEON_PURPLE = Color3.fromRGB(170, 0, 255)
local NEON_PURPLE_DARK = Color3.fromRGB(100, 0, 180)
local NEON_PURPLE_BG = Color3.fromRGB(8, 0, 15)

local AimAssistEnabled = false
local SilentAimEnabled = false
local RageAimEnabled   = false
local AutoShootEnabled = false
local TargetLocked     = false
local silentTargetPart = nil
local rageTargetPart   = nil
local silentMouse      = LocalPlayer:GetMouse()
local lastShotTime     = 0

local FlySpeed         = 50
local SpeedValue       = 32
local JumpPowerValue   = 100
local ClickTPDistance  = 50
local FlyConnection    = nil
local NoclipConnection = nil
local AntiAFKConnection = nil

local WatermarkEnabled  = true
local WatermarkColor    = NEON_PURPLE
local WatermarkBG       = NEON_PURPLE_BG
local WatermarkShowFPS  = true
local WatermarkShowPing = true
local WatermarkShowUser = true
local WatermarkShowTime = false

--=====================================================================
-- Window (neon purple icon)
--=====================================================================
local Window = Library:CreateWindow({
    Title            = "VYX",
    Footer           = "version: V5.1",
    Icon             = 6031097230, -- neon/purple themed icon
    NotifySide       = "Right",
    ShowCustomCursor = true,
})

-- Apply neon purple theme
Library.Scheme = Library.Scheme or {}
Library.Scheme.Accent = NEON_PURPLE
Library.Scheme.Background = NEON_PURPLE_BG
Library.Scheme.Outline = NEON_PURPLE_DARK
Library.Scheme.FontColor = Color3.fromRGB(220, 200, 255)

local Tabs = {
    Combat          = Window:AddTab("Combat", "crosshair"),
    ESP             = Window:AddTab("ESP", "eye"),
    ["Player Mods"] = Window:AddTab("Player Mods", "person-standing"),
    Watermark       = Window:AddTab("Watermark", "activity"),
    ["Unlock All"]  = Window:AddTab("Unlock All", "unlock"),
    Misc            = Window:AddTab("Misc", "settings-2"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

--=====================================================================
-- COMBAT — organised into 3 clear groups
--=====================================================================
local CombatMain  = Tabs.Combat:AddLeftGroupbox("Aimbot & Silent")
local CombatFOV   = Tabs.Combat:AddLeftGroupbox("FOV Settings")
local CombatRage  = Tabs.Combat:AddRightGroupbox("Ragebot")

-- Aimbot & Silent
CombatMain:AddToggle("EnableAimbot", { Text = "Enable Aimbot (mouse moves to target)", Default = false })
Toggles.EnableAimbot:OnChanged(function()
    AimAssistEnabled = Toggles.EnableAimbot.Value
end)

CombatMain:AddToggle("EnableSilentAim", { Text = "Enable Silent Aim (bullets redirect)", Default = false })
Toggles.EnableSilentAim:OnChanged(function()
    SilentAimEnabled = Toggles.EnableSilentAim.Value
end)

CombatMain:AddDropdown("AimBone", {
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso", "LeftHand", "RightHand", "LeftFoot", "RightFoot", "Closest" },
    Default = "Head", Text = "Aim Bone", Searchable = false,
})

CombatMain:AddSlider("AimSmoothness", { Text = "Snap Strength", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Compact = true })
CombatMain:AddSlider("SilentChance", { Text = "Silent Hit Chance %", Default = 100, Min = 0, Max = 100, Rounding = 0, Compact = true })
CombatMain:AddToggle("TeamCheck", { Text = "Team Check", Default = true })
CombatMain:AddToggle("VisibleCheck", { Text = "Visible Check", Default = true })
CombatMain:AddToggle("HoldToAim", { Text = "Hold to Aim (aimbot)", Default = true })
CombatMain:AddToggle("StickyAim", { Text = "Sticky Aim", Default = true })
CombatMain:AddToggle("SilentWallbang", { Text = "Silent Wallbang", Default = false })
CombatMain:AddLabel("Combat Keybind"):AddKeyPicker("CombatKey", {
    Default = "MB2", NoUI = false, SyncToggleState = false, Mode = "Hold", Text = "Hold for combat",
})

-- FOV Settings
CombatFOV:AddSlider("AimFOV", { Text = "Aim FOV", Default = 150, Min = 25, Max = 800, Rounding = 0, Compact = true })
CombatFOV:AddSlider("SilentFOV", { Text = "Silent FOV", Default = 200, Min = 25, Max = 1000, Rounding = 0, Compact = true })
CombatFOV:AddToggle("ShowFOVCircle", { Text = "Show Aim FOV Circle", Default = true })
CombatFOV:AddToggle("ShowSilentFOV", { Text = "Show Silent FOV Circle", Default = true })
CombatFOV:AddSlider("FOVCircleThickness", { Text = "Aim Thickness", Default = 2, Min = 1, Max = 8, Rounding = 0, Compact = true })
CombatFOV:AddSlider("SilentFOVThickness", { Text = "Silent Thickness", Default = 1, Min = 1, Max = 8, Rounding = 0, Compact = true })
CombatFOV:AddLabel("Aim Color"):AddColorPicker("FOVCircleColor", {
    Default = NEON_PURPLE, Title = "Aim FOV Color",
})
CombatFOV:AddLabel("Silent Color"):AddColorPicker("SilentFOVColor", {
    Default = Color3.fromRGB(0, 200, 255), Title = "Silent FOV Color",
})
CombatFOV:AddToggle("GlowWhenLocked", { Text = "Glow When Locked", Default = true })

-- Ragebot
CombatRage:AddToggle("EnableRage", { Text = "Enable Ragebot", Default = false })
Toggles.EnableRage:OnChanged(function()
    RageAimEnabled = Toggles.EnableRage.Value
end)

CombatRage:AddToggle("RageAutoShoot", { Text = "Auto Shoot", Default = true })
Toggles.RageAutoShoot:OnChanged(function()
    AutoShootEnabled = Toggles.RageAutoShoot.Value
end)

CombatRage:AddDropdown("RageBone", {
    Values = { "Head", "UpperTorso", "HumanoidRootPart", "Closest" },
    Default = "Head", Text = "Rage Bone", Searchable = false,
})

CombatRage:AddSlider("RageFOV", { Text = "Rage FOV", Default = 400, Min = 50, Max = 1500, Rounding = 0, Compact = true })
CombatRage:AddSlider("RageDelay", { Text = "Shot Delay (s)", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2, Compact = true })
CombatRage:AddToggle("RageTeamCheck", { Text = "Rage Team Check", Default = true })
CombatRage:AddToggle("RageAutoFire", { Text = "Auto Fire (hold key)", Default = true })
CombatRage:AddToggle("RageSilent", { Text = "Silent Mode (bullets to target)", Default = true })
CombatRage:AddLabel("Rage Keybind"):AddKeyPicker("RageKey", {
    Default = "MB2", NoUI = false, SyncToggleState = false, Mode = "Hold", Text = "Hold to rage",
})

--=====================================================================
-- ESP
--=====================================================================
local ESPBoxesGroup     = Tabs.ESP:AddLeftGroupbox("Box ESP")
local ESPNamesGroup     = Tabs.ESP:AddLeftGroupbox("Name ESP")
local ESPHealthGroup    = Tabs.ESP:AddLeftGroupbox("Health ESP")
local ESPTracerGroup    = Tabs.ESP:AddRightGroupbox("Tracers")
local ESPHighlightGroup = Tabs.ESP:AddRightGroupbox("Highlight")
local ESPSkeletonGroup  = Tabs.ESP:AddRightGroupbox("Skeleton")
local ESPExtrasGroup    = Tabs.ESP:AddRightGroupbox("Extras")

ESPBoxesGroup:AddToggle("ESPBoxes", { Text = "Enable Box ESP", Default = false })
ESPBoxesGroup:AddLabel("Box Color"):AddColorPicker("ESPBoxColor", {
    Default = NEON_PURPLE, Title = "Box Color",
})
ESPBoxesGroup:AddSlider("ESPBoxThickness", { Text = "Box Thickness", Default = 1, Min = 1, Max = 5, Rounding = 0, Compact = true })
ESPNamesGroup:AddToggle("ESPNames", { Text = "Enable Name ESP", Default = false })
ESPNamesGroup:AddLabel("Name Color"):AddColorPicker("ESPNameColor", {
    Default = Color3.fromRGB(255, 255, 255), Title = "Name Color",
})
ESPNamesGroup:AddSlider("ESPNameSize", { Text = "Text Size", Default = 14, Min = 8, Max = 24, Rounding = 0, Compact = true })
ESPHealthGroup:AddToggle("ESPHealth", { Text = "Enable Health ESP", Default = false })
ESPHealthGroup:AddToggle("ESPHealthBar", { Text = "Health Bar", Default = false })
ESPTracerGroup:AddToggle("ESPTracers", { Text = "Enable Tracers", Default = false })
ESPTracerGroup:AddLabel("Tracer Color"):AddColorPicker("ESPTracerColor", {
    Default = NEON_PURPLE, Title = "Tracer Color",
})
ESPTracerGroup:AddSlider("ESPTracerThickness", { Text = "Thickness", Default = 1, Min = 1, Max = 5, Rounding = 0, Compact = true })
ESPHighlightGroup:AddToggle("ESPHighlight", { Text = "Enable Highlight", Default = false })
ESPHighlightGroup:AddLabel("Highlight Color"):AddColorPicker("ESPHighlightColor", {
    Default = NEON_PURPLE, Title = "Highlight Color",
})
ESPSkeletonGroup:AddToggle("ESPSkeleton", { Text = "Enable Skeleton ESP", Default = false })
ESPSkeletonGroup:AddLabel("Skeleton Color"):AddColorPicker("ESPSkeletonColor", {
    Default = Color3.fromRGB(255, 255, 255), Title = "Skeleton Color",
})
ESPExtrasGroup:AddToggle("ESPDistance", { Text = "Show Distance", Default = false })

--=====================================================================
-- Player Mods
--=====================================================================
local MoveGroup   = Tabs["Player Mods"]:AddLeftGroupbox("Movement")
local JumpGroup   = Tabs["Player Mods"]:AddLeftGroupbox("Jump")
local FlyGroup    = Tabs["Player Mods"]:AddRightGroupbox("Fly")
local MiscPMGroup = Tabs["Player Mods"]:AddRightGroupbox("Misc")

MoveGroup:AddToggle("SpeedEnabled", { Text = "Speed Hack", Default = false })
Toggles.SpeedEnabled:OnChanged(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = Toggles.SpeedEnabled.Value and SpeedValue or 16
    end
end)
MoveGroup:AddSlider("SpeedValue", { Text = "Walk Speed", Default = 32, Min = 16, Max = 500, Rounding = 0, Compact = true })
Options.SpeedValue:OnChanged(function()
    SpeedValue = Options.SpeedValue.Value
    if Toggles.SpeedEnabled.Value then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then char.Humanoid.WalkSpeed = SpeedValue end
    end
end)

MoveGroup:AddToggle("NoclipEnabled", { Text = "Noclip", Default = false })
Toggles.NoclipEnabled:OnChanged(function()
    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    if Toggles.NoclipEnabled.Value then
        local function clearCollide(char)
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        local char = LocalPlayer.Character
        if char then clearCollide(char) end
        NoclipConnection = char and char.DescendantAdded:Connect(function(desc)
            if desc:IsA("BasePart") then
                task.defer(function() pcall(function() desc.CanCollide = false end) end)
            end
        end)
    end
end)

MoveGroup:AddToggle("ClickTPEnabled", { Text = "Click Teleport", Default = false })
MoveGroup:AddSlider("ClickTPDistance", { Text = "Max TP Distance", Default = 50, Min = 10, Max = 500, Rounding = 0, Compact = true })
Options.ClickTPDistance:OnChanged(function()
    ClickTPDistance = Options.ClickTPDistance.Value
end)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Toggles.ClickTPEnabled.Value and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = LocalPlayer:GetMouse()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and mouse.Hit then
            local target = mouse.Hit.Position
            local hrp = char.HumanoidRootPart
            if (target - hrp.Position).Magnitude <= ClickTPDistance then
                hrp.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
            end
        end
    end
end)

JumpGroup:AddToggle("JumpPowerEnabled", { Text = "Jump Power Override", Default = false })
Toggles.JumpPowerEnabled:OnChanged(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.UseJumpPower = true
        char.Humanoid.JumpPower = Toggles.JumpPowerEnabled.Value and JumpPowerValue or 50
    end
end)
JumpGroup:AddSlider("JumpPowerValue", { Text = "Jump Power", Default = 100, Min = 50, Max = 500, Rounding = 0, Compact = true })
Options.JumpPowerValue:OnChanged(function()
    JumpPowerValue = Options.JumpPowerValue.Value
    if Toggles.JumpPowerEnabled.Value then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then char.Humanoid.JumpPower = JumpPowerValue end
    end
end)
JumpGroup:AddToggle("InfJumpEnabled", { Text = "Infinite Jump", Default = false })
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJumpEnabled.Value then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

FlyGroup:AddToggle("FlyEnabled", { Text = "Fly", Default = false })
Toggles.FlyEnabled:OnChanged(function()
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if Toggles.FlyEnabled.Value then
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = hrp.CFrame
        bodyGyro.Parent = hrp
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.zero
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.Parent = hrp
        FlyConnection = RunService.RenderStepped:Connect(function()
            local hrp2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp2 or not bodyGyro.Parent then return end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
            bodyVel.Velocity = move * FlySpeed
            bodyGyro.CFrame = Camera.CFrame
        end)
        _G.__VYX_FlyBodyGyro = bodyGyro
        _G.__VYX_FlyBodyVel = bodyVel
    else
        if _G.__VYX_FlyBodyGyro then pcall(function() _G.__VYX_FlyBodyGyro:Destroy() end) end
        if _G.__VYX_FlyBodyVel then pcall(function() _G.__VYX_FlyBodyVel:Destroy() end) end
        _G.__VYX_FlyBodyGyro = nil
        _G.__VYX_FlyBodyVel = nil
    end
end)
FlyGroup:AddSlider("FlySpeedValue", { Text = "Fly Speed", Default = 50, Min = 10, Max = 500, Rounding = 0, Compact = true })
Options.FlySpeedValue:OnChanged(function() FlySpeed = Options.FlySpeedValue.Value end)

MiscPMGroup:AddToggle("AntiAFK", { Text = "Anti-AFK", Default = true })
Toggles.AntiAFK:OnChanged(function()
    if Toggles.AntiAFK.Value then
        if not AntiAFKConnection then
            AntiAFKConnection = LocalPlayer.Idled:Connect(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    else
        if AntiAFKConnection then AntiAFKConnection:Disconnect() AntiAFKConnection = nil end
    end
end)

MiscPMGroup:AddToggle("Fullbright", { Text = "Fullbright", Default = false })
Toggles.Fullbright:OnChanged(function()
    if Toggles.Fullbright.Value then
        Lighting.Brightness = 5
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)

MiscPMGroup:AddButton("Reset Character", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then char.Humanoid.Health = 0 end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Toggles.SpeedEnabled.Value then hum.WalkSpeed = SpeedValue end
    if Toggles.JumpPowerEnabled.Value then
        hum.UseJumpPower = true
        hum.JumpPower = JumpPowerValue
    end
end)

--=====================================================================
-- Watermark
--=====================================================================
local WMGroup  = Tabs.Watermark:AddLeftGroupbox("Watermark")
local WMColors = Tabs.Watermark:AddRightGroupbox("Colors")

WMGroup:AddToggle("WatermarkEnabled", { Text = "Show Watermark", Default = true })
Toggles.WatermarkEnabled:OnChanged(function() WatermarkEnabled = Toggles.WatermarkEnabled.Value end)
WMGroup:AddToggle("WMFPS", { Text = "Show FPS", Default = true })
Toggles.WMFPS:OnChanged(function() WatermarkShowFPS = Toggles.WMFPS.Value end)
WMGroup:AddToggle("WMPing", { Text = "Show Ping", Default = true })
Toggles.WMPing:OnChanged(function() WatermarkShowPing = Toggles.WMPing.Value end)
WMGroup:AddToggle("WMUser", { Text = "Show Username", Default = true })
Toggles.WMUser:OnChanged(function() WatermarkShowUser = Toggles.WMUser.Value end)
WMGroup:AddToggle("WMTime", { Text = "Show Time", Default = false })
Toggles.WMTime:OnChanged(function() WatermarkShowTime = Toggles.WMTime.Value end)

WMColors:AddLabel("Text Color"):AddColorPicker("WMColor", {
    Default = NEON_PURPLE, Title = "Watermark Text Color",
})
Options.WMColor:OnChanged(function() WatermarkColor = Options.WMColor.Value end)
WMColors:AddLabel("Background Color"):AddColorPicker("WMBG", {
    Default = NEON_PURPLE_BG, Title = "Watermark BG Color",
})
Options.WMBG:OnChanged(function() WatermarkBG = Options.WMBG.Value end)

--=====================================================================
-- Unlock All (deferred)
--=====================================================================
local UnlockGroup = Tabs["Unlock All"]:AddLeftGroupbox("Unlock All")
local UnlockInfo  = Tabs["Unlock All"]:AddRightGroupbox("Info")

local UnlockState = { Active = false }

local function _runFullUnlockAll()
    local _plrs     = Players
    local _rs       = ReplicatedStorage
    local _lp       = _plrs.LocalPlayer
    local _pscripts = _lp.PlayerScripts
    local _ctrl     = _pscripts:WaitForChild("Controllers", 10)
    local _mods     = _rs:WaitForChild("Modules", 10)
    if not _mods or not _ctrl then error("Not in Rivals") end

    coroutine.wrap(function()
        pcall(function()
            local _stbl
            _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
                if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
                    local tr = debug.traceback()
                    if tr:find("MiscellaneousController") then
                        return _stbl({1,2,3}, {})
                    end
                end
                return _stbl(tbl, mt)
            end))
        end)
        pcall(function()
            local _tags = {"anticheat","ac","detection","ban","kick","security","moderation"}
            local function _proc(o)
                pcall(function()
                    if o:IsA("LocalScript") or o:IsA("ModuleScript") then
                        local _s, nm = pcall(function() return o.Name:lower() end)
                        if not _s or not nm then return end
                        for _i = 1, #_tags do
                            if nm:find(_tags[_i]) then
                                pcall(function() o.Disabled = true end)
                                break
                            end
                        end
                    end
                end)
            end
            local _desc = game:GetDescendants()
            local _n = 0
            for _i = 1, #_desc do
                _proc(_desc[_i])
                _n = _n + 1
                if _n % 500 == 0 then task.wait() end
            end
            pcall(function() game.DescendantAdded:Connect(_proc) end)
        end)
        pcall(function()
            local _rf = game:GetService("ReplicatedFirst")
            local _tgt = _rf:WaitForChild("LocalScript3", 10)
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
                        pcall(function() hookfunction(_fn, function() end) end)
                        break
                    end
                end
                if _i % 500 == 0 then task.wait() end
            end
        end)
    end)()

    local _enumLib = require(_mods:WaitForChild("EnumLibrary", 10))
    if _enumLib then pcall(function() _enumLib:WaitForEnumBuilder() end) end
    local _cosLib  = require(_mods:WaitForChild("CosmeticLibrary", 10))
    local _datCtrl = require(_ctrl:WaitForChild("PlayerDataController", 10))

    local _eq, _favs = {}, {}
    local _buildingWep = nil
    local _cosTypes = {"Skin","Wrap","Charm","Dance","Emote"}
    local function _isCosType(cosObj)
        if not cosObj then return false end
        for _, t in ipairs(_cosTypes) do
            if cosObj.Type == t then return true end
        end
        return false
    end

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
                    _out[wn][ct] = {Name = cd.Name, Inverted = cd.Inverted, OnlyUseFavorites = cd.OnlyUseFavorites}
                end
            end
        end
        return {equipped = _out, favorites = _favs}
    end
    if isfile and readfile then
        pcall(function()
            if isfile(_cfgFile) then
                local _raw = readfile(_cfgFile)
                if _raw and _raw ~= "" then
                    local _dec = HttpService:JSONDecode(_raw)
                    if _dec.favorites then _favs = _dec.favorites end
                    if _dec.equipped then
                        for wn, cos in pairs(_dec.equipped) do
                            _eq[wn] = {}
                            for ct, sd in pairs(cos) do
                                if sd and sd.Name and _cosLib.Cosmetics[sd.Name] then
                                    local _cloned = _mkCosmetic(sd.Name, ct, {
                                        inverted = sd.Inverted, favoritesOnly = sd.OnlyUseFavorites
                                    })
                                    if _cloned then _eq[wn][ct] = _cloned end
                                end
                            end
                            if not next(_eq[wn]) then _eq[wn] = nil end
                        end
                    end
                end
            end
        end)
    end
    local function _saveCfg()
        if not writefile or _saveLock then return end
        _saveLock = true
        task.spawn(function()
            task.wait(1)
            local _ok, _enc = pcall(HttpService.JSONEncode, HttpService, _stripForSave())
            if _ok then pcall(writefile, _cfgFile, _enc) end
            _saveLock = false
        end)
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
                end
            })
        end
        if key == "FavoritedCosmetics" then
            local _res = _val and table.clone(_val) or {}
            for wep, fv in pairs(_favs) do
                _res[wep] = _res[wep] or {}
                for nm, isFav in pairs(fv) do
                    local c = _cosLib.Cosmetics[nm]
                    if c and _isCosType(c) then _res[wep][nm] = isFav end
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
            for ct, cd in pairs(_eq[wn]) do _m[ct] = cd end
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
        if _equipRem then
            local _onc
            _onc = hookmetamethod(game, "__namecall", function(self, ...)
                if getnamecallmethod() ~= "FireServer" then
                    return _onc(self, ...)
                end
                local _a = {...}
                if self == _equipRem then
                    local _wn, _ct, _cn = _a[1], _a[2], _a[3]
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
                            inverted = _opts.IsInverted, favoritesOnly = _opts.OnlyUseFavorites
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
            local _wn = self.Name
            local _wp = self.ClientFighter and self.ClientFighter.Player
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
                    if _eq[_wn].Skin  then vmRef.Data.Skin = _eq[_wn].Skin; vmRef.Data.Name = _eq[_wn].Skin.Name end
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
            local _wp = cliItm.ClientFighter and cliItm.ClientFighter.Player
            local _wn = _buildingWep or cliItm.Name
            if _wp == _lp and _eq[_wn] then
                local _RC = require(_rs.Modules.ReplicatedClass)
                local _dk = _RC:ToEnum("Data")
                repData[_dk] = repData[_dk] or {}
                local _cos = _eq[_wn]
                if _cos.Skin  then repData[_dk][_RC:ToEnum("Skin")]  = _cos.Skin  end
                if _cos.Charm then repData[_dk][_RC:ToEnum("Charm")] = _cos.Charm end
                if _cos.Wrap  then repData[_dk][_RC:ToEnum("Wrap")]  = _cos.Wrap  end
            end
            return _origNew(repData, cliItm)
        end
    end
end

UnlockGroup:AddButton("Enable Unlock All", function()
    if UnlockState.Active then
        Library:Notify("Unlock All is already active", 2)
        return
    end
    Library:Notify("Enabling Unlock All — may take 5-15 seconds...", 4)
    task.spawn(function()
        local ok, err = pcall(_runFullUnlockAll)
        if ok then
            UnlockState.Active = true
            Library:Notify("Unlock All ENABLED", 4)
        else
            Library:Notify("Failed: " .. tostring(err), 8)
        end
    end)
end)

UnlockInfo:AddLabel(
    "Client-side cosmetic unlock. Hooks:\n" ..
    "• CosmeticLibrary (ownership)\n" ..
    "• PlayerDataController (inventory)\n" ..
    "• EquipCosmetic remote\n" ..
    "• ViewModel renderer\n" ..
    "• AC setmetatable + loading screen\n\n" ..
    "Enable only if you accept the ban risk.",
    true
)

--=====================================================================
-- Misc
--=====================================================================
local MiscGroup  = Tabs.Misc:AddLeftGroupbox("Misc Cheats")
local MiscGroup2 = Tabs.Misc:AddRightGroupbox("Visual Misc")

MiscGroup:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

MiscGroup:AddToggle("AntiRagdoll", { Text = "Anti Ragdoll", Default = false })
Toggles.AntiRagdoll:OnChanged(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not Toggles.AntiRagdoll.Value)
end)

MiscGroup:AddToggle("AntiFling", { Text = "Anti Fling", Default = false })
Toggles.AntiFling:OnChanged(function()
    if Toggles.AntiFling.Value then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function()
                hrp.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
            end) end
        end
    end
end)

MiscGroup2:AddToggle("RemoveFog", { Text = "Remove Fog", Default = false })
Toggles.RemoveFog:OnChanged(function()
    if Toggles.RemoveFog.Value then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = 10000
        Lighting.FogStart = 0
    end
end)

MiscGroup2:AddToggle("NoParticles", { Text = "Remove Particles", Default = false })
Toggles.NoParticles:OnChanged(function()
    if not Toggles.NoParticles.Value then return end
    task.spawn(function()
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke")
                or obj:IsA("Fire") or obj:IsA("Sparkles")
                or obj:IsA("Trail") or obj:IsA("Beam") then
                pcall(function() obj.Enabled = false end)
            end
            count = count + 1
            if count % 500 == 0 then task.wait() end
        end
        Library:Notify("Particles removed", 2)
    end)
end)

--=====================================================================
-- FOV visuals (neon purple)
--=====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VYX_FOV"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Parent = ScreenGui
local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(1,0) Corner.Parent = FOVCircle
local Stroke = Instance.new("UIStroke") Stroke.Color = NEON_PURPLE Stroke.Thickness = 2 Stroke.Parent = FOVCircle

local SilentCircle = Instance.new("Frame")
SilentCircle.AnchorPoint = Vector2.new(0.5, 0.5)
SilentCircle.BackgroundTransparency = 1
SilentCircle.BorderSizePixel = 0
SilentCircle.Visible = false
SilentCircle.ZIndex = 998
SilentCircle.Parent = ScreenGui
local SilentCorner = Instance.new("UICorner") SilentCorner.CornerRadius = UDim.new(1,0) SilentCorner.Parent = SilentCircle
local SilentStroke = Instance.new("UIStroke") SilentStroke.Color = Color3.fromRGB(0,200,255) SilentStroke.Thickness = 1 SilentStroke.Transparency = 0.3 SilentStroke.Parent = SilentCircle

local RageCircle = Instance.new("Frame")
RageCircle.AnchorPoint = Vector2.new(0.5, 0.5)
RageCircle.BackgroundTransparency = 1
RageCircle.BorderSizePixel = 0
RageCircle.Visible = false
RageCircle.ZIndex = 997
RageCircle.Parent = ScreenGui
local RageCorner = Instance.new("UICorner") RageCorner.CornerRadius = UDim.new(1,0) RageCorner.Parent = RageCircle
local RageStroke = Instance.new("UIStroke") RageStroke.Color = NEON_PURPLE RageStroke.Thickness = 2 RageStroke.Transparency = 0.2 RageStroke.Parent = RageCircle

--=====================================================================
-- Watermark GUI (neon purple)
--=====================================================================
local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "VYX_Watermark"
WatermarkGui.ResetOnSpawn = false
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.DisplayOrder = 997
WatermarkGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local WMFrame = Instance.new("Frame")
WMFrame.Size = UDim2.new(0, 320, 0, 30)
WMFrame.Position = UDim2.new(0, 10, 0, 10)
WMFrame.BackgroundColor3 = NEON_PURPLE_BG
WMFrame.BackgroundTransparency = 0.2
WMFrame.BorderSizePixel = 0
WMFrame.Parent = WatermarkGui

local WMStroke = Instance.new("UIStroke")
WMStroke.Color = NEON_PURPLE
WMStroke.Thickness = 1
WMStroke.Transparency = 0.3
WMStroke.Parent = WMFrame

local WMText = Instance.new("TextLabel")
WMText.Size = UDim2.new(1, -10, 1, 0)
WMText.Position = UDim2.new(0, 5, 0, 0)
WMText.BackgroundTransparency = 1
WMText.Text = "VYX"
WMText.TextColor3 = NEON_PURPLE
WMText.TextSize = 14
WMText.Font = Enum.Font.Code
WMText.TextXAlignment = Enum.TextXAlignment.Left
WMText.Parent = WMFrame

local fpsFrames, fpsAccum, fpsCurrent = 0, 0, 60
local lastWMUpdate = 0

RunService.RenderStepped:Connect(function(dt)
    fpsFrames = fpsFrames + 1
    fpsAccum = fpsAccum + dt
    if fpsAccum >= 0.5 then
        fpsCurrent = math.floor(fpsFrames / fpsAccum)
        fpsFrames = 0
        fpsAccum = 0
    end
    if not WatermarkEnabled then WMFrame.Visible = false return end
    WMFrame.Visible = true
    WMStroke.Color = WatermarkColor
    WMFrame.BackgroundColor3 = WatermarkBG
    lastWMUpdate = lastWMUpdate + dt
    if lastWMUpdate >= 0.5 then
        lastWMUpdate = 0
        local parts = { "VYX" }
        if WatermarkShowFPS then table.insert(parts, "FPS: " .. fpsCurrent) end
        if WatermarkShowPing then
            local ok, ping = pcall(function()
                return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            table.insert(parts, "Ping: " .. (ok and ping or 0) .. "ms")
        end
        if WatermarkShowUser then table.insert(parts, LocalPlayer.Name) end
        if WatermarkShowTime then table.insert(parts, os.date("%H:%M:%S")) end
        WMText.Text = table.concat(parts, " | ")
        WMText.TextColor3 = WatermarkColor
    end
end)

--=====================================================================
-- Helpers
--=====================================================================
local function safeValue(option, fallback)
    if option and option.Value ~= nil then return option.Value end
    return fallback
end
local function isAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end
local function isEnemy(player, checkKey)
    if player == LocalPlayer then return false end
    local toggle = Toggles[checkKey]
    if toggle and not toggle.Value then return true end
    if LocalPlayer.Team and player.Team then return LocalPlayer.Team ~= player.Team end
    return true
end
local function isVisible(part, checkKey)
    local toggle = Toggles[checkKey]
    if toggle and not toggle.Value then return true end
    local character = LocalPlayer.Character
    if not character then return false end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { character }
    local result = workspace:Raycast(origin, direction, params)
    return result and result.Instance:IsDescendantOf(part.Parent) or false
end
local function getBonePart(character, boneName)
    if not character then return nil end
    if boneName == "Closest" then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local parts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "Torso"}
        local best, bestDist = nil, math.huge
        for _, name in ipairs(parts) do
            local p = character:FindFirstChild(name)
            if p and p:IsA("BasePart") then
                local sp, on = Camera:WorldToViewportPoint(p.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestDist then bestDist = d best = p end
                end
            end
        end
        return best
    end
    return character:FindFirstChild(boneName)
end

--=====================================================================
-- Target acquisition
--=====================================================================
local stickyTarget = nil
local function getClosestTarget()
    local boneName = safeValue(Options.AimBone, "Head")
    if safeValue(Options.StickyAim, true) and stickyTarget then
        local stillValid = stickyTarget and stickyTarget.Parent
            and stickyTarget.Parent:FindFirstChildOfClass("Humanoid")
            and stickyTarget.Parent.Humanoid.Health > 0
        if stillValid then
            local viewport = Camera.ViewportSize
            local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
            local radius = safeValue(Options.AimFOV, 150)
            local screenPos, onScreen = Camera:WorldToViewportPoint(stickyTarget.Position)
            if onScreen then
                local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if d <= radius * 1.3 and isVisible(stickyTarget, "VisibleCheck") then
                    return stickyTarget
                end
            end
        end
        stickyTarget = nil
    end
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local radius = safeValue(Options.AimFOV, 150)
    local closestPart, closestDistance = nil, radius
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player, "TeamCheck") then
            local character = player.Character
            if isAlive(character) then
                local part = getBonePart(character, boneName)
                if part and part:IsA("BasePart") then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDistance < closestDistance and isVisible(part, "VisibleCheck") then
                            closestDistance = screenDistance
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    if closestPart then stickyTarget = closestPart end
    return closestPart
end

local function getSilentTarget()
    local boneName = safeValue(Options.AimBone, "Head")
    local radius = safeValue(Options.SilentFOV, 200)
    local chance = safeValue(Options.SilentChance, 100)
    local wallbang = safeValue(Options.SilentWallbang, false)
    if math.random(1, 100) > chance then return nil end
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local closestPart, closestDistance = nil, radius
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player, "TeamCheck") then
            local character = player.Character
            if isAlive(character) then
                local part = getBonePart(character, boneName)
                if part and part:IsA("BasePart") then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        local visibleOK = wallbang or isVisible(part, "VisibleCheck")
                        if screenDistance < closestDistance and visibleOK then
                            closestDistance = screenDistance
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closestPart
end

local function getRageTarget()
    local boneName = safeValue(Options.RageBone, "Head")
    local radius = safeValue(Options.RageFOV, 400)
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local closestPart, closestDistance = nil, radius
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player, "RageTeamCheck") then
            local character = player.Character
            if isAlive(character) then
                local part = getBonePart(character, boneName)
                if part and part:IsA("BasePart") then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDistance < closestDistance then
                            closestDistance = screenDistance
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closestPart
end

--=====================================================================
-- FOV updates
--=====================================================================
local function updateFOV()
    local viewport = Camera.ViewportSize
    local radius = safeValue(Options.AimFOV, 150)
    local show = safeValue(Options.ShowFOVCircle, true)
    local glow = safeValue(Options.GlowWhenLocked, true)
    FOVCircle.Size = UDim2.fromOffset(radius * 2, radius * 2)
    FOVCircle.Position = UDim2.fromOffset(viewport.X / 2, viewport.Y / 2)
    FOVCircle.Visible = AimAssistEnabled and show
    local baseColor = safeValue(Options.FOVCircleColor, NEON_PURPLE)
    if glow and TargetLocked then
        Stroke.Color = Color3.new(math.min(baseColor.R*1.4,1), math.min(baseColor.G*1.4,1), math.min(baseColor.B*1.4,1))
    else
        Stroke.Color = baseColor
    end
    Stroke.Thickness = safeValue(Options.FOVCircleThickness, 2)

    local sradius = safeValue(Options.SilentFOV, 200)
    SilentCircle.Size = UDim2.fromOffset(sradius * 2, sradius * 2)
    SilentCircle.Position = UDim2.fromOffset(viewport.X / 2, viewport.Y / 2)
    SilentCircle.Visible = SilentAimEnabled and safeValue(Options.ShowSilentFOV, true)
    SilentStroke.Color = safeValue(Options.SilentFOVColor, Color3.fromRGB(0, 200, 255))
    SilentStroke.Thickness = safeValue(Options.SilentFOVThickness, 1)

    local rradius = safeValue(Options.RageFOV, 400)
    RageCircle.Size = UDim2.fromOffset(rradius * 2, rradius * 2)
    RageCircle.Position = UDim2.fromOffset(viewport.X / 2, viewport.Y / 2)
    RageCircle.Visible = RageAimEnabled
end

--=====================================================================
-- ESP
--=====================================================================
local espDrawings = {}
local function getOrCreateESP(player)
    if espDrawings[player] then return espDrawings[player] end
    local entry = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        tracer = Drawing.new("Line"),
        healthText = Drawing.new("Text"),
        healthBar = Drawing.new("Square"),
        highlight = nil,
        bones = {},
    }
    espDrawings[player] = entry
    return entry
end
local function destroyESP(player)
    local e = espDrawings[player]
    if not e then return end
    for _, d in pairs(e) do
        if typeof(d) == "table" then
            for _, line in pairs(d) do pcall(function() line:Remove() end) end
        elseif d then
            pcall(function() d:Remove() end)
        end
    end
    if e.highlight then pcall(function() e.highlight:Destroy() end) end
    espDrawings[player] = nil
end
local function getCharacterBounds(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local head = character:FindFirstChild("Head")
    if not head then return nil end
    local topScreen, topOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local botScreen, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
    if not (topOn and botOn) then return nil end
    local height = math.abs(botScreen.Y - topScreen.Y)
    local width = height * 0.5
    return {x = topScreen.X - width / 2, y = topScreen.Y, w = width, h = height, top = topScreen, bot = botScreen}
end

local function updateESP()
    for player, entry in pairs(espDrawings) do
        if not player.Parent or not player.Character or not player.Character:FindFirstChild("Head") then
            destroyESP(player)
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local enemyOK = (not safeValue(Toggles.TeamCheck, true))
            or (not LocalPlayer.Team) or (not player.Team)
            or (LocalPlayer.Team ~= player.Team)
        local char = player.Character
        local shouldDraw = char
            and char:FindFirstChild("Head")
            and char:FindFirstChild("HumanoidRootPart")
            and char:FindFirstChildOfClass("Humanoid")
            and char.Humanoid.Health > 0
            and enemyOK
            and (safeValue(Toggles.ESPBoxes, false)
              or safeValue(Toggles.ESPNames, false)
              or safeValue(Toggles.ESPHealth, false)
              or safeValue(Toggles.ESPTracers, false)
              or safeValue(Toggles.ESPHighlight, false)
              or safeValue(Toggles.ESPSkeleton, false))
        local entry = espDrawings[player]
        if shouldDraw then
            entry = entry or getOrCreateESP(player)
            local bounds = getCharacterBounds(char)
            local hum = char.Humanoid
            if bounds and safeValue(Toggles.ESPBoxes, false) then
                entry.box.Visible = true
                entry.box.Size = Vector2.new(bounds.w, bounds.h)
                entry.box.Position = Vector2.new(bounds.x, bounds.y)
                entry.box.Color = safeValue(Options.ESPBoxColor, NEON_PURPLE)
                entry.box.Thickness = safeValue(Options.ESPBoxThickness, 1)
                entry.box.Filled = false
                entry.box.Transparency = 1
            else entry.box.Visible = false end
            if bounds and safeValue(Toggles.ESPNames, false) then
                entry.name.Visible = true
                local txt = player.Name
                if safeValue(Toggles.ESPDistance, false) then
                    local d = math.floor((char.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude)
                    txt = txt .. " [" .. d .. "m]"
                end
                entry.name.Text = txt
                entry.name.Size = safeValue(Options.ESPNameSize, 14)
                entry.name.Color = safeValue(Options.ESPNameColor, Color3.new(1,1,1))
                entry.name.Center = true
                entry.name.Outline = true
                entry.name.Position = Vector2.new(bounds.top.X, bounds.top.Y - safeValue(Options.ESPNameSize, 14) - 4)
            else entry.name.Visible = false end
            if bounds and safeValue(Toggles.ESPHealth, false) then
                entry.healthText.Visible = true
                entry.healthText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                entry.healthText.Size = 14
                entry.healthText.Color = Color3.new(0, 1, 0)
                entry.healthText.Center = true
                entry.healthText.Outline = true
                entry.healthText.Position = Vector2.new(bounds.bot.X, bounds.bot.Y + 4)
                if safeValue(Toggles.ESPHealthBar, false) then
                    local pct = hum.Health / hum.MaxHealth
                    entry.healthBar.Visible = true
                    entry.healthBar.Size = Vector2.new(2, bounds.h)
                    entry.healthBar.Position = Vector2.new(bounds.x - 6, bounds.y + bounds.h * (1 - pct))
                    entry.healthBar.Color = Color3.new(1 - pct, pct, 0)
                    entry.healthBar.Filled = true
                    entry.healthBar.Transparency = 1
                else entry.healthBar.Visible = false end
            else
                entry.healthText.Visible = false
                entry.healthBar.Visible = false
            end
            if bounds and safeValue(Toggles.ESPTracers, false) then
                local vp = Camera.ViewportSize
                entry.tracer.Visible = true
                entry.tracer.From = Vector2.new(vp.X / 2, vp.Y)
                entry.tracer.To = Vector2.new(bounds.top.X, bounds.bot.Y)
                entry.tracer.Color = safeValue(Options.ESPTracerColor, NEON_PURPLE)
                entry.tracer.Thickness = safeValue(Options.ESPTracerThickness, 1)
                entry.tracer.Transparency = 1
            else entry.tracer.Visible = false end
            if safeValue(Toggles.ESPHighlight, false) then
                if not entry.highlight or not entry.highlight.Parent then
                    local h = Instance.new("Highlight")
                    h.Name = "VYX_Highlight"
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee = char
                    h.Parent = char
                    entry.highlight = h
                end
                entry.highlight.FillColor = safeValue(Options.ESPHighlightColor, NEON_PURPLE)
                entry.highlight.OutlineColor = safeValue(Options.ESPHighlightColor, NEON_PURPLE)
                entry.highlight.FillTransparency = 0.6
            elseif entry.highlight then
                entry.highlight:Destroy()
                entry.highlight = nil
            end
            if bounds and safeValue(Toggles.ESPSkeleton, false) then
                local skelColor = safeValue(Options.ESPSkeletonColor, Color3.new(1,1,1))
                local function line(a, b)
                    if not a or not b then return end
                    local ap, aOn = Camera:WorldToViewportPoint(a)
                    local bp, bOn = Camera:WorldToViewportPoint(b)
                    if not (aOn and bOn) then return nil end
                    return { from = Vector2.new(ap.X, ap.Y), to = Vector2.new(bp.X, bp.Y) }
                end
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local lt = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                local rt = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                local ll = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
                local rl = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")
                local segments = {
                    line(head and head.Position, torso and torso.Position),
                    line(torso and torso.Position, lt and lt.Position),
                    line(torso and torso.Position, rt and rt.Position),
                    line(hrp and hrp.Position, ll and ll.Position),
                    line(hrp and hrp.Position, rl and rl.Position),
                }
                for i = 1, 5 do
                    entry.bones[i] = entry.bones[i] or Drawing.new("Line")
                    local ln = entry.bones[i]
                    local seg = segments[i]
                    if seg then
                        ln.Visible = true
                        ln.From = seg.from
                        ln.To = seg.to
                        ln.Color = skelColor
                        ln.Thickness = 1
                        ln.Transparency = 1
                    else ln.Visible = false end
                end
            else
                for _, ln in pairs(entry.bones) do ln.Visible = false end
            end
        else
            if entry then destroyESP(player) end
        end
    end
end

Players.PlayerRemoving:Connect(function(p) destroyESP(p) end)

--=====================================================================
-- Silent aim hook (deferred)
--=====================================================================
task.spawn(function()
    task.wait(3)
    local hookOK, hookErr = pcall(function()
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, key)
            if not SilentAimEnabled and not (RageAimEnabled and Toggles.RageSilent.Value) then
                return oldIndex(self, key)
            end
            local usePart = silentTargetPart or rageTargetPart
            if not usePart or not usePart.Parent then
                return oldIndex(self, key)
            end
            if key ~= "Hit" and key ~= "Target" and key ~= "TargetPosition" and key ~= "UnitRay" then
                return oldIndex(self, key)
            end
            if self ~= silentMouse then
                return oldIndex(self, key)
            end
            if key == "Hit" then
                local pos = usePart.Position
                return CFrame.new(pos, pos + Camera.CFrame.LookVector)
            elseif key == "Target" then
                return usePart
            elseif key == "TargetPosition" then
                return usePart.Position
            elseif key == "UnitRay" then
                local origin = Camera.CFrame.Position
                local dir = (usePart.Position - origin).Unit
                return Ray.new(origin, dir * 5000)
            end
            return oldIndex(self, key)
        end)
        setreadonly(mt, true)
    end)
    if not hookOK then warn("[VYX] Silent aim hook failed:", hookErr) end
end)

--=====================================================================
-- Main loop
--=====================================================================
RunService.RenderStepped:Connect(function(dt)
    TargetLocked = false

    if AimAssistEnabled then
        local target = getClosestTarget()
        if target then
            TargetLocked = true
            local holdMode = safeValue(Options.HoldToAim, true)
            local holdState = Options.CombatKey and Options.CombatKey:GetState() or false
            if (not holdMode) or holdState then
                local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                if onScreen then
                    local mouse = UserInputService:GetMouseLocation()
                    local dx = screenPos.X - mouse.X
                    local dy = screenPos.Y - mouse.Y
                    local s = math.max(safeValue(Options.AimSmoothness, 0.5), 0.1)
                    if mousemoverel then mousemoverel(dx / s, dy / s) end
                end
            end
        end
    end

    if SilentAimEnabled then
        silentTargetPart = getSilentTarget()
    else
        silentTargetPart = nil
    end

    rageTargetPart = nil
    if RageAimEnabled then
        local rageTarget = getRageTarget()
        if rageTarget then
            rageTargetPart = rageTarget
            TargetLocked = true
        end
    end

    if RageAimEnabled and AutoShootEnabled and rageTargetPart then
        local rageKeyHeld = Options.RageKey and Options.RageKey:GetState() or false
        local autoFire = safeValue(Toggles.RageAutoFire, true)
        if (not autoFire) or rageKeyHeld then
            local now = tick()
            local delay = safeValue(Options.RageDelay, 0.05)
            if now - lastShotTime >= delay then
                lastShotTime = now
                local mouse = LocalPlayer:GetMouse()
                pcall(function() mouse1click() end)
            end
        end
    end

    updateFOV()
    updateESP()
end)

--=====================================================================
-- UI Settings
--=====================================================================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value) Library.KeybindFrame.Visible = value end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor", Default = true,
    Callback = function(Value) Library.ShowCustomCursor = Value end,
})
MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" }, Default = "Right",
    Text = "Notification Side",
    Callback = function(Value) Library:SetNotifySide(Value) end,
})
MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%", Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        Library:SetDPIScale(tonumber(Value))
    end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift", NoUI = false, Text = "Menu Keybind",
    SyncToggleState = false, Mode = "Toggle",
})
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddButton("Unload", function() Library:Unload() end)

--=====================================================================
-- Managers
--=====================================================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("VYX")
SaveManager:SetFolder("VYX/Configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:Notify("VYX v5.1 loaded — RightShift for menu", 3)
