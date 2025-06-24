-- ¢heat Garden Script v3 (Fixed Draggable Menu)
-- Paste this in your executor:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/hungwokang/-heat/main/main.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Create a completely custom draggable UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeatUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- This makes it draggable
MainFrame.Selectable = true
MainFrame.Parent = ScreenGui

-- Title bar
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

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab system
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(1, 0, 0, 30)
TabsFrame.Position = UDim2.new(0, 0, 0, 30)
TabsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 70)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Create tabs
local tabs = {
    "Main",
    "Pets",
    "Teleport",
    "Player",
    "Credits"
}

local currentTab = nil

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name.."Tab"
    TabButton.Size = UDim2.new(0, 70, 1, 0)
    TabButton.Position = UDim2.new(0, (#tabs-1)*70, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    TabButton.BorderSizePixel = 0
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = TabsFrame
    
    TabButton.MouseButton1Click:Connect(function()
        if currentTab then
            currentTab.Visible = false
        end
        currentTab = ContentFrame:FindFirstChild(name.."Content")
        if currentTab then
            currentTab.Visible = true
        end
        -- Update button colors
        for _, btn in pairs(TabsFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end
        TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name.."Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 5
    TabContent.Visible = false
    TabContent.Parent = ContentFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = TabContent
    UIListLayout.Padding = UDim.new(0, 5)
    
    return TabContent
end

-- Create all tabs
for i, name in ipairs(tabs) do
    CreateTab(name)
end

-- Main Tab Content
local MainContent = ContentFrame:FindFirstChild("MainContent")
MainContent.Visible = true
currentTab = MainContent

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
AutoFarmLabel.Parent = MainContent

-- Auto Plant Toggle
local AutoPlantFrame = Instance.new("Frame")
AutoPlantFrame.Name = "AutoPlantFrame"
AutoPlantFrame.Size = UDim2.new(1, 0, 0, 30)
AutoPlantFrame.BackgroundTransparency = 1
AutoPlantFrame.Parent = MainContent

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

local AutoPlant = false
AutoPlantToggle.MouseButton1Click:Connect(function()
    AutoPlant = not AutoPlant
    if AutoPlant then
        AutoPlantToggle.Text = "ON"
        AutoPlantToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        spawn(function()
            while AutoPlant do
                -- Your auto plant code here
                pcall(function()
                    -- Example planting code (adjust for your game)
                    for _,v in pairs(workspace.Plantable:GetChildren()) do
                        if v:FindFirstChild("Soil") and not v:FindFirstChild("Plant") then
                            game:GetService("ReplicatedStorage").Events.Plant:FireServer(v.Name, "BasicSeed")
                        end
                    end
                end)
                wait(0.5)
            end
        end)
    else
        AutoPlantToggle.Text = "OFF"
        AutoPlantToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- Auto Water Toggle (similar structure to Auto Plant)
-- Auto Harvest Toggle (similar structure to Auto Plant)

-- Pets Tab Content
local PetsContent = ContentFrame:FindFirstChild("PetsContent")

-- Add similar UI elements for pet spawning

-- Teleport Tab Content
local TeleportContent = ContentFrame:FindFirstChild("TeleportContent")

-- Player Tab Content
local PlayerContent = ContentFrame:FindFirstChild("PlayerContent")

-- Credits Tab Content
local CreditsContent = ContentFrame:FindFirstChild("CreditsContent")
local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Name = "CreditsLabel"
CreditsLabel.Size = UDim2.new(1, 0, 1, 0)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text = "¢heat Script\nVersion 3.0\n\nMade for your garden game"
CreditsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CreditsLabel.Font = Enum.Font.Gotham
CreditsLabel.TextSize = 14
CreditsLabel.TextYAlignment = Enum.TextYAlignment.Top
CreditsLabel.Parent = CreditsContent

-- Make sure the UI is on top
ScreenGui.DisplayOrder = 999
