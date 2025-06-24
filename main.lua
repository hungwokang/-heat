-- ¢heat Garden Growing Script v2
-- Paste this in a script executor:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/hungwokang/-heat/main/main.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Create the UI library with draggable functionality
local function CreateDraggableUI()
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library.CreateLib("¢heat", "Ocean")
    
    -- Make the main frame draggable
    local MainFrame = Window.MainFrame
    local dragToggle = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local Delta = input.Position - dragStart
        local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
        MainFrame.Position = Position
    end
    
    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)

    -- Main Tab
    local MainTab = Window:NewTab("Main")
    local MainSection = MainTab:NewSection("Auto Farm")
    
    -- Improved Auto Plant with error handling
    MainSection:NewToggle("Auto Plant", "Automatically plants seeds", function(state)
        getgenv().AutoPlant = state
        spawn(function()
            while AutoPlant and task.wait(0.5) do
                pcall(function()
                    local plantable = workspace:FindFirstChild("Plantable") or workspace:FindFirstChild("Garden") or workspace:FindFirstChild("PlantArea")
                    if plantable then
                        for _,v in pairs(plantable:GetChildren()) do
                            if v:FindFirstChild("Soil") and not v:FindFirstChild("Plant") then
                                local args = {
                                    [1] = v.Name,
                                    [2] = "BasicSeed" -- Change to your seed name
                                }
                                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("PlantEvent") or 
                                             game:GetService("ReplicatedStorage").Events:FindFirstChild("Plant") or
                                             game:GetService("ReplicatedStorage").Remotes:FindFirstChild("PlantSeed")
                                if remote then
                                    remote:FireServer(unpack(args))
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)
    
    -- Improved Auto Water with error handling
    MainSection:NewToggle("Auto Water", "Automatically waters plants", function(state)
        getgenv().AutoWater = state
        spawn(function()
            while AutoWater and task.wait(1) do
                pcall(function()
                    local plants = workspace:FindFirstChild("Plants") or workspace:FindFirstChild("GardenPlants")
                    if plants then
                        for _,v in pairs(plants:GetChildren()) do
                            if v:FindFirstChild("Water") and v.Water.Value < 100 then
                                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("WaterEvent") or 
                                             game:GetService("ReplicatedStorage").Events:FindFirstChild("Water") or
                                             game:GetService("ReplicatedStorage").Remotes:FindFirstChild("WaterPlant")
                                if remote then
                                    remote:FireServer(v.Name)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)
    
    -- Improved Auto Harvest with error handling
    MainSection:NewToggle("Auto Harvest", "Automatically harvests plants", function(state)
        getgenv().AutoHarvest = state
        spawn(function()
            while AutoHarvest and task.wait(1) do
                pcall(function()
                    local plants = workspace:FindFirstChild("Plants") or workspace:FindFirstChild("GardenPlants")
                    if plants then
                        for _,v in pairs(plants:GetChildren()) do
                            if v:FindFirstChild("Grow") and v.Grow.Value >= 100 then
                                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("HarvestEvent") or 
                                             game:GetService("ReplicatedStorage").Events:FindFirstChild("Harvest") or
                                             game:GetService("ReplicatedStorage").Remotes:FindFirstChild("HarvestPlant")
                                if remote then
                                    remote:FireServer(v.Name)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)
    
    -- Pets Tab with improved spawner
    local PetsTab = Window:NewTab("Pets")
    local PetsSection = PetsTab:NewSection("Pet Spawner")
    
    local petOptions = {"CommonPet", "RarePet", "EpicPet", "LegendaryPet"} -- Replace with actual pet names
    PetsSection:NewDropdown("Select Pet", "Choose a pet to spawn", petOptions, function(currentPet)
        getgenv().SelectedPet = currentPet
    end)
    
    PetsSection:NewToggle("Auto Spawn Pet", "Automatically spawns selected pet", function(state)
        getgenv().AutoSpawnPet = state
        spawn(function()
            while AutoSpawnPet and SelectedPet and task.wait(10) do
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("PetEvent") or 
                                 game:GetService("ReplicatedStorage").Events:FindFirstChild("SpawnPet") or
                                 game:GetService("ReplicatedStorage").Remotes:FindFirstChild("SummonPet")
                    if remote then
                        remote:FireServer(SelectedPet)
                    end
                end)
            end
        end)
    end)
    
    -- Player Tab with persistence
    local PlayerTab = Window:NewTab("Player")
    local PlayerSection = PlayerTab:NewSection("Player Mods")
    
    PlayerSection:NewSlider("Walk Speed", "Changes player walkspeed", 250, 16, function(s)
        Player.Character:WaitForChild("Humanoid").WalkSpeed = s
    end)
    
    PlayerSection:NewSlider("Jump Power", "Changes player jump power", 250, 50, function(s)
        Player.Character:WaitForChild("Humanoid").JumpPower = s
    end)
    
    -- Character added event to maintain speeds
    Player.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid")
        if getgenv().WalkSpeed then
            humanoid.WalkSpeed = getgenv().WalkSpeed
        end
        if getgenv().JumpPower then
            humanoid.JumpPower = getgenv().JumpPower
        end
    end)
    
    -- Teleport Tab with coordinates display
    local TeleportTab = Window:NewTab("Teleport")
    local TeleportSection = TeleportTab:NewSection("Locations")
    
    local locations = {
        ["Garden"] = CFrame.new(0, 10, 0),
        ["Shop"] = CFrame.new(50, 10, 0),
        ["Bank"] = CFrame.new(-50, 10, 0)
    }
    
    for name, cf in pairs(locations) do
        TeleportSection:NewButton(name, "Teleports you to "..name, function()
            pcall(function()
                Player.Character:WaitForChild("HumanoidRootPart").CFrame = cf
            end)
        end)
    end
    
    -- Add current position button
    TeleportSection:NewButton("Copy Position", "Copies your current position", function()
        local pos = Player.Character:WaitForChild("HumanoidRootPart").Position
        setclipboard(string.format("CFrame.new(%d, %d, %d)", pos.X, pos.Y, pos.Z))
    end)
    
    -- Misc Tab with improved coin collection
    local MiscTab = Window:NewTab("Misc")
    local MiscSection = MiscTab:NewSection("Other Features")
    
    MiscSection:NewButton("Collect All Coins", "Collects nearby coins", function()
        pcall(function()
            local coins = workspace:FindFirstChild("Coins") or workspace:FindFirstChild("Currency") or workspace:FindFirstChild("Drops")
            if coins then
                for _,v in pairs(coins:GetChildren()) do
                    if v:IsA("BasePart") then
                        firetouchinterest(Player.Character.HumanoidRootPart, v, 0)
                        firetouchinterest(Player.Character.HumanoidRootPart, v, 1)
                    end
                end
            end
        end)
    end)
    
    MiscSection:NewToggle("Auto Collect Coins", "Automatically collects coins", function(state)
        getgenv().AutoCollectCoins = state
        spawn(function()
            while AutoCollectCoins and task.wait(0.5) do
                pcall(function()
                    local coins = workspace:FindFirstChild("Coins") or workspace:FindFirstChild("Currency") or workspace:FindFirstChild("Drops")
                    if coins then
                        for _,v in pairs(coins:GetChildren()) do
                            if v:IsA("BasePart") then
                                firetouchinterest(Player.Character.HumanoidRootPart, v, 0)
                                firetouchinterest(Player.Character.HumanoidRootPart, v, 1)
                            end
                        end
                    end
                end)
            end
        end)
    end)
    
    -- Credits Tab
    local CreditsTab = Window:NewTab("Credits")
    local CreditsSection = CreditsTab:NewSection("Made by ¢heat")
    CreditsSection:NewLabel("Discord: discord.gg/example")
    CreditsSection:NewLabel("YouTube: youtube.com/example")
end

-- Initialize the UI
CreateDraggableUI()
