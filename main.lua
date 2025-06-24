-- ¢heat | Simple Grow a Garden GUI

--[[
    Instructions:
    1. Paste this entire script into your executor.
    2. Execute the script.
    3. A small menu will appear on your screen.
    4. Drag the menu by its title bar to move it.
]]

-- Create the main window (ScreenGui)
local CheatsMenu = Instance.new("ScreenGui")
CheatsMenu.Name = "CheatMenu"
CheatsMenu.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
CheatsMenu.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Create the main frame (the background of the menu)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 260) -- Small size
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0) -- Position on the left side
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
Title.Text = "¢heat"
Title.TextSize = 16
Title.Parent = MainFrame

-- Section for Auto Farming
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

-- Section for Seed Spawner
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
SeedInput.PlaceholderText = "Type seed name (e.g., Carrot)"
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

-- Section for Pet Spawner
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
PetInput.PlaceholderText = "Type pet name (e.g., Bee)"
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

-- --- SCRIPT FUNCTIONALITY ---
-- NOTE: The code below requires finding the game's actual RemoteEvents.
-- These are placeholders to show how the buttons would work.
-- Real working functions depend on the game's internal structure.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Placeholder for the game's main remote folder
local GameRemotes = ReplicatedStorage:FindFirstChild("Default") -- This is a common name, but might be different

-- AUTO FARM
local autoFarming = false
AutoFarmButton.MouseButton1Click:Connect(function()
    autoFarming = not autoFarming
    if autoFarming then
        AutoFarmButton.Text = "Stop Auto Farm"
        -- This is a simplified loop. A real script would be more complex.
        while autoFarming do
            pcall(function()
                for i, v in pairs(workspace.Plots:GetChildren()) do
                    if v.Owner.Value == LocalPlayer.Name and v:FindFirstChild("Harvest") then
                        fireproximityprompt(v.Harvest)
                    end
                end
            end)
            task.wait(2)
        end
    else
        AutoFarmButton.Text = "Start Auto Farm"
    end
end)

-- SEED SPAWNER
SpawnSeedButton.MouseButton1Click:Connect(function()
    local seedName = SeedInput.Text
    if seedName ~= "" and GameRemotes then
        pcall(function()
            -- This is a guess. The remote event name and arguments will be different.
            GameRemotes.Plant:FireServer(seedName) 
        end)
    end
end)

-- PET SPAWNER
SpawnPetButton.MouseButton1Click:Connect(function()
    local petName = PetInput.Text
    if petName ~= "" and GameRemotes then
        pcall(function()
            -- This is a guess. The remote event name for spawning pets is unknown.
            GameRemotes.SpawnPet:FireServer(petName)
        end)
    end
end)

