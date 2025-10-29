--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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

--// Collect Button
local collectButton = Instance.new("TextButton")
collectButton.Parent = scroll
collectButton.Size = UDim2.new(1, -10, 0, 20)
collectButton.BackgroundTransparency = 1
collectButton.BorderSizePixel = 0
collectButton.Font = Enum.Font.Code
collectButton.TextColor3 = Color3.fromRGB(255, 0, 0)
collectButton.TextSize = 12
collectButton.Text = "Collect Off"
collectButton.TextXAlignment = Enum.TextXAlignment.Center

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

--// Collect Functions (Integrated from Reference)
local config = {
    radius = 10,
    height = 40,
    rotationSpeed = 1,
    attractionStrength = 1000,
}

local ringPartsEnabled = false

collectButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    collectButton.Text = ringPartsEnabled and "Collect On" or "Collect Off"
    collectButton.TextColor3 = ringPartsEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

local function RetainPart(Part)
    if typeof(Part) == "Instance" and Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(Workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false
        end
        Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Part.CanCollide = false
        return true
    end
    return false
end

local parts = {}
local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) then
            table.insert(parts, part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
end

for _, part in pairs(Workspace:GetDescendants()) do
    addPart(part)
end

Workspace.DescendantAdded:Connect(addPart)
Workspace.DescendantRemoving:Connect(removePart)

-- Enable simulation radius control
local function EnablePartControl()
    LocalPlayer.ReplicationFocus = Workspace
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)
end
EnablePartControl()

-- Orbiting logic
RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    local tornadoCenter = humanoidRootPart.Position
    for _, part in pairs(parts) do
        if part.Parent and not part.Anchored then
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
