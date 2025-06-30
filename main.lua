--[[
    Server v1 - Final Integrated Script
    - Merged functions from the user's provided scripts.
    - Re-organized UI into the requested PLAYER, VISUALS, and CHEAT tabs.
    - Adopted the core style and layout of the second €heat v1 menu.
    - Maintained scrollable tab frames.
    - Removed No-Clip and Unlimited Jump functionalities.
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

-- LOCAL PLAYER & CHARACTER
local player = Players.LocalPlayer
local char, root, humanoid

local function updateCharacter()
    char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end

updateCharacter()
player.CharacterAdded:Connect(function()
    task.wait(1)
    updateCharacter()
end)

-- SCRIPT-WIDE STATES & VARIABLES
local gui, minimized = nil, false
local godConnection, aimConnection
local espEnabled = false -- State for the new ESP system
local espConnections = {} -- Connections for the new ESP system

-- RAINBOW COLOR ANIMATION
local rainbowColors = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211)
}
local colorIndex = 1
local rainbowSpeed = 0.1
local rainbowElements = {} -- Stores elements {element, type} for coloring

local function updateRainbowColors()
    colorIndex = (colorIndex + rainbowSpeed) % #rainbowColors
    local color1 = rainbowColors[math.floor(colorIndex % #rainbowColors) + 1]
    local color2 = rainbowColors[math.floor((colorIndex + 1) % #rainbowColors) + 1]
    local lerpValue = colorIndex % 1
    local lerpedColor = color1:Lerp(color2, lerpValue)

    for element, elementType in pairs(rainbowElements) do
        if element and element.Parent then
            if elementType == "TextColor" then
                element.TextColor3 = lerpedColor
            elseif elementType == "BackgroundColor" then
                element.BackgroundColor3 = lerpedColor
            end
        end
    end
end

---------------------------------------------------
--[[           FUNCTION DEFINITIONS            ]]--
---------------------------------------------------

-- TELEPORT / MOVEMENT FUNCTIONS
local doorPositions = {
    Vector3.new(-466, -1, 220), Vector3.new(-466, -2, 116), Vector3.new(-466, -2, 8),
    Vector3.new(-464, -2, -102), Vector3.new(-351, -2, -100), Vector3.new(-354, -2, 5),
    Vector3.new(-354, -2, 115), Vector3.new(-358, -2, 223)
}

local function getNearestDoor()
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, door in ipairs(doorPositions) do
        local dist = (root.Position - door).Magnitude
        if dist < minDist then
            minDist = dist
            closest = door
        end
    end
    return closest
end

local function teleportToSky()
    if not root then updateCharacter() end
    local door = getNearestDoor()
    if door and root then
        TweenService:Create(root, TweenInfo.new(1.2), { CFrame = CFrame.new(door) }):Play()
        task.wait(1.3)
        root.CFrame = root.CFrame + Vector3.new(0, 200, 0)
    end
end

local function teleportToGround() -- Renamed from "dropDown"
    if not root then updateCharacter() end
    if root then
        root.CFrame = root.CFrame - Vector3.new(0, 50, 0)
    end
end

-- COMBAT / PLAYER STATE FUNCTIONS
function setGodMode(on)
    if not humanoid then updateCharacter() end
    if not humanoid then return end

    if on then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        if godConnection then godConnection:Disconnect() end
        godConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < math.huge then
                humanoid.Health = math.huge
            end
        end)
    else
        if godConnection then godConnection:Disconnect() end
        godConnection = nil
        pcall(function()
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end)
    end
end

function antiStun(on)
    -- The logic for Anti-Stun was not provided in the original scripts.
    -- This is a placeholder. You can add the specific mechanism here.
    if on then
        print("Anti-Stun Enabled (Placeholder)")
    else
        print("Anti-Stun Disabled (Placeholder)")
    end
end

local function getClosestAimbotTarget()
    local closestPlayer, shortestDist = nil, math.huge
    local cam = Workspace.CurrentCamera
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetHRP = p.Character.HumanoidRootPart
            local screenPoint, onScreen = cam:WorldToViewportPoint(targetHRP.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                if dist < shortestDist then
                    closestPlayer = p
                    shortestDist = dist
                end
            end
        end
    end
    return closestPlayer
end

local function toggleAimbot(state)
    if state then
        aimConnection = RunService.Heartbeat:Connect(function()
            local target = getClosestAimbotTarget()
            if target and target.Character and char and root and humanoid then
                local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetHrp.Position.X, root.Position.Y, targetHrp.Position.Z))
                end
            end
        end)
    else
        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
    end
end

-- VISUALS FUNCTIONS
function setInvisible(on)
    if not char then updateCharacter() end
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = on and 1 or part.Parent:IsA("Accessory") and part.Parent.Handle.Transparency or 0
        elseif part:IsA("Decal") then
            part.Transparency = on and 1 or 0
        end
    end
end

-- ESP function from the second script
local function toggleESP(state)
    espEnabled = state
    if state then
        local function applyHighlight(character)
            if not character or character:FindFirstChild("ServerV1ESP") then return end
            local h = Instance.new("Highlight")
            h.Name = "ServerV1ESP"
            h.FillColor = Color3.fromRGB(255, 50, 50)
            h.OutlineColor = Color3.new(1, 1, 1)
            h.FillTransparency = 0.7
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = character
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                applyHighlight(p.Character)
            end
        end
        
        table.insert(espConnections, Players.PlayerAdded:Connect(function(newP)
            newP.CharacterAdded:Connect(function(char)
                if espEnabled then applyHighlight(char) end
            end)
        end))
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(espConnections, p.CharacterAdded:Connect(function(char)
                    if espEnabled then applyHighlight(char) end
                end))
            end
        end
    else
        for _, c in ipairs(espConnections) do c:Disconnect() end
        espConnections = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("ServerV1ESP")
                if h then h:Destroy() end
            end
        end
    end
end

-- WORLD / SERVER FUNCTIONS
local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.playing and server.maxPlayers and server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)])
    else
        StarterGui:SetCore("SendNotification", { Title = "Server Hop", Text = "No other servers found.", Duration = 3 })
    end
end

---------------------------------------------------
--[[                 UI CREATION               ]]--
---------------------------------------------------

local function createMenu()
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "ServerV1Menu"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 220, 0, 250)
    main.Position = UDim2.new(0.5, -110, 0.5, -125)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    -- Title Bar
    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -30, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = "Server v1" -- CHANGED
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.BackgroundTransparency = 1
    rainbowElements[title] = "TextColor"

    local minimize = Instance.new("TextButton", titleBar)
    minimize.Size = UDim2.new(0, 30, 0, 30)
    minimize.Position = UDim2.new(1, -30, 0, 0)
    minimize.Text = "-"
    minimize.BackgroundTransparency = 1
    minimize.TextColor3 = Color3.new(1,1,1)
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 20
    rainbowElements[minimize] = "TextColor"
    
    -- Tab Setup
    local tabs = {"PLAYER", "VISUALS", "CHEAT"} -- CHANGED
    local tabButtons = {}
    local tabFrames = {}

    local tabContainer = Instance.new("Frame", main)
    tabContainer.Size = UDim2.new(1, -10, 0, 30)
    tabContainer.Position = UDim2.new(0, 5, 0, 35)
    tabContainer.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 5)

    local tabContentContainer = Instance.new("Frame", main)
    tabContentContainer.Size = UDim2.new(1, -10, 1, -75)
    tabContentContainer.Position = UDim2.new(0, 5, 0, 70)
    tabContentContainer.BackgroundTransparency = 1

    local function switchTab(tabName)
        for name, frame in pairs(tabFrames) do
            frame.Visible = (name == tabName)
        end
        for _, btn in ipairs(tabButtons) do
            local isSelected = (btn.Name == tabName)
            btn.BackgroundColor3 = isSelected and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(50, 50, 50)
        end
    end

    for i, tabName in ipairs(tabs) do
        -- Create Tab Button
        local tabBtn = Instance.new("TextButton", tabContainer)
        tabBtn.Name = tabName
        tabBtn.Size = UDim2.new(0.33, -5, 1, 0)
        tabBtn.Text = tabName
        tabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(50, 50, 50)
        tabBtn.TextColor3 = Color3.new(1, 1, 1)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 12
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        tabBtn.MouseButton1Click:Connect(function() switchTab(tabName) end)
        table.insert(tabButtons, tabBtn)

        -- Create Tab Content Frame
        local tabFrame = Instance.new("ScrollingFrame", tabContentContainer)
        tabFrame.Name = tabName
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.BorderSizePixel = 0
        tabFrame.ScrollBarThickness = 5
        tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabFrame.Visible = (i == 1)
        local layout = Instance.new("UIListLayout", tabFrame)
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabFrames[tabName] = tabFrame
    end

    -- Button Creation Helpers
    local function createToggleButton(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Name = name
        btn.Size = UDim2.new(0.95, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            callback(state)
        end)
    end
    
    local function createOneShotButton(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Name = name
        btn.Size = UDim2.new(0.95, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(callback)
    end

    -- POPULATE TABS WITH BUTTONS
    -- Player Tab
    createToggleButton(tabFrames["PLAYER"], "GODMODE", setGodMode)
    createToggleButton(tabFrames["PLAYER"], "AIMBOT", toggleAimbot)
    createToggleButton(tabFrames["PLAYER"], "ANTI-STUN", antiStun)
    
    -- Visuals Tab
    createToggleButton(tabFrames["VISUALS"], "ESP", toggleESP)
    createToggleButton(tabFrames["VISUALS"], "INVISIBILITY", setInvisible)

    -- Cheat Tab (Originally 'TELEPORT')
    createOneShotButton(tabFrames["CHEAT"], "TELEPORT SKY", teleportToSky)
    createOneShotButton(tabFrames["CHEAT"], "TELEPORT GROUND", teleportToGround)
    createOneShotButton(tabFrames["CHEAT"], "CHANGE SERVER", serverHop)

    -- UI INTERACTIONS
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 250)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = targetSize }):Play()
        tabContainer.Visible = not minimized
        tabContentContainer.Visible = not minimized
        minimize.Text = minimized and "+" or "-"
    end)

    -- Initialize Rainbow Effect
    RunService.Heartbeat:Connect(updateRainbowColors)
end

-- Initialize Menu
createMenu()
