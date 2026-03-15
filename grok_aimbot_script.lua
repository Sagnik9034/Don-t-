-- Mobile-friendly Aimbot + ESP + Hitbox Expander with Rayfield UI
-- Team check + tracers + basic silent aim

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "Simple Combat GUI",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Grok",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Main", 4483362458) -- random icon id
local SettingsTab = Window:CreateTab("Settings")

-- Settings
getgenv().Settings = {
    AimbotEnabled = false,
    TeamCheck = true,
    WallCheck = true,
    AimPart = "Head",
    FOV = 150,
    Smoothness = 0.05,          -- lower = faster (more obvious)
    ESPEnabled = false,
    TracersEnabled = false,
    HitboxExpander = false,
    HitboxSize = 10,            -- studs
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local DrawingObjects = {}
local Connections = {}

-- Simple world-to-screen function
local function WorldToScreen(pos)
    local screen, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screen.X, screen.Y), onScreen, screen.Z
end

-- Create ESP / Tracer
local function AddESP(plr)
    if plr == LocalPlayer or DrawingObjects[plr] then return end
    
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 0.9
    Box.Color = Color3.fromRGB(255, 50, 50)
    Box.Visible = false
    
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1.5
    Tracer.Color = Color3.fromRGB(255, 100, 100)
    Tracer.Transparency = 0.85
    Tracer.Visible = false
    
    local NameTag = Drawing.new("Text")
    NameTag.Size = 14
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Color = Color3.new(1,1,1)
    NameTag.Visible = false
    
    DrawingObjects[plr] = {Box = Box, Tracer = Tracer, Name = NameTag}
    
    local conn
    conn = plr.CharacterAdded:Connect(function(char)
        -- reset when respawn
    end)
    
    table.insert(Connections, conn)
end

-- Remove when player leaves
Players.PlayerRemoving:Connect(function(plr)
    if DrawingObjects[plr] then
        for _, obj in pairs(DrawingObjects[plr]) do
            obj:Remove()
        end
        DrawingObjects[plr] = nil
    end
end)

-- ESP + Tracer loop
RunService.RenderStepped:Connect(function()
    if not Settings.ESPEnabled and not Settings.TracersEnabled then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local char = plr.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") or char.Humanoid.Health <= 0 then
            if DrawingObjects[plr] then
                for _, v in pairs(DrawingObjects[plr]) do v.Visible = false end
            end
            continue
        end
        
        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        if not head then continue end
        
        local rootPos, onScreen = WorldToScreen(root.Position)
        local headPos = WorldToScreen(head.Position + Vector3.new(0, 1, 0))
        
        if not onScreen then
            if DrawingObjects[plr] then
                for _, v in pairs(DrawingObjects[plr]) do v.Visible = false end
            end
            continue
        end
        
        local data = DrawingObjects[plr]
        if not data then
            AddESP(plr)
            data = DrawingObjects[plr]
        end
        
        -- Box (rough 2D box)
        local top = WorldToScreen(head.Position + Vector3.new(0, 3, 0))
        local bottom = WorldToScreen(root.Position - Vector3.new(0, 3, 0))
        
        local sizeY = math.abs(top.Y - bottom.Y)
        local sizeX = sizeY * 0.55
        
        if Settings.ESPEnabled then
            data.Box.Size = Vector2.new(sizeX, sizeY)
            data.Box.Position = Vector2.new(rootPos.X - sizeX/2, top.Y)
            data.Box.Visible = true
        else
            data.Box.Visible = false
        end
        
        -- Tracer from bottom center of screen
        if Settings.TracersEnabled then
            data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            data.Tracer.To = rootPos
            data.Tracer.Visible = true
        else
            data.Tracer.Visible = false
        end
        
        -- Name + health
        if Settings.ESPEnabled then
            data.Name.Text = plr.Name .. " [" .. math.floor(char.Humanoid.Health) .. "]"
            data.Name.Position = Vector2.new(rootPos.X, top.Y - 20)
            data.Name.Visible = true
        else
            data.Name.Visible = false
        end
    end
end)

-- Hitbox expander (very detectable)
RunService.Heartbeat:Connect(function()
    if not Settings.HitboxExpander then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            root.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            root.Transparency = 0.7   -- semi visible so you know it's expanded
            root.CanCollide = false
        end
    end
end)

-- Basic FOV circle (visual help)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Radius = Settings.FOV
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(220, 100, 100)
fovCircle.Transparency = 0.6
fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
fovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = Settings.FOV
end)

-- Find closest enemy in FOV
local function GetClosest()
    local closest, dist = nil, Settings.FOV
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local char = plr.Character
        if not char or not char:FindFirstChild(Settings.AimPart) or char.Humanoid.Health <= 0 then continue end
        
        local part = char[Settings.AimPart]
        local screenPos, onScreen = WorldToScreen(part.Position)
        if not onScreen then continue end
        
        local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
        if mag < dist then
            -- wall check
            if Settings.WallCheck then
                local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                if hit and hit:IsDescendantOf(char) then
                    closest = part
                    dist = mag
                end
            else
                closest = part
                dist = mag
            end
        end
    end
    
    return closest
end

-- Mouse.Hit hook style silent aim (works better on some executors)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.AimbotEnabled and self == workspace and method == "Raycast" and checkcaller() == false then
        local target = GetClosest()
        if target then
            local origin = args[1]
            local direction = (target.Position - origin).Unit * 1000
            return oldNamecall(self, origin, direction, unpack(args, 3))
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Camera aimbot (more obvious but works on mobile when hooks fail)
RunService.RenderStepped:Connect(function()
    if not Settings.AimbotEnabled then return end
    
    local target = GetClosest()
    if target then
        local goalCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, Settings.Smoothness)
    end
end)

-- UI Toggles / Sliders

MainTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(v)
        Settings.AimbotEnabled = v
        fovCircle.Visible = v
    end
})

MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v) Settings.TeamCheck = v end
})

MainTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Callback = function(v) Settings.WallCheck = v end
})

MainTab:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = "pixels",
    CurrentValue = 150,
    Callback = function(v) Settings.FOV = v end
})

MainTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.01, 0.2},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 0.05,
    Callback = function(v) Settings.Smoothness = v end
})

MainTab:CreateToggle({
    Name = "ESP (Boxes + Names)",
    CurrentValue = false,
    Callback = function(v) Settings.ESPEnabled = v end
})

MainTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Callback = function(v) Settings.TracersEnabled = v end
})

MainTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v) Settings.HitboxExpander = v end
})

MainTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {4, 25},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 10,
    Callback = function(v) Settings.HitboxSize = v end
})

Rayfield:Notify({
    Title = "Loaded!",
    Content = "Aimbot / ESP / Hitbox ready. Be careful — many games ban fast.",
    Duration = 6
})