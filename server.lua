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
    radius = 5, -- Reduced spread radius to minimize scattering
    height = 30, -- Base height above player for floating
    rotationSpeed = 0.5, -- Slower rotation to reduce erratic movement
    attractionStrength = 30, -- Base velocity for close parts
    shootSpeed = 300, -- Speed for shooting parts to target
}

-- Filters parts to include in the collection (unanchored only)
function CollectModule.retainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false -- Exclude player
        end
        -- Disable collision for all collected parts to prevent scattering
        Part.CanCollide = false
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
                    local speed = CollectModule.config.attractionStrength + (distance * 20) -- Increased multiplier for stronger far pull
                    speed = math.min(speed, 1500) -- Higher cap for very far parts
                    -- Stronger damping when close to prevent overshoot and reverse movement
                    if distance < 10 then
                        speed = speed * 0.4
                    end
                    if distance < 3 then
                        speed = speed * 0.1
                    end
                    -- Additional anti-reverse: if moving away, boost pull slightly
                    local currentVelDot = part.Velocity:Dot(direction)
                    if currentVelDot < 0 and distance < 20 then
                        speed = speed * 1.5
                    end

                    -- Apply real velocity (replicates to all clients, allows collision)
                    part.Velocity = direction * speed

                    -- Ensure non-collidable and unanchored
                    part.CanCollide = false
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
    -- Clear all ESPs and selected targets
    for player, _ in pairs(ESPModule.esps) do
        ESPModule.removeESP(player)
    end
    -- Reset GUI states if needed (handled in button clicks)
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

    --// Click Sound
    local clickSound = Instance.new("Sound")
    clickSound.SoundId = "rbxassetid://131961136"
    clickSound.Volume = 0.5
    clickSound.Parent = gui

    --// Main Frame
    frame = Instance.new("Frame")
    frame.Parent = gui
    frame.Size = UDim2.new(0, 120, 0, 220) -- Initial height, will adjust
    frame.Position = UDim2.new(0.5, -60, 0.5, -110)
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
    minimize.MouseButton1Click:Connect(function()
        clickSound:Play()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 120, 0, 25) or UDim2.new(0, 120, 0, layout.AbsoluteContentSize.Y + 42)
        local targetText = minimized and "+" or "-"
        TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
        scroll.Visible = not minimized
        footer.Visible = not minimized
        minimize.Text = targetText
    end)

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
        frame.Size = UDim2.new(0, 120, 0, math.max(220, layout.AbsoluteContentSize.Y + 42))
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

    --// Header (Select Target)
    local headerButton = Instance.new("TextButton")
    headerButton.Parent = scroll
    headerButton.Size = UDim2.new(1, -10, 0, 20)
    headerButton.BackgroundTransparency = 1 -- fully transparent header
    headerButton.BorderSizePixel = 0
    headerButton.Font = Enum.Font.Code
    headerButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    headerButton.TextSize = 12
    headerButton.Text = "PLAYER LIST"
    headerButton.TextXAlignment = Enum.TextXAlignment.Center

    --// Player list container (slight transparency)
    playerScroll = Instance.new("ScrollingFrame")
    playerScroll.Parent = scroll
    playerScroll.Size = UDim2.new(1, -10, 0, 60)
    playerScroll.Position = UDim2.new(0, 5, 0, 25)
    playerScroll.BackgroundColor3 = Color3.new(0, 0, 0)
    playerScroll.BackgroundTransparency = 0.6 -- slight transparent effect
    playerScroll.BorderSizePixel = 0
    playerScroll.ScrollBarThickness = 2
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerScroll.Visible = false

    playerLayout = Instance.new("UIListLayout")
    playerLayout.Parent = playerScroll
    playerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    playerLayout.Padding = UDim.new(0, 1)

    --// Player list update function
    function GUIModule.updatePlayerList()
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

    GUIModule.updatePlayerList()
    Players.PlayerAdded:Connect(GUIModule.updatePlayerList)
    Players.PlayerRemoving:Connect(function(p)
        selectedTargets[p.Name] = nil
        ESPModule.removeESP(p)
        GUIModule.updatePlayerList()
    end)

    --// Toggle list visibility when clicking header
    headerButton.MouseButton1Click:Connect(function()
        clickSound:Play()
        listHidden = not listHidden
        local visible = not listHidden
        playerScroll.Visible = visible
        playerScroll.Size = visible and UDim2.new(1, -10, 0, 60) or UDim2.new(1, -10, 0, 0)
        updateScrollCanvas()
    end)

    --// Main Action Frame (FLOAT    SHOOT)
    local mainActionFrame = Instance.new("Frame")
    mainActionFrame.Parent = scroll
    mainActionFrame.Size = UDim2.new(1, -10, 0, 25)
    mainActionFrame.BackgroundTransparency = 1
    mainActionFrame.Visible = true

    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Parent = mainActionFrame
    mainLayout.FillDirection = Enum.FillDirection.Horizontal
    mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    mainLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    mainLayout.Padding = UDim.new(0, 10)

    -- FLOAT Button
    local floatButton = Instance.new("TextButton")
    floatButton.Parent = mainActionFrame
    floatButton.Size = UDim2.new(0, 50, 0, 20)
    floatButton.BackgroundColor3 = Color3.new(0, 0, 0)
    floatButton.BackgroundTransparency = 0.4
    floatButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    floatButton.BorderSizePixel = 1
    floatButton.Font = Enum.Font.Code
    floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatButton.TextSize = 12
    floatButton.Text = "FLOAT"
    floatButton.TextXAlignment = Enum.TextXAlignment.Center

    floatButton.MouseButton1Click:Connect(function()
        clickSound:Play()
        CollectModule.startCollect()
        game.StarterGui:SetCore("SendNotification", {
            Title = "hung",
            Text = "Collecting Parts!",
            Duration = 3,
        })
        mainActionFrame.Visible = false
        collectModeFrame.Visible = true
        updateScrollCanvas()
    end)

    -- SHOOT Button
    local shootEntryButton = Instance.new("TextButton")
    shootEntryButton.Parent = mainActionFrame
    shootEntryButton.Size = UDim2.new(0, 50, 0, 20)
    shootEntryButton.BackgroundColor3 = Color3.new(0, 0, 0)
    shootEntryButton.BackgroundTransparency = 0.4
    shootEntryButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    shootEntryButton.BorderSizePixel = 1
    shootEntryButton.Font = Enum.Font.Code
    shootEntryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    shootEntryButton.TextSize = 12
    shootEntryButton.Text = "SHOOT"
    shootEntryButton.TextXAlignment = Enum.TextXAlignment.Center

    shootEntryButton.MouseButton1Click:Connect(function()
        clickSound:Play()
        mainActionFrame.Visible = false
        shootModeFrame.Visible = true
        updateScrollCanvas()
    end)

    --// Collect Mode Frame (for FLOAT click)
    local collectModeFrame = Instance.new("Frame")
    collectModeFrame.Parent = scroll
    collectModeFrame.Size = UDim2.new(1, -10, 0, 65)
    collectModeFrame.BackgroundTransparency = 1
    collectModeFrame.Visible = false

    local collectModeLayout = Instance.new("UIListLayout")
    collectModeLayout.Parent = collectModeFrame
    collectModeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    collectModeLayout.Padding = UDim.new(0, 5)

    -- COLLECT Button in collect mode (Pull Unanchored & Orbit logic)
    local collectButton = Instance.new("TextButton")
    collectButton.Parent = collectModeFrame
    collectButton.Size = UDim2.new(1, 0, 0, 20)
    collectButton.BackgroundColor3 = Color3.new(0, 0, 0)
    collectButton.BackgroundTransparency = 0.4
    collectButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    collectButton.BorderSizePixel = 1
    collectButton.Font = Enum.Font.Code
    collectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    collectButton.TextSize = 12
    collectButton.Text = "COLLECT"
    collectButton.TextXAlignment = Enum.TextXAlignment.Center

    collectButton.MouseButton1Click:Connect(function()
        clickSound:Play()
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
                return
            end

            OrbitModule.startOrbit(partsToOrbit, root)

            game.StarterGui:SetCore("SendNotification", {
                Title = "Success",
                Text = #partsToOrbit .. " unanchored parts pulled and orbiting above you (replicated & lag-optimized)",
                Duration = 4,
            })
        end)
    end)

    -- STOP Button in collect mode
    local stopButton = Instance.new("TextButton")
    stopButton.Parent = collectModeFrame
    stopButton.Size = UDim2.new(1, 0, 0, 20)
    stopButton.BackgroundColor3 = Color3.new(0, 0, 0)
    stopButton.BackgroundTransparency = 0.4
    stopButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    stopButton.BorderSizePixel = 1
    stopButton.Font = Enum.Font.Code
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextSize = 12
    stopButton.Text = "STOP"
    stopButton.TextXAlignment = Enum.TextXAlignment.Center

    stopButton.MouseButton1Click:Connect(function()
        clickSound:Play()
        ResetModule.resetAll()
        CollectModule.stopCollect()
        game.StarterGui:SetCore("SendNotification", {
            Title = "hung",
            Text = "All effects stopped and reset!",
            Duration = 3,
        })
    end)

    -- BACK Button in collect mode
    local backButtonCollect = Instance.new("TextButton")
    backButtonCollect.Parent = collectModeFrame
    backButtonCollect.Size = UDim2.new(1, 0, 0, 20)
    backButtonCollect.BackgroundColor3 = Color3.new(0, 0, 0)
    backButtonCollect.BackgroundTransparency = 0.4
    backButtonCollect.BorderColor3 = Color3.fromRGB(255, 0, 0)
    backButtonCollect.BorderSizePixel = 1
    backButtonCollect.Font = Enum.Font.Code
    backButtonCollect.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButtonCollect.TextSize = 12
    backButtonCollect.Text = "BACK"
    backButtonCollect.TextXAlignment = Enum.TextXAlignment.Center

    backButtonCollect.MouseButton1Click:Connect(function()
        clickSound:Play()
        mainActionFrame.Visible = true
        collectModeFrame.Visible = false
        updateScrollCanvas()
    end)

    --// Shoot Mode Frame (for SHOOT click)
    local shootModeFrame = Instance.new("Frame")
    shootModeFrame.Parent = scroll
    shootModeFrame.Size = UDim2.new(1, -10, 0, 65)
    shootModeFrame.BackgroundTransparency = 1
    shootModeFrame.Visible = false

    local shootModeLayout = Instance.new("UIListLayout")
    shootModeLayout.Parent = shootModeFrame
    shootModeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    shootModeLayout.Padding = UDim.new(0, 5)

    -- COLLECT Button in shoot mode (same as above)
    local collectButtonShoot = Instance.new("TextButton")
    collectButtonShoot.Parent = shootModeFrame
    collectButtonShoot.Size = UDim2.new(1, 0, 0, 20)
    collectButtonShoot.BackgroundColor3 = Color3.new(0, 0, 0)
    collectButtonShoot.BackgroundTransparency = 0.4
    collectButtonShoot.BorderColor3 = Color3.fromRGB(255, 0, 0)
    collectButtonShoot.BorderSizePixel = 1
    collectButtonShoot.Font = Enum.Font.Code
    collectButtonShoot.TextColor3 = Color3.fromRGB(255, 255, 255)
    collectButtonShoot.TextSize = 12
    collectButtonShoot.Text = "COLLECT"
    collectButtonShoot.TextXAlignment = Enum.TextXAlignment.Center

    collectButtonShoot.MouseButton1Click:Connect(function()
        clickSound:Play()
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
                return
            end

            OrbitModule.startOrbit(partsToOrbit, root)

            game.StarterGui:SetCore("SendNotification", {
                Title = "Success",
                Text = #partsToOrbit .. " unanchored parts pulled and orbiting above you (replicated & lag-optimized)",
                Duration = 4,
            })
        end)
    end)

    -- SHOOT Button in shoot mode
    local shootActionButton = Instance.new("TextButton")
    shootActionButton.Parent = shootModeFrame
    shootActionButton.Size = UDim2.new(1, 0, 0, 20)
    shootActionButton.BackgroundColor3 = Color3.new(0, 0, 0)
    shootActionButton.BackgroundTransparency = 0.4
    shootActionButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    shootActionButton.BorderSizePixel = 1
    shootActionButton.Font = Enum.Font.Code
    shootActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    shootActionButton.TextSize = 12
    shootActionButton.Text = "SHOOT"
    shootActionButton.TextXAlignment = Enum.TextXAlignment.Center

    shootActionButton.MouseButton1Click:Connect(function()
        clickSound:Play()
        if CollectModule.shootToTargets(selectedTargets) then
            game.StarterGui:SetCore("SendNotification", {
                Title = "hung",
                Text = "Parts shot to targets!",
                Duration = 3,
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "hung",
                Text = "Collect parts first or select targets!",
                Duration = 3,
            })
        end
    end)

    -- BACK Button in shoot mode
    local backButtonShoot = Instance.new("TextButton")
    backButtonShoot.Parent = shootModeFrame
    backButtonShoot.Size = UDim2.new(1, 0, 0, 20)
    backButtonShoot.BackgroundColor3 = Color3.new(0, 0, 0)
    backButtonShoot.BackgroundTransparency = 0.4
    backButtonShoot.BorderColor3 = Color3.fromRGB(255, 0, 0)
    backButtonShoot.BorderSizePixel = 1
    backButtonShoot.Font = Enum.Font.Code
    backButtonShoot.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButtonShoot.TextSize = 12
    backButtonShoot.Text = "BACK"
    backButtonShoot.TextXAlignment = Enum.TextXAlignment.Center

    backButtonShoot.MouseButton1Click:Connect(function()
        clickSound:Play()
        mainActionFrame.Visible = true
        shootModeFrame.Visible = false
        updateScrollCanvas()
    end)

    updateScrollCanvas()

    --// Notification
    game.StarterGui:SetCore("SendNotification", {
        Title = "hung v1",
        Text = "Modular GUI Loaded (Orbit + Collect/Shoot with Dynamic ESP)",
        Duration = 4,
    })
end

--// Initialize
GUIModule.setupGUI()
