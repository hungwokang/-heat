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

--// Parts Collection System (exact from Super Ring)
local parts = {}
local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(Workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) or Part.Parent:FindFirstChild("Humanoid") or Part.Name == "Handle" then
            return false
        end
        Part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
        Part.CanCollide = false
        return true
    end
    return false
end
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
-- Initial scan
for _, part in pairs(Workspace:GetDescendants()) do
    addPart(part)
end
Workspace.DescendantAdded:Connect(addPart)
Workspace.DescendantRemoving:Connect(removePart)

--// Variables
local levitatingParts = {}
local levitateConnection = nil
local witchBtn = nil
local witchMode = false
local maxGrab = 10
local config = {
    radius = 20,
    height = 40,
    rotationSpeed = 1,
    attractionStrength = 200,
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

--// Functions
local function findNearestLooseParts(num)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or #parts == 0 then return {} end
    local pos = root.Position
    local sortedParts = {}
    for _, part in pairs(parts) do
        if part.Parent then
            table.insert(sortedParts, {part = part, dist = (part.Position - pos).Magnitude})
        end
    end
    table.sort(sortedParts, function(a, b) return a.dist < b.dist end)
    local selected = {}
    for i = 1, math.min(num, #sortedParts) do
        local p = sortedParts[i].part
        pcall(function() p:SetNetworkOwner(LocalPlayer) end)
        p.BrickColor = BrickColor.new("Bright red")  -- Make red for visibility
        p.Transparency = 0  -- Ensure visible
        p.Touched:Connect(function(hit)
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end)
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
        currentAngle = currentAngle + config.rotationSpeed * deltaTime
        local center = root.Position
        for i = #levitatingParts, 1, -1 do
            local part = levitatingParts[i]
            if not part.Parent then
                table.remove(levitatingParts, i)
            else
                local angle = currentAngle + (2 * math.pi * (i - 1) / #levitatingParts)
                local targetPos = Vector3.new(
                    center.X + math.cos(angle) * config.radius,
                    center.Y + config.height,
                    center.Z + math.sin(angle) * config.radius
                )
                local directionToTarget = (targetPos - part.Position).Unit
                part.Velocity = directionToTarget * config.attractionStrength + (root.AssemblyLinearVelocity or Vector3.new())
            end
        end
    end)
end

--// Create initial WITCH button
witchBtn = Instance.new("TextButton")
witchBtn.Name = "WITCH"
witchBtn.Parent = scroll
witchBtn.Size = UDim2.new(1, 0, 0, 25)
witchBtn.BackgroundTransparency = 1
witchBtn.Text = "WITCH"
witchBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
witchBtn.Font = Enum.Font.Code
witchBtn.TextSize = 14
witchBtn.TextXAlignment = Enum.TextXAlignment.Center
witchBtn.MouseButton1Click:Connect(function()
    if witchMode then
        witchMode = false
        witchBtn.Text = "WITCH"
        if levitateConnection then
            levitateConnection:Disconnect()
            levitateConnection = nil
        end
        levitatingParts = {}
        game.StarterGui:SetCore("SendNotification", {Title = "WITCH", Text = "Orbit disabled!", Duration = 3})
    else
        witchMode = true
        witchBtn.Text = "WITCH OFF"
        local partList = findNearestLooseParts(maxGrab)
        if #partList == 0 then
            game.StarterGui:SetCore("SendNotification", {Title = "Error", Text = "No loose parts found!", Duration = 3})
            witchMode = false
            witchBtn.Text = "WITCH"
            return
        end
        game.StarterGui:SetCore("SendNotification", {Title = "WITCH", Text = "Orbiting " .. #partList .. " parts!", Duration = 5})
        orbitParts(partList)
    end
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
    Text = "WITCH loaded! (Orbit)";
    Duration = 5;
})
