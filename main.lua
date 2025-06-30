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
local gui = nil
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

-- AIMBOT LOGIC: MODIFIED TO PRIORITIZE NEARBY PLAYERS
local aimbotRange = 100 -- Set a range for aimbot targeting (e.g., 100 studs)

local function getClosestAimbotTarget()
    if not root then return nil end -- Ensure player's root part exists

    local closestPlayer, shortestDist = nil, aimbotRange -- Initialize shortestDist with the aimbot range
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetHRP = p.Character.HumanoidRootPart
            local dist = (root.Position - targetHRP.Position).Magnitude -- Calculate distance from player's root to target's root
            
            if dist < shortestDist then
                closestPlayer = p
                shortestDist = dist
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
                    -- Face the target's HumanoidRootPart, maintaining current Y position
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
    main.Size = UDim2.new(0, 250, 0, 350) -- Adjusted size to fit more options vertically
    main.Position = UDim2.new(0.5, -125, 0.5, -175) -- Center the frame
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)

    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Text = "Server v1"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1) -- Initial color before rainbow takes over
    rainbowElements[title] = "TextColor"
    title.TextScaled = true -- Allow text to scale to fit
    title.MinimumFontSize = 12

    local scrollFrame = Instance.new("ScrollingFrame", main)
    scrollFrame.Size = UDim2.new(1, -10, 1, -40) -- Adjusted size for content area
    scrollFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    scrollFrame.CanvasSize = UDim2.new(0,0,0,0) -- Set by AutomaticCanvasSize.Y

    local layout = Instance.new("UIListLayout", scrollFrame)
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local uiPadding = Instance.new("UIPadding", scrollFrame)
    uiPadding.PaddingTop = UDim.new(0, 5)
    uiPadding.PaddingBottom = UDim.new(0, 5)

    local function createHeader(parent, text)
        local header = Instance.new("TextLabel", parent)
        header.Size = UDim2.new(1, 0, 0, 25)
        header.Text = text
        header.Font = Enum.Font.GothamBold
        header.TextSize = 16
        header.BackgroundTransparency = 1
        header.TextColor3 = Color3.new(1, 1, 1)
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.TextScaled = true
        header.MinimumFontSize = 10
        header.LayoutOrder = -1 -- Ensures headers appear at the top of their section
        rainbowElements[header] = "TextColor"
        return header
    end

    local function createToggleButton(parent, name, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -10, 0, 30) -- Wider button frame
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BackgroundTransparency = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local textLabel = Instance.new("TextLabel", frame)
        textLabel.Size = UDim2.new(1, -40, 1, 0) -- Make space for indicator
        textLabel.Position = UDim2.new(0, 10, 0, 0) -- Padding from left
        textLabel.Text = name
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.new(1, 1, 1)

        local indicator = Instance.new("Frame", frame)
        indicator.Size = UDim2.new(0, 18, 0, 18)
        indicator.Position = UDim2.new(1, -25, 0.5, -9) -- Aligned right, centered vertically
        indicator.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red for OFF
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0) -- Circle

        local state = false
        local function updateIndicator()
            indicator.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        end
        updateIndicator()

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = "" -- No text, frame contains it
        btn.MouseButton1Click:Connect(function()
            state = not state
            updateIndicator()
            callback(state)
        end)
        
        return btn -- Return the clickable part for potential further reference
    end
    
    local function createOneShotButton(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -10, 0, 30) -- Wider button
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.BackgroundTransparency = 0
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- POPULATE UI WITH HEADERS AND BUTTONS
    
    -- PLAYER SETTINGS
    createHeader(scrollFrame, "PLAYER SETTINGS")
    createToggleButton(scrollFrame, "GODMODE", setGodMode)
    createToggleButton(scrollFrame, "AIMBOT", toggleAimbot)
    createToggleButton(scrollFrame, "ANTI-STUN", antiStun)
    createToggleButton(scrollFrame, "BOOST JUMP", function(state)
        boostJumpEnabled = state
    end)
    
    -- VISUAL SETTINGS
    createHeader(scrollFrame, "VISUAL SETTINGS")
    createToggleButton(scrollFrame, "ESP", toggleESP)
    createToggleButton(scrollFrame, "INVISIBLE", setInvisible) -- Renamed from VISIBILITY for clarity with function name

    -- STEAL SETTINGS
    createHeader(scrollFrame, "STEAL SETTINGS")
    createOneShotButton(scrollFrame, "TELEPORT SKY", teleportToSky)
    createOneShotButton(scrollFrame, "TELEPORT GROUND", teleportToGround)

    -- WORLD
    createHeader(scrollFrame, "WORLD")
    createOneShotButton(scrollFrame, "CHANGE SERVER", serverHop)

    -- Initialize Rainbow Effect
    RunService.Heartbeat:Connect(updateRainbowColors)
end

-- Initialize Menu
createMenu()
