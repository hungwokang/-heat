--// Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Bypass for simulation ownership (exploit required)
if getgenv().SimRadiusSet ~= true then
    getgenv().SimRadiusSet = true
    pcall(function()
        LocalPlayer.ReplicationFocus = workspace
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)
end

--// Orbiting state
local orbitingParts = {}
local orbitingConnection
local orbitSpeed = 5 -- radians per second
local orbitRadius = 5
local orbitHeight = 10

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
title.Text = "hunggggg"
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

local espHighlights = {}

local function addESP(player)
    if espHighlights[player.Name] then return end

    local function onCharacterAdded(char)
        if espHighlights[player.Name] then
            espHighlights[player.Name]:Destroy()
        end
        local highlight = Instance.new("Highlight")
        highlight.Parent = char
        highlight.FillColor = Color3.new(0, 1, 0)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        espHighlights[player.Name] = highlight
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function removeESP(player)
    if espHighlights[player.Name] then
        espHighlights[player.Name]:Destroy()
        espHighlights[player.Name] = nil
    end
end

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
					removeESP(p)
				else
					selectedTargets[p.Name] = true
					btn.Text = p.Name .. " ✓"
					btn.TextColor3 = Color3.fromRGB(0, 255, 0)
					addESP(p)
				end
			end)

			if selectedTargets[p.Name] then
				addESP(p)
			end
		end
	end
	playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y)
	updateScrollCanvas()
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(p)
	removeESP(p)
end)
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

--// Pull Unanchored Parts Button (Fixed with Bypass & Orbit)
local pullButton = Instance.new("TextButton")
pullButton.Parent = scroll
pullButton.Size = UDim2.new(1, -10, 0, 20)
pullButton.BackgroundColor3 = Color3.new(0, 0, 0)
pullButton.BackgroundTransparency = 0.4
pullButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
pullButton.BorderSizePixel = 1
pullButton.Font = Enum.Font.Code
pullButton.TextColor3 = Color3.fromRGB(255, 255, 255)
pullButton.TextSize = 12
pullButton.Text = "Pull"
pullButton.TextXAlignment = Enum.TextXAlignment.Center

pullButton.MouseButton1Click:Connect(function()
    pcall(function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Error",
                Text = "No character found",
                Duration = 3,
            })
            return
        end

        local root = character.HumanoidRootPart
        local parts = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored and obj.Name ~= "HumanoidRootPart" and not obj:IsDescendantOf(character) then
                table.insert(parts, obj)
            end
        end

        if #parts == 0 then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Info",
                Text = "No unanchored parts found",
                Duration = 3,
            })
            return
        end

        -- Stop previous orbit
        if orbitingConnection then
            orbitingConnection:Disconnect()
            orbitingConnection = nil
        end
        orbitingParts = {}

        -- Process parts
        for i, part in ipairs(parts) do
            pcall(function()
                -- Clean existing controllers
                for _, child in ipairs(part:GetChildren()) do
                    if child:IsA("BodyMover") or child:IsA("AlignPosition") or child:IsA("VectorForce") or child:IsA("Torque") then
                        child:Destroy()
                    end
                end

                -- Optimize physics
                part.CanCollide = false
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)

                -- Add spinning
                local bav = Instance.new("BodyAngularVelocity")
                bav.MaxTorque = Vector3.new(0, math.huge, 0)
                bav.AngularVelocity = Vector3.new(0, 20, 0)
                bav.Parent = part

                -- Add position control for orbit
                local bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bp.Position = part.Position -- Start from current to avoid snap
                bp.P = 5000 -- High power for fast pull
                bp.D = 1000 -- Damping
                bp.Parent = part

                -- Store data
                local baseAngle = (i / #parts) * math.pi * 2
                local heightOffset = math.floor((i - 1) / 20) * 1 -- Stack every 20 parts
                local partRadius = orbitRadius + ((i - 1) % 20) * 0.2 -- Slight radius variation
                table.insert(orbitingParts, {
                    part = part,
                    bp = bp,
                    bav = bav,
                    baseAngle = baseAngle,
                    heightOffset = heightOffset,
                    radius = partRadius
                })
            end)
        end

        -- Start orbiting loop (efficient Heartbeat)
        local lastTime = tick()
        orbitingConnection = RunService.Heartbeat:Connect(function()
            local deltaTime = tick() - lastTime
            lastTime = tick()

            if not character or not root or #orbitingParts == 0 then
                return
            end

            local cf = root.CFrame
            local rightVec = cf.RightVector
            local lookVec = cf.LookVector
            local upVec = cf.UpVector

            for _, data in ipairs(orbitingParts) do
                if data.part.Parent and data.bp.Parent then
                    local currentTime = tick()
                    local angle = data.baseAngle + (orbitSpeed * currentTime)
                    local xOffset = math.cos(angle) * data.radius
                    local zOffset = math.sin(angle) * data.radius
                    local targetPos = root.Position + (upVec * (orbitHeight + data.heightOffset)) + (rightVec * xOffset) + (lookVec * zOffset)
                    data.bp.Position = targetPos
                end
            end
        end)

        game.StarterGui:SetCore("SendNotification", {
            Title = "Success",
            Text = #parts .. " unanchored parts pulled and orbiting above you (replicated & lag-optimized)",
            Duration = 4,
        })
    end)
end)

--// Notification
game.StarterGui:SetCore("SendNotification", {
	Title = "hung",
	Text = "Player List GUI Loaded (with Orbit Bypass)",
	Duration = 4,
})
