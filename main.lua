-- ¢heat v1 Menu
-- Paste this in your executor: loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSERNAME/REPO/main/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Create the main GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SpeedButton = Instance.new("TextButton")
local JumpButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")

-- GUI Properties
ScreenGui.Name = "CheatV1"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "¢heat v1"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.TextSize = 18

-- Speed Button
SpeedButton.Name = "SpeedButton"
SpeedButton.Parent = MainFrame
SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedButton.BorderSizePixel = 0
SpeedButton.Position = UDim2.new(0.1, 0, 0.2, 0)
SpeedButton.Size = UDim2.new(0.8, 0, 0, 30)
SpeedButton.Font = Enum.Font.Gotham
SpeedButton.Text = "Speed (16)"
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.TextSize = 14

local speedEnabled = false
local originalSpeed = Humanoid.WalkSpeed

SpeedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        Humanoid.WalkSpeed = 50
        SpeedButton.Text = "Speed (50)"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    else
        Humanoid.WalkSpeed = originalSpeed
        SpeedButton.Text = "Speed ("..originalSpeed..")"
        SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- Jump Button
JumpButton.Name = "JumpButton"
JumpButton.Parent = MainFrame
JumpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
JumpButton.BorderSizePixel = 0
JumpButton.Position = UDim2.new(0.1, 0, 0.4, 0)
JumpButton.Size = UDim2.new(0.8, 0, 0, 30)
JumpButton.Font = Enum.Font.Gotham
JumpButton.Text = "Jump (50)"
JumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpButton.TextSize = 14

local jumpEnabled = false
local originalJump = Humanoid.JumpPower

JumpButton.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        Humanoid.JumpPower = 100
        JumpButton.Text = "Jump (100)"
        JumpButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    else
        Humanoid.JumpPower = originalJump
        JumpButton.Text = "Jump ("..originalJump..")"
        JumpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- Close Button
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(0.1, 0, 0.8, 0)
CloseButton.Size = UDim2.new(0.8, 0, 0, 30)
CloseButton.Font = Enum.Font.Gotham
CloseButton.Text = "Close"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Handle character respawns
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    
    if speedEnabled then
        Humanoid.WalkSpeed = 50
    else
        Humanoid.WalkSpeed = originalSpeed
    end
    
    if jumpEnabled then
        Humanoid.JumpPower = 100
    else
        Humanoid.JumpPower = originalJump
    end
end)

return "¢heat v1 loaded successfully!"
