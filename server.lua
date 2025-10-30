--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

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


-- Rainbow TextLabel
local textHue = 0
RunService.Heartbeat:Connect(function()
    textHue = (textHue + 0.01) % 1
    title.TextColor3 = Color3.fromHSV(textHue, 1, 1)
	footer.TextColor3 = Color3.fromHSV(textHue, 1, 1)
end)



-- Configuration table - stores customizable values
local config = {
    radius = 10, -- Spread radius for floating parts above player
    height = 15, -- Base height above player for floating
    rotationSpeed = 1, -- How fast parts rotate while floating
    attractionStrength = 100, -- Increased base force for faster movement
    maxParts = 100, -- Maximum number of parts to collect
    shootSpeed = 200, -- Speed for shooting parts to target
}


-- Network ownership bypass to control distant parts
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    -- Retain network ownership of parts (preserve collidability)
    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, Part)
            -- Remove CustomPhysicalProperties to allow real physics
            if Part:FindFirstChildOfClass("CustomPhysicalProperties") then
                Part:FindFirstChildOfClass("CustomPhysicalProperties"):Destroy()
            end
            -- Preserve or enable collision
            Part.CanCollide = true
        end
    end

    -- Force server to replicate part changes
    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) -- Bypass distance limit
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(Workspace) and Part.Parent then
                    -- Removed fixed velocity override to allow per-part control
                end
            end
        end)
    end

    EnablePartControl()
end

-- Filters parts to include in the collection (unanchored only)
local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false -- Exclude player
        end
        -- Enable collision for all collected parts
        Part.CanCollide = true
        -- Retain network ownership
        Network.RetainPart(Part)
        return true
    end
    return false
end

local parts = {} -- Table of parts in the collection

-- Add part to collection list (limit to maxParts)
local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) and #parts < config.maxParts then
            table.insert(parts, part)
        end
    end
end

-- Remove part when destroyed
local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
    -- Clean up from network list if needed
    local netIndex = table.find(Network.BaseParts, part)
    if netIndex then
        table.remove(Network.BaseParts, netIndex)
    end
end

-- Initialize with existing unanchored parts (limit to maxParts)
local tempParts = {}
for _, part in pairs(workspace:GetDescendants()) do
    if RetainPart(part) and not table.find(tempParts, part) then
        table.insert(tempParts, part)
        if #tempParts >= config.maxParts then
            break
        end
    end
end
for _, part in pairs(tempParts) do
    table.insert(parts, part)
end

-- Listen for new/destroyed parts
workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

-- Main collection loop - runs every frame (floating above and following)
RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end

    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local playerPos = humanoidRootPart.Position
        local time = tick()
        for i, part in pairs(parts) do
            if part.Parent and part and part.Parent ~= nil and part:IsDescendantOf(workspace) then
                -- Calculate floating position above player (orbiting for spread)
                local angle = (time * config.rotationSpeed) + (i * math.pi * 2 / math.max(#parts, 1)) -- Unique angle per part, avoid div0
                local offsetX = math.sin(angle) * config.radius
                local offsetZ = math.cos(angle) * config.radius
                local floatHeight = config.height + math.sin(time * 2 + i) * 2 -- Slight bobbing for floating effect
                local targetPos = playerPos + Vector3.new(offsetX, floatHeight, offsetZ)

                -- Direction and distance
                local direction = (targetPos - part.Position).Unit
                local distance = (targetPos - part.Position).Magnitude

                -- Scale speed with distance for far pulls (stronger when farther, increased multiplier for speed)
                local speed = config.attractionStrength + (distance * 10) -- Increased from 5 to 10 for faster pull
                speed = math.min(speed, 300) -- Increased cap from 200 to 300 for faster movement

                -- Apply real velocity (replicates to all clients, allows collision)
                part.Velocity = direction * speed

                -- Ensure collidable and unanchored
                part.CanCollide = true
                part.Anchored = false
            end
        end
    end
end)




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

playerScroll.Visible = listHidden 
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

--// Toggle list visibility when clicking header
headerButton.MouseButton1Click:Connect(function()
	playerScroll.Visible = not listHidden
	listHidden = not listHidden
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

-- Collect button
local collectButton = Instance.new("TextButton")
collectButton.Parent = scroll
collectButton.Size = UDim2.new(1, -10, 0, 20)
collectButton.BackgroundTransparency = 1
collectButton.BorderSizePixel = 0
collectButton.Font = Enum.Font.Code
collectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collectButton.TextSize = 12
collectButton.Text = "Collect"
collectButton.TextXAlignment = Enum.TextXAlignment.Center

collectButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    collectButton.Text = ringPartsEnabled and "Collecting..." or "Collect"
    collectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- Shoot button
local shootButton = Instance.new("TextButton")
shootButton.Parent = scroll
shootButton.Size = UDim2.new(1, -10, 0, 20)
shootButton.BackgroundTransparency = 1
shootButton.BorderSizePixel = 0
shootButton.Font = Enum.Font.Code
shootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shootButton.TextSize = 12
shootButton.Text = "Shoot"
shootButton.TextXAlignment = Enum.TextXAlignment.Center

-- Shoot function
local function shootParts()
    local targets = {}
    for _, player in pairs(selectedTargets) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, player.Character.HumanoidRootPart)
        end
    end
    
    if #targets == 0 then
        game.StarterGui:SetCore("SendNotification", {
            Title = "hung",
            Text = "No valid targets selected!",
            Duration = 3,
        })
        return
    end
    
    local numTargets = #targets
    local partIndex = 1
    for i, part in pairs(parts) do
        if part and part.Parent then
            local target = targets[partIndex % numTargets + 1] -- Cycle through targets
            if target then
                local direction = (target.Position - part.Position).Unit
                part.Velocity = direction * config.shootSpeed
            end
            partIndex = partIndex + 1
        end
    end
    
    -- Clear parts after shooting
    parts = {}
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "hung",
        Text = "Parts shot to targets!",
        Duration = 3,
    })
end

shootButton.MouseButton1Click:Connect(function()
    if ringPartsEnabled and #parts > 0 then
        shootParts()
        ringPartsEnabled = false -- Stop collecting after shooting
        collectButton.Text = "Collect"
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "hung",
            Text = "Collect parts first!",
            Duration = 3,
        })
    end
end)

--// Notification
game.StarterGui:SetCore("SendNotification", {
	Title = "hung",
	Text = "Floating Collector GUI Loaded (100 Parts Max, Faster, Shoot Added)",
	Duration = 4,
})
