-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Colors
local colorBlack = Color3.fromRGB(15, 15, 15)
local colorPurple = Color3.fromRGB(138, 43, 226)
local colorDarkPurple = Color3.fromRGB(60, 10, 110)
local colorWhite = Color3.fromRGB(255, 255, 255)

-- UI Protection
local targetParent = (gethui and gethui()) or game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

-- Remove old versions to prevent lag/overlap
if targetParent:FindFirstChild("EmperorsScriptGui") then
    targetParent.EmperorsScriptGui:Destroy()
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmperorsScriptGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetParent

-- Universal Draggable Function (Works for Mobile & PC)
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Water Flow Effect Function
local function applyWaterFlow(guiElement)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorBlack),
        ColorSequenceKeypoint.new(0.3, colorDarkPurple),
        ColorSequenceKeypoint.new(0.5, colorPurple),
        ColorSequenceKeypoint.new(0.7, colorDarkPurple),
        ColorSequenceKeypoint.new(1, colorBlack)
    })
    gradient.Rotation = 45 -- Diagonal flow
    gradient.Parent = guiElement

    -- Animate the gradient offset to create the "flow"
    local offset = -1
    RunService.RenderStepped:Connect(function(dt)
        offset = offset + (dt * 0.4) -- Speed of the water flow
        if offset > 1 then 
            offset = -1 
        end
        gradient.Offset = Vector2.new(offset, offset)
    end)
end

-- Smaller Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 50, 0, 25)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = colorWhite
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Toggle"
toggleButton.TextColor3 = colorWhite
toggleButton.TextSize = 12

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 220, 0, 130)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
mainFrame.BackgroundColor3 = colorWhite
mainFrame.BorderSizePixel = 0

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = colorWhite
frameStroke.Thickness = 1
frameStroke.Transparency = 0.5
frameStroke.Parent = mainFrame

-- Apply features
makeDraggable(toggleButton) 
makeDraggable(mainFrame)    
applyWaterFlow(toggleButton) 
applyWaterFlow(mainFrame)    

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Text = "EMPERORS SCRIPT"
titleLabel.TextColor3 = colorWhite
titleLabel.TextSize = 16

-- Player Count Label
local playersLabel = Instance.new("TextLabel")
playersLabel.Parent = mainFrame
playersLabel.Size = UDim2.new(1, -20, 0, 30)
playersLabel.Position = UDim2.new(0, 15, 0, 45)
playersLabel.BackgroundTransparency = 1
playersLabel.Font = Enum.Font.GothamSemibold
playersLabel.Text = "Players: Loading..."
playersLabel.TextColor3 = colorWhite
playersLabel.TextSize = 14
playersLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Session Time Label (Corrected from Server Uptime)
local sessionLabel = Instance.new("TextLabel")
sessionLabel.Parent = mainFrame
sessionLabel.Size = UDim2.new(1, -20, 0, 30)
sessionLabel.Position = UDim2.new(0, 15, 0, 80)
sessionLabel.BackgroundTransparency = 1
sessionLabel.Font = Enum.Font.GothamSemibold
sessionLabel.Text = "Session: 00:00:00"
sessionLabel.TextColor3 = colorWhite
sessionLabel.TextSize = 14
sessionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Logic
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Formatting function for Time
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Background Loop
task.spawn(function()
    while task.wait(1) do
        if not screenGui.Parent then break end
        
        -- Update Player Count
        playersLabel.Text = "👥 Players: " .. #Players:GetPlayers()
        
        -- Update Session Time
        sessionLabel.Text = "⏳ Session: " .. formatTime(Workspace.DistributedGameTime)
    end
end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Water Flow Effect Function
local function applyWaterFlow(guiElement)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorBlack),
        ColorSequenceKeypoint.new(0.3, colorDarkPurple),
        ColorSequenceKeypoint.new(0.5, colorPurple),
        ColorSequenceKeypoint.new(0.7, colorDarkPurple),
        ColorSequenceKeypoint.new(1, colorBlack)
    })
    gradient.Rotation = 45 -- Diagonal flow
    gradient.Parent = guiElement

    -- Animate the gradient offset to create the "flow"
    local offset = -1
    RunService.RenderStepped:Connect(function(dt)
        offset = offset + (dt * 0.4) -- Speed of the water flow
        if offset > 1 then 
            offset = -1 
        end
        gradient.Offset = Vector2.new(offset, offset)
    end)
end

-- Smaller Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 50, 0, 25) -- Made smaller
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = colorWhite -- Base color (gradient covers this)
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Toggle"
toggleButton.TextColor3 = colorWhite
toggleButton.TextSize = 12

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 220, 0, 130)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
mainFrame.BackgroundColor3 = colorWhite -- Base color (gradient covers this)
mainFrame.BorderSizePixel = 0

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = colorWhite
frameStroke.Thickness = 1
frameStroke.Transparency = 0.5
frameStroke.Parent = mainFrame

-- Apply features
makeDraggable(toggleButton) -- Toggle is now draggable
makeDraggable(mainFrame)    -- Main menu is draggable
applyWaterFlow(toggleButton) -- Water flow on toggle
applyWaterFlow(mainFrame)    -- Water flow on main menu

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Text = "EMPERORS SCRIPT"
titleLabel.TextColor3 = colorWhite
titleLabel.TextSize = 16

-- Player Count Label
local playersLabel = Instance.new("TextLabel")
playersLabel.Parent = mainFrame
playersLabel.Size = UDim2.new(1, -20, 0, 30)
playersLabel.Position = UDim2.new(0, 15, 0, 45)
playersLabel.BackgroundTransparency = 1
playersLabel.Font = Enum.Font.GothamSemibold
playersLabel.Text = "Players: Loading..."
playersLabel.TextColor3 = colorWhite
playersLabel.TextSize = 14
playersLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Uptime Label
local uptimeLabel = Instance.new("TextLabel")
uptimeLabel.Parent = mainFrame
uptimeLabel.Size = UDim2.new(1, -20, 0, 30)
uptimeLabel.Position = UDim2.new(0, 15, 0, 80)
uptimeLabel.BackgroundTransparency = 1
uptimeLabel.Font = Enum.Font.GothamSemibold
uptimeLabel.Text = "Uptime: 00:00:00"
uptimeLabel.TextColor3 = colorWhite
uptimeLabel.TextSize = 14
uptimeLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Logic
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Formatting function for Uptime
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Background Loop
task.spawn(function()
    while task.wait(1) do
        -- Failsafe if GUI is destroyed
        if not screenGui.Parent then break end
        
        -- Player Count
        playersLabel.Text = "👥 Players: " .. #Players:GetPlayers()
        
        -- True Server Uptime (Strictly pulling from Workspace)
        -- Note: If you join a brand new server, this will start at 0.
        local serverTime = Workspace.DistributedGameTime
        uptimeLabel.Text = "⏳ Uptime: " .. formatTime(serverTime)
    end
end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 80, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = colorBlack
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Toggle"
toggleButton.TextColor3 = colorPurple
toggleButton.TextSize = 14
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = colorPurple
btnStroke.Thickness = 2
btnStroke.Parent = toggleButton

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 220, 0, 130)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
mainFrame.BackgroundColor3 = colorBlack
mainFrame.BorderSizePixel = 0
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = colorPurple
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

makeDraggable(mainFrame) -- Apply dragging to the frame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Text = "EMPERORS SCRIPT"
titleLabel.TextColor3 = colorPurple
titleLabel.TextSize = 16

-- Player Count Label
local playersLabel = Instance.new("TextLabel")
playersLabel.Parent = mainFrame
playersLabel.Size = UDim2.new(1, -20, 0, 30)
playersLabel.Position = UDim2.new(0, 15, 0, 45)
playersLabel.BackgroundTransparency = 1
playersLabel.Font = Enum.Font.GothamSemibold
playersLabel.Text = "Players: Loading..."
playersLabel.TextColor3 = colorWhite
playersLabel.TextSize = 14
playersLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Uptime Label
local uptimeLabel = Instance.new("TextLabel")
uptimeLabel.Parent = mainFrame
uptimeLabel.Size = UDim2.new(1, -20, 0, 30)
uptimeLabel.Position = UDim2.new(0, 15, 0, 80)
uptimeLabel.BackgroundTransparency = 1
uptimeLabel.Font = Enum.Font.GothamSemibold
uptimeLabel.Text = "Uptime: 00:00:00"
uptimeLabel.TextColor3 = colorWhite
uptimeLabel.TextSize = 14
uptimeLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Logic
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Formatting function
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Background Loop
task.spawn(function()
    while task.wait(1) do
        if not screenGui.Parent then break end
        playersLabel.Text = "👥 Players: " .. #Players:GetPlayers()
        uptimeLabel.Text = "⏳ Uptime: " .. formatTime(Workspace.DistributedGameTime)
    end
end)
