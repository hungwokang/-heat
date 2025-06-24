-- ¢heat Garden Growing Script
-- Paste this in a script executor:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/hungwokang/-heat/main/main.lua"))()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("¢heat", "Ocean")

-- Main Tab
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Auto Farm")

MainSection:NewToggle("Auto Plant", "Automatically plants seeds", function(state)
    getgenv().AutoPlant = state
    while AutoPlant do
        wait(0.5)
        for _,v in pairs(game:GetService("Workspace").Plantable:GetChildren()) do
            if v:FindFirstChild("Soil") and not v:FindFirstChild("Plant") then
                game:GetService("ReplicatedStorage").Events.Plant:FireServer(v.Name, "BasicSeed") -- Change seed type as needed
            end
        end
    end
end)

MainSection:NewToggle("Auto Water", "Automatically waters plants", function(state)
    getgenv().AutoWater = state
    while AutoWater do
        wait(1)
        for _,v in pairs(game:GetService("Workspace").Plants:GetChildren()) do
            if v:FindFirstChild("Water") and v.Water.Value < 100 then
                game:GetService("ReplicatedStorage").Events.Water:FireServer(v.Name)
            end
        end
    end
end)

MainSection:NewToggle("Auto Harvest", "Automatically harvests plants", function(state)
    getgenv().AutoHarvest = state
    while AutoHarvest do
        wait(1)
        for _,v in pairs(game:GetService("Workspace").Plants:GetChildren()) do
            if v:FindFirstChild("Grow") and v.Grow.Value >= 100 then
                game:GetService("ReplicatedStorage").Events.Harvest:FireServer(v.Name)
            end
        end
    end
end)

-- Pets Tab
local PetsTab = Window:NewTab("Pets")
local PetsSection = PetsTab:NewSection("Pet Spawner")

local petOptions = {}
-- Add pet names from your game here
for _,pet in pairs({"CommonPet", "RarePet", "EpicPet", "LegendaryPet"}) do -- Replace with actual pet names
    table.insert(petOptions, pet)
end

PetsSection:NewDropdown("Select Pet", "Choose a pet to spawn", petOptions, function(currentPet)
    getgenv().SelectedPet = currentPet
end)

PetsSection:NewToggle("Auto Spawn Pet", "Automatically spawns selected pet", function(state)
    getgenv().AutoSpawnPet = state
    while AutoSpawnPet and SelectedPet do
        game:GetService("ReplicatedStorage").Events.SpawnPet:FireServer(SelectedPet)
        wait(10) -- Adjust cooldown as needed
    end
end)

-- Player Tab
local PlayerTab = Window:NewTab("Player")
local PlayerSection = PlayerTab:NewSection("Player Mods")

PlayerSection:NewSlider("Walk Speed", "Changes player walkspeed", 250, 16, function(s)
    game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

PlayerSection:NewSlider("Jump Power", "Changes player jump power", 250, 50, function(s)
    game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = s
end)

-- Teleport Tab
local TeleportTab = Window:NewTab("Teleport")
local TeleportSection = TeleportTab:NewSection("Locations")

local locations = {
    ["Garden"] = CFrame.new(0, 10, 0), -- Replace with actual coordinates
    ["Shop"] = CFrame.new(50, 10, 0),  -- Replace with actual coordinates
    ["Bank"] = CFrame.new(-50, 10, 0)  -- Replace with actual coordinates
}

for name, cf in pairs(locations) do
    TeleportSection:NewButton(name, "Teleports you to "..name, function()
        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = cf
    end)
end

-- Misc Tab
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Other Features")

MiscSection:NewButton("Collect All Coins", "Collects nearby coins", function()
    for _,v in pairs(game:GetService("Workspace").Coins:GetChildren()) do
        if v:IsA("BasePart") then
            firetouchinterest(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, v, 0)
            firetouchinterest(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, v, 1)
        end
    end
end)

MiscSection:NewToggle("Auto Collect Coins", "Automatically collects coins", function(state)
    getgenv().AutoCollectCoins = state
    while AutoCollectCoins do
        wait(1)
        for _,v in pairs(game:GetService("Workspace").Coins:GetChildren()) do
            if v:IsA("BasePart") then
                firetouchinterest(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, v, 0)
                firetouchinterest(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, v, 1)
            end
        end
    end
end)

-- Credits
local CreditsTab = Window:NewTab("Credits")
local CreditsSection = CreditsTab:NewSection("Made by ¢heat")
CreditsSection:NewLabel("Discord: discord.gg/example")
CreditsSection:NewLabel("YouTube: youtube.com/example")
