-- ¢heat v1 - Enhanced Menu
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/hungwokang/-heat/main/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ButtonContainer = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

-- GUI Configuration
ScreenGui.Name = "CheatV1"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "¢heat v1"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 20

ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Parent = MainFrame
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Position = UDim2.new(0, 10, 0, 50)
ButtonContainer.Size = UDim2.new(1, -20, 1, -60)

UIListLayout.Parent = ButtonContainer
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Button Template
local function CreateButton(text)
    local button = Instance.new("TextButton")
    button.Name = text.."Button"
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Parent = ButtonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    return button
end

-- Features
local originalSpeed = Humanoid.WalkSpeed
local originalJump = Humanoid.JumpPower

-- Speed Toggle
local speedButton = CreateButton("Speed: "..originalSpeed)
local speedEnabled = false

speedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        Humanoid.WalkSpeed = 50
        speedButton.Text = "Speed: 50"
        speedButton.BackgroundColor3 = Color3.fromRGB(70, 120, 70)
    else
        Humanoid.WalkSpeed = originalSpeed
        speedButton.Text = "Speed: "..originalSpeed
        speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end
end)

-- Jump Toggle
local jumpButton = CreateButton("Jump: "..originalJump)
local jumpEnabled = false

jumpButton.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        Humanoid.JumpPower = 100
        jumpButton.Text = "Jump: 100"
        jumpButton.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
    else
        Humanoid.JumpPower = originalJump
        jumpButton.Text = "Jump: "..originalJump
        jumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end
end)

-- Noclip Toggle
local noclipButton = CreateButton("Noclip: OFF")
local noclipEnabled = false
local noclipConnection

noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipButton.Text = "Noclip: ON"
        noclipButton.BackgroundColor3 = Color3.fromRGB(120, 70, 70)
        
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        noclipButton.Text = "Noclip: OFF"
        noclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

-- Close Button
local closeButton = CreateButton("Close Menu")
closeButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)

closeButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
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

return "¢heat v1 successfully loaded!"
