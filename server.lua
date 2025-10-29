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
    radius = 10, -- Max horizontal distance parts can orbit
    aboveHeight = 20, -- Base height above the player for floating
    bobAmplitude = 2, -- Amplitude of bobbing motion
    bobSpeed = 2, -- Speed of bobbing motion
    rotationSpeed = 1000, -- Rotation speed for visible movement
    searchRadius = 1000 -- Radius to search for parts to avoid lag
}


-- Ring Parts Claim
local Workspace = game:GetService("workspace")

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Edits
local ringPartsEnabled = false -- Toggle state

-- Filters parts to include in the tornado
local function RetainPart(Part)
    if Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false -- Exclude player
        end
        if Part.Parent:FindFirstChild("Humanoid") or Part.Parent:FindFirstChild("Head") or Part.Name == "Handle" then
            return false
        end
        Part.CanCollide = false
        return true
    end
    return false
end

local parts = {} -- Table of parts in the tornado

-- Remove part when destroyed
local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
end

-- Listen for destroyed parts
workspace.DescendantRemoving:Connect(removePart)

-- Main loop - runs every frame
RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end

    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local tornadoCenter = humanoidRootPart.Position
        local currentTime = tick()
        for i, part in pairs(parts) do
            if part.Parent then
                local angle = (i / #parts) * math.pi * 2 + currentTime * config.rotationSpeed -- Even distribution with rotation
                local bobOffset = math.sin(currentTime * config.bobSpeed + angle) * config.bobAmplitude -- Bobbing based on angle for varied motion
                local targetPos = Vector3.new(
                    tornadoCenter.X + math.cos(angle) * config.radius,
                    tornadoCenter.Y + config.aboveHeight + bobOffset,
                    tornadoCenter.Z + math.sin(angle) * config.radius
                )
                part.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.pi, 0, 0) -- Upside down
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

-- Now create the button (unchanged)
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

-- Now the click event (now button exists)
collectButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    collectButton.Text = ringPartsEnabled and "Collecting..." or "Collect"
    collectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    if ringPartsEnabled then
        parts = {}
        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local playerPos = humanoidRootPart.Position
            local candidates = {}
            for _, desc in pairs(workspace:GetDescendants()) do
                if RetainPart(desc) and (desc.Position - playerPos).Magnitude < config.searchRadius then
                    table.insert(candidates, {part = desc, dist = (desc.Position - playerPos).Magnitude})
                end
            end
            table.sort(candidates, function(a, b) return a.dist < b.dist end)
            local numParts = math.min(50, #candidates)
            for i = 1, numParts do
                local part = candidates[i].part
                table.insert(parts, part)

                -- Remove any movers
                for _, x in next, part:GetChildren() do
                    if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") or x:IsA("AlignPosition") or x:IsA("AlignOrientation") or x:IsA("Torque") or x:IsA("Attachment") then
                        x:Destroy()
                    end
                end

                -- Break joints and anchor
                part:BreakJoints()
                part.Anchored = true

                -- Instant collect by setting initial position
                local initialAngle = (i / numParts) * math.pi * 2
                local initialTargetPos = Vector3.new(
                    playerPos.X + math.cos(initialAngle) * config.radius,
                    playerPos.Y + config.aboveHeight,
                    playerPos.Z + math.sin(initialAngle) * config.radius
                )
                part.CFrame = CFrame.new(initialTargetPos) * CFrame.Angles(math.pi, 0, 0)
            end
        end
    else
        -- Release parts when disabling
        for _, part in pairs(parts) do
            if part.Parent then
                part.Anchored = false
            end
        end
        parts = {}
    end
end)

--// Notification
game.StarterGui:SetCore("SendNotification", {
	Title = "hung",
	Text = "Player List GUI Loaded",
	Duration = 4,
})
