-- ================================================
--           EMPEROR'S SCRIPT v3
--        Built for Delta Mobile Executor
--   Aimbot | Silent Aim | ESP | Tracers | Chams
--              Powered by Orion UI
-- ================================================

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

-- ================================================
-- CLEANUP
-- ================================================
if workspace:FindFirstChild("EmperorsESP") then
    workspace.EmperorsESP:Destroy()
end
if LocalPlayer.PlayerGui:FindFirstChild("EmperorsAimGui") then
    LocalPlayer.PlayerGui.EmperorsAimGui:Destroy()
end

-- ================================================
-- MOBILE DETECTION
-- ================================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ================================================
-- SETTINGS
-- ================================================
local Settings = {
    AimbotEnabled   = false,
    SilentAim       = true,
    LockOn          = true,
    WallCheck       = true,
    TeamCheck       = true,
    Prediction      = true,
    AimbotSmooth    = IsMobile and 0.55 or 0.25,
    AimbotFOV       = IsMobile and 280  or 200,
    AimbotPart      = "Head",
    ShowFOVRing     = true,
    ESPEnabled      = false,
    ShowHealthBars  = true,
    ShowTracers     = true,
    ShowChams       = true,
    ShowSnaplines   = false,
    ShowWeaponLabel = true,
    ShowDistance    = true,
    EnemyColor      = Color3.fromRGB(255, 60,  60),
    TeamColor       = Color3.fromRGB(60,  255, 120),
    LockedColor     = Color3.fromRGB(255, 200,   0),
}

-- ================================================
-- ORION WINDOW
-- ================================================
local Window = OrionLib:MakeWindow({
    Name         = "Emperor's Script v3",
    HidePremium  = false,
    SaveConfig   = false,
    ConfigFolder = "EmperorsScript",
    IntroEnabled = true,
    IntroText    = "Emperor's Script v3",
})

-- ================================================
-- AIMBOT TAB
-- ================================================
local AimTab = Window:MakeTab({
    Name        = "Aimbot",
    Icon        = "rbxassetid://4483345998",
    PremiumOnly = false,
})

AimTab:AddSection({ Name = "Aimbot" })

AimTab:AddToggle({
    Name     = "Aimbot",
    Default  = false,
    Callback = function(v) Settings.AimbotEnabled = v end,
})

AimTab:AddToggle({
    Name     = "Silent Aim",
    Default  = true,
    Callback = function(v) Settings.SilentAim = v end,
})

AimTab:AddToggle({
    Name     = "Lock-On",
    Default  = true,
    Callback = function(v) Settings.LockOn = v end,
})

AimTab:AddToggle({
    Name     = "Prediction",
    Default  = true,
    Callback = function(v) Settings.Prediction = v end,
})

AimTab:AddToggle({
    Name     = "Wall Check",
    Default  = true,
    Callback = function(v) Settings.WallCheck = v end,
})

AimTab:AddToggle({
    Name     = "Team Check",
    Default  = true,
    Callback = function(v) Settings.TeamCheck = v end,
})

AimTab:AddToggle({
    Name     = "FOV Ring",
    Default  = true,
    Callback = function(v) Settings.ShowFOVRing = v end,
})

AimTab:AddSlider({
    Name      = "FOV Size",
    Min       = 50,
    Max       = 500,
    Default   = Settings.AimbotFOV,
    Color     = Color3.fromRGB(120, 0, 255),
    Increment = 10,
    ValueName = "px",
    Callback  = function(v) Settings.AimbotFOV = v end,
})

AimTab:AddSlider({
    Name      = "Smoothness",
    Min       = 1,
    Max       = 100,
    Default   = math.floor(Settings.AimbotSmooth * 100),
    Color     = Color3.fromRGB(120, 0, 255),
    Increment = 1,
    ValueName = "%",
    Callback  = function(v) Settings.AimbotSmooth = v / 100 end,
})

AimTab:AddDropdown({
    Name     = "Aim Part",
    Default  = "Head",
    Options  = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Callback = function(v) Settings.AimbotPart = v end,
})

-- ================================================
-- ESP TAB
-- ================================================
local ESPTab = Window:MakeTab({
    Name        = "ESP",
    Icon        = "rbxassetid://4483345998",
    PremiumOnly = false,
})

ESPTab:AddSection({ Name = "ESP" })

ESPTab:AddToggle({
    Name     = "ESP",
    Default  = false,
    Callback = function(v) Settings.ESPEnabled = v end,
})

ESPTab:AddToggle({
    Name     = "Health Bars",
    Default  = true,
    Callback = function(v) Settings.ShowHealthBars = v end,
})

ESPTab:AddToggle({
    Name     = "Tracers",
    Default  = true,
    Callback = function(v) Settings.ShowTracers = v end,
})

ESPTab:AddToggle({
    Name     = "Chams",
    Default  = true,
    Callback = function(v) Settings.ShowChams = v end,
})

ESPTab:AddToggle({
    Name     = "Snaplines",
    Default  = false,
    Callback = function(v) Settings.ShowSnaplines = v end,
})

ESPTab:AddToggle({
    Name     = "Weapon Label",
    Default  = true,
    Callback = function(v) Settings.ShowWeaponLabel = v end,
})

ESPTab:AddToggle({
    Name     = "Distance",
    Default  = true,
    Callback = function(v) Settings.ShowDistance = v end,
})

-- ================================================
-- AIM BUTTON (separate GUI, always visible)
-- ================================================
local aimGui = Instance.new("ScreenGui")
aimGui.Name           = "EmperorsAimGui"
aimGui.ResetOnSpawn   = false
aimGui.IgnoreGuiInset = true
aimGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
aimGui.Parent         = LocalPlayer.PlayerGui

local AimBtnSz     = IsMobile and 100 or 85
local AimActive    = false
local LockedTarget = nil

local AimBtn = Instance.new("TextButton", aimGui)
AimBtn.Size             = UDim2.new(0, AimBtnSz, 0, AimBtnSz)
AimBtn.Position         = UDim2.new(1, -(AimBtnSz + 14), 1, -(AimBtnSz + 90))
AimBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 180)
AimBtn.Text             = "AIM"
AimBtn.TextColor3       = Color3.new(1, 1, 1)
AimBtn.TextSize         = IsMobile and 18 or 14
AimBtn.Font             = Enum.Font.GothamBold
AimBtn.BorderSizePixel  = 0
AimBtn.ZIndex           = 10
AimBtn.Active           = true
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(1, 0)
local aimStroke = Instance.new("UIStroke", AimBtn)
aimStroke.Color     = Color3.fromRGB(160, 60, 255)
aimStroke.Thickness = 2

-- Draggable AIM button
do
    local dragging, dragStart, startPos = false, nil, nil
    AimBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = AimBtn.Position
        end
    end)
    AimBtn.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = inp.Position - dragStart
            AimBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    AimBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

AimBtn.MouseButton1Down:Connect(function()
    AimActive = true
    if not Settings.LockOn then LockedTarget = nil end
    Camera.CameraType       = Enum.CameraType.Scriptable
    AimBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    aimStroke.Color         = Color3.fromRGB(230, 130, 255)
end)
AimBtn.MouseButton1Up:Connect(function()
    AimActive = false
    if not Settings.LockOn then LockedTarget = nil end
    Camera.CameraType       = Enum.CameraType.Custom
    AimBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 180)
    aimStroke.Color         = Color3.fromRGB(160, 60, 255)
end)

-- ================================================
-- FOV RING + LOCK DOT
-- ================================================
local FOVRing = Instance.new("Frame", aimGui)
FOVRing.BackgroundTransparency = 1
FOVRing.BorderSizePixel        = 0
FOVRing.ZIndex                 = 2
FOVRing.AnchorPoint            = Vector2.new(0.5, 0.5)
FOVRing.Position               = UDim2.new(0.5, 0, 0.5, 0)
local ringImg = Instance.new("ImageLabel", FOVRing)
ringImg.BackgroundTransparency = 1
ringImg.Image                  = "rbxassetid://3570695787"
ringImg.ImageColor3            = Color3.fromRGB(160, 60, 255)
ringImg.ImageTransparency      = 0.3
ringImg.ScaleType              = Enum.ScaleType.Stretch
ringImg.Size                   = UDim2.new(1, 0, 1, 0)
ringImg.ZIndex                 = 2

local LockDot = Instance.new("Frame", aimGui)
LockDot.Size             = UDim2.new(0, 14, 0, 14)
LockDot.AnchorPoint      = Vector2.new(0.5, 0.5)
LockDot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
LockDot.BorderSizePixel  = 0
LockDot.ZIndex           = 15
LockDot.Visible          = false
Instance.new("UICorner", LockDot).CornerRadius = UDim.new(1, 0)
local lockStroke = Instance.new("UIStroke", LockDot)
lockStroke.Color     = Color3.fromRGB(255, 255, 100)
lockStroke.Thickness = 2

-- ================================================
-- HELPERS
-- ================================================
local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function SameTeam(p)
    return p.Team ~= nil and p.Team == LocalPlayer.Team
end

local function HasWall(origin, target)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType                 = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, target - origin, params)
    if not result then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character
           and result.Instance:IsDescendantOf(plr.Character) then
            return false
        end
    end
    return true
end

local function ToScreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

local velHistory = {}
local function SmoothedVel(player, raw)
    if not velHistory[player] then velHistory[player] = {} end
    local h = velHistory[player]
    table.insert(h, raw)
    if #h > 4 then table.remove(h, 1) end
    local sum = Vector3.new(0, 0, 0)
    for _, v in ipairs(h) do sum = sum + v end
    return sum / #h
end

local function PredictedPos(player, part)
    if not Settings.Prediction then return part.Position end
    local rawVel = part.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    local vel    = SmoothedVel(player, rawVel)
    local dist   = (Camera.CFrame.Position - part.Position).Magnitude
    local lag    = (dist / 400) + 0.065
    return part.Position + vel * lag
end

local function GetClosest()
    local best, bestDist = nil, Settings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not IsAlive(p) then continue end
        if Settings.TeamCheck and SameTeam(p) then continue end
        local part = p.Character:FindFirstChild(Settings.AimbotPart)
                  or p.Character:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local aimPos = PredictedPos(p, part)
        local sp, on = ToScreen(aimPos)
        if not on then continue end
        if Settings.WallCheck and HasWall(Camera.CFrame.Position, aimPos) then continue end
        local d = (sp - mid).Magnitude
        if d < bestDist then bestDist = d; best = p end
    end
    return best
end

-- ================================================
-- SILENT AIM HOOK
-- ================================================
local SilentTarget = nil

local _oldFindPart = workspace.FindPartOnRayWithWhitelist
if _oldFindPart then
    workspace.FindPartOnRayWithWhitelist = function(ws, ray, wl, ...)
        if Settings.AimbotEnabled and Settings.SilentAim and SilentTarget then
            local part = SilentTarget.Character
                and (SilentTarget.Character:FindFirstChild(Settings.AimbotPart)
                     or SilentTarget.Character:FindFirstChild("HumanoidRootPart"))
            if part then
                local aimPos = PredictedPos(SilentTarget, part)
                local newDir = (aimPos - ray.Origin).Unit * ray.Direction.Magnitude
                ray = Ray.new(ray.Origin, newDir)
            end
        end
        return _oldFindPart(ws, ray, wl, ...)
    end
end

-- ================================================
-- ESP
-- ================================================
local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name  = "EmperorsESP"
local ESPCache  = {}

local function GetWeapon(char)
    local tool = char and char:FindFirstChildOfClass("Tool")
    return tool and tool.Name or nil
end

local function BuildESP(player)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local color = SameTeam(player) and Settings.TeamColor or Settings.EnemyColor
    local o     = {}

    local hl = Instance.new("Highlight", ESPFolder)
    hl.Adornee             = char
    hl.OutlineColor        = color
    hl.FillTransparency    = 0.82
    hl.OutlineTransparency = 0
    hl.FillColor           = color
    o.Highlight            = hl

    local nameBB = Instance.new("BillboardGui", ESPFolder)
    nameBB.Adornee      = root
    nameBB.AlwaysOnTop  = true
    nameBB.ResetOnSpawn = false
    nameBB.Size         = UDim2.new(0, 160, 0, 40)
    nameBB.StudsOffset  = Vector3.new(0, 3.8, 0)

    local nameLbl = Instance.new("TextLabel", nameBB)
    nameLbl.Size                   = UDim2.new(1, 0, 0.55, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text                   = player.DisplayName
    nameLbl.TextColor3             = color
    nameLbl.TextSize               = 14
    nameLbl.Font                   = Enum.Font.GothamBold
    nameLbl.TextStrokeTransparency = 0
    nameLbl.TextStrokeColor3       = Color3.new(0, 0, 0)

    local weapLbl = Instance.new("TextLabel", nameBB)
    weapLbl.Size                   = UDim2.new(1, 0, 0.45, 0)
    weapLbl.Position               = UDim2.new(0, 0, 0.55, 0)
    weapLbl.BackgroundTransparency = 1
    weapLbl.TextColor3             = Color3.fromRGB(255, 210, 80)
    weapLbl.TextSize               = 11
    weapLbl.Font                   = Enum.Font.Gotham
    weapLbl.TextStrokeTransparency = 0
    weapLbl.TextStrokeColor3       = Color3.new(0, 0, 0)
    weapLbl.Text                   = ""

    o.NameBB  = nameBB
    o.NameLbl = nameLbl
    o.WeapLbl = weapLbl

    local distBB = Instance.new("BillboardGui", ESPFolder)
    distBB.Adornee      = root
    distBB.AlwaysOnTop  = true
    distBB.ResetOnSpawn = false
    distBB.Size         = UDim2.new(0, 120, 0, 18)
    distBB.StudsOffset  = Vector3.new(0, -3.6, 0)
    local distLbl = Instance.new("TextLabel", distBB)
    distLbl.Size                   = UDim2.new(1, 0, 1, 0)
    distLbl.BackgroundTransparency = 1
    distLbl.TextColor3             = Color3.fromRGB(200, 200, 200)
    distLbl.TextSize               = 11
    distLbl.Font                   = Enum.Font.Gotham
    distLbl.TextStrokeTransparency = 0
    distLbl.TextStrokeColor3       = Color3.new(0, 0, 0)
    o.DistBB  = distBB
    o.DistLbl = distLbl

    local hpBB = Instance.new("BillboardGui", ESPFolder)
    hpBB.Adornee      = root
    hpBB.AlwaysOnTop  = true
    hpBB.ResetOnSpawn = false
    hpBB.Size         = UDim2.new(0, 7, 0, 44)
    hpBB.StudsOffset  = Vector3.new(-2.4, 0, 0)

    local hpBg = Instance.new("Frame", hpBB)
    hpBg.Size             = UDim2.new(1, 0, 1, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    hpBg.BorderSizePixel  = 0
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 4)

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.AnchorPoint      = Vector2.new(0, 1)
    hpFill.Position         = UDim2.new(0, 0, 1, 0)
    hpFill.Size             = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(60, 220, 80)
    hpFill.BorderSizePixel  = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 4)
    o.HpBB   = hpBB
    o.HpFill = hpFill

    local line = Drawing.new("Line")
    line.Visible      = false
    line.Thickness    = IsMobile and 1.5 or 1
    line.Color        = Settings.EnemyColor
    line.Transparency = 0.2
    o.TracerLine      = line

    local snap = Drawing.new("Line")
    snap.Visible      = false
    snap.Thickness    = 1
    snap.Color        = Color3.fromRGB(255, 255, 100)
    snap.Transparency = 0.4
    o.SnapLine        = snap

    o.Root = root
    o.Char = char
    ESPCache[player] = o
    return o
end

local function RemoveESP(player)
    local o = ESPCache[player]
    if not o then return end
    if o.Highlight  then o.Highlight:Destroy()  end
    if o.NameBB     then o.NameBB:Destroy()     end
    if o.DistBB     then o.DistBB:Destroy()     end
    if o.HpBB       then o.HpBB:Destroy()       end
    if o.TracerLine then o.TracerLine:Remove()  end
    if o.SnapLine   then o.SnapLine:Remove()    end
    ESPCache[player]   = nil
    velHistory[player] = nil
end

Players.PlayerRemoving:Connect(RemoveESP)

-- ================================================
-- MAIN LOOP
-- ================================================
RunService.RenderStepped:Connect(function()

    local mid     = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local screenH = Camera.ViewportSize.Y
    local tracerO = Vector2.new(mid.X, screenH)

    local fovD = Settings.AimbotFOV * 2
    FOVRing.Size    = UDim2.new(0, fovD, 0, fovD)
    FOVRing.Visible = Settings.ShowFOVRing and Settings.AimbotEnabled
    ringImg.ImageColor3 = AimActive
        and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(160, 60, 255)

    if Settings.AimbotEnabled and AimActive then

        if Settings.LockOn and LockedTarget then
            if not IsAlive(LockedTarget) then
                LockedTarget = nil
            else
                local part = LockedTarget.Character:FindFirstChild(Settings.AimbotPart)
                          or LockedTarget.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp, on = ToScreen(part.Position)
                    if not on or (sp - mid).Magnitude > Settings.AimbotFOV * 1.6 then
                        LockedTarget = nil
                    end
                end
            end
        end

        if not LockedTarget then LockedTarget = GetClosest() end
        SilentTarget = LockedTarget

        if LockedTarget and LockedTarget.Character then
            local part = LockedTarget.Character:FindFirstChild(Settings.AimbotPart)
                      or LockedTarget.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local aimPos = PredictedPos(LockedTarget, part)

                if not Settings.SilentAim then
                    if Camera.CameraType ~= Enum.CameraType.Scriptable then
                        Camera.CameraType = Enum.CameraType.Scriptable
                    end
                    local dist = (Camera.CFrame.Position - aimPos).Magnitude
                    local snap = math.clamp(
                        Settings.AimbotSmooth + (1 / math.max(dist, 1)) * 3,
                        Settings.AimbotSmooth, 0.    TeamCheck       = true,
    Prediction      = true,
    AimbotSmooth    = IsMobile and 0.55 or 0.25,
    AimbotFOV       = IsMobile and 280  or 200,
    AimbotPart      = "Head",
    ShowFOVRing     = true,
    ESPEnabled      = false,
    ShowHealthBars  = true,
    ShowTracers     = true,
    ShowChams       = true,
    ShowSnaplines   = false,
    ShowWeaponLabel = true,
    ShowDistance    = true,
    EnemyColor      = Color3.fromRGB(255, 60,  60),
    TeamColor       = Color3.fromRGB(60,  255, 120),
    LockedColor     = Color3.fromRGB(255, 200,   0),
}

-- ================================================
-- TWEEN HELPER
-- ================================================
local TI_FAST = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function Tween(obj, props, info)
    TweenService:Create(obj, info or TI_FAST, props):Play()
end

-- ================================================
-- SCALED SIZES (Mobile vs PC)
-- ================================================
local PanelW   = IsMobile and 320  or 300
local PanelH   = IsMobile and 490  or 450
local TabW     = IsMobile and 180  or 160
local TabH     = IsMobile and 52   or 44
local ToggleH  = IsMobile and 58   or 50
local FontSz   = IsMobile and 16   or 14
local AimBtnSz = IsMobile and 100  or 85
local Pad      = IsMobile and 8    or 6
local CloseSz  = IsMobile and 40   or 32

-- ================================================
-- GUI ROOT
-- ================================================
local gui = Instance.new("ScreenGui")
gui.Name           = "EmperorsGUI"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LocalPlayer.PlayerGui

-- Tab Button
local TabBtn = Instance.new("TextButton", gui)
TabBtn.Size             = UDim2.new(0, TabW, 0, TabH)
TabBtn.Position         = UDim2.new(0.5, -TabW/2, 1, -(TabH + 10))
TabBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 180)
TabBtn.Text             = "EMPEROR'S"
TabBtn.TextColor3       = Color3.new(1, 1, 1)
TabBtn.TextSize         = FontSz
TabBtn.Font             = Enum.Font.GothamBold
TabBtn.BorderSizePixel  = 0
TabBtn.ZIndex           = 10
TabBtn.Active           = true
Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 26)
local tabStroke = Instance.new("UIStroke", TabBtn)
tabStroke.Color     = Color3.fromRGB(160, 60, 255)
tabStroke.Thickness = 1.5
TabBtn.MouseEnter:Connect(function() Tween(TabBtn, {BackgroundColor3=Color3.fromRGB(110,20,220)}) end)
TabBtn.MouseLeave:Connect(function() Tween(TabBtn, {BackgroundColor3=Color3.fromRGB(80,0,180)}) end)

-- Main Panel
local Panel = Instance.new("Frame", gui)
Panel.Size             = UDim2.new(0, PanelW, 0, PanelH)
Panel.Position         = UDim2.new(0.5, -PanelW/2, 0.5, -PanelH/2)
Panel.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
Panel.BorderSizePixel  = 0
Panel.Active           = true
Panel.Draggable        = true
Panel.Visible          = false
Panel.ZIndex           = 5
Panel.ClipsDescendants = true
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 16)
local panelStroke = Instance.new("UIStroke", Panel)
panelStroke.Color     = Color3.fromRGB(120, 0, 240)
panelStroke.Thickness = 1.5

-- Title Bar
local TitleBar = Instance.new("Frame", Panel)
TitleBar.Size             = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(55, 0, 135)
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 6
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size                   = UDim2.new(1, -55, 0, 28)
TitleLbl.Position               = UDim2.new(0, 14, 0, 6)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text                   = "EMPEROR'S SCRIPT"
TitleLbl.TextColor3             = Color3.new(1, 1, 1)
TitleLbl.TextSize               = FontSz
TitleLbl.Font                   = Enum.Font.GothamBold
TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left
TitleLbl.ZIndex                 = 7

local VersionLbl = Instance.new("TextLabel", TitleBar)
VersionLbl.Size                   = UDim2.new(1, -55, 0, 16)
VersionLbl.Position               = UDim2.new(0, 14, 1, -18)
VersionLbl.BackgroundTransparency = 1
VersionLbl.Text                   = "v3 Beast | " .. (IsMobile and "Mobile" or "PC")
VersionLbl.TextColor3             = Color3.fromRGB(160, 80, 255)
VersionLbl.TextSize               = 10
VersionLbl.Font                   = Enum.Font.Gotham
VersionLbl.TextXAlignment         = Enum.TextXAlignment.Left
VersionLbl.ZIndex                 = 7

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size             = UDim2.new(0, CloseSz, 0, CloseSz)
CloseBtn.Position         = UDim2.new(1, -(CloseSz + 8), 0.5, -CloseSz/2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text             = "X"
CloseBtn.TextColor3       = Color3.new(1, 1, 1)
CloseBtn.TextSize         = FontSz
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.ZIndex           = 8
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3=Color3.fromRGB(220,50,50)}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3=Color3.fromRGB(180,30,30)}) end)

-- Scroll Frame
local Scroll = Instance.new("ScrollingFrame", Panel)
Scroll.Size                   = UDim2.new(1, -16, 1, -60)
Scroll.Position               = UDim2.new(0, 8, 0, 56)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness     = IsMobile and 5 or 3
Scroll.ScrollBarImageColor3   = Color3.fromRGB(120, 0, 240)
Scroll.BorderSizePixel        = 0
Scroll.ZIndex                 = 6

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding   = UDim.new(0, Pad)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 14)
end)

-- Animated panel open/close
local panelOpen = false
local function SetPanelVisible(state)
    panelOpen = state
    if state then
        Panel.Visible = true
        Panel.Size    = UDim2.new(0, PanelW, 0, 0)
        Panel.BackgroundTransparency = 0.7
        Tween(Panel, {Size=UDim2.new(0,PanelW,0,PanelH), BackgroundTransparency=0}, TI_MED)
    else
        Tween(Panel, {Size=UDim2.new(0,PanelW,0,0), BackgroundTransparency=0.7}, TI_MED)
        task.delay(0.25, function()
            if not panelOpen then Panel.Visible = false end
        end)
    end
end

TabBtn.MouseButton1Click:Connect(function() SetPanelVisible(not panelOpen) end)
CloseBtn.MouseButton1Click:Connect(function() SetPanelVisible(false) end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        SetPanelVisible(not panelOpen)
    end
end)

-- ================================================
-- TOAST NOTIFICATIONS
-- ================================================
local toastCount = 0
local function Notify(msg, isOn)
    toastCount = toastCount + 1
    local offset = (toastCount - 1) * 44
    local toast = Instance.new("Frame", gui)
    toast.Size             = UDim2.new(0, 240, 0, 38)
    toast.Position         = UDim2.new(0.5, -120, 0, -50 - offset)
    toast.BackgroundColor3 = isOn and Color3.fromRGB(38,0,95) or Color3.fromRGB(24,24,36)
    toast.BorderSizePixel  = 0
    toast.ZIndex           = 30
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)
    local ts = Instance.new("UIStroke", toast)
    ts.Color     = isOn and Color3.fromRGB(130,0,255) or Color3.fromRGB(70,70,90)
    ts.Thickness = 1

    local badge = Instance.new("TextLabel", toast)
    badge.Size                   = UDim2.new(0, 36, 1, 0)
    badge.Position               = UDim2.new(0, 4, 0, 0)
    badge.BackgroundTransparency = 1
    badge.Text                   = isOn and "[ON]" or "[OFF]"
    badge.TextColor3             = isOn and Color3.fromRGB(80,255,80) or Color3.fromRGB(255,80,80)
    badge.TextSize               = 10
    badge.Font                   = Enum.Font.GothamBold
    badge.ZIndex                 = 31

    local lbl = Instance.new("TextLabel", toast)
    lbl.Size                   = UDim2.new(1, -44, 1, 0)
    lbl.Position               = UDim2.new(0, 42, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = msg
    lbl.TextColor3             = Color3.new(1, 1, 1)
    lbl.TextSize               = 13
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.ZIndex                 = 31

    Tween(toast, {Position=UDim2.new(0.5,-120,0,14+offset)}, TI_MED)
    task.delay(2.2, function()
        Tween(toast, {Position=UDim2.new(0.5,-120,0,-50-offset)}, TI_MED)
        task.delay(0.25, function()
            toast:Destroy()
            toastCount = math.max(0, toastCount - 1)
        end)
    end)
end

-- ================================================
-- TOGGLE FACTORY
-- ================================================
local function MakeSection(text, order)
    local f = Instance.new("Frame", Scroll)
    f.LayoutOrder            = order
    f.Size                   = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.ZIndex                 = 7
    local l = Instance.new("TextLabel", f)
    l.Size                   = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text                   = text
    l.TextColor3             = Color3.fromRGB(160, 80, 255)
    l.TextSize               = 11
    l.Font                   = Enum.Font.GothamBold
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.ZIndex                 = 8
end

local function MakeToggle(labelText, settingKey, order, desc)
    local btn = Instance.new("TextButton", Scroll)
    btn.LayoutOrder     = order
    btn.Size            = UDim2.new(1, 0, 0, ToggleH)
    btn.BorderSizePixel = 0
    btn.ZIndex          = 7
    btn.Text            = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local lbl = Instance.new("TextLabel", btn)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = FontSz
    lbl.TextColor3             = Color3.new(1, 1, 1)
    lbl.Text                   = labelText
    lbl.ZIndex                 = 8

    if desc then
        lbl.Size     = UDim2.new(1, -70, 0, 22)
        lbl.Position = UDim2.new(0, 14, 0, 8)
        local sub = Instance.new("TextLabel", btn)
        sub.Size                   = UDim2.new(1, -70, 0, 14)
        sub.Position               = UDim2.new(0, 14, 0, 30)
        sub.BackgroundTransparency = 1
        sub.TextXAlignment         = Enum.TextXAlignment.Left
        sub.Font                   = Enum.Font.Gotham
        sub.TextSize               = 10
        sub.TextColor3             = Color3.fromRGB(150, 150, 180)
        sub.Text                   = desc
        sub.ZIndex                 = 8
    else
        lbl.Size     = UDim2.new(1, -70, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
    end

    local track = Instance.new("Frame", btn)
    track.Size            = UDim2.new(0, 52, 0, 30)
    track.Position        = UDim2.new(1, -62, 0.5, -15)
    track.BorderSizePixel = 0
    track.ZIndex          = 8
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 24, 0, 24)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 9
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function Refresh(anim)
        local on       = Settings[settingKey]
        local bgCol    = on and Color3.fromRGB(38,0,95)    or Color3.fromRGB(20,20,32)
        local trackCol = on and Color3.fromRGB(120,0,255)  or Color3.fromRGB(52,52,68)
        local knobPos  = on and UDim2.new(1,-26,0.5,-12)   or UDim2.new(0,3,0.5,-12)
        if anim then
            Tween(btn,   {BackgroundColor3=bgCol})
            Tween(track, {BackgroundColor3=trackCol})
            Tween(knob,  {Position=knobPos})
        else
            btn.BackgroundColor3   = bgCol
            track.BackgroundColor3 = trackCol
            knob.Position          = knobPos
        end
    end
    Refresh(false)

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        Refresh(true)
        Notify(labelText .. " " .. (Settings[settingKey] and "ON" or "OFF"), Settings[settingKey])
    end)
end

-- Build menu items
MakeSection("  -- AIMBOT --", 1)
MakeToggle("Aimbot",        "AimbotEnabled",   2,  nil)
MakeToggle("Silent Aim",    "SilentAim",        3,  "Bullets hit without camera move")
MakeToggle("Lock-On",       "LockOn",           4,  "Stay locked to target")
MakeToggle("Prediction",    "Prediction",       5,  "Lead moving targets")
MakeToggle("Wall Check",    "WallCheck",        6,  nil)
MakeToggle("Team Check",    "TeamCheck",        7,  nil)
MakeToggle("FOV Ring",      "ShowFOVRing",      8,  nil)
MakeSection("  -- ESP --",  20)
MakeToggle("ESP",           "ESPEnabled",       21, nil)
MakeToggle("Health Bars",   "ShowHealthBars",   22, nil)
MakeToggle("Tracers",       "ShowTracers",      23, "Lines from screen to enemy")
MakeToggle("Chams",         "ShowChams",        24, "Colored body highlight")
MakeToggle("Snaplines",     "ShowSnaplines",    25, "Vertical line under enemy")
MakeToggle("Weapon Label",  "ShowWeaponLabel",  26, nil)

-- ================================================
-- AIM BUTTON (draggable, mobile-sized)
-- ================================================
local AimActive    = false
local LockedTarget = nil

local AimBtn = Instance.new("TextButton", gui)
AimBtn.Size             = UDim2.new(0, AimBtnSz, 0, AimBtnSz)
AimBtn.Position         = UDim2.new(1, -(AimBtnSz + 14), 1, -(AimBtnSz + 90))
AimBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 180)
AimBtn.Text             = "AIM"
AimBtn.TextColor3       = Color3.new(1, 1, 1)
AimBtn.TextSize         = IsMobile and 18 or 14
AimBtn.Font             = Enum.Font.GothamBold
AimBtn.BorderSizePixel  = 0
AimBtn.ZIndex           = 10
AimBtn.Active           = true
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(1, 0)
local aimStroke = Instance.new("UIStroke", AimBtn)
aimStroke.Color     = Color3.fromRGB(160, 60, 255)
aimStroke.Thickness = 2

-- Draggable logic
do
    local dragging, dragStart, startPos = false, nil, nil
    AimBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = AimBtn.Position
        end
    end)
    AimBtn.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = inp.Position - dragStart
            AimBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    AimBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

AimBtn.MouseButton1Down:Connect(function()
    AimActive = true
    if not Settings.LockOn then LockedTarget = nil end
    Camera.CameraType = Enum.CameraType.Scriptable
    Tween(AimBtn,    {BackgroundColor3=Color3.fromRGB(150,0,255)})
    Tween(aimStroke, {Color=Color3.fromRGB(230,130,255)})
end)
AimBtn.MouseButton1Up:Connect(function()
    AimActive = false
    if not Settings.LockOn then LockedTarget = nil end
    Camera.CameraType = Enum.CameraType.Custom
    Tween(AimBtn,    {BackgroundColor3=Color3.fromRGB(80,0,180)})
    Tween(aimStroke, {Color=Color3.fromRGB(160,60,255)})
end)

-- ================================================
-- FOV RING + LOCK DOT
-- ================================================
local FOVRing = Instance.new("Frame", gui)
FOVRing.BackgroundTransparency = 1
FOVRing.BorderSizePixel        = 0
FOVRing.ZIndex                 = 2
FOVRing.AnchorPoint            = Vector2.new(0.5, 0.5)
FOVRing.Position               = UDim2.new(0.5, 0, 0.5, 0)
local ringImg = Instance.new("ImageLabel", FOVRing)
ringImg.BackgroundTransparency = 1
ringImg.Image                  = "rbxassetid://3570695787"
ringImg.ImageColor3            = Color3.fromRGB(160, 60, 255)
ringImg.ImageTransparency      = 0.3
ringImg.ScaleType              = Enum.ScaleType.Stretch
ringImg.Size                   = UDim2.new(1, 0, 1, 0)
ringImg.ZIndex                 = 2

local LockDot = Instance.new("Frame", gui)
LockDot.Size             = UDim2.new(0, 14, 0, 14)
LockDot.AnchorPoint      = Vector2.new(0.5, 0.5)
LockDot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
LockDot.BorderSizePixel  = 0
LockDot.ZIndex           = 15
LockDot.Visible          = false
Instance.new("UICorner", LockDot).CornerRadius = UDim.new(1, 0)
local lockStroke = Instance.new("UIStroke", LockDot)
lockStroke.Color     = Color3.fromRGB(255, 255, 100)
lockStroke.Thickness = 2

-- ================================================
-- HELPER FUNCTIONS
-- ================================================
local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function SameTeam(p)
    return p.Team ~= nil and p.Team == LocalPlayer.Team
end

local function HasWall(origin, target)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType                 = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, target - origin, params)
    if not result then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character
           and result.Instance:IsDescendantOf(plr.Character) then
            return false
        end
    end
    return true
end

local function ToScreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

-- Velocity smoothing across 4 frames
local velHistory = {}
local function SmoothedVel(player, raw    TeamCheck       = true,
    Prediction      = true,
    AimbotSmooth    = IsMobile and 0.55 or 0.25,
    AimbotFOV       = IsMobile and 280  or 200,
    AimbotPart      = "Head",
    ShowFOVRing     = true,
    ESPEnabled      = false,
    ShowHealthBars  = true,
    ShowTracers     = true,
    ShowChams       = true,
    ShowSnaplines   = false,
    ShowWeaponLabel = true,
    ShowDistance    = true,
    EnemyColor      = Color3.fromRGB(255, 60,  60),
    TeamColor       = Color3.fromRGB(60,  255, 120),
    LockedColor     = Color3.fromRGB(255, 200,   0),
}

-- ================================================
-- TWEEN HELPER
-- ================================================
local TI_FAST = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function Tween(obj, props, info)
    TweenService:Create(obj, info or TI_FAST, props):Play()
end

-- ================================================
-- SCALED SIZES (Mobile vs PC)
-- ================================================
local PanelW   = IsMobile and 320  or 300
local PanelH   = IsMobile and 490  or 450
local TabW     = IsMobile and 180  or 160
local TabH     = IsMobile and 52   or 44
local ToggleH  = IsMobile and 58   or 50
local FontSz   = IsMobile and 16   or 14
local AimBtnSz = IsMobile and 100  or 85
local Pad      = IsMobile and 8    or 6
local CloseSz  = IsMobile and 40   or 32

-- ================================================
-- GUI ROOT
-- ================================================
local gui = Instance.new("ScreenGui")
gui.Name           = "EmperorsGUI"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = LocalPlayer.PlayerGui

-- Tab Button
local TabBtn = Instance.new("TextButton", gui)
TabBtn.Size             = UDim2.new(0, TabW, 0, TabH)
TabBtn.Position         = UDim2.new(0.5, -TabW/2, 1, -(TabH + 10))
TabBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 180)
TabBtn.Text             = "EMPEROR'S"
TabBtn.TextColor3       = Color3.new(1, 1, 1)
TabBtn.TextSize         = FontSz
TabBtn.Font             = Enum.Font.GothamBold
TabBtn.BorderSizePixel  = 0
TabBtn.ZIndex           = 10
TabBtn.Active           = true
Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 26)
local tabStroke = Instance.new("UIStroke", TabBtn)
tabStroke.Color     = Color3.fromRGB(160, 60, 255)
tabStroke.Thickness = 1.5
TabBtn.MouseEnter:Connect(function() Tween(TabBtn, {BackgroundColor3=Color3.fromRGB(110,20,220)}) end)
TabBtn.MouseLeave:Connect(function() Tween(TabBtn, {BackgroundColor3=Color3.fromRGB(80,0,180)}) end)

-- Main Panel
local Panel = Instance.new("Frame", gui)
Panel.Size             = UDim2.new(0, PanelW, 0, PanelH)
Panel.Position         = UDim2.new(0.5, -PanelW/2, 0.5, -PanelH/2)
Panel.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
Panel.BorderSizePixel  = 0
Panel.Active           = true
Panel.Draggable        = true
Panel.Visible          = false
Panel.ZIndex           = 5
Panel.ClipsDescendants = true
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 16)
local panelStroke = Instance.new("UIStroke", Panel)
panelStroke.Color     = Color3.fromRGB(120, 0, 240)
panelStroke.Thickness = 1.5

-- Title Bar
local TitleBar = Instance.new("Frame", Panel)
TitleBar.Size             = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(55, 0, 135)
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 6
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size                   = UDim2.new(1, -55, 0, 28)
TitleLbl.Position               = UDim2.new(0, 14, 0, 6)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text                   = "EMPEROR'S SCRIPT"
TitleLbl.TextColor3             = Color3.new(1, 1, 1)
TitleLbl.TextSize               = FontSz
TitleLbl.Font                   = Enum.Font.GothamBold
TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left
TitleLbl.ZIndex                 = 7

local VersionLbl = Instance.new("TextLabel", TitleBar)
VersionLbl.Size                   = UDim2.new(1, -55, 0, 16)
VersionLbl.Position               = UDim2.new(0, 14, 1, -18)
VersionLbl.BackgroundTransparency = 1
VersionLbl.Text                   = "v3 Beast | " .. (IsMobile and "Mobile" or "PC")
VersionLbl.TextColor3             = Color3.fromRGB(160, 80, 255)
VersionLbl.TextSize               = 10
VersionLbl.Font                   = Enum.Font.Gotham
VersionLbl.TextXAlignment         = Enum.TextXAlignment.Left
VersionLbl.ZIndex                 = 7

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size             = UDim2.new(0, CloseSz, 0, CloseSz)
CloseBtn.Position         = UDim2.new(1, -(CloseSz + 8), 0.5, -CloseSz/2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text             = "X"
CloseBtn.TextColor3       = Color3.new(1, 1, 1)
CloseBtn.TextSize         = FontSz
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.ZIndex           = 8
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3=Color3.fromRGB(220,50,50)}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3=Color3.fromRGB(180,30,30)}) end)

-- Scroll Frame
local Scroll = Instance.new("ScrollingFrame", Panel)
Scroll.Size                   = UDim2.new(1, -16, 1, -60)
Scroll.Position               = UDim2.new(0, 8, 0, 56)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness     = IsMobile and 5 or 3
Scroll.ScrollBarImageColor3   = Color3.fromRGB(120, 0, 240)
Scroll.BorderSizePixel        = 0
Scroll.ZIndex                 = 6

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding   = UDim.new(0, Pad)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 14)
end)

-- Animated panel open/close
local panelOpen = false
local function SetPanelVisible(state)
    panelOpen = state
    if state then
        Panel.Visible = true
        Panel.Size    = UDim2.new(0, PanelW, 0, 0)
        Panel.BackgroundTransparency = 0.7
        Tween(Panel, {Size=UDim2.new(0,PanelW,0,PanelH), BackgroundTransparency=0}, TI_MED)
    else
        Tween(Panel, {Size=UDim2.new(0,PanelW,0,0), BackgroundTransparency=0.7}, TI_MED)
        task.delay(0.25, function()
            if not panelOpen then Panel.Visible = false end
        end)
    end
end

TabBtn.MouseButton1Click:Connect(function() SetPanelVisible(not panelOpen) end)
CloseBtn.MouseButton1Click:Connect(function() SetPanelVisible(false) end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        SetPanelVisible(not panelOpen)
    end
end)

-- ================================================
-- TOAST NOTIFICATIONS
-- ================================================
local toastCount = 0
local function Notify(msg, isOn)
    toastCount = toastCount + 1
    local offset = (toastCount - 1) * 44
    local toast = Instance.new("Frame", gui)
    toast.Size             = UDim2.new(0, 240, 0, 38)
    toast.Position         = UDim2.new(0.5, -120, 0, -50 - offset)
    toast.BackgroundColor3 = isOn and Color3.fromRGB(38,0,95) or Color3.fromRGB(24,24,36)
    toast.BorderSizePixel  = 0
    toast.ZIndex           = 30
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)
    local ts = Instance.new("UIStroke", toast)
    ts.Color     = isOn and Color3.fromRGB(130,0,255) or Color3.fromRGB(70,70,90)
    ts.Thickness = 1

    local badge = Instance.new("TextLabel", toast)
    badge.Size                   = UDim2.new(0, 36, 1, 0)
    badge.Position               = UDim2.new(0, 4, 0, 0)
    badge.BackgroundTransparency = 1
    badge.Text                   = isOn and "[ON]" or "[OFF]"
    badge.TextColor3             = isOn and Color3.fromRGB(80,255,80) or Color3.fromRGB(255,80,80)
    badge.TextSize               = 10
    badge.Font                   = Enum.Font.GothamBold
    badge.ZIndex                 = 31

    local lbl = Instance.new("TextLabel", toast)
    lbl.Size                   = UDim2.new(1, -44, 1, 0)
    lbl.Position               = UDim2.new(0, 42, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = msg
    lbl.TextColor3             = Color3.new(1, 1, 1)
    lbl.TextSize               = 13
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.ZIndex                 = 31

    Tween(toast, {Position=UDim2.new(0.5,-120,0,14+offset)}, TI_MED)
    task.delay(2.2, function()
        Tween(toast, {Position=UDim2.new(0.5,-120,0,-50-offset)}, TI_MED)
        task.delay(0.25, function()
            toast:Destroy()
            toastCount = math.max(0, toastCount - 1)
        end)
    end)
end

-- ================================================
-- TOGGLE FACTORY
-- ================================================
local function MakeSection(text, order)
    local f = Instance.new("Frame", Scroll)
    f.LayoutOrder            = order
    f.Size                   = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.ZIndex                 = 7
    local l = Instance.new("TextLabel", f)
    l.Size                   = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text                   = text
    l.TextColor3             = Color3.fromRGB(160, 80, 255)
    l.TextSize               = 11
    l.Font                   = Enum.Font.GothamBold
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.ZIndex                 = 8
end

local function MakeToggle(labelText, settingKey, order, desc)
    local btn = Instance.new("TextButton", Scroll)
    btn.LayoutOrder     = order
    btn.Size            = UDim2.new(1, 0, 0, ToggleH)
    btn.BorderSizePixel = 0
    btn.ZIndex          = 7
    btn.Text            = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local lbl = Instance.new("TextLabel", btn)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = FontSz
    lbl.TextColor3             = Color3.new(1, 1, 1)
    lbl.Text                   = labelText
    lbl.ZIndex                 = 8

    if desc then
        lbl.Size     = UDim2.new(1, -70, 0, 22)
        lbl.Position = UDim2.new(0, 14, 0, 8)
        local sub = Instance.new("TextLabel", btn)
        sub.Size                   = UDim2.new(1, -70, 0, 14)
        sub.Position               = UDim2.new(0, 14, 0, 30)
        sub.BackgroundTransparency = 1
        sub.TextXAlignment         = Enum.TextXAlignment.Left
        sub.Font                   = Enum.Font.Gotham
        sub.TextSize               = 10
        sub.TextColor3             = Color3.fromRGB(150, 150, 180)
        sub.Text                   = desc
        sub.ZIndex                 = 8
    else
        lbl.Size     = UDim2.new(1, -70, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
    end

    local track = Instance.new("Frame", btn)
    track.Size            = UDim2.new(0, 52, 0, 30)
    track.Position        = UDim2.new(1, -62, 0.5, -15)
    track.BorderSizePixel = 0
    track.ZIndex          = 8
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 24, 0, 24)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 9
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function Refresh(anim)
        local on       = Settings[settingKey]
        local bgCol    = on and Color3.fromRGB(38,0,95)    or Color3.fromRGB(20,20,32)
        local trackCol = on and Color3.fromRGB(120,0,255)  or Color3.fromRGB(52,52,68)
        local knobPos  = on and UDim2.new(1,-26,0.5,-12)   or UDim2.new(0,3,0.5,-12)
        if anim then
            Tween(btn,   {BackgroundColor3=bgCol})
            Tween(track, {BackgroundColor3=trackCol})
            Tween(knob,  {Position=knobPos})
        else
            btn.BackgroundColor3   = bgCol
            track.BackgroundColor3 = trackCol
            knob.Position          = knobPos
        end
    end
    Refresh(false)

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        Refresh(true)
        Notify(labelText .. " " .. (Settings[settingKey] and "ON" or "OFF"), Settings[settingKey])
    end)
end

-- Build menu items
MakeSection("  -- AIMBOT --", 1)
MakeToggle("Aimbot",        "AimbotEnabled",   2,  nil)
MakeToggle("Silent Aim",    "SilentAim",        3,  "Bullets hit without camera move")
MakeToggle("Lock-On",       "LockOn",           4,  "Stay locked to target")
MakeToggle("Prediction",    "Prediction",       5,  "Lead moving targets")
MakeToggle("Wall Check",    "WallCheck",        6,  nil)
MakeToggle("Team Check",    "TeamCheck",        7,  nil)
MakeToggle("FOV Ring",      "ShowFOVRing",      8,  nil)
MakeSection("  -- ESP --",  20)
MakeToggle("ESP",           "ESPEnabled",       21, nil)
MakeToggle("Health Bars",   "ShowHealthBars",   22, nil)
MakeToggle("Tracers",       "ShowTracers",      23, "Lines from screen to enemy")
MakeToggle("Chams",         "ShowChams",        24, "Colored body highlight")
MakeToggle("Snaplines",     "ShowSnaplines",    25, "Vertical line under enemy")
MakeToggle("Weapon Label",  "ShowWeaponLabel",  26, nil)

-- ================================================
-- AIM BUTTON (draggable, mobile-sized)
-- ================================================
local AimActive    = false
local LockedTarget = nil

local AimBtn = Instance.new("TextButton", gui)
AimBtn.Size             = UDim2.new(0, AimBtnSz, 0, AimBtnSz)
AimBtn.Position         = UDim2.new(1, -(AimBtnSz + 14), 1, -(AimBtnSz + 90))
AimBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 180)
AimBtn.Text             = "AIM"
AimBtn.TextColor3       = Color3.new(1, 1, 1)
AimBtn.TextSize         = IsMobile and 18 or 14
AimBtn.Font             = Enum.Font.GothamBold
AimBtn.BorderSizePixel  = 0
AimBtn.ZIndex           = 10
AimBtn.Active           = true
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(1, 0)
local aimStroke = Instance.new("UIStroke", AimBtn)
aimStroke.Color     = Color3.fromRGB(160, 60, 255)
aimStroke.Thickness = 2

-- Draggable logic
do
    local dragging, dragStart, startPos = false, nil, nil
    AimBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = AimBtn.Position
        end
    end)
    AimBtn.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = inp.Position - dragStart
            AimBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    AimBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

AimBtn.MouseButton1Down:Connect(function()
    AimActive = true
    if not Settings.LockOn then LockedTarget = nil end
    Camera.CameraType = Enum.CameraType.Scriptable
    Tween(AimBtn,    {BackgroundColor3=Color3.fromRGB(150,0,255)})
    Tween(aimStroke, {Color=Color3.fromRGB(230,130,255)})
end)
AimBtn.MouseButton1Up:Connect(function()
    AimActive = false
    if not Settings.LockOn then LockedTarget = nil end
    Camera.CameraType = Enum.CameraType.Custom
    Tween(AimBtn,    {BackgroundColor3=Color3.fromRGB(80,0,180)})
    Tween(aimStroke, {Color=Color3.fromRGB(160,60,255)})
end)

-- ================================================
-- FOV RING + LOCK DOT
-- ================================================
local FOVRing = Instance.new("Frame", gui)
FOVRing.BackgroundTransparency = 1
FOVRing.BorderSizePixel        = 0
FOVRing.ZIndex                 = 2
FOVRing.AnchorPoint            = Vector2.new(0.5, 0.5)
FOVRing.Position               = UDim2.new(0.5, 0, 0.5, 0)
local ringImg = Instance.new("ImageLabel", FOVRing)
ringImg.BackgroundTransparency = 1
ringImg.Image                  = "rbxassetid://3570695787"
ringImg.ImageColor3            = Color3.fromRGB(160, 60, 255)
ringImg.ImageTransparency      = 0.3
ringImg.ScaleType              = Enum.ScaleType.Stretch
ringImg.Size                   = UDim2.new(1, 0, 1, 0)
ringImg.ZIndex                 = 2

local LockDot = Instance.new("Frame", gui)
LockDot.Size             = UDim2.new(0, 14, 0, 14)
LockDot.AnchorPoint      = Vector2.new(0.5, 0.5)
LockDot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
LockDot.BorderSizePixel  = 0
LockDot.ZIndex           = 15
LockDot.Visible          = false
Instance.new("UICorner", LockDot).CornerRadius = UDim.new(1, 0)
local lockStroke = Instance.new("UIStroke", LockDot)
lockStroke.Color     = Color3.fromRGB(255, 255, 100)
lockStroke.Thickness = 2

-- ================================================
-- HELPER FUNCTIONS
-- ================================================
local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function SameTeam(p)
    return p.Team ~= nil and p.Team == LocalPlayer.Team
end

local function HasWall(origin, target)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType                 = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, target - origin, params)
    if not result then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character
           and result.Instance:IsDescendantOf(plr.Character) then
            return false
        end
    end
    return true
end

local function ToScreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

-- Velocity smoothing across 4 frames
local velHistory = {}
local function SmoothedVel(player, rawVel)
    if not velHistory[player] then velHistory[player] = {} end
    local h = velHistory[player]
    table.insert(h, rawVel)
    if #h > 4 then table.remove(h, 1) end
    local sum = Vector3.new(0, 0, 0)
    for _, v in ipairs(h) do sum = sum + v end
    return sum / #h
end

local function PredictedPos(player, part)
    if not Settings.Prediction then return part.Position end
    local rawVel = part.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    local vel    = SmoothedVel(player, rawVel)
    local dist   = (Camera.CFrame.Position - part.Position).Magnitude
    local lag    = (dist / 400) + 0.065
    return part.Position + vel * lag
end

local function GetClosest()
    local best, bestDist = nil, Settings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not IsAlive(p) then continue end
        if Settings.TeamCheck and SameTeam(p) then continue end
        local part = p.Character:FindFirstChild(Settings.AimbotPart)
                  or p.Character:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local aimPos = PredictedPos(p, part)
        local sp, on = ToScreen(aimPos)
        if not on then continue end
        if Settings.WallCheck and HasWall(Camera.CFrame.Position, aimPos) then continue end
        local d = (sp - mid).Magnitude
        if d < bestDist then bestDist = d; best = p end
    end
    return best
end

-- ================================================
-- SILENT AIM HOOK
-- ================================================
local SilentTarget = nil

local _oldFindPart = workspace.FindPartOnRayWithWhitelist
if _oldFindPart then
    workspace.FindPartOnRayWithWhitelist = function(ws, ray, wl, ...)
        if Settings.AimbotEnabled and Settings.SilentAim and SilentTarget then
            local part = SilentTarget.Character
                and (SilentTarget.Character:FindFirstChild(Settings.AimbotPart)
                     or SilentTarget.Character:FindFirstChild("HumanoidRootPart"))
            if part then
                local aimPos = PredictedPos(SilentTarget, part)
                local newDir = (aimPos - ray.Origin).Unit * ray.Direction.Magnitude
                ray = Ray.new(ray.Origin, newDir)
            end
        end
        return _oldFindPart(ws, ray, wl, ...)
    end
end

-- ================================================
-- ESP SYSTEM
-- ================================================
local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name  = "EmperorsESP"
local ESPCache  = {}

local function GetWeapon(char)
    local tool = char and char:FindFirstChildOfClass("Tool")
    return tool and tool.Name or nil
end

local function BuildESP(player)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local color = SameTeam(player) and Settings.TeamColor or Settings.EnemyColor
    local o     = {}

    -- Highlight / chams
    local hl = Instance.new("Highlight", ESPFolder)
    hl.Adornee             = char
    hl.OutlineColor        = color
    hl.FillTransparency    = 0.82
    hl.OutlineTransparency = 0
    hl.FillColor           = color
    o.Highlight            = hl

    -- Name + weapon billboard
    local nameBB = Instance.new("BillboardGui", ESPFolder)
    nameBB.Adornee      = root
    nameBB.AlwaysOnTop  = true
    nameBB.ResetOnSpawn = false
    nameBB.Size         = UDim2.new(0, 160, 0, 40)
    nameBB.StudsOffset  = Vector3.new(0, 3.8, 0)

    local nameLbl = Instance.new("TextLabel", nameBB)
    nameLbl.Size                   = UDim2.new(1, 0, 0.55, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text                   = player.DisplayName
    nameLbl.TextColor3             = color
    nameLbl.TextSize               = 14
    nameLbl.Font                   = Enum.Font.GothamBold
    nameLbl.TextStrokeTransparency = 0
    nameLbl.TextStrokeColor3       = Color3.new(0, 0, 0)

    local weapLbl = Instance.new("TextLabel", nameBB)
    weapLbl.Size                   = UDim2.new(1, 0, 0.45, 0)
    weapLbl.Position               = UDim2.new(0, 0, 0.55, 0)
    weapLbl.BackgroundTransparency = 1
    weapLbl.TextColor3             = Color3.fromRGB(255, 210, 80)
    weapLbl.TextSize               = 11
    weapLbl.Font                   = Enum.Font.Gotham
    weapLbl.TextStrokeTransparency = 0
    weapLbl.TextStrokeColor3       = Color3.new(0, 0, 0)
    weapLbl.Text                   = ""

    o.NameBB  = nameBB
    o.NameLbl = nameLbl
    o.WeapLbl = weapLbl

    -- Distance billboard
    local distBB = Instance.new("BillboardGui", ESPFolder)
    distBB.Adornee      = root
    distBB.AlwaysOnTop  = true
    distBB.ResetOnSpawn = false
    distBB.Size         = UDim2.new(0, 120, 0, 18)
    distBB.StudsOffset  = Vector3.new(0, -3.6, 0)
    local distLbl = Instance.new("TextLabel", distBB)
    distLbl.Size                   = UDim2.new(1, 0, 1, 0)
    distLbl.BackgroundTransparency = 1
    distLbl.TextColor3             = Color3.fromRGB(200, 200, 200)
    distLbl.TextSize               = 11
    distLbl.Font                   = Enum.Font.Gotham
    distLbl.TextStrokeTransparency = 0
    distLbl.TextStrokeColor3       = Color3.new(0, 0, 0)
    o.DistBB  = distBB
    o.DistLbl = distLbl

    -- Health bar
    local hpBB = Instance.new("BillboardGui", ESPFolder)
    hpBB.Adornee      = root
    hpBB.AlwaysOnTop  = true
    hpBB.ResetOnSpawn = false
    hpBB.Size         = UDim2.new(0, 7, 0, 44)
    hpBB.StudsOffset  = Vector3.new(-2.4, 0, 0)

    local hpBg = Instance.new("Frame", hpBB)
    hpBg.Size             = UDim2.new(1, 0, 1, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    hpBg.BorderSizePixel  = 0
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 4)

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.AnchorPoint      = Vector2.new(0, 1)
    hpFill.Position         = UDim2.new(0, 0, 1, 0)
    hpFill.Size             = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(60, 220, 80)
    hpFill.BorderSizePixel  = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 4)
    o.HpBB   = hpBB
    o.HpFill = hpFill

    -- Tracer (Drawing)
    local line = Drawing.new("Line")
    line.Visible      = false
    line.Thickness    = IsMobile and 1.5 or 1
    line.Color        = Settings.EnemyColor
    line.Transparency = 0.2
    o.TracerLine      = line

    -- Snapline (Drawing)
    local snap = Drawing.new("Line")
    snap.Visible      = false
    snap.Thickness    = 1
    snap.Color        = Color3.fromRGB(255, 255, 100)
    snap.Transparency = 0.4
    o.SnapLine        = snap

    o.Root = root
    o.Char = char
    ESPCache[player] = o
    return o
end

local function RemoveESP(player)
    local o = ESPCache[player]
    if not o then return end
    if o.Highlight  then o.Highlight:Destroy()  end
    if o.NameBB     then o.NameBB:Destroy()     end
    if o.DistBB     then o.DistBB:Destroy()     end
    if o.HpBB       then o.HpBB:Destroy()       end
    if o.TracerLine then o.TracerLine:Remove()  end
    if o.SnapLine   then o.SnapLine:Remove()    end
    ESPCache[player]   = nil
    velHistory[player] = nil
end

Players.PlayerRemoving:Connect(RemoveESP)

-- ================================================
-- MAIN LOOP
-- ================================================
RunService.RenderStepped:Connect(function()

    local mid     = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local screenH = Camera.ViewportSize.Y
    local tracerO = Vector2.new(mid.X, screenH)

    -- FOV Ring update
    local fovD = Settings.AimbotFOV * 2
    FOVRing.Size    = UDim2.new(0, fovD, 0, fovD)
    FOVRing.Visible = Settings.ShowFOVRing and Settings.AimbotEnabled
    ringImg.ImageColor3 = AimActive
        and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(160, 60, 255)

    -- AIMBOT
    if Settings.AimbotEnabled and AimActive then

        -- Maintain lock-on
        if Settings.LockOn and LockedTarget then
            if not IsAlive(LockedTarget) then
                LockedTarget = nil
            else
                local part = LockedTarget.Character:FindFirstChild(Settings.AimbotPart)
                          or LockedTarget.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp, on = ToScreen(part.Position)
                    if not on or (sp - mid).Magnitude > Settings.AimbotFOV * 1.6 then
                        LockedTarget = nil
                    end
                end
            end
        end

        if not LockedTarget then
            LockedTarget = GetClosest()
        end
        SilentTarget = LockedTarget

        if LockedTarget and LockedTarget.Character then
            local part = LockedTarget.Character:FindFirstChild(Settings.AimbotPart)
                      or LockedTarget.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local aimPos = PredictedPos(LockedTarget, part)

                if not Settings.SilentAim then
                    if Camera.CameraType ~= Enum.CameraType.Scriptable then
                        Camera.CameraType = Enum.CameraType.Scriptable
                    end
                    local dist = (Camera.CFrame.Position - aimPos).Magnitude
                    local snap = math.clamp(
                        Settings.AimbotSmooth + (1 / math.max(dist, 1)) * 3,
                        Settings.AimbotSmooth, 0.98)
                    local goal = CFrame.new(Camera.CFrame.Position, aimPos)
                    Camera.CFrame = Camera.CFrame:Lerp(goal, snap)
                end

                local sp, on = ToScreen(aimPos)
                LockDot.Visible  = on
                LockDot.Position = UDim2.new(0, sp.X, 0, sp.Y)
            else
                LockDot.Visible = false
            end
        else
            SilentTarget = nil
            LockDot.Visible = false
        end

    else
        if not AimActive then
            if Camera.CameraType == Enum.CameraType.Scriptable then
                Camera.CameraType = Enum.CameraType.Custom
            end
            if not Settings.LockOn then LockedTarget = nil end
            SilentTarget = nil
        end
        LockDot.Visible = false
    end

    -- ESP LOOP
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        if not Settings.ESPEnabled or not IsAlive(player)
           or (Settings.TeamCheck and SameTeam(player)) then
            RemoveESP(player)
            continue
        end

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not root then RemoveESP(player); continue end

        local cached = ESPCache[player]
        if not cached or cached.Char ~= char then
            RemoveESP(player)
            cached = BuildESP(player)
            if not cached then continue end
        end

        local isLocked = (player == LockedTarget)
        local color    = isLocked and Settings.LockedColor
                      or (SameTeam(player) and Settings.TeamColor or Settings.EnemyColor)

        local hum   = char:FindFirstChildOfClass("Humanoid")
        local hp    = hum and hum.Health    or 0
        local maxHp = hum and hum.MaxHealth or 100
        local hpPct = math.clamp(hp / math.max(maxHp, 1), 0, 1)
        local dist  = math.floor((Camera.CFrame.Position - root.Position).Magnitude)

        -- Name / weapon
        cached.NameLbl.Text       = player.DisplayName .. (isLocked and " [LOCKED]" or "")
        cached.NameLbl.TextColor3 = color
        local wep = Settings.ShowWeaponLabel and GetWeapon(char)
        cached.WeapLbl.Text    = wep and ("[" .. wep .. "]") or ""
        cached.WeapLbl.Visible = Settings.ShowWeaponLabel
        cached.DistLbl.Text    = Settings.ShowDistance and (dist .. " studs") or ""

        -- Chams
        cached.Highlight.Enabled          = Settings.ShowChams
        cached.Highlight.OutlineColor     = color
        cached.Highlight.FillColor        = color
        cached.Highlight.FillTransparency = isLocked and 0.65 or 0.82

        -- Health bar
        cached.HpBB.Enabled   = Settings.ShowHealthBars
        cached.HpFill.Size    = UDim2.new(1, 0, hpPct, 0)
        cached.HpFill.BackgroundColor3 = Color3.fromRGB(
            math.floor(255 * (1 - hpPct)),
            math.floor(210 * hpPct),
            35)

        -- Tracer
        local footPos     = root.Position - Vector3.new(0, 2.8, 0)
        local sp, onScr   = ToScreen(footPos)

        if cached.TracerLine then
            cached.TracerLine.Visible = Settings.ShowTracers and onScr
            if Settings.ShowTracers and onScr then
                cached.TracerLine.From      = tracerO
                cached.TracerLine.To        = sp
                cached.TracerLine.Color     = color
                cached.TracerLine.Thickness = isLocked and 2.5 or (IsMobile and 1.5 or 1)
            end
        end

        -- Snapline
        if cached.SnapLine then
            cached.SnapLine.Visible = Settings.ShowSnaplines and onScr
            if Settings.ShowSnaplines and onScr then
                cached.SnapLine.From  = sp
                cached.SnapLine.To    = Vector2.new(sp.X, screenH)
                cached.SnapLine.Color = color
            end
        end
    end
end)

-- ================================================
print("Emperor's Script v3 Beast - Loaded!")
-- ================================================
