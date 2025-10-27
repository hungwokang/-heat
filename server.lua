--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

--// Simulation Radius Exploit
RunService.Heartbeat:Connect(function()
    pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
end)
LocalPlayer.ReplicationFocus = Workspace

--// Functionality Variables
local selectedTargets = {}
local parts = {}
local orbitingEnabled = false
local orbitHeight = 40  -- Height above HRP
local orbitRadius = 5   -- Radius of circle
local rotationSpeed = 1 -- Degrees per second
local throwSpeed = 200  -- Velocity for throwing
local currentAngle = 0
local witchMode = false
local addedConn = nil
local removingConn = nil
local selectLabel = nil
local playerScroll = nil
local buttonFrame = nil

--// Collect unanchored BaseParts
local function collectParts()
	parts = {}
	for _, part in pairs(Workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored and part.Parent ~= LocalPlayer.Character and not part:IsDescendantOf(LocalPlayer.Character) and not part.Parent:FindFirstChild("Humanoid") and part.Name ~= "Handle" then
			pcall(function() part:SetNetworkOwner(LocalPlayer) end)
			part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
			part.CanCollide = false
			local touchConn = part.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = 0
				end
			end)
			part.Destroying:Connect(function()
				touchConn:Disconnect()
			end)
			table.insert(parts, part)
		end
	end
end

--// Orbit Logic
RunService.Heartbeat:Connect(function(deltaTime)
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if orbitingEnabled then
		currentAngle = currentAngle + math.rad(rotationSpeed) * deltaTime
		local numParts = #parts
		for i, part in ipairs(parts) do
			if part and part.Parent then
				local angle = currentAngle + (i / numParts) * 2 * math.pi
				local targetPos = hrp.Position + Vector3.new(math.cos(angle) * orbitRadius, orbitHeight, math.sin(angle) * orbitRadius)
				local directionToTarget = (targetPos - part.Position).Unit
				part.Velocity = directionToTarget * 100 + hrp.Velocity
			end
		end
	end
end)

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
footer.TextXAlignment = Enum.TextXAlignment.Center

--// Create initial WITCH button
local witchBtn = Instance.new("TextButton")
witchBtn.Name = "WITCH"
witchBtn.Parent = scroll
witchBtn.Size = UDim2.new(1, 0, 0, 25)
witchBtn.BackgroundTransparency = 1
witchBtn.Text = "WITCH"
witchBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
witchBtn.Font = Enum.Font.Code
witchBtn.TextSize = 14
witchBtn.TextXAlignment = Enum.TextXAlignment.Center

-- Target selection frame (hidden initially)
local targetFrame = Instance.new("Frame")
targetFrame.Parent = scroll
targetFrame.Size = UDim2.new(1, 0, 0, 170)
targetFrame.BackgroundTransparency = 1
targetFrame.Visible = false

-- Select target label
selectLabel = Instance.new("TextLabel")
selectLabel.Parent = targetFrame
selectLabel.Size = UDim2.new(1, 0, 0, 20)
selectLabel.BackgroundTransparency = 1
selectLabel.Text = "select target:"
selectLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
selectLabel.Font = Enum.Font.Code
selectLabel.TextSize = 12
selectLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Player List Scroll
playerScroll = Instance.new("ScrollingFrame")
playerScroll.Parent = targetFrame
playerScroll.Position = UDim2.new(0, 0, 0, 20)
playerScroll.Size = UDim2.new(1, 0, 0, 60)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.ScrollBarThickness = 2

local playerLayout = Instance.new("UIListLayout")
playerLayout.Parent = playerScroll
playerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 1)

-- Target All button
local targetAllButton = Instance.new("TextButton")
targetAllButton.Parent = targetFrame
targetAllButton.Position = UDim2.new(0, 0, 0, 80)
targetAllButton.Size = UDim2.new(1, 0, 0, 20)
targetAllButton.BackgroundTransparency = 1
targetAllButton.Text = "Target All: Off"
targetAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
targetAllButton.Font = Enum.Font.Code
targetAllButton.TextSize = 12

-- Orbit button
local orbitButton = Instance.new("TextButton")
orbitButton.Parent = targetFrame
orbitButton.Position = UDim2.new(0, 0, 0, 105)
orbitButton.Size = UDim2.new(0.5, 0, 0, 20)
orbitButton.BackgroundTransparency = 1
orbitButton.Text = "Orbit Off"
orbitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitButton.Font = Enum.Font.Code
orbitButton.TextSize = 12

-- Throw button
local throwButton = Instance.new("TextButton")
throwButton.Parent = targetFrame
throwButton.Position = UDim2.new(0.5, 0, 0, 105)
throwButton.Size = UDim2.new(0.5, 0, 0, 20)
throwButton.BackgroundTransparency = 1
throwButton.Text = "Throw"
throwButton.TextColor3 = Color3.fromRGB(255, 255, 255)
throwButton.Font = Enum.Font.Code
throwButton.TextSize = 12

-- Back button
local backBtn = Instance.new("TextButton")
backBtn.Parent = targetFrame
backBtn.Position = UDim2.new(0, 0, 0, 130)
backBtn.Size = UDim2.new(1, 0, 0, 20)
backBtn.BackgroundTransparency = 1
backBtn.Text = "Back"
backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
backBtn.Font = Enum.Font.Code
backBtn.TextSize = 12

-- Function to populate player list
local function populatePlayers()
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

-- WITCH button click
witchBtn.MouseButton1Click:Connect(function()
    collectParts()
    witchBtn.Visible = false
    targetFrame.Visible = true
    populatePlayers()
    scroll.CanvasSize = UDim2.new(0, 0, 0, 170)
    updateScrollCanvas()
    addedConn = Players.PlayerAdded:Connect(populatePlayers)
    removingConn = Players.PlayerRemoving:Connect(populatePlayers)
end)

-- Target All click
local targetAll = false
targetAllButton.MouseButton1Click:Connect(function()
    targetAll = not targetAll
    targetAllButton.Text = "Target All: " .. (targetAll and "On" or "Off")
    selectedTargets = {}
    populatePlayers()  -- Refresh list to update texts
end)

-- Orbit button click
orbitButton.MouseButton1Click:Connect(function()
    orbitingEnabled = not orbitingEnabled
    orbitButton.Text = "Orbit " .. (orbitingEnabled and "On" or "Off")
    if orbitingEnabled then
        game.StarterGui:SetCore("SendNotification", {Title = "WITCH", Text = "Orbiting parts!", Duration = 3})
    else
        game.StarterGui:SetCore("SendNotification", {Title = "WITCH", Text = "Orbit disabled!", Duration = 3})
    end
end)

-- Throw button click
throwButton.MouseButton1Click:Connect(function()
    local count = 0
    for _ in pairs(selectedTargets) do count = count + 1 end
    if count == 0 then
        game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Select at least 1 target!", Duration = 3})
        return
    end
    if #parts == 0 then
        game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "No parts left!", Duration = 3})
        return
    end
    local partIndex = math.random(1, #parts)
    local part = table.remove(parts, partIndex)
    local target = selectedTargets[math.random(1, count)]
    local h = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if h then
        local direction = (h.Position - part.Position).Unit
        part.Velocity = direction * throwSpeed
        game.StarterGui:SetCore("SendNotification", {Title = "WITCH", Text = "Thrown part at " .. target.Name .. "!", Duration = 3})
    else
        table.insert(parts, part)  -- Reinsert if no target HRP
    end
end)

-- Back click
backBtn.MouseButton1Click:Connect(function()
    targetFrame.Visible = false
    witchBtn.Visible = true
    selectedTargets = {}
    orbitingEnabled = false
    parts = {}
    if addedConn then addedConn:Disconnect() end
    if removingConn then removingConn:Disconnect() end
    scroll.CanvasSize = UDim2.new(0, 0, 0, 30)
    updateScrollCanvas()
end)

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
    Title = "hung";
    Text = "WITCH loaded!";
    Duration = 5;
})
