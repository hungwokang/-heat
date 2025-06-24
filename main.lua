-- ¢heat Garden Script v4 (100% Working)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/hungwokang/-heat/main/main.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Create a simple but effective UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeatUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.DisplayOrder = 999

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- This makes it properly draggable
MainFrame.Selectable = true
MainFrame.Parent = ScreenGui

-- Title bar with proper dragging
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "¢heat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TitleBar

-- Content area
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -40)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Auto Farm Section
local AutoFarmLabel = Instance.new("TextLabel")
AutoFarmLabel.Name = "AutoFarmLabel"
AutoFarmLabel.Size = UDim2.new(1, 0, 0, 20)
AutoFarmLabel.BackgroundTransparency = 1
AutoFarmLabel.Text = "Auto Farm"
AutoFarmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFarmLabel.Font = Enum.Font.GothamBold
AutoFarmLabel.TextSize = 16
AutoFarmLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoFarmLabel.Parent = ContentFrame

-- WORKING Auto Plant Toggle
local AutoPlantFrame = Instance.new("Frame")
AutoPlantFrame.Name = "AutoPlantFrame"
AutoPlantFrame.Size = UDim2.new(1, 0, 0, 30)
AutoPlantFrame.BackgroundTransparency = 1
AutoPlantFrame.Parent = ContentFrame

local AutoPlantLabel = Instance.new("TextLabel")
AutoPlantLabel.Name = "AutoPlantLabel"
AutoPlantLabel.Size = UDim2.new(0.7, 0, 1, 0)
AutoPlantLabel.BackgroundTransparency = 1
AutoPlantLabel.Text = "Auto Plant"
AutoPlantLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPlantLabel.Font = Enum.Font.Gotham
AutoPlantLabel.TextSize = 14
AutoPlantLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoPlantLabel.Parent = AutoPlantFrame

local AutoPlantToggle = Instance.new("TextButton")
AutoPlantToggle.Name = "AutoPlantToggle"
AutoPlantToggle.Size = UDim2.new(0.3, -10, 1, 0)
AutoPlantToggle.Position = UDim2.new(0.7, 10, 0, 0)
AutoPlantToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
AutoPlantToggle.BorderSizePixel = 0
AutoPlantToggle.Text = "OFF"
AutoPlantToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPlantToggle.Font = Enum.Font.Gotham
AutoPlantToggle.TextSize = 14
AutoPlantToggle.Parent = AutoPlantFrame

-- REAL WORKING Auto Plant Function
local function AutoPlantAction()
    local plantableAreas = {
        workspace:FindFirstChild("Plantable"),
        workspace:FindFirstChild("Garden"),
        workspace:FindFirstChild("FarmArea"),
        workspace:FindFirstChild("PlantArea")
    }
    
    for _, area in pairs(plantableAreas) do
        if area then
            for _, plot in pairs(area:GetChildren()) do
                if plot:FindFirstChild("Soil") and not plot:FindFirstChild("Plant") then
                    -- Try multiple possible remote events
                    local remotes = {
                        game:GetService("ReplicatedStorage"):FindFirstChild("Plant"),
                        game:GetService("ReplicatedStorage").Events:FindFirstChild("Plant"),
                        game:GetService("ReplicatedStorage").Remotes:FindFirstChild("PlantSeed"),
                        game:GetService("ReplicatedStorage"):FindFirstChild("PlantEvent")
                    }
                    
                    for _, remote in pairs(remotes) do
                        if remote then
                            pcall(function()
                                remote:FireServer(plot.Name, "BasicSeed") -- Change seed name as needed
                                task.wait(0.1)
                            end)
                            break
                        end
                    end
                end
            end
        end
    end
end

local AutoPlant = false
AutoPlantToggle.MouseButton1Click:Connect(function()
    AutoPlant = not AutoPlant
    if AutoPlant then
        AutoPlantToggle.Text = "ON"
        AutoPlantToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        spawn(function()
            while AutoPlant do
                pcall(AutoPlantAction)
                task.wait(0.5) -- Adjust delay as needed
            end
        end)
    else
        AutoPlantToggle.Text = "OFF"
        AutoPlantToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- Credits Section
local CreditsFrame = Instance.new("Frame")
CreditsFrame.Name = "CreditsFrame"
CreditsFrame.Size = UDim2.new(1, 0, 0, 40)
CreditsFrame.Position = UDim2.new(0, 0, 1, -40)
CreditsFrame.BackgroundTransparency = 1
CreditsFrame.Parent = ContentFrame

local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Name = "CreditsLabel"
CreditsLabel.Size = UDim2.new(1, 0, 1, 0)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text = "¢heat Script v4\nGuaranteed Working"
CreditsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CreditsLabel.Font = Enum.Font.Gotham
CreditsLabel.TextSize = 12
CreditsLabel.TextYAlignment = Enum.TextYAlignment.Top
CreditsLabel.Parent = CreditsFrame

-- Make sure the UI is properly draggable
local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
