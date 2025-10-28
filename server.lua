--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Infinite Simulation Radius
RunService.Heartbeat:Connect(function()
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)
end)
LocalPlayer.ReplicationFocus = Workspace

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "ServerGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

--// Main Frame
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 120, 0, 160)
frame.Position = UDim2.new(0.5, -60, 0.5, -80)
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
title.Text = "hung"
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
local scroll = Instance.new("ScrollingFrame")
scroll.Parent = frame
scroll.Position = UDim2.new(0, 0, 0, 22)
scroll.Size = UDim2.new(1, 0, 1, -42)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 2

--// Layout
local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local function updateScrollCanvas()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollCanvas)

--// Footer
local footer = Instance.new("TextLabel")
footer.Parent = frame
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.Font = Enum.Font.Code
footer.Text = "published by server"
footer.TextColor3 = Color3.fromRGB(255, 0, 0)
footer.TextSize = 10
footer.TextXAlignment = Enum.TextXAlignment.Center

--// Header (Select Target)
local headerButton = Instance.new("TextButton")
headerButton.Parent = scroll
headerButton.Size = UDim2.new(1, -10, 0, 20)
headerButton.BackgroundTransparency = 1 -- fully transparent header
headerButton.BorderSizePixel = 0
headerButton.Font = Enum.Font.Code
headerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
headerButton.TextSize = 12
headerButton.Text = "Select Target"
headerButton.TextXAlignment = Enum.TextXAlignment.Center

--// Player list container (slight transparency)
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Parent = scroll
playerScroll.Size = UDim2.new(1, -10, 0, 60)
playerScroll.Position = UDim2.new(0, 5, 0, 0)
playerScroll.BackgroundColor3 = Color3.new(0, 0, 0)
playerScroll.BackgroundTransparency = 0.6 -- slight transparent effect
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 2
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local playerLayout = Instance.new("UIListLayout")
playerLayout.Parent = playerScroll
playerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 1)

local selectedTargets = {}
local listHidden = false

--// Player list update
local function updatePlayerList()
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
                    btn.Text = p.Name
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    selectedTargets[p.Name] = p
                    btn.Text = p.Name .. " ✓"
                    btn.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
            end)
        end
    end
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y)
    updateScrollCanvas()
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

--// Toggle list visibility when clicking header
headerButton.MouseButton1Click:Connect(function()
    listHidden = not listHidden
    playerScroll.Visible = not listHidden
end)

--// Minimize toggle
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 120, 0, 25) or UDim2.new(0, 120, 0, 160)
    local targetText = minimized and "+" or "-"
    TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = targetSize
    }):Play()
    scroll.Visible = not minimized
    footer.Visible = not minimized
    minimize.Text = targetText
end)

--// Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "hung",
    Text = "Player List GUI Loaded",
    Duration = 4,
})

--// Parts collection and auto refresh
local parts = {}
local MAX_PARTS = 10
local function collectParts()
    parts = {}
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local candidates = {}
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(Workspace) then
            if part.Parent == LocalPlayer.Character or part:IsDescendantOf(LocalPlayer.Character) then
                -- skip
            else
                table.insert(candidates, part)
            end
        end
    end
    
    -- Sort by distance
    table.sort(candidates, function(a, b)
        return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
    end)
    
    for i = 1, math.min(MAX_PARTS, #candidates) do
        table.insert(parts, candidates[i])
    end
end

collectParts()
Workspace.DescendantAdded:Connect(collectParts)
task.spawn(function()
    while true do
        collectParts()
        task.wait(5)
    end
end)

--// Orbit Variables
local orbitConn = nil
local orbitSpeed = 3
local orbitRadius = 20
local orbitHeight = 30

--// Orbit Functions
local function startOrbit()
    if orbitConn then return end
    collectParts()  -- Refresh parts
    if #parts == 0 then
        game.StarterGui:SetCore("SendNotification", {Title="hung", Text="No unanchored parts found", Duration=3})
        return
    end
    
    game.StarterGui:SetCore("SendNotification", {Title="hung", Text="Orbiting "..#parts.." parts", Duration=4})
    
    local t = 0
    orbitConn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt * orbitSpeed
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for i, part in pairs(parts) do
            if part and part.Parent then
                part.CanCollide = false
                local angle = (i / #parts) * math.pi * 2 + t
                local offset = Vector3.new(math.cos(angle) * orbitRadius, orbitHeight, math.sin(angle) * orbitRadius)
                part.Velocity = Vector3.zero
                part.RotVelocity = Vector3.zero
                part.CFrame = CFrame.new(root.Position + offset) * CFrame.Angles(0, angle + math.pi/2, 0)
            end
        end
    end)
end

local function stopOrbit()
    if orbitConn then
        orbitConn:Disconnect()
        orbitConn = nil
        game.StarterGui:SetCore("SendNotification", {Title="hung", Text="Orbit stopped", Duration=2})
    end
end

--// Bump Function (one-time, lasts 3 seconds)
local function startBump()
    stopOrbit()  -- Stop orbit to avoid conflict
    collectParts()  -- Refresh parts
    
    local validTargets = {}
    for _, target in pairs(selectedTargets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(validTargets, target.Character.HumanoidRootPart)
        end
    end
    
    if #validTargets == 0 then
        game.StarterGui:SetCore("SendNotification", {Title="hung", Text="No target selected!", Duration=3})
        return
    end
    
    if #parts == 0 then
        game.StarterGui:SetCore("SendNotification", {Title="hung", Text="No unanchored parts found", Duration=3})
        return
    end
    
    game.StarterGui:SetCore("SendNotification", {Title="hung", Text="Bumping with "..#parts.." parts!", Duration=4})
    
    for _, obj in pairs(parts) do
        if obj and obj.Parent then
            obj.CanCollide = true
            local closestTarget
            local closestDist = math.huge
            
            for _, hrp in pairs(validTargets) do
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestTarget = hrp
                end
            end
            
            if closestTarget then
                task.spawn(function()
                    local lifetime = 3
                    local startTime = tick()
                    while tick() - startTime < lifetime do
                        if obj and obj.Parent and closestTarget and closestTarget.Parent then
                            local dir = (closestTarget.Position - obj.Position)
                            obj.AssemblyLinearVelocity = dir.Unit * 250
                            obj.AssemblyAngularVelocity = Vector3.new(math.random(), math.random(), math.random()) * 50
                        else
                            break
                        end
                        RunService.Heartbeat:Wait()
                    end
                    -- Stop and stay
                    if obj and obj.Parent then
                        obj.AssemblyLinearVelocity = Vector3.zero
                        obj.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
            end
        end
    end
end

--// Add buttons below player list
local orbitButton = Instance.new("TextButton")
orbitButton.Parent = scroll
orbitButton.Size = UDim2.new(1, -10, 0, 20)
orbitButton.Text = "Orbit"
orbitButton.Font = Enum.Font.Code
orbitButton.TextSize = 12
orbitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
orbitButton.TextColor3 = Color3.new(0, 0, 0)
orbitButton.MouseButton1Click:Connect(startOrbit)

local stopOrbitButton = Instance.new("TextButton")
stopOrbitButton.Parent = scroll
stopOrbitButton.Size = UDim2.new(1, -10, 0, 20)
stopOrbitButton.Text = "Stop"
stopOrbitButton.Font = Enum.Font.Code
stopOrbitButton.TextSize = 12
stopOrbitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
stopOrbitButton.TextColor3 = Color3.new(0, 0, 0)
stopOrbitButton.MouseButton1Click:Connect(stopOrbit)

local bumpButton = Instance.new("TextButton")
bumpButton.Parent = scroll
bumpButton.Size = UDim2.new(1, -10, 0, 20)
bumpButton.Text = "Bump"
bumpButton.Font = Enum.Font.Code
bumpButton.TextSize = 12
bumpButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
bumpButton.TextColor3 = Color3.new(0, 0, 0)
bumpButton.MouseButton1Click:Connect(startBump)
