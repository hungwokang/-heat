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
local antiStunConnection = nil

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
local espEnabled = false
local espConnections = {}
local boostJumpEnabled = false
local rainbowTextEnabled = true -- Control for rainbow text effects

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
    if not rainbowTextEnabled then return end
    
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

local function teleportToGround()
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
    if not humanoid then updateCharacter() end
    if not humanoid then return end

    if on then
        -- Store original values
        local originalWalkSpeed = humanoid.WalkSpeed
        local originalJumpPower = humanoid.JumpPower
        
        -- Disconnect existing connection if any
        if antiStunConnection then
            antiStunConnection:Disconnect()
        end
        
        -- Create new connection
        antiStunConnection = RunService.Heartbeat:Connect(function()
            if not humanoid or not humanoid.Parent then
                if antiStunConnection then
                    antiStunConnection:Disconnect()
                end
                return
            end
            
            -- Reset movement properties
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.JumpPower = originalJumpPower
            
            -- Reset platform stand and sitting
            humanoid.PlatformStand = false
            humanoid.Sit = false
            
            -- Remove any velocity constraints
            for _, v in ipairs(humanoid.Parent:GetDescendants()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyAngularVelocity") then
                    v:Destroy()
                end
            end
            
            -- Force running state if needed
            if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            
            -- Additional protection against root part velocity manipulation
            if root then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, math.clamp(root.AssemblyLinearVelocity.Y, -50, 100), root.AssemblyLinearVelocity.Z)
            end
        end)
        
        -- Handle character respawns
        player.CharacterAdded:Connect(function()
            task.wait(1) -- Wait for character to fully load
            if on then -- Only reconnect if anti-stun is still enabled
                antiStun(true)
            end
        end)
    else
        -- Disable anti-stun
        if antiStunConnection then
            antiStunConnection:Disconnect()
            antiStunConnection = nil
        end
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
                    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetHrp.Position.X, root.Position.Y, targetHrp.Position.Z))
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

-- BOOST JUMP LOGIC
UserInputService.JumpRequest:Connect(function()
    if boostJumpEnabled and humanoid and root then
        root.AssemblyLinearVelocity = Vector3.new(0, 100, 0)
        local gravityConn
        gravityConn = RunService.Stepped:Connect(function()
            if not char or not root or not humanoid or not boostJumpEnabled then
                gravityConn:Disconnect()
                return
            end

            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                root.Velocity = Vector3.new(root.Velocity.X, math.clamp(root.Velocity.Y, -20, 150), root.Velocity.Z)
            elseif humanoid.FloorMaterial ~= Enum.Material.Air then
                gravityConn:Disconnect()
            end
        end)
    end
end)

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

local function toggleESP(state)
    espEnabled = state
    if state then
        local function applyHighlight(character)
            if not character or character:FindFirstChild("ServerV1ESP") then return end
            local h = Instance.new("Highlight")
            h.Name = "ServerV1ESP"
            h.FillColor = Color3.fromRGB(255, 50, 50)
            h.OutlineColor = Color3.new(1, 1, 1)
            h.FillTransparency = 1
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
--[[                 COMPACT UI                ]]--
---------------------------------------------------

local function createMenu()
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "ServerV1Menu"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 180, 0, 200) -- Smaller size
    main.Position = UDim2.new(0.5, -90, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)

    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 25) -- Smaller title bar
    titleBar.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -25, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "Server v1"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14 -- Smaller text
    title.BackgroundTransparency = 1
    rainbowElements[title] = "TextColor"

    local minimize = Instance.new("TextButton", titleBar)
    minimize.Size = UDim2.new(0, 25, 0, 25) -- Smaller button
    minimize.Position = UDim2.new(1, -25, 0, 0)
    minimize.Text = "-"
    minimize.BackgroundTransparency = 1
    minimize.TextColor3 = Color3.new(1,1,1)
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 16
    rainbowElements[minimize] = "TextColor"
    
    local tabs = {"PLAYER", "VISUAL", "CHEAT"} -- Shortened tab names
    local tabButtons = {}
    local tabFrames = {}

    local tabContainer = Instance.new("Frame", main)
    tabContainer.Size = UDim2.new(1, -10, 0, 25) -- Smaller tab bar
    tabContainer.Position = UDim2.new(0, 5, 0, 30)
    tabContainer.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 2) -- Reduced padding

    local tabContentContainer = Instance.new("Frame", main)
    tabContentContainer.Size = UDim2.new(1, -10, 1, -65) -- Adjusted for smaller UI
    tabContentContainer.Position = UDim2.new(0, 5, 0, 60)
    tabContentContainer.BackgroundTransparency = 1
    tabContentContainer.ClipsDescendants = true

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
        local tabBtn = Instance.new("TextButton", tabContainer)
        tabBtn.Name = tabName
        tabBtn.Size = UDim2.new(0.33, -2, 1, 0) -- Tightly packed
        tabBtn.Text = tabName
        
        tabBtn.TextColor3 = Color3.new(1, 1, 1)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 10 -- Smaller text
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 4)
        tabBtn.MouseButton1Click:Connect(function() switchTab(tabName) end)
        table.insert(tabButtons, tabBtn)

        local tabFrame = Instance.new("ScrollingFrame", tabContentContainer)
        tabFrame.Name = tabName
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.BorderSizePixel = 0
        tabFrame.ScrollBarThickness = 4
        tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabFrame.Visible = (i == 1)
        local layout = Instance.new("UIListLayout", tabFrame)
        layout.Padding = UDim.new(0, 4) -- Reduced padding
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabFrames[tabName] = tabFrame
    end

    local function createToggleButton(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Name = name
        btn.Size = UDim2.new(1, 0, 0, 20) -- Smaller, full width
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = name..": OFF" -- Initial state
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10 -- Smaller text
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            
            btn.Text = name..(state and ": ON" or ": OFF")
            callback(state)
        end)
        
        rainbowElements[btn] = "TextColor"
    end
    
    local function createOneShotButton(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Name = name
        btn.Size = UDim2.new(1, 0, 0, 20) -- Smaller, full width
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10 -- Smaller text
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(callback)
        rainbowElements[btn] = "TextColor"
    end

    -- POPULATE TABS WITH BUTTONS
    -- Player Tab
    createToggleButton(tabFrames["PLAYER"], "GODMODE", setGodMode)
    createToggleButton(tabFrames["PLAYER"], "AIMBOT", toggleAimbot)
    createToggleButton(tabFrames["PLAYER"], "ANTI-STUN", antiStun)
    createToggleButton(tabFrames["PLAYER"], "BOOST JUMP", function(state)
        boostJumpEnabled = state
    end)
    
    -- Visual Tab (renamed from VISUALS)
    createToggleButton(tabFrames["VISUAL"], "ESP", toggleESP)
    createToggleButton(tabFrames["VISUAL"], "INVISIBLE", setInvisible)

    -- Cheat Tab
    createOneShotButton(tabFrames["CHEAT"], "TELEPORT UP", teleportToSky)
    createOneShotButton(tabFrames["CHEAT"], "TELEPORT DOWN", teleportToGround)
    createOneShotButton(tabFrames["VISUAL"], "ZSERVER HOP", serverHop)

    -- UI INTERACTIONS
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 180, 0, 25) or UDim2.new(0, 180, 0, 200)
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

