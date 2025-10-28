--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Infinite Simulation Radius (for FE replication)
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

--// Functionality Variables
local orbitingEnabled = false
local bumpingEnabled = false
local orbitHeight = 30   -- Tighter for kill aura
local orbitRadius = 3   -- Tighter for kill aura
local rotationSpeed = 60 -- Degrees per second
local bumpSpeed = 50   -- Faster for better bump
local angularScale = 5  -- For fling rotation during bump
local currentAngle = 0
local parts = {}
local MAX_PARTS = 10

--// Collect unanchored BaseParts (closest 50)
local function collectParts()
    parts = {}
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local candidates = {}
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and part.Parent ~= LocalPlayer.Character and not part.Parent:FindFirstChild("Humanoid") and part.Name ~= "Handle" then
            table.insert(candidates, part)
        end
    end
    
    -- Sort by distance
    table.sort(candidates, function(a, b)
        return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
    end)
    
    -- Take top 50 and setup kill aura (touch kill)
    for i = 1, math.min(MAX_PARTS, #candidates) do
        local part = candidates[i]
        table.insert(parts, part)
        part.CanCollide = true  -- For better collision/kill detection
        local touchConn = part.Touched:Connect(function(hit)
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
            end
        end)
        part.Destroying:Connect(function()
            touchConn:Disconnect()
        end)
    end
end

--// Auto refresh parts (every 5 sec + on new parts)
task.spawn(function()
    while true do
        collectParts()
        task.wait(5)
    end
end)
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and not obj.Anchored then
        collectParts()
    end
end)

--// Orbit (kill aura) and Bump Logic
RunService.Heartbeat:Connect(function(dt)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if orbitingEnabled then
        currentAngle = currentAngle + math.rad(rotationSpeed) * dt
        local numParts = #parts
        for i, part in ipairs(parts) do
            if part and part.Parent then
                local angle = currentAngle + (i / numParts) * 2 * math.pi
                local targetPos = hrp.Position + Vector3.new(math.cos(angle) * orbitRadius, orbitHeight, math.sin(angle) * orbitRadius)
                part.Position = targetPos  -- Direct pos for tight aura orbit
                part.AssemblyLinearVelocity = Vector3.zero  -- Reset vel for stable orbit
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
    
    if bumpingEnabled then
        local numTargets = #selectedTargets
        if numTargets == 0 then return end
        for i, part in ipairs(parts) do
            if part and part.Parent then
                local targetPlayer = selectedTargets[((i - 1) % numTargets) + 1]
                local targetHrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    local dir = (targetHrp.Position - part.Position)
                    if dir.Magnitude > 0 then
                        part.AssemblyLinearVelocity = dir.Unit * bumpSpeed
                        part.AssemblyAngularVelocity = Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10)) * angularScale
                    end
                end
            end
        end
    end
end)

--// Orbit button
local orbitButton = Instance.new("TextButton")
orbitButton.Parent = scroll
orbitButton.Size = UDim2.new(1, -10, 0, 20)
orbitButton.Text = "Orbit Off"
orbitButton.Font = Enum.Font.Code
orbitButton.TextSize = 12
orbitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
orbitButton.TextColor3 = Color3.new(0, 0, 0)
orbitButton.MouseButton1Click:Connect(function()
    orbitingEnabled = not orbitingEnabled
    bumpingEnabled = false
    orbitButton.Text = orbitingEnabled and "Orbit On" or "Orbit Off"
end)

--// Bump button
local bumpButton = Instance.new("TextButton")
bumpButton.Parent = scroll
bumpButton.Size = UDim2.new(1, -10, 0, 20)
bumpButton.Text = "Bump"
bumpButton.Font = Enum.Font.Code
bumpButton.TextSize = 12
bumpButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
bumpButton.TextColor3 = Color3.new(0, 0, 0)
bumpButton.MouseButton1Click:Connect(function()
    bumpingEnabled = not bumpingEnabled
    orbitingEnabled = false
    bumpButton.Text = bumpingEnabled and "Bump On" or "Bump"
end)
