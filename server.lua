--// Services
local TweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local mouse = player:GetMouse()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

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
title.Text = "hung"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 0, 0, 0)

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

-- Network setup from original
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
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

-- Function to force part
local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", Part)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

local function ForcePart(v)
    if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChild("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, x in next, v:GetChildren() do
            if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        if v:FindFirstChild("Attachment") then
            v:FindFirstChild("Attachment"):Destroy()
        end
        if v:FindFirstChild("AlignPosition") then
            v:FindFirstChild("AlignPosition"):Destroy()
        end
        if v:FindFirstChild("Torque") then
            v:FindFirstChild("Torque"):Destroy()
        end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = 999999999999999999
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1
        Network.RetainPart(v)
    end
end

-- Collect loose parts
local parts = {}
local function RetainPart(part)
    if part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(Workspace) then
        if part.Parent == player.Character or part:IsDescendantOf(player.Character) then
            return false
        end
        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        part.CanCollide = false
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

for _, part in pairs(Workspace:GetDescendants()) do
    addPart(part)
end

Workspace.DescendantAdded:Connect(addPart)
Workspace.DescendantRemoving:Connect(removePart)

-- GUI Buttons
local function createTransparentButton(text)
    local button = Instance.new("TextButton")
    button.BackgroundTransparency = 1
    button.Text = text
    button.Font = Enum.Font.Code
    button.TextColor3 = Color3.fromRGB(255, 0, 0)
    button.TextSize = 12
    button.Size = UDim2.new(1, 0, 0, 20)
    return button
end

-- Selected players table
local selectedPlayers = {}

-- Function to populate main menu
local function populateMainMenu()
    scroll:ClearAllChildren()
    local newLayout = Instance.new("UIListLayout")
    newLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    newLayout.SortOrder = Enum.SortOrder.LayoutOrder
    newLayout.Padding = UDim.new(0, 5)
    newLayout.Parent = scroll

    local witchButton = createTransparentButton("WITCH")
    witchButton.Parent = scroll
    witchButton.MouseButton1Click:Connect(function()
        populateWitchMenu()
    end)

    local flyButton = createTransparentButton("FLY")
    flyButton.Parent = scroll
    flyButton.MouseButton1Click:Connect(function()
        loadstring([[
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = game.Workspace.CurrentCamera

-- Variables
local isFlying = false
local flySpeed = 50
local velocities = {
    forward = 0,
    horizontal = 0,
    vertical = 0
}
local bodyVelocity = nil

-- GUI Setup
local FlyGui = Instance.new("ScreenGui")
FlyGui.Name = "FlyGui"
FlyGui.Parent = player:WaitForChild("PlayerGui")
FlyGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = FlyGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.75, 0, 0.6, 0)
Frame.Size = UDim2.new(0, 180, 0, 180)
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.1, 0)
UICorner.Parent = Frame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 200))
}
UIGradient.Parent = Frame

local GridLayout = Instance.new("UIGridLayout")
GridLayout.Parent = Frame
GridLayout.CellSize = UDim2.new(0, 50, 0, 50)
GridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
GridLayout.StartOrder = Enum.SortOrder.LayoutOrder

-- Button Creation Function
local function createButton(name, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = Frame
    button.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.ZIndex = 2
    local corner = UICorner:Clone()
    corner.Parent = button
    return button
end

-- Create Buttons
local forwardButton = createButton("Forward", "Up")
local upButton = createButton("Up", "Up Arrow")
local backwardButton = createButton("Backward", "Down")
local leftButton = createButton("Left", "Left Arrow")
local flyButton = createButton("Fly", "Fly")
local rightButton = createButton("Right", "Right Arrow")
local speedMinus = createButton("SpeedMinus", "-")
local downButton = createButton("Down", "Down Arrow")
local speedPlus = createButton("SpeedPlus", "+")

-- Connect Events
flyButton.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    flyButton.Text = isFlying and "Unfly" or "Fly"
end)

speedPlus.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 10
end)

speedMinus.MouseButton1Click:Connect(function()
    flySpeed = math.max(10, flySpeed - 10)
end)

-- Direction Buttons
forwardButton.MouseButton1Down:Connect(function() velocities.forward = flySpeed end)
forwardButton.MouseButton1Up:Connect(function() velocities.forward = 0 end)

backwardButton.MouseButton1Down:Connect(function() velocities.forward = -flySpeed end)
backwardButton.MouseButton1Up:Connect(function() velocities.forward = 0 end)

leftButton.MouseButton1Down:Connect(function() velocities.horizontal = -flySpeed end)
leftButton.MouseButton1Up:Connect(function() velocities.horizontal = 0 end)

rightButton.MouseButton1Down:Connect(function() velocities.horizontal = flySpeed end)
rightButton.MouseButton1Up:Connect(function() velocities.horizontal = 0 end)

upButton.MouseButton1Down:Connect(function() velocities.vertical = flySpeed end)
upButton.MouseButton1Up:Connect(function() velocities.vertical = 0 end)

downButton.MouseButton1Down:Connect(function() velocities.vertical = -flySpeed end)
downButton.MouseButton1Up:Connect(function() velocities.vertical = 0 end)

-- Fly Logic
RunService.RenderStepped:Connect(function()
    if isFlying then
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "FlyVelocity"
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = hrp
            humanoid.PlatformStand = true
        end
        local velocity = (camera.CFrame.LookVector * velocities.forward) +
            (camera.CFrame.RightVector * velocities.horizontal) +
            Vector3.new(0, velocities.vertical, 0)
        bodyVelocity.Velocity = velocity
    else
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
            humanoid.PlatformStand = false
        end
    end
end)
        ]])()
    end)
end

-- Function to populate witch menu
local function populateWitchMenu()
    scroll:ClearAllChildren()
    local newLayout = Instance.new("UIListLayout")
    newLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    newLayout.SortOrder = Enum.SortOrder.LayoutOrder
    newLayout.Padding = UDim.new(0, 5)
    newLayout.Parent = scroll

    local selectLabel = Instance.new("TextLabel")
    selectLabel.BackgroundTransparency = 1
    selectLabel.Text = "Select Target:"
    selectLabel.Font = Enum.Font.Code
    selectLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    selectLabel.TextSize = 12
    selectLabel.Size = UDim2.new(1, 0, 0, 20)
    selectLabel.Parent = scroll

    selectedPlayers = {}

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local plrButton = createTransparentButton(plr.Name)
            plrButton.Parent = scroll
            plrButton.MouseButton1Click:Connect(function()
                if table.find(selectedPlayers, plr) then
                    table.remove(selectedPlayers, table.find(selectedPlayers, plr))
                    plrButton.Text = plr.Name
                else
                    table.insert(selectedPlayers, plr)
                    plrButton.Text = "[X] " .. plr.Name
                end
            end)
        end
    end

    local startButton = createTransparentButton("Start")
    startButton.Parent = scroll
    startButton.MouseButton1Click:Connect(function()
        if #selectedPlayers > 0 and #parts > 0 then
            local target = selectedPlayers[math.random(1, #selectedPlayers)]  -- Pick random if multiple
            local chosenPart = parts[math.random(1, #parts)]  -- Pick random loose part

            ForcePart(chosenPart)

            -- Levitate above player
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local levitateConnection
                levitateConnection = RunService.Heartbeat:Connect(function()
                    Part.Position = hrp.Position + Vector3.new(0, 10, 0)
                end)

                wait(3)

                levitateConnection:Disconnect()

                -- Shoot to target
                local targetChar = target.Character
                local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    -- Remove controls
                    if chosenPart:FindFirstChild("Torque") then chosenPart:FindFirstChild("Torque"):Destroy() end
                    if chosenPart:FindFirstChild("AlignPosition") then chosenPart:FindFirstChild("AlignPosition"):Destroy() end
                    if chosenPart:FindFirstChild("Attachment") then chosenPart:FindFirstChild("Attachment"):Destroy() end

                    chosenPart.CanCollide = true
                    local direction = (targetHrp.Position - chosenPart.Position).unit
                    chosenPart.Velocity = direction * 500
                end
            end
        end
    end)

    local backButton = createTransparentButton("Back")
    backButton.Parent = scroll
    backButton.MouseButton1Click:Connect(function()
        populateMainMenu()
    end)

    -- Update canvas size
    scroll.CanvasSize = UDim2.new(0, 0, 0, newLayout.AbsoluteContentSize.Y + 10)
end

-- Initial population
populateMainMenu()
