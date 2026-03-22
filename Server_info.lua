-- Emperors Script - Optimized for Delta / Mobile Execution
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Colors (Black & Purple Theme)
local colorBlack = Color3.fromRGB(15, 15, 15)
local colorPurple = Color3.fromRGB(120, 0, 255)
local colorWhite = Color3.fromRGB(255, 255, 255)

-- UI Protection (gethui is best for Delta)
local targetParent = (gethui and gethui()) or game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

-- Remove old versions to prevent lag
if targetParent:FindFirstChild("EmperorsScriptGui") then
    targetParent.EmperorsScriptGui:Destroy()
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmperorsScriptGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetParent

-- Draggable Function (For Mobile/Delta users)
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
