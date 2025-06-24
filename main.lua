-- Grow a Garden Menu Script
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local LoadBtn = Instance.new("TextButton")
local PetBtn = Instance.new("TextButton")
local FarmBtn = Instance.new("TextButton")
local dragging, dragInput, dragStart, startPos

-- Enable GUI
ScreenGui.Name = "GrowGardenMenu"
ScreenGui.Parent = game.CoreGui

-- Frame Setup
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 300, 0, 220)
Frame.Active = true
Frame.Draggable = true
UICorner.Parent = Frame

-- Title
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🌱 Grow A Garden Menu"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

-- Load Button
LoadBtn.Parent = Frame
LoadBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
LoadBtn.Size = UDim2.new(0.8, 0, 0, 40)
LoadBtn.Text = "Load Main Script"
LoadBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
LoadBtn.TextColor3 = Color3.new(1,1,1)
LoadBtn.Font = Enum.Font.Gotham
LoadBtn.TextSize = 16
LoadBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hungwokang/-heat/main/main.lua"))()
end)

-- Pet Button
PetBtn.Parent = Frame
PetBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
PetBtn.Size = UDim2.new(0.8, 0, 0, 40)
PetBtn.Text = "Spawn Pet"
PetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
PetBtn.TextColor3 = Color3.new(1,1,1)
PetBtn.Font = Enum.Font.Gotham
PetBtn.TextSize = 16
PetBtn.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local pet = Instance.new("Part", workspace)
    pet.Name = "Pet"
    pet.Size = Vector3.new(1, 1, 1)
    pet.Shape = Enum.PartType.Ball
    pet.Color = Color3.fromRGB(255, 200, 0)
    pet.Anchored = false
    pet.CanCollide = false
    local weld = Instance.new("WeldConstraint", pet)
    weld.Part0 = pet
    weld.Part1 = char:WaitForChild("HumanoidRootPart")
    pet.Position = char.HumanoidRootPart.Position + Vector3.new(2, 1, 0)
end)

-- Auto Farm Button
FarmBtn.Parent = Frame
FarmBtn.Position = UDim2.new(0.1, 0, 0.8, 0)
FarmBtn.Size = UDim2.new(0.8, 0, 0, 40)
FarmBtn.Text = "Auto Farm"
FarmBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
FarmBtn.TextColor3 = Color3.new(1,1,1)
FarmBtn.Font = Enum.Font.Gotham
FarmBtn.TextSize = 16

local farming = false
FarmBtn.MouseButton1Click:Connect(function()
    farming = not farming
    FarmBtn.Text = farming and "Stop Farming" or "Auto Farm"
    while farming do
        local crops = workspace:FindFirstChild("Crops") or workspace:FindFirstChildOfClass("Folder")
        if crops then
            for _, v in ipairs(crops:GetDescendants()) do
                if v:IsA("ClickDetector") then
                    fireclickdetector(v)
                    wait(0.1)
                end
            end
        end
        wait(1)
    end
end)
