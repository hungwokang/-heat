-- Grow a Garden Ultimate Cheat
-- Version 2.0 - Fully Functional

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Create the GUI
local CheatsMenu = Instance.new("ScreenGui")
CheatsMenu.Name = "UltimateCheatMenu"
CheatsMenu.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 380)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderColor3 = Color3.fromRGB(120, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Parent = CheatsMenu

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Grow a Garden Ultimate Cheat"
Title.TextSize = 16
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -25, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

-- Auto Farm Section
local AutoFarmLabel = Instance.new("TextLabel")
AutoFarmLabel.Name = "AutoFarmLabel"
AutoFarmLabel.Size = UDim2.new(1, -10, 0, 20)
AutoFarmLabel.Position = UDim2.new(0, 5, 0, 35)
AutoFarmLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AutoFarmLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoFarmLabel.Font = Enum.Font.SourceSans
AutoFarmLabel.Text = "Auto Farm:"
AutoFarmLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoFarmLabel.TextSize = 14
AutoFarmLabel.Parent = MainFrame

local AutoFarmButton = Instance.new("TextButton")
AutoFarmButton.Name = "AutoFarmButton"
AutoFarmButton.Size = UDim2.new(0.45, -10, 0, 25)
AutoFarmButton.Position = UDim2.new(0, 5, 0, 55)
AutoFarmButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AutoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFarmButton.Font = Enum.Font.SourceSansBold
AutoFarmButton.Text = "Start Auto Farm"
AutoFarmButton.TextSize = 14
AutoFarmButton.Parent = MainFrame

local StopButton = Instance.new("TextButton")
StopButton.Name = "StopButton"
StopButton.Size = UDim2.new(0.45, -10, 0, 25)
StopButton.Position = UDim2.new(0.55, 5, 0, 55)
StopButton.BackgroundColor3 = Color3.fromRGB(60, 50, 50)
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.SourceSansBold
StopButton.Text = "Stop"
StopButton.TextSize = 14
StopButton.Parent = MainFrame

local ShovelButton = Instance.new("TextButton")
ShovelButton.Name = "ShovelButton"
ShovelButton.Size = UDim2.new(1, -10, 0, 25)
ShovelButton.Position = UDim2.new(0, 5, 0, 85)
ShovelButton.BackgroundColor3 = Color3.fromRGB(50, 60, 50)
ShovelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShovelButton.Font = Enum.Font.SourceSansBold
ShovelButton.Text = "Shovel [Destroy Plants]"
ShovelButton.TextSize = 14
ShovelButton.Parent = MainFrame

-- Seed Spawner Section
local SeedLabel = Instance.new("TextLabel")
SeedLabel.Name = "SeedLabel"
SeedLabel.Size = UDim2.new(1, -10, 0, 20)
SeedLabel.Position = UDim2.new(0, 5, 0, 120)
SeedLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SeedLabel.Font = Enum.Font.SourceSans
SeedLabel.Text = "Seed Spawner:"
SeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SeedLabel.TextSize = 14
SeedLabel.Parent = MainFrame

local SeedInput = Instance.new("TextBox")
SeedInput.Name = "SeedInput"
SeedInput.Size = UDim2.new(1, -10, 0, 25)
SeedInput.Position = UDim2.new(0, 5, 0, 140)
SeedInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SeedInput.PlaceholderText = "Strawberry"
SeedInput.Text = "Strawberry"
SeedInput.Font = Enum.Font.SourceSans
SeedInput.TextSize = 14
SeedInput.Parent = MainFrame

local SpawnSeedButton = Instance.new("TextButton")
SpawnSeedButton.Name = "SpawnSeedButton"
SpawnSeedButton.Size = UDim2.new(1, -10, 0, 25)
SpawnSeedButton.Position = UDim2.new(0, 5, 0, 170)
SpawnSeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SpawnSeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnSeedButton.Font = Enum.Font.SourceSansBold
SpawnSeedButton.Text = "Spawn Seed"
SpawnSeedButton.TextSize = 14
SpawnSeedButton.Parent = MainFrame

-- Pet Spawner Section
local PetLabel = Instance.new("TextLabel")
PetLabel.Name = "PetLabel"
PetLabel.Size = UDim2.new(1, -10, 0, 20)
PetLabel.Position = UDim2.new(0, 5, 0, 205)
PetLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
PetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PetLabel.Font = Enum.Font.SourceSans
PetLabel.Text = "Pet Spawner:"
PetLabel.TextXAlignment = Enum.TextXAlignment.Left
PetLabel.TextSize = 14
PetLabel.Parent = MainFrame

local PetInput = Instance.new("TextBox")
PetInput.Name = "PetInput"
PetInput.Size = UDim2.new(1, -10, 0, 25)
PetInput.Position = UDim2.new(0, 5, 0, 225)
PetInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PetInput.PlaceholderText = "Dog"
PetInput.Text = "Dog"
PetInput.Font = Enum.Font.SourceSans
PetInput.TextSize = 14
PetInput.Parent = MainFrame

local SpawnPetButton = Instance.new("TextButton")
SpawnPetButton.Name = "SpawnPetButton"
SpawnPetButton.Size = UDim2.new(1, -10, 0, 25)
SpawnPetButton.Position = UDim2.new(0, 5, 0, 255)
SpawnPetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SpawnPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnPetButton.Font = Enum.Font.SourceSansBold
SpawnPetButton.Text = "Spawn Pet"
SpawnPetButton.TextSize = 14
SpawnPetButton.Parent = MainFrame

-- Status Section
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -10, 0, 20)
StatusLabel.Position = UDim2.new(0, 5, 0, 290)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Status: Ready"
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Pet Info Section
local PetInfoLabel = Instance.new("TextLabel")
PetInfoLabel.Name = "PetInfoLabel"
PetInfoLabel.Size = UDim2.new(1, -10, 0, 60)
PetInfoLabel.Position = UDim2.new(0, 5, 0, 315)
PetInfoLabel.BackgroundTransparency = 1
PetInfoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
PetInfoLabel.Font = Enum.Font.SourceSans
PetInfoLabel.Text = "Pet Info: None"
PetInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
PetInfoLabel.TextSize = 14
PetInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
PetInfoLabel.Parent = MainFrame

-- Function to update status
local function UpdateStatus(text, color)
    StatusLabel.Text = "Status: "..text
    StatusLabel.TextColor3 = color or Color3.fromRGB(0, 255, 0)
end

-- Function to update pet info
local function UpdatePetInfo()
    local petInfo = ""
    for _, pet in ipairs(workspace:GetChildren()) do
        if pet:FindFirstChild("Owner") and pet.Owner.Value == LocalPlayer then
            local weight = pet:FindFirstChild("Weight") and pet.Weight.Value or "N/A"
            local age = pet:FindFirstChild("Age") and pet.Age.Value or "N/A"
            petInfo = petInfo..pet.Name.." ["..weight.." KG] [Age "..age.."]\n"
        end
    end
    PetInfoLabel.Text = "Pet Info:\n"..(petInfo ~= "" and petInfo or "None")
end

-- Auto Farm Variables
local autoFarming = false
local autoFarmConnection = nil

-- Find the correct remote for planting
local function FindPlantRemote()
    -- Common remote names for planting
    local possibleNames = {"PlantSeed", "Plant", "plantSeed", "Planting", "GrowPlant", "PlantRequest"}
    
    for _, name in ipairs(possibleNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            return remote
        end
    end
    
    -- Search deeper if not found
    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        if (descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction")) then
            if string.find(descendant.Name:lower(), "plant") or string.find(descendant.Name:lower(), "seed") then
                return descendant
            end
        end
    end
    
    return nil
end

-- Find the correct remote for pets
local function FindPetRemote()
    -- Common remote names for pets
    local possibleNames = {"SummonPet", "SpawnPet", "PetSummon", "EquipPet", "PetRequest"}
    
    for _, name in ipairs(possibleNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            return remote
        end
    end
    
    -- Search deeper if not found
    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        if (descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction")) then
            if string.find(descendant.Name:lower(), "pet") or string.find(descendant.Name:lower(), "summon") then
                return descendant
            end
        end
    end
    
    return nil
end

local PlantRemote = FindPlantRemote()
local PetRemote = FindPetRemote()

-- Auto Farm Functionality
AutoFarmButton.MouseButton1Click:Connect(function()
    autoFarming = true
    AutoFarmButton.BackgroundColor3 = Color3.fromRGB(50, 80, 50)
    StopButton.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    UpdateStatus("Auto Farming: ON", Color3.fromRGB(0, 255, 0))
    
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
    end
    
    autoFarmConnection = RunService.Heartbeat:Connect(function()
        if not autoFarming then return end
        
        pcall(function()
            -- Find all harvestable plants
            for _, plot in ipairs(workspace:FindFirstChild("Plots"):GetChildren()) do
                if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer then
                    local harvest = plot:FindFirstChild("Harvest")
                    if harvest then
                        -- Use both methods for maximum compatibility
                        fireproximityprompt(harvest)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, harvest, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, harvest, 1)
                    end
                end
            end
        end)
    end)
end)

StopButton.MouseButton1Click:Connect(function()
    autoFarming = false
    AutoFarmButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    StopButton.BackgroundColor3 = Color3.fromRGB(60, 50, 50)
    UpdateStatus("Auto Farming: OFF", Color3.fromRGB(255, 255, 0))
    
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
end)

-- Shovel Functionality
ShovelButton.MouseButton1Click:Connect(function()
    pcall(function()
        -- Find shovel tool
        local shovel = LocalPlayer.Backpack:FindFirstChild("Shovel") or LocalPlayer.Character:FindFirstChild("Shovel")
        if not shovel then
            UpdateStatus("Error: No shovel found", Color3.fromRGB(255, 0, 0))
            return
        end
        
        -- Equip shovel
        LocalPlayer.Character.Humanoid:EquipTool(shovel)
        
        -- Destroy plants
        for _, plot in ipairs(workspace:FindFirstChild("Plots"):GetChildren()) do
            if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer then
                local plant = plot:FindFirstChildOfClass("Model")
                if plant then
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, plant, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, plant, 1)
                    task.wait(0.1)
                end
            end
        end
        
        UpdateStatus("Plants destroyed", Color3.fromRGB(255, 150, 0))
    end)
end)

-- Seed Spawner Functionality
SpawnSeedButton.MouseButton1Click:Connect(function()
    local seedName = SeedInput.Text
    if seedName == "" then
        UpdateStatus("Error: Enter seed name", Color3.fromRGB(255, 0, 0))
        return
    end
    
    pcall(function()
        -- Method 1: Use remote event if found
        if PlantRemote then
            PlantRemote:FireServer(seedName)
            UpdateStatus("Planted: "..seedName, Color3.fromRGB(0, 255, 0))
            return
        end
        
        -- Method 2: Find and use the tool directly
        local tool = LocalPlayer.Backpack:FindFirstChild(seedName) or LocalPlayer.Character:FindFirstChild(seedName)
        if tool then
            LocalPlayer.Character.Humanoid:EquipTool(tool)
            for i = 1, 5 do
                tool:Activate()
                task.wait(0.2)
            end
            UpdateStatus("Planted (fallback): "..seedName, Color3.fromRGB(0, 200, 200))
        else
            UpdateStatus("Error: Seed not found", Color3.fromRGB(255, 0, 0))
        end
    end)
end)

-- Pet Spawner Functionality
SpawnPetButton.MouseButton1Click:Connect(function()
    local petName = PetInput.Text
    if petName == "" then
        UpdateStatus("Error: Enter pet name", Color3.fromRGB(255, 0, 0))
        return
    end
    
    pcall(function()
        -- Method 1: Use remote event if found
        if PetRemote then
            PetRemote:FireServer(petName)
            UpdateStatus("Spawned Pet: "..petName, Color3.fromRGB(0, 255, 0))
            UpdatePetInfo()
            return
        end
        
        -- Method 2: Clone from ReplicatedStorage
        local petsFolder = ReplicatedStorage:FindFirstChild("Pets") or ReplicatedStorage:FindFirstChild("PetModels")
        if petsFolder then
            local petModel = petsFolder:FindFirstChild(petName)
            if petModel then
                local clone = petModel:Clone()
                clone.Parent = workspace
                clone:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
                
                -- Set owner if possible
                if clone:FindFirstChild("Owner") then
                    clone.Owner.Value = LocalPlayer
                end
                
                UpdateStatus("Spawned (fallback): "..petName, Color3.fromRGB(0, 200, 200))
                UpdatePetInfo()
            else
                UpdateStatus("Error: Pet not found", Color3.fromRGB(255, 0, 0))
            end
        else
            UpdateStatus("Error: No pet system found", Color3.fromRGB(255, 0, 0))
        end
    end)
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    CheatsMenu:Destroy()
end)

-- Initialize pet info
UpdatePetInfo()

-- Periodically update pet info
task.spawn(function()
    while CheatsMenu.Parent do
        UpdatePetInfo()
        task.wait(5)
    end
end)

-- Initial status
if PlantRemote then
    UpdateStatus("Ready - Plant remote found", Color3.fromRGB(0, 255, 0))
else
    UpdateStatus("Ready - Using fallback methods", Color3.fromRGB(255, 150, 0))
end
