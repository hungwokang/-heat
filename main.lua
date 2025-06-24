-- Grow a Garden Ultimate Cheat v3.0
-- Includes Pet Customization Features

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
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
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

-- Currency Display
local CurrencyLabel = Instance.new("TextLabel")
CurrencyLabel.Name = "CurrencyLabel"
CurrencyLabel.Size = UDim2.new(1, -10, 0, 20)
CurrencyLabel.Position = UDim2.new(0, 5, 0, 35)
CurrencyLabel.BackgroundTransparency = 1
CurrencyLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
CurrencyLabel.Font = Enum.Font.SourceSansBold
CurrencyLabel.Text = "ZYSUME CURRENCY: 0.0"
CurrencyLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrencyLabel.TextSize = 14
CurrencyLabel.Parent = MainFrame

-- Minigames Button
local MinigamesButton = Instance.new("TextButton")
MinigamesButton.Name = "MinigamesButton"
MinigamesButton.Size = UDim2.new(1, -10, 0, 25)
MinigamesButton.Position = UDim2.new(0, 5, 0, 60)
MinigamesButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinigamesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinigamesButton.Font = Enum.Font.SourceSansBold
MinigamesButton.Text = "Play Minigames [Earn Currency]"
MinigamesButton.TextSize = 14
MinigamesButton.Parent = MainFrame

-- Pet Spawner Section
local PetSpawnerLabel = Instance.new("TextLabel")
PetSpawnerLabel.Name = "PetSpawnerLabel"
PetSpawnerLabel.Size = UDim2.new(1, -10, 0, 20)
PetSpawnerLabel.Position = UDim2.new(0, 5, 0, 95)
PetSpawnerLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
PetSpawnerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PetSpawnerLabel.Font = Enum.Font.SourceSansBold
PetSpawnerLabel.Text = "PET SPAWNER"
PetSpawnerLabel.TextSize = 14
PetSpawnerLabel.Parent = MainFrame

local SelectPetLabel = Instance.new("TextLabel")
SelectPetLabel.Name = "SelectPetLabel"
SelectPetLabel.Size = UDim2.new(1, -10, 0, 20)
SelectPetLabel.Position = UDim2.new(0, 5, 0, 120)
SelectPetLabel.BackgroundTransparency = 1
SelectPetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SelectPetLabel.Font = Enum.Font.SourceSans
SelectPetLabel.Text = "Select Pet"
SelectPetLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectPetLabel.TextSize = 14
SelectPetLabel.Parent = MainFrame

local PetInput = Instance.new("TextBox")
PetInput.Name = "PetInput"
PetInput.Size = UDim2.new(1, -10, 0, 25)
PetInput.Position = UDim2.new(0, 5, 0, 140)
PetInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PetInput.PlaceholderText = "Echo Frog"
PetInput.Text = "Echo Frog"
PetInput.Font = Enum.Font.SourceSans
PetInput.TextSize = 14
PetInput.Parent = MainFrame

-- Pet Customization
local SizeLabel = Instance.new("TextLabel")
SizeLabel.Name = "SizeLabel"
SizeLabel.Size = UDim2.new(0.5, -10, 0, 20)
SizeLabel.Position = UDim2.new(0, 5, 0, 175)
SizeLabel.BackgroundTransparency = 1
SizeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SizeLabel.Font = Enum.Font.SourceSans
SizeLabel.Text = "Pet Size Multiplier:"
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
SizeLabel.TextSize = 14
SizeLabel.Parent = MainFrame

local SizeInput = Instance.new("TextBox")
SizeInput.Name = "SizeInput"
SizeInput.Size = UDim2.new(0.2, -5, 0, 25)
SizeInput.Position = UDim2.new(0.5, 5, 0, 175)
SizeInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeInput.Text = "1"
SizeInput.Font = Enum.Font.SourceSans
SizeInput.TextSize = 14
SizeInput.Parent = MainFrame

local WeightLabel = Instance.new("TextLabel")
WeightLabel.Name = "WeightLabel"
WeightLabel.Size = UDim2.new(0.5, -10, 0, 20)
WeightLabel.Position = UDim2.new(0, 5, 0, 205)
WeightLabel.BackgroundTransparency = 1
WeightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
WeightLabel.Font = Enum.Font.SourceSans
WeightLabel.Text = "Pet Weight:"
WeightLabel.TextXAlignment = Enum.TextXAlignment.Left
WeightLabel.TextSize = 14
WeightLabel.Parent = MainFrame

local WeightInput = Instance.new("TextBox")
WeightInput.Name = "WeightInput"
WeightInput.Size = UDim2.new(0.2, -5, 0, 25)
WeightInput.Position = UDim2.new(0.5, 5, 0, 205)
WeightInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
WeightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WeightInput.Text = "1"
WeightInput.Font = Enum.Font.SourceSans
WeightInput.TextSize = 14
WeightInput.Parent = MainFrame

local AgeLabel = Instance.new("TextLabel")
AgeLabel.Name = "AgeLabel"
AgeLabel.Size = UDim2.new(0.5, -10, 0, 20)
AgeLabel.Position = UDim2.new(0, 5, 0, 235)
AgeLabel.BackgroundTransparency = 1
AgeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AgeLabel.Font = Enum.Font.SourceSans
AgeLabel.Text = "Pet Age:"
AgeLabel.TextXAlignment = Enum.TextXAlignment.Left
AgeLabel.TextSize = 14
AgeLabel.Parent = MainFrame

local AgeInput = Instance.new("TextBox")
AgeInput.Name = "AgeInput"
AgeInput.Size = UDim2.new(0.2, -5, 0, 25)
AgeInput.Position = UDim2.new(0.5, 5, 0, 235)
AgeInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AgeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
AgeInput.Text = "1"
AgeInput.Font = Enum.Font.SourceSans
AgeInput.TextSize = 14
AgeInput.Parent = MainFrame

local SpawnPetButton = Instance.new("TextButton")
SpawnPetButton.Name = "SpawnPetButton"
SpawnPetButton.Size = UDim2.new(1, -10, 0, 30)
SpawnPetButton.Position = UDim2.new(0, 5, 0, 270)
SpawnPetButton.BackgroundColor3 = Color3.fromRGB(80, 50, 80)
SpawnPetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnPetButton.Font = Enum.Font.SourceSansBold
SpawnPetButton.Text = "SPAWN THE PET"
SpawnPetButton.TextSize = 16
SpawnPetButton.Parent = MainFrame

-- Status Section
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -10, 0, 40)
StatusLabel.Position = UDim2.new(0, 5, 0, 310)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Status: Ready\nPet Info: None"
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextSize = 14
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Parent = MainFrame

-- Function to update status
local function UpdateStatus(text, color)
    local currentText = StatusLabel.Text
    local lines = currentText:split("\n")
    lines[1] = "Status: "..text
    StatusLabel.Text = table.concat(lines, "\n")
    StatusLabel.TextColor3 = color or Color3.fromRGB(0, 255, 0)
end

-- Function to update pet info
local function UpdatePetInfo()
    local petInfo = {}
    for _, pet in ipairs(workspace:GetChildren()) do
        if pet:FindFirstChild("Owner") and pet.Owner.Value == LocalPlayer then
            local weight = pet:FindFirstChild("Weight") and pet.Weight.Value or "N/A"
            local age = pet:FindFirstChild("Age") and pet.Age.Value or "N/A"
            local size = pet:FindFirstChild("Size") and pet.Size.Value or "N/A"
            table.insert(petInfo, string.format("%s [%s KG] [Age %s] [Size %s]", pet.Name, weight, age, size))
        end
    end
    
    local currentText = StatusLabel.Text
    local lines = currentText:split("\n")
    lines[2] = "Pet Info: "..(#petInfo > 0 and table.concat(petInfo, "\n") or "None")
    StatusLabel.Text = table.concat(lines, "\n")
end

-- Function to update currency display
local function UpdateCurrency()
    pcall(function()
        -- Try to find the player's currency value
        local currency = 0
        if LocalPlayer:FindFirstChild("Zysume") then
            currency = LocalPlayer.Zysume.Value
        elseif LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Zysume") then
            currency = LocalPlayer.leaderstats.Zysume.Value
        end
        
        CurrencyLabel.Text = "ZYSUME CURRENCY: "..tostring(currency)
    end)
end

-- Find the correct remote for pets
local function FindPetRemote()
    -- Common remote names for pets
    local possibleNames = {
        "SummonPet", "SpawnPet", "PetSummon", "EquipPet", "PetRequest",
        "CreatePet", "GeneratePet", "AddPet", "NewPet"
    }
    
    -- First check ReplicatedStorage
    for _, name in ipairs(possibleNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            return remote
        end
    end
    
    -- Then check ServerScriptService
    local serverScriptService = game:GetService("ServerScriptService")
    for _, name in ipairs(possibleNames) do
        local remote = serverScriptService:FindFirstChild(name)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            return remote
        end
    end
    
    -- Finally search through all descendants
    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        if (descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction")) then
            if string.find(descendant.Name:lower(), "pet") or 
               string.find(descendant.Name:lower(), "summon") or
               string.find(descendant.Name:lower(), "spawn") then
                return descendant
            end
        end
    end
    
    return nil
end

local PetRemote = FindPetRemote()

-- Minigames Button Functionality
MinigamesButton.MouseButton1Click:Connect(function()
    pcall(function()
        -- Try to find minigame remote
        local minigameRemote = ReplicatedStorage:FindFirstChild("StartMinigame") or
                              ReplicatedStorage:FindFirstChild("PlayMinigame") or
                              ReplicatedStorage:FindFirstChild("RequestMinigame")
        
        if minigameRemote then
            minigameRemote:FireServer()
            UpdateStatus("Started minigame", Color3.fromRGB(0, 255, 255))
        else
            -- Try to find minigame parts in workspace
            for _, part in ipairs(workspace:GetChildren()) do
                if part.Name:find("Minigame") and part:IsA("BasePart") then
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 1)
                    UpdateStatus("Triggered minigame (fallback)", Color3.fromRGB(0, 200, 200))
                    return
                end
            end
            UpdateStatus("Error: No minigame found", Color3.fromRGB(255, 0, 0))
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
    
    local sizeMultiplier = tonumber(SizeInput.Text) or 1
    local weight = tonumber(WeightInput.Text) or 1
    local age = tonumber(AgeInput.Text) or 1
    
    pcall(function()
        -- Method 1: Use remote event if found
        if PetRemote then
            -- Try different argument combinations
            local success, _ = pcall(function()
                PetRemote:FireServer(petName, sizeMultiplier, weight, age)
                UpdateStatus("Spawned: "..petName, Color3.fromRGB(0, 255, 0))
                UpdatePetInfo()
            end)
            
            if not success then
                PetRemote:FireServer(petName, {
                    Size = sizeMultiplier,
                    Weight = weight,
                    Age = age
                })
                UpdateStatus("Spawned (alt): "..petName, Color3.fromRGB(0, 200, 200))
                UpdatePetInfo()
            end
            return
        end
        
        -- Method 2: Clone from ReplicatedStorage and modify
        local petsFolder = ReplicatedStorage:FindFirstChild("Pets") or 
                          ReplicatedStorage:FindFirstChild("PetModels") or
                          ReplicatedStorage:FindFirstChild("Animals")
        
        if petsFolder then
            local petModel = petsFolder:FindFirstChild(petName, true) -- recursive search
            if petModel then
                local clone = petModel:Clone()
                clone.Parent = workspace
                clone:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
                
                -- Set properties
                if clone:FindFirstChild("Owner") then
                    clone.Owner.Value = LocalPlayer
                end
                
                -- Add or modify size/weight/age values
                local sizeValue = Instance.new("NumberValue")
                sizeValue.Name = "Size"
                sizeValue.Value = sizeMultiplier
                sizeValue.Parent = clone
                
                local weightValue = Instance.new("NumberValue")
                weightValue.Name = "Weight"
                weightValue.Value = weight
                weightValue.Parent = clone
                
                local ageValue = Instance.new("NumberValue")
                ageValue.Name = "Age"
                ageValue.Value = age
                ageValue.Parent = clone
                
                -- Apply size multiplier
                for _, part in ipairs(clone:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size * sizeMultiplier
                    end
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

-- Initialize displays
UpdateCurrency()
UpdatePetInfo()

-- Periodically update displays
task.spawn(function()
    while CheatsMenu.Parent do
        UpdateCurrency()
        UpdatePetInfo()
        task.wait(5)
    end
end)

-- Initial status
if PetRemote then
    UpdateStatus("Ready - Pet remote found", Color3.fromRGB(0, 255, 0))
else
    UpdateStatus("Ready - Using fallback methods", Color3.fromRGB(255, 150, 0))
end
