-- VYX Hub v11.0
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local NEON = Color3.fromRGB(170, 0, 255)
local PINK = Color3.fromRGB(255, 40, 100)

local AimEnabled, RageEnabled, AutoShoot = false, false, false
local TargetLocked = false
local AimTargetPart, RageTargetPart = nil, nil
local lastShotTick = 0

local SpeedValue, JumpPowerValue, FlySpeed = 32, 100, 50
local FlyConn, NoclipConn, AntiAFKConn, WSConn = nil, nil, nil, nil

local WMEnabled, WMColor, WMBG = true, NEON, Color3.fromRGB(8, 0, 15)
local WMFPS, WMPing, WMUser = true, true, true

local HitSoundEnabled, KillFeedEnabled = false, false
local HubClosed = false

local Window = Library:CreateWindow({
    Title = "VYX", Footer = "version: V11.0", Icon = 6031097230,
    NotifySide = "Right", ShowCustomCursor = true,
})

Library.Scheme = Library.Scheme or {}
Library.Scheme.Accent     = NEON
Library.Scheme.Background = Color3.fromRGB(8, 0, 15)
Library.Scheme.Outline    = Color3.fromRGB(100, 0, 180)
Library.Scheme.FontColor  = Color3.fromRGB(220, 200, 255)

local Tabs = {
    Combat = Window:AddTab("Combat", "crosshair"),
    ESP = Window:AddTab("ESP", "eye"),
    ["Player Mods"] = Window:AddTab("Player Mods", "person-standing"),
    Watermark = Window:AddTab("Watermark", "activity"),
    ["Unlock All"] = Window:AddTab("Unlock All", "unlock"),
    Misc = Window:AddTab("Misc", "settings-2"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- ========== COMBAT ==========
local CT = Tabs.Combat
local AimWin = CT:AddLeftGroupbox("Aimbot")
local ExtWin = CT:AddLeftGroupbox("External Scripts")
local RagWin = CT:AddRightGroupbox("Ragebot")
local ChkWin = CT:AddRightGroupbox("Checks")

AimWin:AddToggle("AimEn", { Text = "Enable Aimbot", Default = false })
Toggles.AimEn:OnChanged(function() AimEnabled = Toggles.AimEn.Value end)
AimWin:AddDropdown("AimBone", {
    Values = { "Head", "UpperTorso", "HumanoidRootPart", "Closest" },
    Default = "Head", Text = "Aim Bone",
})
AimWin:AddSlider("AimSmooth", { Text = "Snap", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Compact = true })
AimWin:AddSlider("AimFOV", { Text = "Aimbot FOV", Default = 150, Min = 25, Max = 800, Rounding = 0, Compact = true })
AimWin:AddToggle("HoldAim", { Text = "Hold to Aim", Default = true })
AimWin:AddLabel("Key"):AddKeyPicker("CombatKey", {
    Default = "MB2", NoUI = false, SyncToggleState = false, Mode = "Hold", Text = "Aim Key",
})

ExtWin:AddToggle("ExtSilent", { Text = "Enable Silent Aim (external)", Default = false })
Toggles.ExtSilent:OnChanged(function(v)
    if getgenv() and getgenv().SA_Config then getgenv().SA_Config.Enabled = v end
end)
ExtWin:AddToggle("ExtKatana", { Text = "Enable Katana / Auto-Fire (external)", Default = false })
Toggles.ExtKatana:OnChanged(function(v)
    if getgenv() and getgenv().Config then getgenv().Config.Enabled = v end
end)

RagWin:AddToggle("RagEn", { Text = "Enable Ragebot", Default = false })
Toggles.RagEn:OnChanged(function() RageEnabled = Toggles.RagEn.Value end)
RagWin:AddToggle("RagAuto", { Text = "Auto Shoot", Default = true })
Toggles.RagAuto:OnChanged(function() AutoShoot = Toggles.RagAuto.Value end)
RagWin:AddSlider("RagFOV", { Text = "Rage FOV", Default = 400, Min = 50, Max = 1500, Rounding = 0, Compact = true })
RagWin:AddSlider("RagDelay", { Text = "Shot Delay", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2, Compact = true })
RagWin:AddLabel("Rage Color"):AddColorPicker("RagColor", { Default = Color3.fromRGB(255, 100, 0) })
RagWin:AddSlider("RagThick", { Text = "Rage Thick", Default = 2, Min = 1, Max = 8, Rounding = 0, Compact = true })

ChkWin:AddToggle("TeamChk", { Text = "Team Check", Default = true })
ChkWin:AddToggle("VisChk", { Text = "Visible Check", Default = true })
ChkWin:AddLabel("Aim Color"):AddColorPicker("FOVColor", { Default = NEON })
ChkWin:AddSlider("FOVThick", { Text = "Aim Thick", Default = 2, Min = 1, Max = 8, Rounding = 0, Compact = true })

-- ========== ESP UI ==========
local ESPBox = Tabs.ESP:AddLeftGroupbox("Box ESP")
local ESPName = Tabs.ESP:AddLeftGroupbox("Name ESP")
local ESPHealth = Tabs.ESP:AddLeftGroupbox("Health ESP")
local ESPHL = Tabs.ESP:AddRightGroupbox("Highlight")
local ESPTracers = Tabs.ESP:AddRightGroupbox("Tracers")
local ESPSkeleton = Tabs.ESP:AddRightGroupbox("Skeleton")

ESPBox:AddToggle("ESPBoxes", { Text = "Box ESP", Default = false })
ESPBox:AddSlider("ESPBoxThick", { Text = "Thickness", Default = 1, Min = 1, Max = 5, Rounding = 0, Compact = true })
ESPBox:AddLabel("Box Color"):AddColorPicker("ESPBoxCol", { Default = NEON })

ESPName:AddToggle("ESPNames", { Text = "Name ESP", Default = false })
ESPName:AddSlider("ESPNameSize", { Text = "Size", Default = 14, Min = 8, Max = 24, Rounding = 0, Compact = true })
ESPName:AddLabel("Name Color"):AddColorPicker("ESPNameCol", { Default = Color3.fromRGB(255, 255, 255) })
ESPName:AddToggle("ESPDistance", { Text = "Show Distance", Default = false })

ESPHealth:AddToggle("ESPHealthBar", { Text = "Health Bar", Default = false })
ESPHealth:AddToggle("ESPHealthText", { Text = "Health Text", Default = false })

ESPHL:AddToggle("ESPHL", { Text = "Highlight", Default = false })
ESPHL:AddLabel("Color"):AddColorPicker("ESPHLCol", { Default = NEON })

ESPTracers:AddToggle("ESPTracers", { Text = "Tracers", Default = false })
ESPTracers:AddLabel("Color"):AddColorPicker("ESPTracerCol", { Default = NEON })
ESPTracers:AddSlider("ESPTracerThick", { Text = "Thickness", Default = 1, Min = 1, Max = 5, Rounding = 0, Compact = true })

ESPSkeleton:AddToggle("ESPSkeleton", { Text = "Skeleton ESP", Default = false })
ESPSkeleton:AddLabel("Color"):AddColorPicker("ESPSkelCol", { Default = Color3.fromRGB(255, 255, 255) })

-- ========== Player Mods ==========
local MoveG = Tabs["Player Mods"]:AddLeftGroupbox("Movement")
local JumpG = Tabs["Player Mods"]:AddLeftGroupbox("Jump")
local FlyG = Tabs["Player Mods"]:AddRightGroupbox("Fly")
local MiscG = Tabs["Player Mods"]:AddRightGroupbox("Misc")

MoveG:AddToggle("SpeedEn", { Text = "Speed Hack", Default = false })
Toggles.SpeedEn:OnChanged(function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChildOfClass("Humanoid") then
        c.Humanoid.WalkSpeed = Toggles.SpeedEn.Value and SpeedValue or 16
    end
end)
MoveG:AddSlider("SpeedVal", { Text = "Speed", Default = 32, Min = 16, Max = 500, Rounding = 0, Compact = true })
Options.SpeedVal:OnChanged(function()
    SpeedValue = Options.SpeedVal.Value
    if Toggles.SpeedEn.Value then
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then c.Humanoid.WalkSpeed = SpeedValue end
    end
end)

MoveG:AddToggle("WSJump", { Text = "Walkspeed Jump Boost", Default = false })
Toggles.WSJump:OnChanged(function()
    if WSConn then WSConn:Disconnect() WSConn = nil end
    if Toggles.WSJump.Value then
        WSConn = RunService.Heartbeat:Connect(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChildOfClass("Humanoid") and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                c.Humanoid.WalkSpeed = SpeedValue + 20
            end
        end)
    end
end)

MoveG:AddToggle("NoclipEn", { Text = "Noclip", Default = false })
Toggles.NoclipEn:OnChanged(function()
    if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
    if Toggles.NoclipEn.Value then
        local function clear(char)
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        local c = LocalPlayer.Character
        if c then clear(c) end
        NoclipConn = c and c.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") then task.defer(function() pcall(function() d.CanCollide = false end) end) end
        end)
    end
end)

JumpG:AddToggle("JumpEn", { Text = "Jump Power", Default = false })
Toggles.JumpEn:OnChanged(function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChildOfClass("Humanoid") then
        c.Humanoid.UseJumpPower = true
        c.Humanoid.JumpPower = Toggles.JumpEn.Value and JumpPowerValue or 50
    end
end)
JumpG:AddSlider("JumpVal", { Text = "Jump Power", Default = 100, Min = 50, Max = 500, Rounding = 0, Compact = true })
Options.JumpVal:OnChanged(function()
    JumpPowerValue = Options.JumpVal.Value
    if Toggles.JumpEn.Value then
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then c.Humanoid.JumpPower = JumpPowerValue end
    end
end)

JumpG:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump.Value then
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

FlyG:AddToggle("FlyEn", { Text = "Fly", Default = false })
Toggles.FlyEn:OnChanged(function()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    if not Toggles.FlyEn.Value then
        if _G.__VYX_FlyBG then pcall(function() _G.__VYX_FlyBG:Destroy() end) end
        if _G.__VYX_FlyBV then pcall(function() _G.__VYX_FlyBV:Destroy() end) end
        _G.__VYX_FlyBG, _G.__VYX_FlyBV = nil, nil
        return
    end
    local c = LocalPlayer.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4 bg.MaxTorque = Vector3.new(9e9,9e9,9e9) bg.CFrame = hrp.CFrame bg.Parent = hrp
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Parent = hrp
    FlyConn = RunService.RenderStepped:Connect(function()
        local h2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not h2 or not bg.Parent then return end
        local mv = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
        bv.Velocity = mv * FlySpeed
        bg.CFrame = Camera.CFrame
    end)
    _G.__VYX_FlyBG, _G.__VYX_FlyBV = bg, bv
end)
FlyG:AddSlider("FlySpd", { Text = "Fly Speed", Default = 50, Min = 10, Max = 500, Rounding = 0, Compact = true })
Options.FlySpd:OnChanged(function() FlySpeed = Options.FlySpd.Value end)

MiscG:AddToggle("Fullbright", { Text = "Fullbright", Default = false })
Toggles.Fullbright:OnChanged(function()
    if Toggles.Fullbright.Value then
        Lighting.Brightness = 5 Lighting.ClockTime = 12
        Lighting.FogEnd = 100000 Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
    else
        Lighting.Brightness = 2 Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    end
end)

MiscG:AddToggle("AntiAFK", { Text = "Anti-AFK", Default = true })
Toggles.AntiAFK:OnChanged(function()
    if Toggles.AntiAFK.Value then
        if not AntiAFKConn then
            AntiAFKConn = LocalPlayer.Idled:Connect(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    else
        if AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn = nil end
    end
end)

MiscG:AddButton("Reset Character", function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChildOfClass("Humanoid") then c.Humanoid.Health = 0 end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local h = char:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if Toggles.SpeedEn.Value then h.WalkSpeed = SpeedValue end
    if Toggles.JumpEn.Value then h.UseJumpPower = true h.JumpPower = JumpPowerValue end
end)

-- ========== Watermark tab ==========
local WG = Tabs.Watermark:AddLeftGroupbox("Watermark")
local WC = Tabs.Watermark:AddRightGroupbox("Colors")

WG:AddToggle("WMEn", { Text = "Show Watermark", Default = true })
Toggles.WMEn:OnChanged(function() WMEnabled = Toggles.WMEn.Value end)
WG:AddToggle("WMFPS", { Text = "FPS", Default = true })
Toggles.WMFPS:OnChanged(function() WMFPS = Toggles.WMFPS.Value end)
WG:AddToggle("WMPing", { Text = "Ping", Default = true })
Toggles.WMPing:OnChanged(function() WMPing = Toggles.WMPing.Value end)
WG:AddToggle("WMUser", { Text = "Username", Default = true })
Toggles.WMUser:OnChanged(function() WMUser = Toggles.WMUser.Value end)
WC:AddLabel("Text"):AddColorPicker("WMColor", { Default = NEON })
Options.WMColor:OnChanged(function() WMColor = Options.WMColor.Value end)
WC:AddLabel("BG"):AddColorPicker("WMBG", { Default = Color3.fromRGB(8, 0, 15) })
Options.WMBG:OnChanged(function() WMBG = Options.WMBG.Value end)

-- ========== Animated FOV circles (aimbot + rage) ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2 FOVCircle.Color = NEON FOVCircle.Filled = false
FOVCircle.NumSides = 64 FOVCircle.Transparency = 0.5 FOVCircle.Visible = false
local FOVTargetRadius, FOVTargetColor = 150, NEON

local RageCircle = Drawing.new("Circle")
RageCircle.Thickness = 2 RageCircle.Color = Color3.fromRGB(255,100,0) RageCircle.Filled = false
RageCircle.NumSides = 64 RageCircle.Transparency = 0.5 RageCircle.Visible = false
local RageTargetRadius, RageTargetColor = 400, Color3.fromRGB(255,100,0)

local pulsePhase = 0
RunService.RenderStepped:Connect(function(dt)
    pulsePhase = pulsePhase + dt * 6

    local curR = FOVCircle.Radius
    FOVCircle.Radius = curR + (FOVTargetRadius - curR) * math.min(dt * 12, 1)
    local c = FOVCircle.Color
    FOVCircle.Color = Color3.new(
        c.R + (FOVTargetColor.R - c.R) * math.min(dt * 8, 1),
        c.G + (FOVTargetColor.G - c.G) * math.min(dt * 8, 1),
        c.B + (FOVTargetColor.B - c.B) * math.min(dt * 8, 1)
    )
    if TargetLocked then
        FOVCircle.Thickness = 2 + math.sin(pulsePhase) * 0.7
    else
        FOVCircle.Thickness = FOVCircle.Thickness + (2 - FOVCircle.Thickness) * math.min(dt * 10, 1)
    end

    local curRR = RageCircle.Radius
    RageCircle.Radius = curRR + (RageTargetRadius - curRR) * math.min(dt * 12, 1)
    local cr = RageCircle.Color
    RageCircle.Color = Color3.new(
        cr.R + (RageTargetColor.R - cr.R) * math.min(dt * 8, 1),
        cr.G + (RageTargetColor.G - cr.G) * math.min(dt * 8, 1),
        cr.B + (RageTargetColor.B - cr.B) * math.min(dt * 8, 1)
    )
    if RageEnabled then
        RageCircle.Thickness = 2 + math.sin(pulsePhase * 1.2) * 0.8
    end
end)

local wasLocked = false
RunService.RenderStepped:Connect(function()
    local locked = TargetLocked
    if locked and not wasLocked then
        FOVCircle.Transparency = 0
        TweenService:Create(FOVCircle, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Transparency = 0.5 }):Play()
    end
    wasLocked = locked
end)

-- Watermark GUI
local WMGui = Instance.new("ScreenGui")
WMGui.Name = "VYX_WM" WMGui.ResetOnSpawn = false WMGui.IgnoreGuiInset = true
WMGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local WMF = Instance.new("Frame")
WMF.Size = UDim2.new(0, 320, 0, 30) WMF.Position = UDim2.new(0, 10, 0, 10)
WMF.BackgroundColor3 = WMBG WMF.BackgroundTransparency = 0.2 WMF.BorderSizePixel = 0 WMF.Parent = WMGui
local WMS = Instance.new("UIStroke", WMF) WMS.Color = NEON WMS.Thickness = 1 WMS.Transparency = 0.3
local WMT = Instance.new("TextLabel")
WMT.Size = UDim2.new(1,-10,1,0) WMT.Position = UDim2.new(0,5,0,0)
WMT.BackgroundTransparency = 1 WMT.Text = "VYX" WMT.TextColor3 = NEON
WMT.TextSize = 14 WMT.Font = Enum.Font.Code WMT.TextXAlignment = Enum.TextXAlignment.Left
WMT.Parent = WMF

-- ========== Helpers ==========
local function sv(opt, fb) if opt and opt.Value ~= nil then return opt.Value end return fb end
local function isAlive(c)
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end
local function isEnemy(p)
    if p == LocalPlayer then return false end
    if not sv(Toggles.TeamChk, true) then return true end
    if LocalPlayer.Team and p.Team then return LocalPlayer.Team ~= p.Team end
    return true
end

local rayP = RaycastParams.new()
rayP.FilterType = Enum.RaycastFilterType.Exclude
rayP.IgnoreWater = true

local function isVisible(part)
    if not sv(Toggles.VisChk, true) then return true end
    local c = LocalPlayer.Character
    if not c then return false end
    rayP.FilterDescendantsInstances = { c }
    local origin = Camera.CFrame.Position
    local hit = Workspace:Raycast(origin, part.Position - origin, rayP)
    return not hit or hit.Instance:IsDescendantOf(part.Parent)
end

local function getBone(character, boneName)
    if not character then return nil end
    if boneName == "Closest" then
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local parts = {"Head","UpperTorso","LowerTorso","HumanoidRootPart","Torso"}
        local best, bestD = nil, math.huge
        for _, n in ipairs(parts) do
            local p = character:FindFirstChild(n)
            if p and p:IsA("BasePart") then
                local sp, on = Camera:WorldToViewportPoint(p.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestD then bestD = d best = p end
                end
            end
        end
        return best
    end
    return character:FindFirstChild(boneName)
end

-- ========== ESP renderer ==========
local espTable = {}
local function espGet(p)
    if espTable[p] then return espTable[p] end
    local e = {
        box = Drawing.new("Square"), name = Drawing.new("Text"),
        tracer = Drawing.new("Line"), healthBar = Drawing.new("Square"),
        healthText = Drawing.new("Text"), hl = nil, bones = {},
    }
    espTable[p] = e
    return e
end

local function espKill(p)
    local e = espTable[p]
    if not e then return end
    for _, d in pairs(e) do
        if typeof(d) == "Instance" then pcall(function() d:Destroy() end)
        elseif typeof(d) == "table" then
            for _, ln in pairs(d) do pcall(function() ln:Remove() end) end
        elseif d then pcall(function() d:Remove() end) end
    end
    espTable[p] = nil
end

local function bounds(c)
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local head = c:FindFirstChild("Head")
    if not hrp or not head then return nil end
    local top, topOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
    local bot, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
    if not (topOn and botOn) then return nil end
    local h = math.abs(bot.Y - top.Y)
    local w = h * 0.5
    return { x = top.X - w/2, y = top.Y, w = w, h = h, top = top, bot = bot }
end

local function updateESP()
    for p, _ in pairs(espTable) do
        if not p.Parent or not p.Character or not p.Character:FindFirstChild("Head") then
            espKill(p)
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isEnemy(p) then
            local c = p.Character
            local ok = c and c:FindFirstChild("Head") and c:FindFirstChildOfClass("Humanoid") and c.Humanoid.Health > 0
            local want = ok and (
                sv(Toggles.ESPBoxes, false) or sv(Toggles.ESPNames, false)
                or sv(Toggles.ESPHL, false) or sv(Toggles.ESPTracers, false)
                or sv(Toggles.ESPHealthBar, false) or sv(Toggles.ESPHealthText, false)
                or sv(Toggles.ESPSkeleton, false)
            )
            if want then
                local e = espGet(p)
                local b = bounds(c)
                local hum = c.Humanoid
                if b then
                    e.box.Visible = sv(Toggles.ESPBoxes, false)
                    e.box.Size = Vector2.new(b.w, b.h)
                    e.box.Position = Vector2.new(b.x, b.y)
                    e.box.Color = sv(Options.ESPBoxCol, NEON)
                    e.box.Thickness = sv(Options.ESPBoxThick, 1)
                    e.box.Filled = false
                    e.box.Transparency = 1

                    local txt = p.Name
                    if sv(Toggles.ESPDistance, false) then
                        local d = math.floor((c.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude)
                        txt = txt .. " [" .. d .. "m]"
                    end
                    e.name.Visible = sv(Toggles.ESPNames, false)
                    e.name.Text = txt
                    e.name.Size = sv(Options.ESPNameSize, 14)
                    e.name.Color = sv(Options.ESPNameCol, Color3.new(1,1,1))
                    e.name.Center = true
                    e.name.Outline = true
                    e.name.Position = Vector2.new(b.top.X, b.top.Y - 18)

                    local vp = Camera.ViewportSize
                    e.tracer.Visible = sv(Toggles.ESPTracers, false)
                    e.tracer.From = Vector2.new(vp.X/2, vp.Y)
                    e.tracer.To = Vector2.new(b.top.X, b.bot.Y)
                    e.tracer.Color = sv(Options.ESPTracerCol, NEON)
                    e.tracer.Thickness = sv(Options.ESPTracerThick, 1)
                    e.tracer.Transparency = 1

                    if sv(Toggles.ESPHealthBar, false) then
                        local pct = hum.Health / hum.MaxHealth
                        e.healthBar.Visible = true
                        e.healthBar.Size = Vector2.new(3, b.h)
                        e.healthBar.Position = Vector2.new(b.x - 7, b.y + b.h * (1 - pct))
                        e.healthBar.Color = Color3.new(1 - pct, pct, 0)
                        e.healthBar.Filled = true
                        e.healthBar.Transparency = 1
                    else
                        e.healthBar.Visible = false
                    end

                    if sv(Toggles.ESPHealthText, false) then
                        e.healthText.Visible = true
                        e.healthText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                        e.healthText.Size = 13
                        e.healthText.Color = Color3.new(0, 1, 0)
                        e.healthText.Center = true
                        e.healthText.Outline = true
                        e.healthText.Position = Vector2.new(b.bot.X, b.bot.Y + 4)
                    else
                        e.healthText.Visible = false
                    end
                end

                if sv(Toggles.ESPHL, false) then
                    if not e.hl or not e.hl.Parent then
                        local h = Instance.new("Highlight")
                        h.Name = "VYX_HL"
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Adornee = c
                        h.Parent = c
                        e.hl = h
                    end
                    e.hl.FillColor = sv(Options.ESPHLCol, NEON)
                    e.hl.OutlineColor = sv(Options.ESPHLCol, NEON)
                    e.hl.FillTransparency = 0.6
                elseif e.hl then
                    e.hl:Destroy()
                    e.hl = nil
                end

                if sv(Toggles.ESPSkeleton, false) and b then
                    local skelColor = sv(Options.ESPSkelCol, Color3.new(1,1,1))
                    local function line(a, bb)
                        if not a or not bb then return end
                        local ap, aOn = Camera:WorldToViewportPoint(a)
                        local bp, bOn = Camera:WorldToViewportPoint(bb)
                        if not (aOn and bOn) then return nil end
                        return { from = Vector2.new(ap.X, ap.Y), to = Vector2.new(bp.X, bp.Y) }
                    end
                    local head = c:FindFirstChild("Head")
                    local torso = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    local lt = c:FindFirstChild("LeftHand") or c:FindFirstChild("Left Arm")
                    local rt = c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")
                    local ll = c:FindFirstChild("LeftFoot") or c:FindFirstChild("Left Leg")
                    local rl = c:FindFirstChild("RightFoot") or c:FindFirstChild("Right Leg")
                    local segments = {
                        line(head and head.Position, torso and torso.Position),
                        line(torso and torso.Position, lt and lt.Position),
                        line(torso and torso.Position, rt and rt.Position),
                        line(hrp and hrp.Position, ll and ll.Position),
                        line(hrp and hrp.Position, rl and rl.Position),
                    }
                    for i = 1, 5 do
                        e.bones[i] = e.bones[i] or Drawing.new("Line")
                        local ln = e.bones[i]
                        local seg = segments[i]
                        if seg then
                            ln.Visible = true ln.From = seg.from ln.To = seg.to
                            ln.Color = skelColor ln.Thickness = 1 ln.Transparency = 1
                        else ln.Visible = false end
                    end
                else
                    for _, ln in pairs(e.bones) do ln.Visible = false end
                end
            else
                espKill(p)
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(p) espKill(p) end)

-- ========== Main loop ==========
local fpsF, fpsA, fpsC = 0, 0, 60
local lastWM = 0

RunService.RenderStepped:Connect(function(dt)
    fpsF = fpsF + 1
    fpsA = fpsA + dt
    if fpsA >= 0.5 then fpsC = math.floor(fpsF / fpsA) fpsF = 0 fpsA = 0 end

    TargetLocked = false
    AimTargetPart = nil
    RageTargetPart = nil

    if AimEnabled then
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)
        local best, bestD = nil, sv(Options.AimFOV, 150)
        for _, p in ipairs(Players:GetPlayers()) do
            if isEnemy(p) and isAlive(p.Character) then
                local bone = getBone(p.Character, sv(Options.AimBone, "Head"))
                if bone and bone:IsA("BasePart") then
                    local sp, on = Camera:WorldToViewportPoint(bone.Position)
                    if on then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestD and isVisible(bone) then bestD = d best = bone end
                    end
                end
            end
        end
        if best then
            TargetLocked = true
            AimTargetPart = best
            local hold = sv(Toggles.HoldAim, true)
            local held = Options.CombatKey and Options.CombatKey:GetState() or false
            if (not hold) or held then
                local sp, on = Camera:WorldToViewportPoint(best.Position)
                if on then
                    local m = UserInputService:GetMouseLocation()
                    local s = math.max(sv(Options.AimSmooth, 0.5), 0.1)
                    if mousemoverel then mousemoverel((sp.X - m.X) / s, (sp.Y - m.Y) / s) end
                end
            end
        end
    end

    if RageEnabled then
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)
        local best, bestD = nil, sv(Options.RagFOV, 400)
        for _, p in ipairs(Players:GetPlayers()) do
            if isEnemy(p) and isAlive(p.Character) then
                local bone = getBone(p.Character, "Head")
                if bone then
                    local sp, on = Camera:WorldToViewportPoint(bone.Position)
                    if on then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestD then bestD = d best = bone end
                    end
                end
            end
        end
        if best then
            TargetLocked = true
            RageTargetPart = best
            if AutoShoot then
                local now = tick()
                if now - lastShotTick >= sv(Options.RagDelay, 0.05) then
                    lastShotTick = now
                    pcall(function() mouse1click() end)
                end
            end
        end
    end

    local vp = Camera.ViewportSize
    FOVTargetRadius = sv(Options.AimFOV, 150)
    FOVTargetColor = sv(Options.FOVColor, NEON)
    FOVCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
    FOVCircle.Visible = AimEnabled

    RageTargetRadius = sv(Options.RagFOV, 400)
    RageTargetColor = sv(Options.RagColor, Color3.fromRGB(255,100,0))
    RageCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
    RageCircle.Visible = RageEnabled

    if not WMEnabled then
        WMF.Visible = false
    else
        WMF.Visible = true
        WMS.Color = WMColor
        WMF.BackgroundColor3 = WMBG
        lastWM = lastWM + dt
        if lastWM >= 0.5 then
            lastWM = 0
            local parts = { "VYX" }
            if WMFPS then table.insert(parts, "FPS: " .. fpsC) end
            if WMPing then
                local ok, ping = pcall(function()
                    return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                table.insert(parts, "Ping: " .. (ok and ping or 0) .. "ms")
            end
            if WMUser then table.insert(parts, LocalPlayer.Name) end
            WMT.Text = table.concat(parts, " | ")
            WMT.TextColor3 = WMColor
        end
    end

    updateESP()
end)

-- ========== Unlock All ==========
local UnlockGroup = Tabs["Unlock All"]:AddLeftGroupbox("Unlock All")
local UnlockInfo  = Tabs["Unlock All"]:AddRightGroupbox("Info")
local UnlockState = { Active = false }

local function _runFullUnlockAll()
    local _plrs = Players
    local _rs   = ReplicatedStorage
    local _lp   = _plrs.LocalPlayer
    local _ctrl = _lp.PlayerScripts:WaitForChild("Controllers", 10)
    local _mods = _rs:WaitForChild("Modules", 10)
    if not _mods or not _ctrl then error("Not in Rivals") end

    coroutine.wrap(function()
        pcall(function()
            local _stbl
            _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
                if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
                    local tr = debug.traceback()
                    if tr:find("MiscellaneousController") then return _stbl({1,2,3}, {}) end
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
                            if nm:find(_tags[_i]) then pcall(function() o.Disabled = true end) break end
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
    end)()

    local _enumLib = require(_mods:WaitForChild("EnumLibrary", 10))
    if _enumLib then pcall(function() _enumLib:WaitForEnumBuilder() end) end
    local _cosLib  = require(_mods:WaitForChild("CosmeticLibrary", 10))
    local _datCtrl = require(_ctrl:WaitForChild("PlayerDataController", 10))

    local _eq, _favs = {}, {}
    local _cosTypes = {"Skin","Wrap","Charm","Dance","Emote"}
    local function _isCosType(c)
        if not c then return false end
        for _, t in ipairs(_cosTypes) do
            if c.Type == t then return true end
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

    _cosLib.OwnsCosmeticNormally = function() return true end
    _cosLib.OwnsCosmeticUniversally = function() return true end
    _cosLib.OwnsCosmeticForWeapon = function() return true end
    local _origOwns = _cosLib.OwnsCosmetic
    _cosLib.OwnsCosmetic = function(self, inv, nm, wep)
        if nm:find("MISSING_") or nm == "Bubble Gun" then return _origOwns(self, inv, nm, wep) end
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

    if hookmetamethod then
        local _remotes = _rs:FindFirstChild("Remotes")
        local _dataRem = _remotes and _remotes:FindFirstChild("Data")
        local _equipRem = _dataRem and _dataRem:FindFirstChild("EquipCosmetic")
        if _equipRem then
            local _onc
            _onc = hookmetamethod(game, "__namecall", function(self, ...)
                if getnamecallmethod() ~= "FireServer" then return _onc(self, ...) end
                if self == _equipRem then
                    local _a = {...}
                    local _cn = _a[3]
                    if _cn and _cn ~= "None" and _cn ~= "" then
                        local c = _cosLib.Cosmetics[_cn]
                        if c and _isCosType(c) then return end
                    end
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
            if _wp == _lp and _eq[_wn] then
                local _dk = self:ToEnum("Data")
                if vmRef[_dk] then
                    if _eq[_wn].Skin then
                        vmRef[_dk][self:ToEnum("Skin")] = _eq[_wn].Skin
                        vmRef[_dk][self:ToEnum("Name")] = _eq[_wn].Skin.Name
                    end
                    if _eq[_wn].Charm then vmRef[_dk][self:ToEnum("Charm")] = _eq[_wn].Charm end
                    if _eq[_wn].Wrap  then vmRef[_dk][self:ToEnum("Wrap")]  = _eq[_wn].Wrap  end
                end
            end
            return _origCVM(self, vmRef)
        end
    end
end

UnlockGroup:AddButton("Enable Unlock All", function()
    if UnlockState.Active then Library:Notify("Unlock All is already active", 2) return end
    Library:Notify("Enabling Unlock All — may take 5-15 seconds...", 4)
    task.spawn(function()
        local ok, err = pcall(_runFullUnlockAll)
        if ok then
            UnlockState.Active = true
            Library:Notify("Unlock All ENABLED", 4)
        else
            Library:Notify("Failed: " .. tostring(err), 6)
        end
    end)
end)

UnlockInfo:AddLabel("Client-side cosmetic unlock.\nHooks CosmeticLibrary, PlayerDataController,\nEquipCosmetic remote, and ViewModel renderer.\nUse on alt account only.", true)

-- ========== Misc ==========
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc Cheats")
local MiscGroup2 = Tabs.Misc:AddRightGroupbox("Visual Misc")
local FeedGroup = Tabs.Misc:AddRightGroupbox("Effects")

MiscGroup:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
MiscGroup:AddToggle("AntiRagdoll", { Text = "Anti Ragdoll", Default = false })
Toggles.AntiRagdoll:OnChanged(function()
    local c = LocalPlayer.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not Toggles.AntiRagdoll.Value) end
end)
MiscGroup:AddToggle("AntiFling", { Text = "Anti Fling", Default = false })
Toggles.AntiFling:OnChanged(function()
    if Toggles.AntiFling.Value then
        local c = LocalPlayer.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function()
                hrp.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
            end) end
        end
    end
end)
MiscGroup:AddButton("Respawn", function() LocalPlayer:LoadCharacter() end)

MiscGroup2:AddToggle("RemoveFog", { Text = "Remove Fog", Default = false })
Toggles.RemoveFog:OnChanged(function()
    if Toggles.RemoveFog.Value then Lighting.FogEnd = 100000 Lighting.FogStart = 0
    else Lighting.FogEnd = 10000 Lighting.FogStart = 0 end
end)
MiscGroup2:AddToggle("NoParticles", { Text = "Remove Particles", Default = false })
Toggles.NoParticles:OnChanged(function()
    if not Toggles.NoParticles.Value then return end
    task.spawn(function()
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam") then
                pcall(function() obj.Enabled = false end)
            end
            count = count + 1
            if count % 500 == 0 then task.wait() end
        end
        Library:Notify("Particles removed", 2)
    end)
end)
MiscGroup2:AddToggle("NoShadows", { Text = "Remove Shadows", Default = false })
Toggles.NoShadows:OnChanged(function()
    if Toggles.NoShadows.Value then Lighting.GlobalShadows = false else Lighting.GlobalShadows = true end
end)

FeedGroup:AddToggle("HitSoundEn", { Text = "Hit Sound", Default = false })
Toggles.HitSoundEn:OnChanged(function() HitSoundEnabled = Toggles.HitSoundEn.Value end)
FeedGroup:AddToggle("KillFeedEn", { Text = "Kill Feed", Default = false })
Toggles.KillFeedEn:OnChanged(function() KillFeedEnabled = Toggles.KillFeedEn.Value end)

local FeedGui = Instance.new("ScreenGui")
FeedGui.Name = "VYX_Feed" FeedGui.ResetOnSpawn = false FeedGui.IgnoreGuiInset = true
FeedGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local FeedFrame = Instance.new("Frame")
FeedFrame.Size = UDim2.new(0, 300, 0, 200) FeedFrame.Position = UDim2.new(1, -310, 0, 80)
FeedFrame.BackgroundTransparency = 1 FeedFrame.Parent = FeedGui

local function pushFeed(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22) lbl.Position = UDim2.new(0, 0, 0, 178)
    lbl.BackgroundTransparency = 0.3 lbl.BackgroundColor3 = Color3.fromRGB(8, 0, 15)
    lbl.Text = text lbl.TextColor3 = color or NEON lbl.TextSize = 14
    lbl.Font = Enum.Font.Code lbl.TextXAlignment = Enum.TextXAlignment.Right
    lbl.TextStrokeTransparency = 0.4 lbl.Parent = FeedFrame
    TweenService:Create(lbl, TweenInfo.new(2.0, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, 0, 0, 0), TextTransparency = 1, BackgroundTransparency = 1
    }):Play()
    task.delay(2.1, function() lbl:Destroy() end)
end

local feedCooldown = 0
RunService.RenderStepped:Connect(function()
    if not TargetLocked then return end
    local now = tick()
    if now - feedCooldown < 0.2 then return end
    feedCooldown = now
    if HitSoundEnabled then
        task.spawn(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://4877538726"
            s.Volume = 2 s.Parent = SoundService s:Play()
            task.wait(1.5) s:Destroy()
        end)
    end
    if KillFeedEnabled and AimTargetPart then
        local parent = AimTargetPart.Parent
        local p = Players:GetPlayerFromCharacter(parent)
        if p then pushFeed("HIT > " .. p.Name, PINK) end
    end
end)

-- ========== UI Settings ==========
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
local KeybindGroup = Tabs["UI Settings"]:AddRightGroupbox("Keybinds")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu",
    Callback = function(v) Library.KeybindFrame.Visible = v end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor", Default = true,
    Callback = function(v) Library.ShowCustomCursor = v end,
})
MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" }, Default = "Right", Text = "Notification Side",
    Callback = function(v) Library:SetNotifySide(v) end,
})
MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%", Text = "DPI Scale",
    Callback = function(v) v = v:gsub("%%", "") Library:SetDPIScale(tonumber(v)) end,
})
MenuGroup:AddDivider()
MenuGroup:AddButton("Unload", function() Library:Unload() end)

KeybindGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift", NoUI = false, Text = "Toggle Menu",
    SyncToggleState = false, Mode = "Toggle",
})
KeybindGroup:AddLabel("Close / Open Hub"):AddKeyPicker("CloseMenuKeybind", {
    Default = "RightControl", NoUI = false, Text = "Close or reopen hub",
    SyncToggleState = false, Mode = "Toggle",
})

Library.ToggleKeybind = Options.MenuKeybind

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local keyVal = Options.CloseMenuKeybind and Options.CloseMenuKeybind.Value
    if typeof(keyVal) == "EnumItem" then
        if input.KeyCode == keyVal or input.UserInputType == keyVal then
            if HubClosed then
                HubClosed = false
                Library:Notify("Menu: Opened", 2)
                pcall(function() Library:SetOpen(true) end)
            else
                HubClosed = true
                Library:Notify("Menu: Closed (press key to reopen)", 2)
                pcall(function() Library:SetOpen(false) end)
            end
        end
    end
end)

-- ========== Managers ==========
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "CloseMenuKeybind" })
ThemeManager:SetFolder("VYX")
SaveManager:SetFolder("VYX/Configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:Notify("VYX v11.0 loaded — RightShift menu / RightCtrl close", 4)

-- VYX Rivals External Scripts

-- ==================== SILENT AIM ====================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local SA_Configuration = {
    Enabled = false,
    FOV = 200,
    MaxAngle = 30,
    TeamCheck = true,
    HitParts = { "Head", "UpperTorso", "HumanoidRootPart" },
    Prediction = 0.06,
    TargetRate = 1 / 20,
    CacheRate = 1,
}
getgenv().SA_Config = SA_Configuration

local Char0, Char1, Char2, Char3 = utf8.char(0), utf8.char(1), utf8.char(2), utf8.char(3)
local Char4, Char5 = utf8.char(4), utf8.char(5)

local UpdateState, UpdateCameraRotation
pcall(function()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    local Rep = Remotes and Remotes:WaitForChild("Replication", 10)
    local Fighter = Rep and Rep:WaitForChild("Fighter", 10)
    if Fighter then
        UpdateState = Fighter:WaitForChild("UpdateState", 10)
        UpdateCameraRotation = Fighter:WaitForChild("UpdateCameraRotation", 10)
    end
end)

local Utility = nil
pcall(function()
    Utility = require(ReplicatedStorage.Modules.Utility)
end)

local Cached, LastCache = {}, 0

local function IsSameTeam(character)
    if not SA_Configuration.TeamCheck or not character then return false end
    local player = Players:GetPlayerFromCharacter(character)
    if player then
        local mine = LocalPlayer:GetAttribute("TeamID")
        local theirs = player:GetAttribute("TeamID")
        if mine ~= nil and theirs ~= nil and mine == theirs then return true end
        if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return true end
    end
    return false
end

local function RefreshCache()
    if tick() - LastCache < SA_Configuration.CacheRate then return end
    LastCache = tick()
    table.clear(Cached)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not IsSameTeam(plr.Character) then
            table.insert(Cached, plr.Character)
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
            if model:IsA("Model") then table.insert(Cached, model) end
        end
    end
end

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude
RayParams.IgnoreWater = true

local function IsVisible(from, to, char)
    if not LocalPlayer.Character then return true end
    RayParams.FilterDescendantsInstances = { LocalPlayer.Character, CurrentCamera }
    local hit = Workspace:Raycast(from, to - from, RayParams)
    if not hit then return true end
    return hit.Instance:IsDescendantOf(char)
end

local LastTarget, LastPart, LastScan = nil, nil, 0

local function GetTarget()
    if not SA_Configuration.Enabled then
        getgenv().__SA_Lock = false
        return nil, nil
    end
    if tick() - LastScan < SA_Configuration.TargetRate then
        return LastTarget, LastPart
    end
    LastScan = tick()
    RefreshCache()
    local mouse = UserInputService:GetMouseLocation()
    local cx, cy = mouse.X, mouse.Y
    local camPos = CurrentCamera.CFrame.Position
    local camLook = CurrentCamera.CFrame.LookVector
    local bestPos, bestPart, bestDist = nil, nil, SA_Configuration.FOV
    for _, model in ipairs(Cached) do
        if model and model.Parent then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                for _, name in ipairs(SA_Configuration.HitParts) do
                    local part = model:FindFirstChild(name)
                    if part and part:IsA("BasePart") then
                        local vel = part.AssemblyLinearVelocity
                        local aim = vel.Magnitude > 2 and part.Position + vel * SA_Configuration.Prediction or part.Position
                        local s, onScreen = CurrentCamera:WorldToViewportPoint(aim)
                        if onScreen then
                            local dx, dy = s.X - cx, s.Y - cy
                            local d = math.sqrt(dx * dx + dy * dy)
                            if d < bestDist then
                                local dir = (aim - camPos).Unit
                                if camLook:Dot(dir) > math.cos(math.rad(SA_Configuration.MaxAngle)) then
                                    if IsVisible(camPos, aim, model) then
                                        bestDist = d
                                        bestPos = aim
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
    end
    LastTarget, LastPart = bestPos, bestPart
    if bestPos then
        getgenv().__SA_Shot = { Pos = bestPos, T = tick() }
        getgenv().__SA_Lock = true
    else
        getgenv().__SA_Lock = false
    end
    return bestPos, bestPart
end

RunService.RenderStepped:Connect(function()
    pcall(GetTarget)
end)

local function Encode(cf)
    local rx, ry, rz = cf:ToOrientation()
    return { [Char0] = cf.X, [Char1] = cf.Y, [Char2] = cf.Z, [Char3] = rx, [Char4] = ry, [Char5] = rz }
end

local function EncodeRot(target)
    local rx, ry = CFrame.new(CurrentCamera.CFrame.Position, target):ToOrientation()
    local ok, enc = pcall(function()
        return Utility:EncodeCameraRotation(Vector2.new(rx, ry))
    end)
    if ok and enc then return enc end
    local function b(v)
        return utf8.char(math.clamp(math.floor(v % 6.2831853 / 6.2831853 * 256 + 0.5), 0, 255))
    end
    return b(rx) .. b(ry)
end

local function HookRemote(remote, fn)
    if not remote then return end
    pcall(function()
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
    end)
end

HookRemote(UpdateState, function(call, self, enumId, a1, a2, ...)
    if not SA_Configuration.Enabled then
        return call(self, enumId, a1, a2, ...)
    end
    if type(a2) == "table" then
        local pos, part = LastTarget, LastPart
        if pos and part and part.Parent then
            local ok, pcf = pcall(function() return part.CFrame end)
            if ok then
                local noff = Encode(pcf:Inverse() * CFrame.new(pos))
                local cloned = table.clone(a2)
                for k, e in pairs(cloned) do
                    if type(e) == "table" and e[Char2] ~= nil then
                        local n = table.clone(e)
                        n[Char2] = part
                        n[Char3] = noff
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
    if not SA_Configuration.Enabled then
        return call(self, rot, ...)
    end
    local s = getgenv().__SA_Shot
    if s and tick() - s.T < 0.5 and rot ~= nil then
        rot = EncodeRot(s.Pos)
    end
    return call(self, rot, ...)
end)

-- ==================== KATANA AUTO-FIRE ====================
local repS = cloneref and cloneref(game:GetService("ReplicatedStorage")) or game:GetService("ReplicatedStorage")
local plrs = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
local runS = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local ws = cloneref and cloneref(game:GetService("Workspace")) or game:GetService("Workspace")
local lplr = plrs.LocalPlayer

getgenv().Config = {
    Enabled = false,
    FireRate = 0.0005,
    WeaponSlot = "Melee"
}

local slots = { Primary = 1, Secondary = 2, Melee = 3 }
local function getSlotNumber()
    return slots[getgenv().Config.WeaponSlot] or 3
end

task.spawn(function()
    local util, enum, FighterController, SpectateController
    pcall(function() util = require(repS.Modules.Utility) end)
    pcall(function() enum = require(repS.Modules.EnumLibrary) end)
    pcall(function() FighterController = require(lplr.PlayerScripts.Controllers.FighterController) end)
    pcall(function() SpectateController = require(lplr.PlayerScripts.Controllers:WaitForChild("SpectateController")) end)
    if not (util and enum and FighterController) then
        warn("[VYX] Katana script: Rivals modules not found")
        return
    end
    task.wait(2)
    local lastFire = 0
    local deflecting = {}
    plrs.PlayerRemoving:Connect(function(player) deflecting[player] = nil end)

    local function updateDeflection()
        if not FighterController.Objects then return end
        for _, fighterObj in FighterController.Objects do
            local player = fighterObj.Player
            if not player then continue end
            if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get("IsSpectating") then
                deflecting[player] = false
                continue
            end
            local equipped = fighterObj.EquippedItem
            local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == "Katana"
            local isDeflecting = false
            if isKatana then
                isDeflecting = (equipped._attack_cooldown and equipped._attack_cooldown > tick()) or false
            end
            deflecting[player] = isDeflecting
        end
    end

    local function isEnemy(player)
        if player == lplr then return false end
        local duel = SpectateController and SpectateController.CurrentDuelSubject
        local localDueler = duel and duel:GetDueler(lplr)
        local localTeam = localDueler and localDueler:Get("TeamID") or nil
        if localTeam and duel and duel.Duelers then
            for _, dueler in duel.Duelers do
                if dueler.Player == player then
                    local team = dueler:Get("TeamID")
                    return team ~= localTeam
                end
            end
        end
        local pTeam = player:GetAttribute("TeamID")
        local lTeam = lplr:GetAttribute("TeamID")
        if pTeam and lTeam then return pTeam ~= lTeam end
        return true
    end

    local function getClosestTarget()
        local char = lplr.Character
        if not char then return nil, nil, nil end
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil, nil, nil end
        local closestPlayer, closestRoot, closestHead = nil, nil, nil
        local closestDist = 500
        for _, player in plrs:GetPlayers() do
            if not isEnemy(player) then continue end
            local pChar = player.Character
            if not pChar then continue end
            local pRoot = pChar:FindFirstChild("HumanoidRootPart")
            local pHead = pChar:FindFirstChild("Head")
            local pHum = pChar:FindFirstChildWhichIsA("Humanoid")
            if not (pRoot and pHead and pHum and pHum.Health > 0) then continue end
            local dist = (myRoot.Position - pRoot.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlayer = player
                closestRoot = pRoot
                closestHead = pHead
            end
        end
        return closestPlayer, closestRoot, closestHead
    end

    runS.Heartbeat:Connect(function()
        updateDeflection()
        if not getgenv().Config.Enabled then return end
        local targetPlayer, targetRoot, targetHead = getClosestTarget()
        if not (targetPlayer and targetRoot and targetHead) then return end
        if deflecting[targetPlayer] then return end
        if not lplr.Character or not lplr.Character:FindFirstChild("HumanoidRootPart") then return end
        if not FighterController.LocalFighter then return end
        local item = FighterController.LocalFighter.EquippedItem
        if not item then return end
        if tick() - lastFire < getgenv().Config.FireRate then return end
        lastFire = tick()
        local desyncPos = (targetRoot.CFrame * CFrame.new(0, 1, 2)).Position
        local desyncCF = CFrame.lookAt(desyncPos, targetHead.Position)
        local aimCF = CFrame.lookAt(desyncCF.Position, targetHead.Position)
        local targetCF = targetHead.CFrame
        local aimedPos = targetHead.Position + Vector3.new(
            (math.random() - 0.5) * 0.1,
            (math.random() - 0.5) * 0.1,
            (math.random() - 0.5) * 0.1
        )
        local objSpaceHeadOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(aimedPos))
        local cameradata = {}
        cameradata[utf8.char(1)] = {
            [utf8.char(0)] = util:EncodeCFrame(aimCF),
            [utf8.char(1)] = util:EncodeCFrame(targetCF),
            [utf8.char(2)] = targetHead,
            [utf8.char(3)] = util:EncodeCFrame(objSpaceHeadOffset)
        }
        repS.Remotes.Replication.Fighter.UseItem:FireServer(
            item:Get("ObjectID"),
            enum:ToEnum("StartShooting"),
            cameradata,
            nil
        )
    end)
end)

print("[VYX External] Silent aim + Katana loaded")

