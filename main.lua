-- ¢heat | Grow a Garden Advanced GUI

--[[
    Instructions:
    1. Paste this entire script into your executor (Synapse, Krnl, etc.)
    2. Execute the script
    3. Use the GUI to activate features
]]

-- Create the main window
local CheatsMenu = Instance.new("ScreenGui")
CheatsMenu.Name = "CheatMenu"
CheatsMenu.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
CheatsMenu.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderColor3 = Color3.fromRGB(120, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Parent = CheatsMenu

-- Title bar
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Grow a Garden ¢heat"
Title.TextSize = 16
Title.Parent = MainFrame

-- Close button
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

CloseButton.MouseButton1Click:Connect(function()
    CheatsMenu:Destroy()
end)

-- Auto Farm Section
local AutoFarmLabel = Instance.new("TextLabel")
AutoFarmLabel.Name = "AutoFarmLabel"
AutoFarmLabel.Size = UDim2.new(1, -10, 0, 20)
AutoFarmLabel.Position = UDim2.new(0, 5, 0, 35)
AutoFarmLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AutoFarmLabel.BorderSizePixel = 0
AutoFarmLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoFarmLabel.Font = Enum.Font.SourceSans
AutoFarmLabel.Text = "Auto Farm:"
AutoFarmLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoFarmLabel.TextSize = 14
AutoFarmLabel.Parent = MainFrame

local AutoFarmButton = Instance.new("TextButton")
AutoFarmButton.Name = "AutoFarmButton"
AutoFarmButton.Size = UDim2.new(1, -10, 0, 25)
AutoFarmButton.Position = UDim2.new(0, 5, 0, 55)
AutoFarmButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AutoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFarmButton.Font = Enum.Font.SourceSansBold
AutoFarmButton.Text = "Start Auto Farm"
AutoFarmButton.TextSize = 14
AutoFarmButton.Parent = MainFrame

-- Seed Spawner Section
local SeedLabel = Instance.new("TextLabel")
SeedLabel.Name = "SeedLabel"
SeedLabel.Size = UDim2.new(1, -10, 0, 20)
SeedLabel.Position = UDim2.new(0, 5, 0, 90)
SeedLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SeedLabel.BorderSizePixel = 0
SeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SeedLabel.Font = Enum.Font.SourceSans
SeedLabel.Text = "Seed Spawner:"
SeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SeedLabel.TextSize = 14
SeedLabel.Parent = MainFrame

local SeedInput = Instance.new("TextBox")
SeedInput.Name = "SeedInput"
SeedInput.Size = UDim2.new(1, -10, 0, 25)
SeedInput.Position = UDim2.new(0, 5, 0, 110)
SeedInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SeedInput.PlaceholderText = "Seed name (e.g., Carrot)"
SeedInput.Font = Enum.Font.SourceSans
SeedInput.TextSize = 14
SeedInput.Parent = MainFrame

local SpawnSeedButton = Instance.new("TextButton")
SpawnSeedButton.Name = "SpawnSeedButton"
SpawnSeedButton.Size = UDim2.new(1, -10, 0, 25)
SpawnSeedButton.Position = UDim2.new(0, 5, 0, 140)
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
PetLabel.Position = UDim2.new(0, 5, 0, 175)
PetLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
PetLabel.BorderSizePixel = 0
PetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PetLabel.Font = Enum.Font.SourceSans
PetLabel.Text = "Pet Spawner:"
PetLabel.TextXAlignment = Enum.TextXAlignment.Left
PetLabel.TextSize = 14
PetLabel.Parent = MainFrame

local PetInput = Instance.new("TextBox")
PetInput.Name = "PetInput"
PetInput.Size = UDim2.new(1, -10, 0, 25)
PetInput.Position = UDim2.new(0, 5, 0, 195)
PetInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PetInput.PlaceholderText = "Pet name (e.g., Bee)"
PetInput.Font = Enum.Font.SourceSans
PetInput.TextSize = 14
PetInput.Parent = MainFrame

local SpawnPetButton = Instance.new("TextButton")
SpawnPetButton.Name = "SpawnPetButton"
SpawnPetButton.Size = UDim2.new(1, -10, 0, 25)
SpawnPetButton.Position = UDim2.new(0, 5, 0, 225)
SpawnPetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SpawnPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnPetButton.Font = Enum.Font.SourceSansBold
SpawnPetButton.Text = "Spawn Pet"
SpawnPetButton.TextSize = 14
SpawnPetButton.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -10, 0, 20)
StatusLabel.Position = UDim2.new(0, 5, 0, 260)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Status: Ready"
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- ===== ACTUAL SCRIPT FUNCTIONALITY =====

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Find the game's remotes (with bypass)
local function FindRemotes()
    local remotes = {}
    
    -- Search in common locations
    for _, location in ipairs({ReplicatedStorage, workspace, game:GetService("ServerScriptService")}) do
        for _, obj in ipairs(location:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                remotes[obj.Name] = obj
            end
        end
    end
    
    return remotes
end

local GameRemotes = FindRemotes()

-- Update status
local function UpdateStatus(text, color)
    StatusLabel.Text = "Status: "..text
    StatusLabel.TextColor3 = color or Color3.fromRGB(0, 255, 0)
end

-- Auto Farm
local autoFarming = false
local autoFarmConnection = nil

AutoFarmButton.MouseButton1Click:Connect(function()
    autoFarming = not autoFarming
    
    if autoFarming then
        AutoFarmButton.Text = "Stop Auto Farm"
        UpdateStatus("Auto Farming Active", Color3.fromRGB(0, 255, 0))
        
        -- Optimized auto-farm with plot detection
        autoFarmConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                -- Check if plots exist
                local plots = workspace:FindFirstChild("Plots")
                if not plots then
                    UpdateStatus("Error: No plots found", Color3.fromRGB(255, 0, 0))
                    return
                end
                
                -- Harvest all ready plants
                for _, plot in ipairs(plots:GetChildren()) do
                    if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name then
                        local harvest = plot:FindFirstChild("Harvest")
                        if harvest then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, harvest, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, harvest, 1)
                        end
                    end
                end
            end)
        end)
    else
        AutoFarmButton.Text = "Start Auto Farm"
        UpdateStatus("Auto Farming Stopped", Color3.fromRGB(255, 255, 0))
        if autoFarmConnection then
            autoFarmConnection:Disconnect()
            autoFarmConnection = nil
        end
    end
end)

-- Seed Spawner
SpawnSeedButton.MouseButton1Click:Connect(function()
    local seedName = SeedInput.Text
    if seedName == "" then
        UpdateStatus("Error: Enter seed name", Color3.fromRGB(255, 0, 0))
        return
    end
    
    pcall(function()
        -- Try different remote events that might handle planting
        local possibleRemotes = {"Plant", "plantSeed", "PlantSeed", "Planting", "PlantRequest"}
        
        for _, remoteName in ipairs(possibleRemotes) do
            if GameRemotes[remoteName] then
                GameRemotes[remoteName]:FireServer(seedName)
                UpdateStatus("Planted: "..seedName, Color3.fromRGB(0, 255, 0))
                return
            end
        end
        
        -- Fallback method if no remote is found
        local tool = LocalPlayer.Backpack:FindFirstChild(seedName) or LocalPlayer.Character:FindFirstChild(seedName)
        if tool then
            LocalPlayer.Character.Humanoid:EquipTool(tool)
            for i = 1, 10 do -- Try multiple times in case of delays
                tool:Activate()
                wait(0.1)
            end
            UpdateStatus("Planted (fallback): "..seedName, Color3.fromRGB(0, 200, 200))
        else
            UpdateStatus("Error: Seed not found", Color3.fromRGB(255, 0, 0))
        end
    end)
end)

-- Pet Spawner
SpawnPetButton.MouseButton1Click:Connect(function()
    local petName = PetInput.Text
    if petName == "" then
        UpdateStatus("Error: Enter pet name", Color3.fromRGB(255, 0, 0))
        return
    end
    
    pcall(function()
        -- Try different remote events that might handle pets
        local possibleRemotes = {"SummonPet", "SpawnPet", "PetSummon", "EquipPet", "PetRequest"}
        
        for _, remoteName in ipairs(possibleRemotes) do
            if GameRemotes[remoteName] then
                GameRemotes[remoteName]:FireServer(petName)
                UpdateStatus("Spawned Pet: "..petName, Color3.fromRGB(0, 255, 0))
                return
            end
        end
        
        -- Fallback method if no remote is found
        local petFolder = ReplicatedStorage:FindFirstChild("Pets") or ReplicatedStorage:FindFirstChild("Pet")
        if petFolder then
            local petModel = petFolder:FindFirstChild(petName)
            if petModel then
                local clone = petModel:Clone()
                clone.Parent = workspace
                clone:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, -5))
                UpdateStatus("Spawned (fallback): "..petName, Color3.fromRGB(0, 200, 200))
            else
                UpdateStatus("Error: Pet not found", Color3.fromRGB(255, 0, 0))
            end
        else
            UpdateStatus("Error: No pet system found", Color3.fromRGB(255, 0, 0))
        end
    end)
end)

-- Initial status
UpdateStatus("Ready - Remotes Found: "..#GameRemotes, Color3.fromRGB(0, 255, 0))
