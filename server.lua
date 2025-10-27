--// Services
local TweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local mouse = player:GetMouse()
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

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
title.Text = "X0N7"
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
local orbitHeight = 10  -- Height above HRP
local orbitRadius = 5   -- Radius of circle
local rotationSpeed = 1 -- Degrees per frame
local currentAngle = 0

--// Collect unanchored BaseParts
local function collectParts()
	parts = {}
	for _, part in pairs(Workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored and part.Parent ~= player.Character and not part.Parent:FindFirstChild("Humanoid") and part.Name ~= "Handle" then
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
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
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

-- Select target label
local selectLabel = Instance.new("TextLabel")
selectLabel.Parent = targetFrame
selectLabel.Size = UDim2.new(1, -10, 0, 20)
selectLabel.Text = "Select Target:"
selectLabel.Font = Enum.Font.Code
selectLabel.TextSize = 12
selectLabel.BackgroundTransparency = 1
selectLabel.TextColor3 = Color3.fromRGB(255, 0, 0)

-- Player list scroll
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Parent = targetFrame
playerScroll.Position = UDim2.new(0, 0, 0, 25)
playerScroll.Size = UDim2.new(1, 0, 0, 50)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 2
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local playerLayout = Instance.new("UIListLayout")
playerLayout.Parent = playerScroll
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 2)

-- Orbit button
local orbitButton = Instance.new("TextButton")
orbitButton.Parent = targetFrame
orbitButton.Position = UDim2.new(0, 0, 0, 80)
orbitButton.Size = UDim2.new(1, -10, 0, 20)
orbitButton.Text = "Orbit Off"
orbitButton.Font = Enum.Font.Code
orbitButton.TextSize = 12
orbitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
orbitButton.TextColor3 = Color3.new(0, 0, 0)

-- Back button
local backButton = Instance.new("TextButton")
backButton.Parent = targetFrame
backButton.Position = UDim2.new(0, 0, 0, 105)
backButton.Size = UDim2.new(1, -10, 0, 20)
backButton.Text = "Back"
backButton.Font = Enum.Font.Code
backButton.TextSize = 12
backButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
backButton.TextColor3 = Color3.new(0, 0, 0)

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
	scroll.CanvasSize = UDim2.new(0, 0, 0, 130)  -- Adjust for content
end)

-- Orbit button click
orbitButton.MouseButton1Click:Connect(function()
	orbitingEnabled = not orbitingEnabled
	orbitButton.Text = orbitingEnabled and "Orbit On" or "Orbit Off"
end)

-- Back click
backButton.MouseButton1Click:Connect(function()
	targetFrame.Visible = false
	enableButton.Visible = true
	selectedTargets = {}
	orbitingEnabled = false
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Update player list on player join/leave
Players.PlayerAdded:Connect(populatePlayers)
Players.PlayerRemoving:Connect(populatePlayers)
