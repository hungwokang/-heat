--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

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

--// Functionality Variables
local selectedTargets = {}
local parts = {}
local orbitingEnabled = false
local orbitHeight = 30  -- Height above HRP
local orbitRadius = 5   -- Radius of circle
local rotationSpeed = 1 -- Degrees per frame
local currentAngle = 0

--// Collect unanchored BaseParts
local function collectParts()
	parts = {}
	for _, part in pairs(Workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored and part.Parent ~= LocalPlayer.Character and not part.Parent:FindFirstChild("Humanoid") and part.Name ~= "Handle" then
			table.insert(parts, part)
			-- Make non-collidable and add kill touch
			part.CanCollide = false
			local touchConn = part.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = 0
				end
			end)
			-- Optional: Destroy conn when part destroyed
			part.Destroying:Connect(function()
				touchConn:Disconnect()
			end)
		end
	end
end

--// Orbit Logic
RunService.Heartbeat:Connect(function(deltaTime)
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if orbitingEnabled then
		currentAngle = currentAngle + rotationSpeed * deltaTime
		local numParts = #parts
		for i, part in ipairs(parts) do
			if part and part.Parent then
				local angle = currentAngle + (i / numParts) * 2 * math.pi
				local targetPos = hrp.Position + Vector3.new(math.cos(angle) * orbitRadius, orbitHeight, math.sin(angle) * orbitRadius)
				part.Position = targetPos  -- Direct position for simplicity; use AlignPosition for physics
			end
		end
	end
end)

--// GUI Elements

-- Initial ENABLE button
local enableButton = Instance.new("TextButton")
enableButton.Parent = scroll
enableButton.Size = UDim2.new(1, 0, 0, 25)
enableButton.BackgroundTransparency = 1
enableButton.Text = "WITCH"
enableButton.TextColor3 = Color3.fromRGB(255, 0, 0)
enableButton.Font = Enum.Font.Code
enableButton.TextSize = 14
enableButton.TextXAlignment = Enum.TextXAlignment.Center

-- Target selection frame (hidden initially)
local targetFrame = Instance.new("Frame")
targetFrame.Parent = scroll
targetFrame.Size = UDim2.new(1, 0, 1, 0)
targetFrame.BackgroundTransparency = 1
targetFrame.Visible = false

-- Select target label
local selectLabel = Instance.new("TextLabel")
selectLabel.Parent = targetFrame
selectLabel.Size = UDim2.new(1, 0, 0, 20)
selectLabel.BackgroundTransparency = 1
selectLabel.Text = "select target:"
selectLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
selectLabel.Font = Enum.Font.Code
selectLabel.TextSize = 12
selectLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Player list scroll
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Parent = targetFrame
playerScroll.Position = UDim2.new(0, 5, 0, 20)
playerScroll.Size = UDim2.new(1, -10, 0, 40)
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
orbitButton.Size = UDim2.new(1, 0, 0, 20)
orbitButton.BackgroundTransparency = 1
orbitButton.Text = "Orbit Off"
orbitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitButton.Font = Enum.Font.Code
orbitButton.TextSize = 12

-- Back button
local backButton = Instance.new("TextButton")
backButton.Parent = targetFrame
backButton.Position = UDim2.new(0, 0, 0, 130)
backButton.Size = UDim2.new(1, 0, 0, 20)
backButton.BackgroundTransparency = 1
backButton.Text = "Back"
backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
backButton.Font = Enum.Font.Code
backButton.TextSize = 12

-- Function to populate player list
local function populatePlayers()
	for _, child in pairs(playerScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	local allPlayers = Players:GetPlayers()
	for _, plr in ipairs(allPlayers) do
		if plr ~= LocalPlayer then
			local plrButton = Instance.new("TextButton")
			plrButton.Parent = playerScroll
			plrButton.Size = UDim2.new(0.95, 0, 0, 16)
			plrButton.BackgroundTransparency = 1
			local isSelected = selectedTargets[plr.Name]
			plrButton.Text = isSelected and (plr.Name .. " ✓") or plr.Name
			plrButton.TextColor3 = isSelected and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
			plrButton.Font = Enum.Font.Code
			plrButton.TextSize = 10
			plrButton.TextXAlignment = Enum.TextXAlignment.Left
			plrButton.MouseButton1Click:Connect(function()
				if selectedTargets[plr.Name] then
					selectedTargets[plr.Name] = nil
					plrButton.Text = plr.Name
					plrButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				else
					selectedTargets[plr.Name] = plr
					plrButton.Text = plr.Name .. " ✓"
					plrButton.TextColor3 = Color3.fromRGB(0, 255, 0)
				end
			end)
		end
	end
	playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y)
	updateScrollCanvas()
end

playerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y)
	updateScrollCanvas()
end)

-- ENABLE button click
enableButton.MouseButton1Click:Connect(function()
	collectParts()  -- Collect parts on enable
	enableButton.Visible = false
	targetFrame.Visible = true
	populatePlayers()
	scroll.CanvasSize = UDim2.new(0, 0, 0, 170)  -- Adjust for content
	updateScrollCanvas()
end)

-- Target All click
local targetAll = false
targetAllButton.MouseButton1Click:Connect(function()
	targetAll = not targetAll
	targetAllButton.Text = "Target All: " .. (targetAll and "On" or "Off")
	if targetAll then
		selectedTargets = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				selectedTargets[plr.Name] = plr
			end
		end
	else
		selectedTargets = {}
	end
	populatePlayers()
end)

-- Orbit button click
orbitButton.MouseButton1Click:Connect(function()
	orbitingEnabled = not orbitingEnabled
	orbitButton.Text = "Orbit " .. (orbitingEnabled and "On" or "Off")
end)

-- Back click
backButton.MouseButton1Click:Connect(function()
	targetFrame.Visible = false
	enableButton.Visible = true
	selectedTargets = {}
	orbitingEnabled = false
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	updateScrollCanvas()
end)

-- Update player list on player join/leave
Players.PlayerAdded:Connect(populatePlayers)
Players.PlayerRemoving:Connect(populatePlayers)

updateScrollCanvas()
