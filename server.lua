--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// Simulation Radius Exploit (like Super Ring)
RunService.Heartbeat:Connect(function()
    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
end)
LocalPlayer.ReplicationFocus = Workspace

--// Variables
local levitatingParts = {}
local levitateConnection = nil
local selectedTargets = {}
local witchBtn = nil
local playerScroll = nil
local selectLabel = nil
local buttonFrame = nil
local addedConn = nil
local removingConn = nil
local witchMode = false
local maxGrab = 10
local config = {
    radius = 20,
    height = 30,
    rotationSpeed = 1,
    attractionStrength = 100,
}

--// Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ServerGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

--// Main Frame
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 120, 0, 130)
frame.Position = UDim2.new(0.5, -60, 0.5, -65)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.4
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true

--// Title bar
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, -20, 0, 20)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Code
title.Text = "hung"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 50, 0, 0)

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

--// Canvas update
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

--// Minimize toggle
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 120, 0, 25) or UDim2.new(0, 120, 0, 130)
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
    Title = "FE HAX";
    Text = "hehe boi get load'd";
    Duration = 11;
})

--// Functions
local function findNearestLooseParts(num)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local pos = root.Position
    local allParts = Workspace:GetDescendants()
    local sortedParts = {}
    for _, part in pairs(allParts) do
        if part:IsA("BasePart") and part.Parent ~= LocalPlayer.Character and not part:IsDescendantOf(LocalPlayer.Character) and not part.Parent:FindFirstChild("Humanoid") and part.Name ~= "Handle" then
            table.insert(sortedParts, {part = part, dist = (part.Position - pos).Magnitude})
        end
    end
    table.sort(sortedParts, function(a, b) return a.dist < b.dist end)
    local selected = {}
    for i = 1, math.min(num, #sortedParts) do
        local p = sortedParts[i].part
        pcall(function() p:SetNetworkOwner(LocalPlayer) end)
        pcall(function() p.Anchored = false end)
        p.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
        p.CanCollide = false
        p.BrickColor = BrickColor.new("Bright red")
        p.Transparency = 0
        table.insert(selected, p)
    end
    return selected
end

local function orbitParts(partList)
    levitatingParts = partList
    if levitateConnection then levitateConnection:Disconnect() end
    local currentAngle = 0
    levitateConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if #levitatingParts == 0 then
            if levitateConnection then levitateConnection:Disconnect() end
            return
        end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        currentAngle = currentAngle + math.rad(config.rotationSpeed) * deltaTime
        local center = root.Position
        local numParts = #levitatingParts
        for i, part in ipairs(levitatingParts) do
            if part and part.Parent then
                local angle = currentAngle + (i / numParts) * 2 * math.pi
                local targetPos = center + Vector3.new(math.cos(angle) * config.radius, config.height, math.sin(angle) * config.radius)
                local directionToTarget = (targetPos - part.Position).Unit
                part.Velocity = directionToTarget * config.attractionStrength + root.Velocity
            end
        end
    end)
end

local function enterWitchMode()
    if witchMode then return end
    witchMode = true
    witchBtn.Visible = false
    selectedTargets = {}
    
    -- Select Label
    selectLabel = Instance.new("TextLabel")
    selectLabel.Name = "SelectLabel"
    selectLabel.Parent = scroll
    selectLabel.Size = UDim2.new(1, 0, 0, 20)
    selectLabel.BackgroundTransparency = 1
    selectLabel.Text = "select target:"
    selectLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectLabel.Font = Enum.Font.Code
    selectLabel.TextSize = 12
    selectLabel.TextXAlignment = Enum.TextXAlignment.Center
    selectLabel.LayoutOrder = 1
    
    -- Player List Scroll
    playerScroll = Instance.new("ScrollingFrame")
    playerScroll.Name = "PlayerList"
    playerScroll.Parent = scroll
    playerScroll.Position = UDim2.new(0, 5, 0, 0)
    playerScroll.Size = UDim2.new(1, -10, 0, 50)
    playerScroll.BackgroundTransparency = 1
    playerScroll.BorderSizePixel = 0
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerScroll.ScrollBarThickness = 2
    playerScroll.LayoutOrder = 2
    
    local playerLayout = Instance.new("UIListLayout")
    playerLayout.Parent = playerScroll
    playerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    playerLayout.Padding = UDim.new(0, 1)
    
    local function updatePlayerList()
        if not playerScroll or not playerScroll.Parent then return end
        for _, btn in pairs(playerScroll:GetChildren()) do
            if btn:IsA("TextButton") then
                btn:Destroy()
            end
        end
        local playerButtonList = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Name = p.Name
                btn.Parent = playerScroll
                btn.Size = UDim2.new(0.95, 0, 0, 16)
                btn.BackgroundTransparency = 1
                local isSelected = selectedTargets[p.Name]
                btn.Text = isSelected and (p.Name .. " ✓") or p.Name
                btn.TextColor3 = isSelected and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.Code
                btn.TextSize = 10
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.LayoutOrder = #playerButtonList + 1
                table.insert(playerButtonList, btn)
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
    addedConn = Players.PlayerAdded:Connect(updatePlayerList)
    removingConn = Players.PlayerRemoving:Connect(updatePlayerList)
    
    -- Button Frame
    buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Parent = scroll
    buttonFrame.Size = UDim2.new(1, 0, 0, 22)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 3
    
    local hLayout = Instance.new("UIListLayout")
    hLayout.Parent = buttonFrame
    hLayout.FillDirection = Enum.FillDirection.Horizontal
    hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    hLayout.Padding = UDim.new(0, 5)
    
    -- Start
    local startBtn = Instance.new("TextButton")
    startBtn.Name = "Start"
    startBtn.Parent = buttonFrame
    startBtn.Size = UDim2.new(0.45, 0, 1, 0)
    startBtn.BackgroundTransparency = 1
    startBtn.Text = "Start"
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.Font = Enum.Font.Code
    startBtn.TextSize = 12
    
    startBtn.MouseButton1Click:Connect(function()
        if #levitatingParts > 0 then
            game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Already grabbing parts!", Duration = 3})
            return
        end
        spawn(function()
            local partList = findNearestLooseParts(maxGrab)
            if #partList == 0 then
                game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "No parts found!", Duration = 3})
                return
            end
            game.StarterGui:SetCore("SendNotification", {Title = "WITCH", Text = "Orbiting " .. #partList .. " parts!", Duration = 5})
            orbitParts(partList)
        end)
    end)
    
    -- Back
    local backBtn = Instance.new("TextButton")
    backBtn.Parent = buttonFrame
    backBtn.Size = UDim2.new(0.45, 0, 1, 0)
    backBtn.BackgroundTransparency = 1
    backBtn.Text = "Back"
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.Font = Enum.Font.Code
    backBtn.TextSize = 12
    
    backBtn.MouseButton1Click:Connect(function()
        if levitateConnection then
            levitateConnection:Disconnect()
            levitateConnection = nil
        end
        for _, p in pairs(levitatingParts) do
            for _, v in pairs(p:GetChildren()) do
                if v:IsA("Constraint") or v:IsA("Attachment") or v:IsA("BodyMover") then
                    v:Destroy()
                end
            end
        end
        levitatingParts = {}
        witchMode = false
        selectedTargets = {}
        if addedConn then addedConn:Disconnect() end
        if removingConn then removingConn:Disconnect() end
        if selectLabel then selectLabel:Destroy() end
        if playerScroll then playerScroll:Destroy() end
        if buttonFrame then buttonFrame:Destroy() end
        witchBtn.Visible = true
        updateScrollCanvas()
    end)
    
    updateScrollCanvas()
end

--// Create initial WITCH button
witchBtn = Instance.new("TextButton")
witchBtn.Name = "WITCH"
witchBtn.Parent = scroll
witchBtn.Size = UDim2.new(1, 0, 0, 25)
witchBtn.BackgroundTransparency = 1
witchBtn.Text = "OPEN"
witchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
witchBtn.Font = Enum.Font.Code
witchBtn.TextSize = 14
witchBtn.TextXAlignment = Enum.TextXAlignment.Center
witchBtn.MouseButton1Click:Connect(enterWitchMode)
updateScrollCanvas()

--// Minimize toggle
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 120, 0, 25) or UDim2.new(0, 120, 0, 130)
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
    Title = "FE HAX";
    Text = "hehe boi get load'd";
    Duration = 11;
})
