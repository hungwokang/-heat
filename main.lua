--[[
  ¢heat - Grow a Garden Script

  Disclaimer: This script is for educational purposes only. 
  Using scripts to exploit games can violate their terms of service.
]]

-- ================== GUI Library ==================
-- In a real script, a GUI library (like a custom one or a publicly available one)
-- would be included here to create the menu interface. For this example, we'll
-- use a simplified structure to represent the menu.

local function createMenu()
    -- Main menu container
    local menu = Instance.new("ScreenGui")
    menu.Name = "¢heatMenu"
    menu.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    menu.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    mainFrame.BorderSizePixel = 2
    mainFrame.Draggable = true
    mainFrame.Active = true
    mainFrame.Parent = menu

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    title.Font = Enum.Font.SourceSansBold
    title.Text = "¢heat - Grow a Garden"
    title.Parent = mainFrame

    -- Tabs for different features
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Size = UDim2.new(1, 0, 0.1, 0)
    tabsFrame.Position = UDim2.new(0, 0, 0.1, 0)
    tabsFrame.Parent = mainFrame
    
    -- Add tabs for Auto Farm, Pet Spawner, Seed Spawner here...

    -- ================== Feature Frames ==================
    -- A frame for each feature would be created and made visible/invisible
    -- based on the selected tab.

    -- Auto Farm Frame
    local autoFarmFrame = Instance.new("Frame")
    autoFarmFrame.Name = "AutoFarmFrame"
    -- ... (Positioning and styling)
    autoFarmFrame.Visible = true -- Default visible frame
    autoFarmFrame.Parent = mainFrame

    local autoFarmToggle = Instance.new("TextButton")
    autoFarmToggle.Name = "AutoFarmToggle"
    autoFarmToggle.Size = UDim2.new(0, 150, 0, 30)
    autoFarmToggle.Position = UDim2.new(0.5, -75, 0.3, 0)
    autoFarmToggle.Text = "Toggle Auto Farm"
    -- ... (Styling)
    autoFarmToggle.Parent = autoFarmFrame
    
    local autoFarmStatus = Instance.new("TextLabel")
    autoFarmStatus.Name = "AutoFarmStatus"
    autoFarmStatus.Text = "Status: Disabled"
    -- ... (Styling)
    autoFarmStatus.Parent = autoFarmFrame

    -- Pet Spawner Frame
    local petSpawnerFrame = Instance.new("Frame")
    petSpawnerFrame.Name = "PetSpawnerFrame"
    -- ... (Positioning and styling)
    petSpawnerFrame.Visible = false
    petSpawnerFrame.Parent = mainFrame

    local petNameInput = Instance.new("TextBox")
    petNameInput.Name = "PetNameInput"
    petNameInput.PlaceholderText = "Enter Pet Name"
    -- ... (Styling)
    petNameInput.Parent = petSpawnerFrame
    
    local spawnPetButton = Instance.new("TextButton")
    spawnPetButton.Name = "SpawnPetButton"
    spawnPetButton.Text = "Spawn Pet"
    -- ... (Styling)
    spawnPetButton.Parent = petSpawnerFrame

    -- Seed Spawner Frame
    local seedSpawnerFrame = Instance.new("Frame")
    seedSpawnerFrame.Name = "SeedSpawnerFrame"
    -- ... (Positioning and styling)
    seedSpawnerFrame.Visible = false
    seedSpawnerFrame.Parent = mainFrame

    local seedSearchBox = Instance.new("TextBox")
    seedSearchBox.Name = "SeedSearchBox"
    seedSearchBox.PlaceholderText = "Search for a seed..."
    -- ... (Styling)
    seedSearchBox.Parent = seedSpawnerFrame

    local seedList = Instance.new("ScrollingFrame")
    -- ... (Styling and positioning)
    seedList.Parent = seedSpawnerFrame
    
    -- Populate seedList with buttons for each seed...

    -- ================== Core Logic ==================

    -- A real script would require analyzing the game's network traffic 
    -- and client-side code to find the remote events or functions that
    -- handle farming, pet creation, and seed planting. This is a complex
    -- process and the functions would be specific to the game's code.

    local seeds = {
        "Carrot", "Strawberry", "Blueberry", "Tomato", "Corn",
        "Daffodil", "Watermelon", "Pumpkin", "Apple", "Bamboo",
        "Coconut", "Cactus", "Dragon Fruit", "Mango", "Grape",
        "Mushroom", "Pepper", "Cacao", "Beanstalk", "Sugar Apple",
        -- This list would be much longer and would need to be kept up-to-date
        -- with the game's latest additions.
    }

    -- Populate the seed list
    for _, seedName in ipairs(seeds) do
        local seedButton = Instance.new("TextButton")
        seedButton.Name = seedName
        seedButton.Text = seedName
        -- ... (Styling)
        seedButton.Parent = seedList

        seedButton.MouseButton1Click:Connect(function()
            -- Placeholder for seed spawning logic
            print("Attempting to spawn: " .. seedName)
            -- In a real script, this would call the game's internal function
            -- for planting a seed, likely passing the seed name as an argument.
        end)
    end

    autoFarmToggle.MouseButton1Click:Connect(function()
        -- Placeholder for auto-farm logic
        local isEnabled = not autoFarmStatus.Text:find("Enabled")
        autoFarmStatus.Text = "Status: " .. (isEnabled and "Enabled" or "Disabled")
        -- Auto-farm logic would go here. This would likely involve a loop
        -- that finds mature plants and harvests them, and then replants seeds.
    end)

    spawnPetButton.MouseButton1Click:Connect(function()
        local petName = petNameInput.Text
        if petName and petName ~= "" then
            -- Placeholder for pet spawning logic
            print("Attempting to spawn pet: " .. petName)
            -- This would call the game's remote event or function for
            -- creating a pet. This is often heavily secured by the game developers.
        end
    end)
end

-- ================== Execution ==================
createMenu()
