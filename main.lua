-- €heat v1 - Mobile Cheat Menu with Tabs
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local gui, minimized = nil, false

-- STATES
local espEnabled = false
local aimbotEnabled = false
local floatEnabled = false
local espConnections = {}
local aimConnection
local floatConnection
local isFloating = false
local lastFloatTime = 0
local floatCooldown = 3 -- seconds

-- Rainbow color animation
local rainbowColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211)
}

local colorIndex = 1
local rainbowSpeed = 0.1
local rainbowTexts = {}
local rainbowButtons = {}
local rainbowTabTexts = {} -- New table for tab texts

local function updateRainbowColors()
    colorIndex = (colorIndex + rainbowSpeed) % #rainbowColors
    local color1 = rainbowColors[math.floor(colorIndex % #rainbowColors) + 1]
    local color2 = rainbowColors[math.floor((colorIndex + 1) % #rainbowColors) + 1]
    local lerpValue = colorIndex % 1

    -- Update regular rainbow texts
    for _, textObj in pairs(rainbowTexts) do
        if textObj and textObj.Parent then
            textObj.TextColor3 = color1:Lerp(color2, lerpValue)
        end
    end
    
    -- Update tab texts
    for _, textObj in pairs(rainbowTabTexts) do
        if textObj and textObj.Parent then
            textObj.TextColor3 = color1:Lerp(color2, lerpValue)
        end
    end
    
    -- Update buttons
    for btn, _ in pairs(rainbowButtons) do
        if btn and btn.Parent then
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
end

-- Toggle Button UI
local function toggleButton(button)
    local state = button.Text:find("OFF")
    if state then
        button.Text = button.Name .. ": ON"
    else
        button.Text = button.Name .. ": OFF"
    end
    return state
end

-- Instant Server Hop (one-click)
local function serverHop()
    local placeId = game.PlaceId
    
    local servers = {}
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)
    
    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.playing and server.maxPlayers and server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers == 0 then
        local altSuccess, altResponse = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://www.roblox.com/games/getgameinstancesjson?placeId=" .. placeId .. "&startindex=0"
            ))
        end)
        
        if altSuccess and altResponse and altResponse.Collection then
            for _, server in ipairs(altResponse.Collection) do
                if server.Connected and server.MaxPlayers and server.Connected < server.MaxPlayers and server.Guid ~= game.JobId then
                    table.insert(servers, server.Guid)
                end
            end
        end
    end
    
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)])
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Server Hop",
            Text = "Finding available servers...",
            Duration = 2,
        })
        task.wait(2)
        serverHop()
    end
end

-- Fixed ESP Function
local function toggleESP(state)
    if state then
        -- First, clear any existing highlights
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChildOfClass("Highlight")
                if h then h:Destroy() end
            end
        end

        -- Create highlights for existing players
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = Instance.new("Highlight")
                h.Name = "€heatESP"
                h.FillColor = Color3.fromRGB(255, 50, 50)
                h.OutlineColor = Color3.new(1, 1, 1)
                h.FillTransparency = 0.9
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Adornee = p.Character
                h.Parent = p.Character
            end
        end
        
        -- Set up connections for new players
        table.insert(espConnections, Players.PlayerAdded:Connect(function(newP)
            newP.CharacterAdded:Connect(function(char)
                if espEnabled then
                    local h = Instance.new("Highlight")
                    h.Name = "€heatESP"
                    h.FillColor = Color3.fromRGB(255, 50, 50)
                    h.OutlineColor = Color3.new(1, 1, 1)
                    h.FillTransparency = 0.9
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee = char
                    h.Parent = char
                end
            end)
        end))
        
        -- Set up connections for existing players' character changes
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(espConnections, p.CharacterAdded:Connect(function(char)
                    if espEnabled then
                        local h = Instance.new("Highlight")
                        h.Name = "€heatESP"
                        h.FillColor = Color3.fromRGB(255, 50, 50)
                        h.OutlineColor = Color3.new(1, 1, 1)
                        h.FillTransparency = 0.9
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Adornee = char
                        h.Parent = char
                    end
                end))
            end
        end
    else
        -- Clear all highlights
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("€heatESP")
                if h then h:Destroy() end
            end
        end
        
        -- Disconnect all connections
        for _, c in ipairs(espConnections) do
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end
        espConnections = {}
    end
end

-- Aimbot
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDist = math.huge
    local cam = Workspace.CurrentCamera

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                local screenPoint, onScreen = cam:WorldToViewportPoint(hrp.Position)
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
    end
    
    return closestPlayer
end

local function toggleAimbot(state)
    if state then
        aimConnection = RunService.Heartbeat:Connect(function()
            local target = getClosestTarget()
            if target and target.Character and player.Character then
                local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                local playerHrp = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if targetHrp and playerHrp and humanoid then
                    local direction = (targetHrp.Position - playerHrp.Position).Unit
                    local lookAt = CFrame.new(playerHrp.Position, playerHrp.Position + Vector3.new(direction.X, 0, direction.Z))
                    playerHrp.CFrame = playerHrp.CFrame:Lerp(lookAt, 0.3)
                    humanoid:MoveTo(playerHrp.Position + direction * 2)
                end
            end
        end)
    else
        if aimConnection then 
            aimConnection:Disconnect()
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:MoveTo(player.Character.HumanoidRootPart.Position)
            end
        end
    end
end

-- Float System with time limit and cooldown
local function handleJump()
    if not floatEnabled or isFloating or (tick() - lastFloatTime) < floatCooldown then
        return
    end
    
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    
    isFloating = true
    lastFloatTime = tick()
    
    -- Create float effect
    local floatBV = Instance.new("BodyVelocity")
    floatBV.Name = "FloatBodyVelocity"
    floatBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    floatBV.Velocity = Vector3.new(0, 25, 0)
    floatBV.P = 10000
    floatBV.Parent = hrp
    
    -- Create particle effect
    local particles = Instance.new("ParticleEmitter", hrp)
    particles.LightEmission = 1
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255))
    particles.Size = NumberSequence.new(0.5)
    particles.Texture = "rbxassetid://243664672"
    particles.Lifetime = NumberRange.new(1)
    particles.Rate = 50
    particles.Speed = NumberRange.new(2)
    particles.VelocitySpread = 180
    
    -- Set time limit to 1.5 seconds
    local startTime = tick()
    local floatConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not hrp.Parent then 
            floatConnection:Disconnect()
            return 
        end
        
        -- Update float movement
        if humanoid.MoveDirection.Magnitude > 0 then
            floatBV.Velocity = Vector3.new(
                humanoid.MoveDirection.X * humanoid.WalkSpeed,
                25,
                humanoid.MoveDirection.Z * humanoid.WalkSpeed
            )
        else
            floatBV.Velocity = Vector3.new(0, 25, 0)
        end
        
        -- Check time limit (2 seconds)
        if tick() - startTime >= 1.5 then
            isFloating = false
            floatBV:Destroy()
            particles:Destroy()
            floatConnection:Disconnect()
            
            -- Show notification
            StarterGui:SetCore("SendNotification", {
                Title = "Float",
                Text = "Float time limit reached!",
                Duration = 1.5,
            })
        end
    end)
end

local function toggleFloat(state)
    floatEnabled = state
    
    if state then
        -- Connect to jump event
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Jumping:Connect(handleJump)
            end
        end
        
        -- Also connect for when character respawns
        player.CharacterAdded:Connect(function(char)
            task.wait(1) -- Wait for humanoid to be added
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Jumping:Connect(handleJump)
            end
        end)
    else
        -- Remove any active float effects
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local floatBV = hrp:FindFirstChild("FloatBodyVelocity")
                if floatBV then floatBV:Destroy() end
                
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("ParticleEmitter") then
                        v:Destroy()
                    end
                end
            end
        end
        isFloating = false
    end
end

-- Menu
local function createMenu()
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "€heatMenu"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 220, 0, 250)
    frame.Position = UDim2.new(0.5, -110, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(0.7, 0, 0, 30)
    title.Position = UDim2.new(0.15, 0, 0, 0)
    title.Text = "€heat v1"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.BackgroundTransparency = 1
    table.insert(rainbowTexts, title)

    local minimize = Instance.new("TextButton", frame)
    minimize.Size = UDim2.new(0.2, 0, 0, 30)
    minimize.Position = UDim2.new(0.8, 0, 0, 0)
    minimize.Text = "-"
    minimize.BackgroundTransparency = 1
    minimize.TextColor3 = Color3.new(1,1,1)
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 20
    table.insert(rainbowTexts, minimize)

    -- Create tab buttons (UPDATED NAMES)
    local tabButtons = {}
    local tabs = {"PLAYER", "INTERFACE"} -- Changed to uppercase
    
    local tabContainer = Instance.new("Frame", frame)
    tabContainer.Size = UDim2.new(1, -20, 0, 30)
    tabContainer.Position = UDim2.new(0, 10, 0, 35)
    tabContainer.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    
    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton", tabContainer)
        tabBtn.Size = UDim2.new(0.5, -5, 1, 0)
        tabBtn.Text = tabName
        tabBtn.Name = tabName
        tabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
        tabBtn.TextColor3 = Color3.new(1, 1, 1)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        table.insert(tabButtons, tabBtn)
        table.insert(rainbowTabTexts, tabBtn) -- Add to rainbow tab texts
        rainbowButtons[tabBtn] = true
    end
    
    -- Create tab content frames
    local tabContent = Instance.new("Frame", frame)
    tabContent.Size = UDim2.new(1, -20, 1, -75)
    tabContent.Position = UDim2.new(0, 10, 0, 70)
    tabContent.BackgroundTransparency = 1
    
    local playerTab = Instance.new("ScrollingFrame", tabContent)
    playerTab.Size = UDim2.new(1, 0, 1, 0)
    playerTab.BackgroundTransparency = 1
    playerTab.CanvasSize = UDim2.new(0, 0, 0, 140) -- Reduced height since high jump was removed
    playerTab.ScrollBarThickness = 4
    playerTab.Visible = true
    playerTab.Name = "PLAYER"
    Instance.new("UIListLayout", playerTab).Padding = UDim.new(0, 8)
    
    local interfaceTab = Instance.new("ScrollingFrame", tabContent)
    interfaceTab.Size = UDim2.new(1, 0, 1, 0)
    interfaceTab.BackgroundTransparency = 1
    interfaceTab.CanvasSize = UDim2.new(0, 0, 0, 120)
    interfaceTab.ScrollBarThickness = 4
    interfaceTab.Visible = false
    interfaceTab.Name = "INTERFACE"
    Instance.new("UIListLayout", interfaceTab).Padding = UDim.new(0, 8)
    
    -- Function to switch tabs
    local function switchTab(tabName)
        playerTab.Visible = tabName == "PLAYER"
        interfaceTab.Visible = tabName == "INTERFACE"
        
        for _, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = btn.Name == tabName and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
        end
    end
    
    -- Connect tab buttons
    for _, btn in ipairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            switchTab(btn.Name)
        end)
    end
    
    -- Create buttons for each tab
    local function createButton(parent, name)
        local btn = Instance.new("TextButton", parent)
        btn.Name = name
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Text = name .. (name == "CHANGE SERVER" and "" or ": OFF")
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        table.insert(rainbowTexts, btn)
        rainbowButtons[btn] = true
        return btn
    end
    
    -- PLAYER Tab buttons (only Aimbot and Float remain)
    local aimbotBtn = createButton(playerTab, "AIMBOT")
    local floatBtn = createButton(playerTab, "FLOAT")
    
    -- INTERFACE Tab buttons
    local espBtn = createButton(interfaceTab, "ESP PLAYER")
    local serverHopBtn = createButton(interfaceTab, "CHANGE SERVER")
    
    -- Connect button functionality
    aimbotBtn.MouseButton1Click:Connect(function()
        aimbotEnabled = toggleButton(aimbotBtn)
        toggleAimbot(aimbotEnabled)
    end)
    
    floatBtn.MouseButton1Click:Connect(function()
        floatEnabled = toggleButton(floatBtn)
        toggleFloat(floatEnabled)
    end)
    
    espBtn.MouseBu-- €heat v1 - Mobile Cheat Menu with Tabs
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local gui, minimized = nil, false

-- STATES
local espEnabled = false
local aimbotEnabled = false
local floatEnabled = false
local espConnections = {}
local aimConnection
local floatConnection
local isFloating = false
local lastFloatTime = 0
local floatCooldown = 3 -- seconds

-- Rainbow color animation
local rainbowColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211)
}

local colorIndex = 1
local rainbowSpeed = 0.1
local rainbowTexts = {}
local rainbowButtons = {}
local rainbowTabTexts = {} -- New table for tab texts

local function updateRainbowColors()
    colorIndex = (colorIndex + rainbowSpeed) % #rainbowColors
    local color1 = rainbowColors[math.floor(colorIndex % #rainbowColors) + 1]
    local color2 = rainbowColors[math.floor((colorIndex + 1) % #rainbowColors) + 1]
    local lerpValue = colorIndex % 1

    -- Update regular rainbow texts
    for _, textObj in pairs(rainbowTexts) do
        if textObj and textObj.Parent then
            textObj.TextColor3 = color1:Lerp(color2, lerpValue)
        end
    end
    
    -- Update tab texts
    for _, textObj in pairs(rainbowTabTexts) do
        if textObj and textObj.Parent then
            textObj.TextColor3 = color1:Lerp(color2, lerpValue)
        end
    end
    
    -- Update buttons
    for btn, _ in pairs(rainbowButtons) do
        if btn and btn.Parent then
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
end

-- Toggle Button UI
local function toggleButton(button)
    local state = button.Text:find("OFF")
    if state then
        button.Text = button.Name .. ": ON"
    else
        button.Text = button.Name .. ": OFF"
    end
    return state
end

-- Instant Server Hop (one-click)
local function serverHop()
    local placeId = game.PlaceId
    
    local servers = {}
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)
    
    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.playing and server.maxPlayers and server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers == 0 then
        local altSuccess, altResponse = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://www.roblox.com/games/getgameinstancesjson?placeId=" .. placeId .. "&startindex=0"
            ))
        end)
        
        if altSuccess and altResponse and altResponse.Collection then
            for _, server in ipairs(altResponse.Collection) do
                if server.Connected and server.MaxPlayers and server.Connected < server.MaxPlayers and server.Guid ~= game.JobId then
                    table.insert(servers, server.Guid)
                end
            end
        end
    end
    
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)])
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Server Hop",
            Text = "Finding available servers...",
            Duration = 2,
        })
        task.wait(2)
        serverHop()
    end
end

-- Fixed ESP Function
local function toggleESP(state)
    if state then
        -- First, clear any existing highlights
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChildOfClass("Highlight")
                if h then h:Destroy() end
            end
        end

        -- Create highlights for existing players
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = Instance.new("Highlight")
                h.Name = "€heatESP"
                h.FillColor = Color3.fromRGB(255, 50, 50)
                h.OutlineColor = Color3.new(1, 1, 1)
                h.FillTransparency = 0.9
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Adornee = p.Character
                h.Parent = p.Character
            end
        end
        
        -- Set up connections for new players
        table.insert(espConnections, Players.PlayerAdded:Connect(function(newP)
            newP.CharacterAdded:Connect(function(char)
                if espEnabled then
                    local h = Instance.new("Highlight")
                    h.Name = "€heatESP"
                    h.FillColor = Color3.fromRGB(255, 50, 50)
                    h.OutlineColor = Color3.new(1, 1, 1)
                    h.FillTransparency = 0.9
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee = char
                    h.Parent = char
                end
            end)
        end))
        
        -- Set up connections for existing players' character changes
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(espConnections, p.CharacterAdded:Connect(function(char)
                    if espEnabled then
                        local h = Instance.new("Highlight")
                        h.Name = "€heatESP"
                        h.FillColor = Color3.fromRGB(255, 50, 50)
                        h.OutlineColor = Color3.new(1, 1, 1)
                        h.FillTransparency = 0.9
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Adornee = char
                        h.Parent = char
                    end
                end))
            end
        end
    else
        -- Clear all highlights
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("€heatESP")
                if h then h:Destroy() end
            end
        end
        
        -- Disconnect all connections
        for _, c in ipairs(espConnections) do
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end
        espConnections = {}
    end
end

-- Aimbot
local function getClosestTarget()
    local closestPlayer = nil
    local shortestDist = math.huge
    local cam = Workspace.CurrentCamera

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                local screenPoint, onScreen = cam:WorldToViewportPoint(hrp.Position)
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
    end
    
    return closestPlayer
end

local function toggleAimbot(state)
    if state then
        aimConnection = RunService.Heartbeat:Connect(function()
            local target = getClosestTarget()
            if target and target.Character and player.Character then
                local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                local playerHrp = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if targetHrp and playerHrp and humanoid then
                    local direction = (targetHrp.Position - playerHrp.Position).Unit
                    local lookAt = CFrame.new(playerHrp.Position, playerHrp.Position + Vector3.new(direction.X, 0, direction.Z))
                    playerHrp.CFrame = playerHrp.CFrame:Lerp(lookAt, 0.3)
                    humanoid:MoveTo(playerHrp.Position + direction * 2)
                end
            end
        end)
    else
        if aimConnection then 
            aimConnection:Disconnect()
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:MoveTo(player.Character.HumanoidRootPart.Position)
            end
        end
    end
end

-- Float System with time limit and cooldown
local function handleJump()
    if not floatEnabled or isFloating or (tick() - lastFloatTime) < floatCooldown then
        return
    end
    
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    
    isFloating = true
    lastFloatTime = tick()
    
    -- Create float effect
    local floatBV = Instance.new("BodyVelocity")
    floatBV.Name = "FloatBodyVelocity"
    floatBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    floatBV.Velocity = Vector3.new(0, 25, 0)
    floatBV.P = 10000
    floatBV.Parent = hrp
    
    -- Create particle effect
    local particles = Instance.new("ParticleEmitter", hrp)
    particles.LightEmission = 1
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255))
    particles.Size = NumberSequence.new(0.5)
    particles.Texture = "rbxassetid://243664672"
    particles.Lifetime = NumberRange.new(1)
    particles.Rate = 50
    particles.Speed = NumberRange.new(2)
    particles.VelocitySpread = 180
    
    -- Set time limit to 1.5 seconds
    local startTime = tick()
    local floatConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not hrp.Parent then 
            floatConnection:Disconnect()
            return 
        end
        
        -- Update float movement
        if humanoid.MoveDirection.Magnitude > 0 then
            floatBV.Velocity = Vector3.new(
                humanoid.MoveDirection.X * humanoid.WalkSpeed,
                25,
                humanoid.MoveDirection.Z * humanoid.WalkSpeed
            )
        else
            floatBV.Velocity = Vector3.new(0, 25, 0)
        end
        
        -- Check time limit (2 seconds)
        if tick() - startTime >= 1.5 then
            isFloating = false
            floatBV:Destroy()
            particles:Destroy()
            floatConnection:Disconnect()
            
            -- Show notification
            StarterGui:SetCore("SendNotification", {
                Title = "Float",
                Text = "Float time limit reached!",
                Duration = 1.5,
            })
        end
    end)
end

local function toggleFloat(state)
    floatEnabled = state
    
    if state then
        -- Connect to jump event
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Jumping:Connect(handleJump)
            end
        end
        
        -- Also connect for when character respawns
        player.CharacterAdded:Connect(function(char)
            task.wait(1) -- Wait for humanoid to be added
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Jumping:Connect(handleJump)
            end
        end)
    else
        -- Remove any active float effects
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local floatBV = hrp:FindFirstChild("FloatBodyVelocity")
                if floatBV then floatBV:Destroy() end
                
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("ParticleEmitter") then
                        v:Destroy()
                    end
                end
            end
        end
        isFloating = false
    end
end

-- Menu
local function createMenu()
    if gui then gui:Destroy() end

    gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "€heatMenu"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 220, 0, 250)
    frame.Position = UDim2.new(0.5, -110, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(0.7, 0, 0, 30)
    title.Position = UDim2.new(0.15, 0, 0, 0)
    title.Text = "€heat v1"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.BackgroundTransparency = 1
    table.insert(rainbowTexts, title)

    local minimize = Instance.new("TextButton", frame)
    minimize.Size = UDim2.new(0.2, 0, 0, 30)
    minimize.Position = UDim2.new(0.8, 0, 0, 0)
    minimize.Text = "-"
    minimize.BackgroundTransparency = 1
    minimize.TextColor3 = Color3.new(1,1,1)
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 20
    table.insert(rainbowTexts, minimize)

    -- Create tab buttons (UPDATED NAMES)
    local tabButtons = {}
    local tabs = {"PLAYER", "INTERFACE"} -- Changed to uppercase
    
    local tabContainer = Instance.new("Frame", frame)
    tabContainer.Size = UDim2.new(1, -20, 0, 30)
    tabContainer.Position = UDim2.new(0, 10, 0, 35)
    tabContainer.BackgroundTransparency = 1
    local tabLayout = Instance.new("UIListLayout", tabContainer)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    
    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton", tabContainer)
        tabBtn.Size = UDim2.new(0.5, -5, 1, 0)
        tabBtn.Text = tabName
        tabBtn.Name = tabName
        tabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
        tabBtn.TextColor3 = Color3.new(1, 1, 1)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        table.insert(tabButtons, tabBtn)
        table.insert(rainbowTabTexts, tabBtn) -- Add to rainbow tab texts
        rainbowButtons[tabBtn] = true
    end
    
    -- Create tab content frames
    local tabContent = Instance.new("Frame", frame)
    tabContent.Size = UDim2.new(1, -20, 1, -75)
    tabContent.Position = UDim2.new(0, 10, 0, 70)
    tabContent.BackgroundTransparency = 1
    
    local playerTab = Instance.new("ScrollingFrame", tabContent)
    playerTab.Size = UDim2.new(1, 0, 1, 0)
    playerTab.BackgroundTransparency = 1
    playerTab.CanvasSize = UDim2.new(0, 0, 0, 140) -- Reduced height since high jump was removed
    playerTab.ScrollBarThickness = 4
    playerTab.Visible = true
    playerTab.Name = "PLAYER"
    Instance.new("UIListLayout", playerTab).Padding = UDim.new(0, 8)
    
    local interfaceTab = Instance.new("ScrollingFrame", tabContent)
    interfaceTab.Size = UDim2.new(1, 0, 1, 0)
    interfaceTab.BackgroundTransparency = 1
    interfaceTab.CanvasSize = UDim2.new(0, 0, 0, 120)
    interfaceTab.ScrollBarThickness = 4
    interfaceTab.Visible = false
    interfaceTab.Name = "INTERFACE"
    Instance.new("UIListLayout", interfaceTab).Padding = UDim.new(0, 8)
    
    -- Function to switch tabs
    local function switchTab(tabName)
        playerTab.Visible = tabName == "PLAYER"
        interfaceTab.Visible = tabName == "INTERFACE"
        
        for _, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = btn.Name == tabName and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
        end
    end
    
    -- Connect tab buttons
    for _, btn in ipairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            switchTab(btn.Name)
        end)
    end
    
    -- Create buttons for each tab
    local function createButton(parent, name)
        local btn = Instance.new("TextButton", parent)
        btn.Name = name
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Text = name .. (name == "CHANGE SERVER" and "" or ": OFF")
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        table.insert(rainbowTexts, btn)
        rainbowButtons[btn] = true
        return btn
    end
    
    -- PLAYER Tab buttons (only Aimbot and Float remain)
    local aimbotBtn = createButton(playerTab, "AIMBOT")
    local floatBtn = createButton(playerTab, "FLOAT")
    
    -- INTERFACE Tab buttons
    local espBtn = createButton(interfaceTab, "ESP PLAYER")
    local serverHopBtn = createButton(interfaceTab, "CHANGE SERVER")
    
    -- Connect button functionality
    aimbotBtn.MouseButton1Click:Connect(function()
        aimbotEnabled = toggleButton(aimbotBtn)
        toggleAimbot(aimbotEnabled)
    end)
    
    floatBtn.MouseButton1Click:Connect(function()
        floatEnabled = toggleButton(floatBtn)
        toggleFloat(floatEnabled)
    end)
    
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = toggleButton(espBtn)
        toggleESP(espEnabled)
    end)
    
    serverHopBtn.MouseButton1Click:Connect(function()
        serverHopBtn.Text = "CHANGING SERVER..."
        serverHop()
    end)

    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        frame.Size = minimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 250)
        tabContainer.Visible = not minimized
        tabContent.Visible = not minimized
        minimize.Text = minimized and "+" or "-"
    end)

    -- Rainbow effect
    RunService.Heartbeat:Connect(updateRainbowColors)
end

-- Initialize
createMenu()tton1Click:Connect(function()
        espEnabled = toggleButton(espBtn)
        toggleESP(espEnabled)
    end)
    
    serverHopBtn.MouseButton1Click:Connect(function()
        serverHopBtn.Text = "CHANGING SERVER..."
        serverHop()
    end)

    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        frame.Size = minimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 250)
        tabContainer.Visible = not minimized
        tabContent.Visible = not minimized
        minimize.Text = minimized and "+" or "-"
    end)

    -- Rainbow effect
    RunService.Heartbeat:Connect(updateRainbowColors)
end

-- Initialize
createMenu()
