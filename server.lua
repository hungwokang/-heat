--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// Simulation Radius Exploit
RunService.Heartbeat:Connect(function()
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)
end)
LocalPlayer.ReplicationFocus = Workspace

--// Parts Collection (ALL unanchored, no limit)
local parts = {}
local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(Workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false
        end
        Part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
        Part.CanCollide = false
        return true
    end
    return false
end

local function addPart(part)
    if RetainPart(part) and not table.find(parts, part) then
        table.insert(parts, part)
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then table.remove(parts, index) end
end

-- Initial scan
for _, part in pairs(Workspace:GetDescendants()) do
    addPart(part)
end
Workspace.DescendantAdded:Connect(addPart)
Workspace.DescendantRemoving:Connect(removePart)

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
local config = {
    radius = 30,
    height = 30,
    rotationSpeed = 1,
    attractionStrength = 1000,
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
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 0)
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
layout SortOrder = Enum.SortOrder.LayoutOrder
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
footer.TextXAlignment = Enum.TextXAlignment.Center

--// Tornado Levitation (ALL parts)
local function tornadoLevitate()
    levitatingParts = {}
    for _, part in pairs(parts) do
        if part and part.Parent then
            pcall(function() part:SetNetworkOwner(LocalPlayer) end)
            part.BrickColor = BrickColor.new("Bright red")
            part.Transparency = 0
            table.insert(levitatingParts, part)
        end
    end

    if levitateConnection then levitateConnection:Disconnect() end
    levitateConnection = RunService.Heartbeat:Connect(function()
        if #levitatingParts == 0 then
            if levitateConnection then levitateConnection:Disconnect() end
            return
        end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tornadoCenter = root.Position

        for i = #levitatingParts, 1, -1 do
            local part = levitatingParts[i]
            if not part or not part.Parent then
                table.remove(levitatingParts, i)
            else
                local pos = part.Position
                local distance = (Vector3.new(pos.X, tornadoCenter.Y, pos.Z) - tornadoCenter).Magnitude
                local angle = math.atan2(pos.Z - tornadoCenter.Z, pos.X - tornadoCenter.X)
                local newAngle = angle + math.rad(config.rotationSpeed)
                local targetPos = Vector3.new(
                    tornadoCenter.X + math.cos(newAngle) * math.min(config.radius, distance),
                    tornadoCenter.Y + (config.height * (math.abs(math.sin((pos.Y - tornadoCenter.Y) / config.height)))),
                    tornadoCenter.Z + math.sin(newAngle) * math.min(config.radius, distance)
                )
                local directionToTarget = (targetPos - part.Position).Unit
                part.Velocity = directionToTarget * config.attractionStrength
            end
        end
    end)
end

--// Shoot to Average Target
local function shootToTarget(targetPos)
    if levitateConnection then
        levitateConnection:Disconnect()
        levitateConnection = nil
    end
    for _, part in pairs(levitatingParts) do
        if part and part.Parent then
            for _, v in pairs(part:GetChildren()) do
                if v:IsA("Constraint") or v:IsA("Attachment") or v:IsA("BodyMover") then
                    v:Destroy()
                end
            end
            local dir = (targetPos - part.Position).Unit
            part.AssemblyLinearVelocity = dir * 600
            part.AssemblyAngularVelocity = Vector3.new()
        end
    end
    levitatingParts = {}
end

--// Enter Witch Mode
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

    -- Player List
    playerScroll = Instance.new("ScrollingFrame")
    playerScroll.Name = "PlayerList"
    playerScroll.Parent = scroll
    playerScroll.Position = UDim2.new(0, 5, 0, 0)
    playerScroll.Size = UDim2.new(1, -10, 0, 40)
    playerScroll.Background tapeTransparency = 1
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
            if btn:IsA("TextButton") then btn:Destroy() end
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Name = p.Name
                btn.Parent = playerScroll
                btn.Size = UDim2.new(0.95, 0, 0, 16)
                btn.BackgroundTransparency = 1
                local isSelected = selectedTargets[p.Name]
                btn.Text = isSelected and (p.Name .. " checkmark") or p.Name
                btn.TextColor3 = isSelected and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
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
                        btn.Text = p.Name .. " checkmark"
                        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
                end)
            end
        end
        playerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y)
        end)
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

    -- Start Button
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
        local count = 0
        for _ in pairs(selectedTargets) do count += 1 end
        if count == 0 then
            game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Select at least 1 target!", Duration = 3})
            return
        end
        if #levitatingParts > 0 then
            game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Already active!", Duration = 3})
            return
        end
        if #parts == 0 then
            game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "No parts found!", Duration = 3})
            return
        end

        spawn(function()
            game.StarterGui:SetCore("SendNotification", {Title = "WITCH", Text = "Tornado started with " .. #parts .. " parts!", Duration = 5})
            tornadoLevitate()
            wait(3)
            local sum = Vector3.new()
            local valid = 0
            for _, t in pairs(selectedTargets) do
                local hrp = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    sum += hrp.Position
                    valid += 1
                end
            end
            if valid > 0 then
                local avg = sum / valid
                shootToTarget(avg)
                game.StarterGui:SetCore("SendNotification", {Title = "WITCH", Text = "Shot to " .. valid .. " target(s)!", Duration = 3})
            else
                game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "No valid targets!", Duration = 3})
            end
        end)
    end)

    -- Back Button
    local backBtn = Instance.new("TextButton")
    backBtn.Parent = buttonFrame
    backBtn.Size = UDim2.new(0.45, 0, 1, 0)
    backBtn.BackgroundTransparency = 1
    backBtn.Text = "Back"
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.Font = Enum.Font.Code
    backBtn.TextSize = 12

    backBtn.MouseButton1Click:Connect(function()
        if levitateConnection then levitateConnection:Disconnect() end
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

--// Openn Button
witchBtn = Instance.new("TextButton")
witchBtn.Name = "Openn"
witchBtn.Parent = scroll
witchBtn.Size = UDim2.new(1, 0, 0, 25)
witchBtn.BackgroundTransparency = 1
witchBtn.Text = "Openn"
witchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
witchBtn.Font = Enum.Font.Code
witchBtn.TextSize = 14
witchBtn.TextXAlignment = Enum.TextXAlignment.Center
witchBtn.MouseButton1Click:Connect(enterWitchMode)
updateScrollCanvas()

--// Minimize
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 120, 0, 25) or UDim2.new(0, 120, 0, 130)
    local targetText = minimized and "+" or "-"
    TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    scroll.Visible = not minimized
    footer.Visible = not minimized
    minimize.Text = targetText
end)

--// Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "hung";
    Text = "WITCH loaded! (Tornado + Shoot)";
    Duration = 5;
})
