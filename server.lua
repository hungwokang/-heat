--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Bypass for simulation ownership (exploit required)
local function setupBypass()
    if getgenv().SimRadiusSet ~= true then
        getgenv().SimRadiusSet = true
        pcall(function()
            LocalPlayer.ReplicationFocus = workspace
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        end)
    end
end

--// Network ownership bypass module
local NetworkModule
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    -- Retain network ownership of parts (preserve collidability)
    getgenv().Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(getgenv().Network.BaseParts, Part)
            -- Set network ownership to local player for full control, even at distance
            pcall(function() Part:SetNetworkOwner(LocalPlayer) end)
            -- Remove CustomPhysicalProperties to allow real physics
            if Part:FindFirstChildOfClass("CustomPhysicalProperties") then
                Part:FindFirstChildOfClass("CustomPhysicalProperties"):Destroy()
            end
            -- Disable collision to prevent parts from pushing each other away
            Part.CanCollide = false
        end
    end

    -- Force server to replicate part changes
    local function enablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) -- Bypass distance limit
            for _, Part in pairs(getgenv().Network.BaseParts) do
                if Part:IsDescendantOf(Workspace) and Part.Parent then
                    -- Ensure no collision during control
                    Part.CanCollide = false
                end
            end
        end)
    end

    enablePartControl()
end
NetworkModule = getgenv().Network

--// Orbiting module
local OrbitModule = {}
OrbitModule.orbitingParts = {}
OrbitModule.orbitingConnection = nil
OrbitModule.orbitSpeed = 5 -- radians per second
OrbitModule.orbitRadius = 15
OrbitModule.orbitHeight = 10

function OrbitModule.startOrbit(partsToOrbit, root)
    if #partsToOrbit == 0 then return end

    -- Stop previous orbit
    OrbitModule.stopOrbit()

    -- Process parts
    for i, part in ipairs(partsToOrbit) do
        pcall(function()
            -- Clean existing controllers
            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("BodyMover") or child:IsA("AlignPosition") or child:IsA("VectorForce") or child:IsA("Torque") then
                    child:Destroy()
                end
            end

            -- Optimize physics
            part.CanCollide = false
            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)

            -- Add spinning
            local bav = Instance.new("BodyAngularVelocity")
            bav.MaxTorque = Vector3.new(0, math.huge, 0)
            bav.AngularVelocity = Vector3.new(0, 20, 0)
            bav.Parent = part

            -- Add position control for orbit
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bp.Position = part.Position -- Start from current to avoid snap
            bp.P = 5000 -- High power for fast pull
            bp.D = 1000 -- Damping
            bp.Parent = part

            -- Store data
            local baseAngle = (i / #partsToOrbit) * math.pi * 2
            local heightOffset = math.floor((i - 1) / 20) * 1 -- Stack every 20 parts
            local partRadius = OrbitModule.orbitRadius + ((i - 1) % 20) * 0.2 -- Slight radius variation
            table.insert(OrbitModule.orbitingParts, {
                part = part,
                bp = bp,
                bav = bav,
                baseAngle = baseAngle,
                heightOffset = heightOffset,
                radius = partRadius
            })
        end)
    end

    -- Start orbiting loop (efficient Heartbeat)
    local lastTime = tick()
    OrbitModule.orbitingConnection = RunService.Heartbeat:Connect(function()
        local deltaTime = tick() - lastTime
        lastTime = tick()

        if not root or #OrbitModule.orbitingParts == 0 then
            return
        end

        local cf = root.CFrame
        local rightVec = cf.RightVector
        local lookVec = cf.LookVector
        local upVec = cf.UpVector

        for _, data in ipairs(OrbitModule.orbitingParts) do
            if data.part.Parent and data.bp.Parent then
                local currentTime = tick()
                local angle = data.baseAngle + (OrbitModule.orbitSpeed * currentTime)
                local xOffset = math.cos(angle) * data.radius
                local zOffset = math.sin(angle) * data.radius
                local targetPos = root.Position + (upVec * (OrbitModule.orbitHeight + data.heightOffset)) + (rightVec * xOffset) + (lookVec * zOffset)
                data.bp.Position = targetPos
            end
        end
    end)
end

function OrbitModule.stopOrbit()
    if OrbitModule.orbitingConnection then
        OrbitModule.orbitingConnection:Disconnect()
        OrbitModule.orbitingConnection = nil
    end

    -- Clean up parts
    for _, data in ipairs(OrbitModule.orbitingParts) do
        if data.part and data.part.Parent then
            if data.bp then data.bp:Destroy() end
            if data.bav then data.bav:Destroy() end
            data.part.CanCollide = true -- Reset collision
            data.part.CustomPhysicalProperties = nil -- Reset physics
        end
    end
    OrbitModule.orbitingParts = {}
end




































































--// Collect/Shoot module
local CollectModule = {}
CollectModule.ringPartsEnabled = false
CollectModule.parts = {} -- Table of parts in the collection
CollectModule.config = {
    radius = 0, -- Reduced spread radius to minimize scattering
    height = 20, -- Base height above player for floating
    rotationSpeed = 0.1, -- Slower rotation to reduce erratic movement
    attractionStrength = 50, -- 30 Base velocity for close parts
    shootSpeed = 300, -- Speed for shooting parts to target
}

-- Filters parts to include in the collection (unanchored only)
function CollectModule.retainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false -- Exclude player
        end
        -- Disable collision for all collected parts to prevent scattering
        Part.CanCollide = true
        -- Retain network ownership (now includes SetNetworkOwner)
        NetworkModule.RetainPart(Part)
        return true
    end
    return false
end

-- Add part to collection list (no limit)
function CollectModule.addPart(part)
    if CollectModule.retainPart(part) then
        if not table.find(CollectModule.parts, part) then
            table.insert(CollectModule.parts, part)
        end
    end
end

-- Remove part when destroyed
function CollectModule.removePart(part)
    local index = table.find(CollectModule.parts, part)
    if index then
        table.remove(CollectModule.parts, index)
    end
    -- Clean up from network list if needed
    local netIndex = table.find(NetworkModule.BaseParts, part)
    if netIndex then
        table.remove(NetworkModule.BaseParts, netIndex)
    end
end

-- Initialize with existing unanchored parts (no limit)
local function initializeParts()
    local tempParts = {}
    for _, part in pairs(workspace:GetDescendants()) do
        if CollectModule.retainPart(part) and not table.find(tempParts, part) then
            table.insert(tempParts, part)
        end
    end
    for _, part in pairs(tempParts) do
        table.insert(CollectModule.parts, part)
    end
end

-- Listen for new/destroyed parts
workspace.DescendantAdded:Connect(CollectModule.addPart)
workspace.DescendantRemoving:Connect(CollectModule.removePart)

-- Main collection loop - runs every frame (floating above and following)
local collectConnection
collectConnection = RunService.Heartbeat:Connect(function()
    if not CollectModule.ringPartsEnabled then return end

    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local playerPos = humanoidRootPart.Position
        local time = tick()
        for i, part in pairs(CollectModule.parts) do
            if part.Parent and part and part.Parent ~= nil and part:IsDescendantOf(workspace) then
                -- Calculate floating position above player (orbiting for spread)
                local angle = (time * CollectModule.config.rotationSpeed) + (i * math.pi * 2 / math.max(#CollectModule.parts, 1)) -- Unique angle per part, avoid div0
                local offsetX = math.sin(angle) * CollectModule.config.radius
                local offsetZ = math.cos(angle) * CollectModule.config.radius
                local floatHeight = CollectModule.config.height + math.sin(time * 2 + i) * 2 -- Slight bobbing for floating effect
                local targetPos = playerPos + Vector3.new(offsetX, floatHeight, offsetZ)

                -- Direction and distance
                local directionVector = (targetPos - part.Position)
                local distance = directionVector.Magnitude
                if distance > 0 then
                    local direction = directionVector.Unit
                    -- More aggressive pull for far distances: higher multiplier and cap
                    local speed = CollectModule.config.attractionStrength + (distance * 50) -- Increased multiplier for stronger far pull 20
                    speed = math.min(speed, 5000) -- Higher cap for very far parts 1500
                    -- Stronger damping when close to prevent overshoot and reverse movement
                    if distance < 10 then
                        speed = speed * 0.4
                    end
                    if distance < 3 then
                        speed = speed * 0.1
                    end
                    -- Additional anti-reverse: if moving away, boost pull slightly
                    local currentVelDot = part.Velocity:Dot(direction)
                    if currentVelDot < 0 and distance < 500 then -- 20
                        speed = speed * 1.5
                    end

                    -- Apply real velocity (replicates to all clients, allows collision)
                    part.Velocity = direction * speed

                    -- Ensure non-collidable and unanchored
                    part.CanCollide = true
                    part.Anchored = false
                else
                    -- If already at target, zero velocity to stop
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

function CollectModule.startCollect()
    CollectModule.ringPartsEnabled = true
end

function CollectModule.stopCollect()
    CollectModule.ringPartsEnabled = false
    -- Reset velocities on parts
    for _, part in pairs(CollectModule.parts) do
        if part and part.Parent then
            part.Velocity = Vector3.new(0, 0, 0)
            part.CanCollide = true -- Reset collision
        end
    end
end

function CollectModule.shootToTargets(selectedTargets)
    if #CollectModule.parts == 0 then return false end
    local targets = {}
    for _, player in pairs(selectedTargets) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, player.Character.HumanoidRootPart)
        end
    end
    if #targets == 0 then return false end
    -- Re-enable collision for shooting (optional, for impact)
    for _, part in pairs(CollectModule.parts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    -- Shoot
    local numTargets = #targets
    local partIndex = 1
    for i, part in pairs(CollectModule.parts) do
        if part and part.Parent then
            local target = targets[partIndex % numTargets + 1] -- Cycle through targets
            if target then
                local direction = (target.Position - part.Position).Unit
                part.Velocity = direction * CollectModule.config.shootSpeed
            end
            partIndex = partIndex + 1
        end
    end
    -- Clear parts after shooting
    CollectModule.parts = {}
    return true
end









--// ESP module for dynamic target players
local ESPModule = {}
ESPModule.esps = {}

function ESPModule.createESP(player)
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
    }
    esp.box.Visible = false
    esp.box.Color = Color3.new(1, 0, 0)
    esp.box.Thickness = 2
    esp.box.Transparency = 0.5
    esp.box.Filled = false
    esp.box.Radius = 0

    esp.name.Visible = false
    esp.name.Color = Color3.new(1, 0, 0)
    esp.name.Size = 16
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Font = 2

    ESPModule.esps[player] = esp
end

function ESPModule.removeESP(player)
    if ESPModule.esps[player] then
        ESPModule.esps[player].box:Remove()
        ESPModule.esps[player].name:Remove()
        ESPModule.esps[player] = nil
    end
end

-- ESP update loop
local espConnection = RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESPModule.esps) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            if onScreen then
                local headPos = workspace.CurrentCamera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                local legPos = workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 4, 0))
                local width = math.abs(headPos.X - legPos.X) * 0.5
                local height = math.abs(headPos.Y - legPos.Y)

                esp.box.Size = Vector2.new(width * 2, height)
                esp.box.Position = Vector2.new(pos.X - width, pos.Y - height / 2)
                esp.box.Visible = true

                esp.name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 20)
                esp.name.Text = player.Name
                esp.name.Visible = true
            else
                esp.box.Visible = false
                esp.name.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
        end
    end
end)

--// Reset module - full reset
local ResetModule = {}

function ResetModule.resetAll()
    -- Stop orbit
    OrbitModule.stopOrbit()
    -- Stop collect
    CollectModule.stopCollect()
    -- Clear network parts
    NetworkModule.BaseParts = {}
    -- Reinitialize parts for future use
    initializeParts()
    
    -- selectedTargets = {} -- DONT INCLUDE target list to be reset
end

--// GUI Module
local GUIModule = {}
local gui, frame, scroll, layout, playerScroll, playerLayout, selectedTargets, listHidden, minimized = nil, nil, nil, nil, nil, nil, {}, false, false
local footer -- To make it accessible in closure


function GUIModule.setupGUI()
    setupBypass()
    initializeParts()

    --// GUI Setup
    gui = Instance.new("ScreenGui")
    gui.Name = "ServerGUI"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    --// Main Frame
    frame = Instance.new("Frame")
    frame.Parent = gui
    frame.Size = UDim2.new(0, 120, 0, 100) -- Initial smaller height
    frame.Position = UDim2.new(0.5, -60, 0.5, -50)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    frame.Active = true
    frame.Draggable = true

    --// Title bar
    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.Text = "hung v1"
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Center

    --// Minimize button
    local minimize = Instance.new("TextButton")
    minimize.Parent = frame
    minimize.Size = UDim2.new(0, 20, 0, 20)
    minimize.Position = UDim2.new(1, -22, 0, 0)
    minimize.Text = "-"
    minimize.Font = Enum.Font.Code
    minimize.TextSize = 14
    minimize.BackgroundTransparency = 1
    minimize.TextColor3 = Color3.fromRGB(255, 0, 0)

    --// Scroll Holder
    scroll = Instance.new("ScrollingFrame")
    scroll.Parent = frame
    scroll.Position = UDim2.new(0, 0, 0, 22)
    scroll.Size = UDim2.new(1, 0, 1, -42)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 2

    --// Layout
    layout = Instance.new("UIListLayout")
    layout.Parent = scroll
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    local function updateScrollCanvas()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        -- Auto-fit frame height
        local newHeight = math.max(110, layout.AbsoluteContentSize.Y + 42) -- Min height 100, + title 20 + footer 20 + padding
        frame.Size = UDim2.new(0, 120, 0, newHeight)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollCanvas)

    --// Footer
    footer = Instance.new("TextLabel")
    footer.Parent = frame
    footer.Size = UDim2.new(1, 0, 0, 20)
    footer.Position = UDim2.new(0, 0, 1, -20)
    footer.BackgroundTransparency = 1
    footer.Font = Enum.Font.Code
    footer.Text = "published by server"
    footer.TextColor3 = Color3.fromRGB(255, 0, 0)
    footer.TextSize = 10
    footer.TextXAlignment = Enum.TextXAlignment.Center

    --// Rainbow TextLabel
    local textHue = 0
    local rainbowTexts = {title, footer}
    RunService.Heartbeat:Connect(function()
        textHue = (textHue + 0.01) % 1
        local color = Color3.fromHSV(textHue, 1, 1)
        for _, text in pairs(rainbowTexts) do
            text.TextColor3 = color
        end
    end)

    layout.Name = "ScrollLayout"

    --// Player list update function
    function GUIModule.updatePlayerList()
        if not playerScroll then return end
        for _, btn in pairs(playerScroll:GetChildren()) do
            if btn:IsA("TextButton") then btn:Destroy() end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Name = p.Name
                btn.Parent = playerScroll
                btn.Size = UDim2.new(0.95, 0, 0, 16)
                btn.BackgroundTransparency = 1
                btn.Text = selectedTargets[p.Name] and (p.Name .. " ✓") or p.Name
                btn.TextColor3 = selectedTargets[p.Name] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.Code
                btn.TextSize = 10
                btn.TextXAlignment = Enum.TextXAlignment.Left

                btn.MouseButton1Click:Connect(function()
                    if selectedTargets[p.Name] then
                        selectedTargets[p.Name] = nil
                        ESPModule.removeESP(p)
                        btn.Text = p.Name
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        selectedTargets[p.Name] = p
                        ESPModule.createESP(p)
                        btn.Text = p.Name .. " ✓"
                        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
                end)
            end
        end
        playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y)
        updateScrollCanvas()
    end

    Players.PlayerAdded:Connect(GUIModule.updatePlayerList)
    Players.PlayerRemoving:Connect(function(p)
        selectedTargets[p.Name] = nil
        ESPModule.removeESP(p)
        GUIModule.updatePlayerList()
    end)

    --// Minimize toggle
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        local currentHeight = frame.Size.Y.Offset
        local targetSize = minimized and UDim2.new(0, 120, 0, 25) or UDim2.new(0, 120, 0, currentHeight)
        local targetText = minimized and "+" or "-"
        TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
        scroll.Visible = not minimized
        footer.Visible = not minimized
        minimize.Text = targetText
    end)

    -- Tab system
    local orbitButtonText = "SEARCH"
    local shootButtonText = "SEARCH"

    local function clearTabContent()
        for _, child in pairs(scroll:GetChildren()) do
            local name = child.Name
            if name ~= "ScrollLayout" then
                child:Destroy()
            end
        end
        playerScroll = nil
        playerLayout = nil
        headerButton = nil
        listHidden = false
    end

    local function buildMainTab()
        clearTabContent()
        -- Add margin above buttons
        local marginFrame = Instance.new("Frame")
        marginFrame.Name = "MarginFrame"
        marginFrame.Size = UDim2.new(1, 0, 0, 3)
        marginFrame.BackgroundTransparency = 1
        marginFrame.Parent = scroll

        local tabFrame = Instance.new("Frame")
        tabFrame.Name = "MainTabFrame"
        tabFrame.Size = UDim2.new(1, 0, 0, 25)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Parent = scroll

        local hLayout = Instance.new("UIListLayout")
        hLayout.FillDirection = Enum.FillDirection.Horizontal
        hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        hLayout.Padding = UDim.new(0, 5)
        hLayout.Parent = tabFrame

        local orbitTabBtn = Instance.new("TextButton")
        orbitTabBtn.Name = "OrbitTabBtn"
        orbitTabBtn.Parent = tabFrame
        orbitTabBtn.Size = UDim2.new(0.45, 0, 1, 0)
        orbitTabBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        orbitTabBtn.BackgroundTransparency = 0.6
        orbitTabBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        orbitTabBtn.BorderSizePixel = 1
        orbitTabBtn.Font = Enum.Font.Code
        orbitTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        orbitTabBtn.TextSize = 12
        orbitTabBtn.Text = "ORBIT"
        orbitTabBtn.TextXAlignment = Enum.TextXAlignment.Center
        orbitTabBtn.MouseButton1Click:Connect(function()
            clearTabContent()
            buildOrbitTab()
        end)

        local shootTabBtn = Instance.new("TextButton")
        shootTabBtn.Name = "ShootTabBtn"
        shootTabBtn.Parent = tabFrame
        shootTabBtn.Size = UDim2.new(0.45, 0, 1, 0)
        shootTabBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        shootTabBtn.BackgroundTransparency = 0.6
        shootTabBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        shootTabBtn.BorderSizePixel = 1
        shootTabBtn.Font = Enum.Font.Code
        shootTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        shootTabBtn.TextSize = 12
        shootTabBtn.Text = "SHOOT"
        shootTabBtn.TextXAlignment = Enum.TextXAlignment.Center
        shootTabBtn.MouseButton1Click:Connect(function()
            clearTabContent()
            buildShootTab()
        end)
        updateScrollCanvas()
    end

    function buildOrbitTab()
        clearTabContent()
        local pullText = Instance.new("TextLabel")
        pullText.Name = "PullText"
        pullText.Parent = scroll
        pullText.Size = UDim2.new(1, -10, 0, 15)
        pullText.BackgroundTransparency = 1
        pullText.Font = Enum.Font.Code
        pullText.TextColor3 = Color3.new(1, 1, 1)
        pullText.TextSize = 8
        pullText.Text = "Pull unanchored loose parts."
        pullText.TextXAlignment = Enum.TextXAlignment.Center

        local searchBtn = Instance.new("TextButton")
        searchBtn.Name = "SearchBtn"
        searchBtn.Parent = scroll
        searchBtn.Size = UDim2.new(1, -10, 0, 20)
        searchBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        searchBtn.BackgroundTransparency = 0.6
        searchBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        searchBtn.BorderSizePixel = 1
        searchBtn.Font = Enum.Font.Code
        searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        searchBtn.TextSize = 12
        searchBtn.Text = "SEARCH"
        searchBtn.TextXAlignment = Enum.TextXAlignment.Center

        local isOrbiting = false
        searchBtn.MouseButton1Click:Connect(function()
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Error",
                        Text = "No character found",
                        Duration = 3,
                    })
                    return
                end

                local root = character.HumanoidRootPart
                if not isOrbiting then
                    pullText.Text = "Searching Parts..."
                    local partsToOrbit = {}
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and not obj.Anchored and obj.Name ~= "HumanoidRootPart" and not obj:IsDescendantOf(character) then
                            table.insert(partsToOrbit, obj)
                        end
                    end

                    if #partsToOrbit == 0 then
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Info",
                            Text = "No unanchored parts found",
                            Duration = 3,
                        })
                        pullText.Text = "Pull unanchored loose parts."
                        return
                    end

                    OrbitModule.startOrbit(partsToOrbit, root)

                    isOrbiting = true
                    searchBtn.Text = "STOP"

                    game.StarterGui:SetCore("SendNotification", {
                        Title = "hung v1",
                        Text = #partsToOrbit .. " unanchored parts pulled and orbiting above you",
                        Duration = 4,
                    })
                else
                    ResetModule.resetAll()

                    isOrbiting = false
                    searchBtn.Text = "SEARCH"
                    pullText.Text = "Pull unanchored loose parts."

                    game.StarterGui:SetCore("SendNotification", {
                        Title = "hung v1",
                        Text = "Orbit stopped!",
                        Duration = 3,
                    })
                end
            end)
        end)

        local backBtn = Instance.new("TextButton")
        backBtn.Name = "BackBtn"
        backBtn.Parent = scroll
        backBtn.Size = UDim2.new(1, -10, 0, 20)
        backBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        backBtn.BackgroundTransparency = 0.6
        backBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        backBtn.BorderSizePixel = 1
        backBtn.Font = Enum.Font.Code
        backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        backBtn.TextSize = 12
        backBtn.Text = "BACK"
        backBtn.TextXAlignment = Enum.TextXAlignment.Center
        backBtn.MouseButton1Click:Connect(function()
            clearTabContent()
            buildMainTab()
        end)
        updateScrollCanvas()
    end

    function buildShootTab()
        clearTabContent()
        --// Header (Select Target)
        local headerButton = Instance.new("TextButton")
        headerButton.Parent = scroll
        headerButton.Name = "PlayerListHeader"
        headerButton.Size = UDim2.new(1, -10, 0, 20)
        headerButton.BackgroundTransparency = 1
        headerButton.BorderSizePixel = 0
        headerButton.Font = Enum.Font.Code
        headerButton.TextColor3 = Color3.fromRGB(255, 0, 0)
        headerButton.TextSize = 12
        headerButton.Text = "SELECT PLAYER"
        headerButton.TextXAlignment = Enum.TextXAlignment.Center

        --// Player list container
        playerScroll = Instance.new("ScrollingFrame")
        playerScroll.Name = "PlayerListScroll"
        playerScroll.Parent = scroll
        playerScroll.Size = UDim2.new(1, -10, 0, 60)
        playerScroll.Position = UDim2.new(0, 5, 0, 0)
        playerScroll.BackgroundColor3 = Color3.new(0, 0, 0)
        playerScroll.BackgroundTransparency = 0.6
        playerScroll.BorderSizePixel = 0
        playerScroll.ScrollBarThickness = 2
        playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

        playerLayout = Instance.new("UIListLayout")
        playerLayout.Parent = playerScroll
        playerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        playerLayout.Padding = UDim.new(0, 1)

        GUIModule.updatePlayerList()

        --// Toggle list visibility when clicking header
        headerButton.MouseButton1Click:Connect(function()
            listHidden = not listHidden
            playerScroll.Visible = not listHidden
            updateScrollCanvas()
        end)

        playerScroll.Visible = true

        local shootText = Instance.new("TextLabel")
        shootText.Name = "ShootText"
        shootText.Parent = scroll
        shootText.Size = UDim2.new(1, -10, 0, 15)
        shootText.BackgroundTransparency = 1
        shootText.Font = Enum.Font.Code
        shootText.TextColor3 = Color3.new(1, 1, 1)
        shootText.TextSize = 8
        shootText.Text = "Shoot parts to target."
        shootText.TextXAlignment = Enum.TextXAlignment.Center

        local searchBtn = Instance.new("TextButton")
        searchBtn.Name = "SearchBtn"
        searchBtn.Parent = scroll
        searchBtn.Size = UDim2.new(1, -10, 0, 20)
        searchBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        searchBtn.BackgroundTransparency = 0.6
        searchBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        searchBtn.BorderSizePixel = 1
        searchBtn.Font = Enum.Font.Code
        searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        searchBtn.TextSize = 12
        searchBtn.Text = "SEARCH"
        searchBtn.TextXAlignment = Enum.TextXAlignment.Center

        local isCollecting = false
        searchBtn.MouseButton1Click:Connect(function()
            if not isCollecting then
                shootText.Text = "Searching Parts..."
                CollectModule.startCollect()
                isCollecting = true
                searchBtn.Text = "SHOT"
                game.StarterGui:SetCore("SendNotification", {
                    Title = "hung v1",
                    Text = "Collecting Parts!",
                    Duration = 3,
                })
            else
                CollectModule.stopCollect()
                if CollectModule.shootToTargets(selectedTargets) then
                    searchBtn.Text = "SEARCH"
                    isCollecting = false
                    shootText.Text = "Shoot parts to target."
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "hung v1",
                        Text = "Parts shot to targets!",
                        Duration = 3,
                    })
                    ResetModule.resetAll()
                else
                    searchBtn.Text = "SEARCH"
                    isCollecting = false
                    shootText.Text = "Shoot parts to target."
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "hung v1",
                        Text = "Collect parts first or select targets!",
                        Duration = 3,
                    })
                end
            end
            updateScrollCanvas()
        end)

        local backBtn = Instance.new("TextButton")
        backBtn.Name = "BackBtn"
        backBtn.Parent = scroll
        backBtn.Size = UDim2.new(1, -10, 0, 20)
        backBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        backBtn.BackgroundTransparency = 0.6
        backBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
        backBtn.BorderSizePixel = 1
        backBtn.Font = Enum.Font.Code
        backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        backBtn.TextSize = 12
        backBtn.Text = "BACK"
        backBtn.TextXAlignment = Enum.TextXAlignment.Center
        backBtn.MouseButton1Click:Connect(function()
            clearTabContent()
            buildMainTab()
        end)
        updateScrollCanvas()
    end

    buildMainTab()

    --// Notification
    game.StarterGui:SetCore("SendNotification", {
        Title = "hung v1",
        Text = "Modular GUI Loaded (Orbit + Collect/Shoot with Dynamic ESP)",
        Duration = 4,
    })
end

--// Initialize
GUIModule.setupGUI()
