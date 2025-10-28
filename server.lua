--// Services
local TweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local mouse = player:GetMouse()
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--// Network Ownership Setup
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = true  -- Set to true as per request
        end
    end

    local function EnablePartControl()
        player.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(player, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(Workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end

    EnablePartControl()
end

--// Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ServerGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

--// Main Frame
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 150, 0, 200)
frame.Position = UDim2.new(0.5, -75, 0.5, -100)
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
title.Text = "X0N777"
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
	local targetSize = minimized and UDim2.new(0, 150, 0, 25) or UDim2.new(0, 150, 0, 200)
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

--// Functionality Variables
local selectedTargets = {}
local parts = {}
local orbitingEnabled = false
local orbitHeight = 40  -- Height above HRP
local orbitRadius = 20   -- Radius of circle
local rotationSpeed = 1 -- Degrees per frame
local throwSpeed = 200  -- Velocity for throwing
local currentAngle = 0

local TargetFolder = Instance.new("Folder")
TargetFolder.Name = "OrbitTargets"
TargetFolder.Parent = Workspace

--// Collect unanchored BaseParts
local function collectParts()
	parts = {}
	for _, part in pairs(Workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored and part.Parent ~= player.Character and not part.Parent:FindFirstChild("Humanoid") and part.Name ~= "Handle" then
			local targetPart = Instance.new("Part")
			targetPart.Anchored = true
			targetPart.CanCollide = false
			targetPart.Transparency = 1
			targetPart.Name = "Target"
			targetPart.Parent = TargetFolder
			local att1 = Instance.new("Attachment", targetPart)
			local att2 = Instance.new("Attachment", part)
			local alignPos = Instance.new("AlignPosition", part)
			alignPos.Attachment0 = att2
			alignPos.Attachment1 = att1
			alignPos.MaxForce = math.huge
			alignPos.MaxVelocity = math.huge
			alignPos.Responsiveness = 200
			alignPos.RigidityEnabled = true  -- Added for better response
			local torque = Instance.new("Torque", part)
			torque.Attachment0 = att2
			torque.Torque = Vector3.new(100000, 100000, 100000)
			Network.RetainPart(part)
			table.insert(parts, {Part = part, Target = targetPart})
		end
	end
end

--// Orbit Logic
RunService.Heartbeat:Connect(function(deltaTime)
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if orbitingEnabled then
		currentAngle = currentAngle + rotationSpeed * deltaTime
		local numParts = #parts
		for i, entry in ipairs(parts) do
			if entry.Part and entry.Part.Parent and entry.Target then
				local angle = currentAngle + (i / numParts) * 2 * math.pi
				local targetPos = hrp.Position + Vector3.new(math.cos(angle) * orbitRadius, orbitHeight, math.sin(angle) * orbitRadius)
				entry.Target.Position = targetPos
			end
		end
	end
end)

--// GUI Elements

-- Initial ENABLE button
local enableButton = Instance.new("TextButton")
enableButton.Parent = scroll
enableButton.Size = UDim2.new(1, -10, 0, 20)
enableButton.Text = "ENABLE"
enableButton.Font = Enum.Font.Code
enableButton.TextSize = 12
enableButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
enableButton.TextColor3 = Color3.new(0, 0, 0)

-- Target selection frame (hidden initially)
local targetFrame = Instance.new("Frame")
targetFrame.Parent = scroll
targetFrame.Size = UDim2.new(1, 0, 1, 0)
targetFrame.BackgroundTransparency = 1
targetFrame.Visible = false

-- Player toggle button
local playerToggle = Instance.new("TextButton")
playerToggle.Parent = targetFrame
playerToggle.Position = UDim2.new(0, 0, 0, 0)
playerToggle.Size = UDim2.new(1, -10, 0, 20)
playerToggle.Text = "Show Targets"
playerToggle.Font = Enum.Font.Code
playerToggle.TextSize = 12
playerToggle.BackgroundTransparency = 1
playerToggle.TextColor3 = Color3.fromRGB(255, 0, 0)

-- Player list scroll
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Parent = targetFrame
playerScroll.Position = UDim2.new(0, 0, 0, 25)
playerScroll.Size = UDim2.new(1, 0, 0, 50)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 2
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Visible = false

local playerLayout = Instance.new("UIListLayout")
playerLayout.Parent = playerScroll
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 2)

-- Target All button
local targetAllButton = Instance.new("TextButton")
targetAllButton.Parent = targetFrame
targetAllButton.Position = UDim2.new(0, 0, 0, 25)
targetAllButton.Size = UDim2.new(1, -10, 0, 20)
targetAllButton.Text = "Target All: Off"
targetAllButton.Font = Enum.Font.Code
targetAllButton.TextSize = 12
targetAllButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
targetAllButton.TextColor3 = Color3.new(0, 0, 0)

-- Orbit button
local orbitButton = Instance.new("TextButton")
orbitButton.Parent = targetFrame
orbitButton.Position = UDim2.new(0, 0, 0, 50)
orbitButton.Size = UDim2.new(0.5, -5, 0, 20)
orbitButton.Text = "Orbit Off"
orbitButton.Font = Enum.Font.Code
orbitButton.TextSize = 12
orbitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
orbitButton.TextColor3 = Color3.new(0, 0, 0)

-- Throw button
local throwButton = Instance.new("TextButton")
throwButton.Parent = targetFrame
throwButton.Position = UDim2.new(0.5, 5, 0, 50)
throwButton.Size = UDim2.new(0.5, -5, 0, 20)
throwButton.Text = "Throw"
throwButton.Font = Enum.Font.Code
throwButton.TextSize = 12
throwButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
throwButton.TextColor3 = Color3.new(0, 0, 0)

-- Back button
local backButton = Instance.new("TextButton")
backButton.Parent = targetFrame
backButton.Position = UDim2.new(0, 0, 0, 75)
backButton.Size = UDim2.new(1, -10, 0, 20)
backButton.Text = "Back"
backButton.Font = Enum.Font.Code
backButton.TextSize = 12
backButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
backButton.TextColor3 = Color3.new(0, 0, 0)

-- Function to update positions based on player list visibility
local function updatePositions(showList)
    playerScroll.Visible = showList
    local listOffset = showList and 80 or 25
    targetAllButton.Position = UDim2.new(0, 0, 0, listOffset)
    local buttonOffset = listOffset + 25
    orbitButton.Position = UDim2.new(0, 0, 0, buttonOffset)
    throwButton.Position = UDim2.new(0.5, 5, 0, buttonOffset)
    local backOffset = buttonOffset + 25
    backButton.Position = UDim2.new(0, 0, 0, backOffset)
    scroll.CanvasSize = UDim2.new(0, 0, 0, showList and 170 or 115)
end

-- Initial setup
updatePositions(false)

-- Player toggle click
playerToggle.MouseButton1Click:Connect(function()
    local newVisible = not playerScroll.Visible
    updatePositions(newVisible)
    playerToggle.Text = newVisible and "Hide Targets" or "Show Targets"
end)

-- Function to populate player list
local function populatePlayers()
	for _, child in pairs(playerScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	local allPlayers = Players:GetPlayers()
	for _, plr in ipairs(allPlayers) do
		if plr ~= player then
			local plrButton = Instance.new("TextButton")
			plrButton.Parent = playerScroll
			plrButton.Size = UDim2.new(1, -10, 0, 20)
			plrButton.Text = plr.Name .. " (Off)"
			plrButton.Font = Enum.Font.Code
			plrButton.TextSize = 12
			plrButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			plrButton.TextColor3 = Color3.new(0, 0, 0)
			plrButton.MouseButton1Click:Connect(function()
				if table.find(selectedTargets, plr) then
					table.remove(selectedTargets, table.find(selectedTargets, plr))
					plrButton.Text = plr.Name .. " (Off)"
				else
					table.insert(selectedTargets, plr)
					plrButton.Text = plr.Name .. " (On)"
				end
			end)
		end
	end
	playerScroll.CanvasSize = UDim2.new(0, 0, 0, #playerScroll:GetChildren() * 22)
end

-- ENABLE button click
enableButton.MouseButton1Click:Connect(function()
	collectParts()  -- Collect parts on enable
	enableButton.Visible = false
	targetFrame.Visible = true
	populatePlayers()
	updatePositions(playerScroll.Visible)  -- Update based on current visibility
end)

-- Target All click
local targetAll = false
targetAllButton.MouseButton1Click:Connect(function()
	targetAll = not targetAll
	targetAllButton.Text = "Target All: " .. (targetAll and "On" or "Off")
	if targetAll then
		selectedTargets = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				table.insert(selectedTargets, plr)
			end
		end
		-- Update buttons
		for _, btn in pairs(playerScroll:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.Text = btn.Text:gsub("%(Off%)", "(On)")
			end
		end
	else
		selectedTargets = {}
		for _, btn in pairs(playerScroll:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.Text = btn.Text:gsub("%(On%)", "(Off)")
			end
		end
	end
end)

-- Orbit button click
orbitButton.MouseButton1Click:Connect(function()
	orbitingEnabled = not orbitingEnabled
	orbitButton.Text = orbitingEnabled and "Orbit Onnn" or "Orbit Off"
end)

-- Throw button click
throwButton.MouseButton1Click:Connect(function()
	if #selectedTargets > 0 and #parts > 0 then
		-- Pick one part and remove it from the orbiting list
		local entry = table.remove(parts, 1)
		local part = entry.Part
		-- Remove from Network.BaseParts
		local index = table.find(Network.BaseParts, part)
		if index then
			table.remove(Network.BaseParts, index)
		end
		-- Destroy movers
		if part:FindFirstChild("AlignPosition") then part:FindFirstChild("AlignPosition"):Destroy() end
		if part:FindFirstChild("Torque") then part:FindFirstChild("Torque"):Destroy() end
		if part:FindFirstChild("Attachment") then part:FindFirstChild("Attachment"):Destroy() end
		if entry.Target then entry.Target:Destroy() end
		-- Pick a random target if multiple
		local target = selectedTargets[math.random(1, #selectedTargets)]
		local targetHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if targetHrp then
			-- Set velocity once for straight throw
			local direction = (targetHrp.Position - part.Position).unit
			part.Velocity = direction * throwSpeed
		end
	end
end)

-- Back click
backButton.MouseButton1Click:Connect(function()
	targetFrame.Visible = false
	enableButton.Visible = true
	selectedTargets = {}
	orbitingEnabled = false
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	-- Clean up
	TargetFolder:ClearAllChildren()
	parts = {}
	Network.BaseParts = {}
end)

-- Update player list on player join/leave
Players.PlayerAdded:Connect(populatePlayers)
Players.PlayerRemoving:Connect(populatePlayers)
