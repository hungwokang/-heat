--// Services
local TweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local mouse = player:GetMouse()
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
title.Text = "Z7N7"
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

--// Helper - make a button
local function makeButton(name, callback)
	local btn = Instance.new("TextButton")
	btn.Parent = scroll
	btn.Size = UDim2.new(0.9, 0, 0, 20)
	btn.BackgroundColor3 = Color3.new(0, 0, 0)
	btn.BackgroundTransparency = 0.5
	btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 12
	btn.Font = Enum.Font.Code
	btn.MouseButton1Click:Connect(callback)
	return btn
end

--// Fling variables
local flingActive = false
local wButton = nil
local flying = false
local flingConnection = nil
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 50
local speed = 50
local power = 999999

--// Function to start fling (extracted for reuse)
local function startFling()
    local message = Instance.new("Message", workspace)
    message.Text = "FE Invisible Fling Loaded"
    wait(3)
    message:Destroy()

    local ch = player.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChild("Humanoid")
    if not root or not hum then return end

    -- Create temporary character for invisibility
    local prt = Instance.new("Model", workspace)
    local z1 = Instance.new("Part", prt)
    z1.Name = "Torso"
    z1.CanCollide = false
    z1.Anchored = true
    z1.Position = Vector3.new(0, 9999, 0)
    local z2 = Instance.new("Part", prt)
    z2.Name = "Head"
    z2.Anchored = true
    z2.CanCollide = false
    z2.Position = Vector3.new(0, 9991, 0)
    local z3 = Instance.new("Humanoid", prt)
    z3.Name = "Humanoid"
    player.Character = prt
    wait(5)
    player.Character = ch

    -- Setup humanoid
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

    -- Clean up character parts
    for _, v in pairs(ch:GetChildren()) do
        if v:IsA("BasePart") and v ~= root then
            v:Destroy()
        elseif v:IsA("Decal") and v.Name == "face" then
            v:Destroy()
        elseif v:IsA("Accessory") then
            v:Destroy()
        end
    end

    -- Setup root part
    root.Transparency = 1
    root.CanCollide = true
    root.CustomPhysicalProperties = PhysicalProperties.new(1000, 0, 0, 0, 0)

    workspace.CurrentCamera.CameraSubject = root
    local se = Instance.new("SelectionBox", root)
    se.Adornee = root

    -- Setup fling physics
    local bav = Instance.new("BodyAngularVelocity", root)
    bav.MaxTorque = Vector3.new(0, math.huge, 0)
    bav.AngularVelocity = Vector3.new(0, power, 0)

    -- Create draggable W button
    wButton = Instance.new("TextButton")
    wButton.Parent = gui
    wButton.Size = UDim2.new(0, 40, 0, 40)
    wButton.Position = UDim2.new(0.5, -20, 0.5, -20)
    wButton.BackgroundColor3 = Color3.new(0, 0, 0)
    wButton.BackgroundTransparency = 0.5
    wButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    wButton.Text = "W"
    wButton.TextColor3 = Color3.new(1, 1, 1)
    wButton.TextSize = 14
    wButton.Font = Enum.Font.Code
    wButton.Active = true
    wButton.Draggable = true

    -- Fly function
    local function Fly()
        flying = true
        hum.PlatformStand = true
        local bg = Instance.new("BodyGyro", root)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = root.CFrame
        local bv = Instance.new("BodyVelocity", root)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        while flying do
            wait()
            bg.CFrame = workspace.CurrentCamera.CFrame
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = math.min(speed + 50, maxspeed)
                bv.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + 
                    ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - 
                    workspace.CurrentCamera.CoordinateFrame.p)) * speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            else
                speed = 50
                bv.Velocity = Vector3.new(0, 0.1, 0) -- Slight upward to prevent falling
                lastctrl = {f = 0, b = 0, l = 0, r = 0} -- Reset to stop lingering movement
            end
            root.AssemblyLinearVelocity = bv.Velocity
        end

        hum.PlatformStand = false
        bg:Destroy()
        bv:Destroy()
    end

    -- Input handling
    flingConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name:lower()
            if key == "w" then
                ctrl.f = 1
            elseif key == "s" then
                ctrl.b = -1
            elseif key == "a" then
                ctrl.l = -1
            elseif key == "d" then
                ctrl.r = 1
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name:lower()
            if key == "w" then
                ctrl.f = 0
            elseif key == "s" then
                ctrl.b = 0
            elseif key == "a" then
                ctrl.l = 0
            elseif key == "d" then
                ctrl.r = 0
            end
        end
    end)

    -- W button press simulation
    wButton.MouseButton1Down:Connect(function()
        ctrl.f = 1
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                ctrl.f = 0
                connection:Disconnect()
            end
        end)
    end)

    Fly() -- Start flying
end

--// Function to stop fling (extracted for reuse)
local function stopFling()
    flying = false
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    if wButton then
        wButton:Destroy()
        wButton = nil
    end
    local ch = player.Character
    if ch then
        local root = ch:FindFirstChild("HumanoidRootPart")
        if root then
            for _, v in pairs(root:GetChildren()) do
                if v:IsA("BodyAngularVelocity") or v:IsA("SelectionBox") then
                    v:Destroy()
                end
            end
            root.Transparency = 0
        end
        local hum = ch:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        end
    end
    -- Respawn to restore character
    local savedPos = ch and ch.HumanoidRootPart.Position or Vector3.new(0, 100, 0)
    respawn()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(savedPos)
    end
end

--// Kill All function using fling ram on all players
local function killAll()
    local flingActiveLocal = flingActive
    local originalPower = power
    power = 1000000  -- Extreme power for robustness
    if not flingActive then
        flingActive = true
        startFling()
    end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        warn("No character root found")
        return
    end
    local bav = root:FindFirstChildOfClass("BodyAngularVelocity")
    if bav then
        bav.AngularVelocity = Vector3.new(0, power, 0)
    end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local connection
                connection = RunService.Heartbeat:Connect(function()
                    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0)  -- Position far behind
                    local direction = (targetRoot.Position - root.Position).Unit
                    root.Velocity = direction * 2000  -- Extreme speed toward target
                    root.AssemblyLinearVelocity = root.Velocity
                end)
                wait(2)  -- Time per target for impact
                if connection then
                    connection:Disconnect()
                end
            end
        end
    end

    if not flingActiveLocal then
        flingActive = false
        stopFling()
    end
    power = originalPower
end

--// Logic
local minimized = false

local function refreshButtons()
	-- Remove only buttons, keep layout
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	makeButton("KILL ALL", killAll)

	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

--// Respawn function
local function respawn()
	local savedPos = player.Character and player.Character.HumanoidRootPart.Position or Vector3.new(0, 100, 0)
	local message = Instance.new("Message", workspace)
	message.Text = "Respawning..."
	wait(1)
	message:Destroy()

	local ch = player.Character
	local prt = Instance.new("Model", workspace)
	local z1 = Instance.new("Part", prt)
	z1.Name = "Torso"
	z1.CanCollide = false
	z1.Anchored = true
	z1.Position = Vector3.new(0, 9999, 0)
	local z2 = Instance.new("Part", prt)
	z2.Name = "Head"
	z2.Anchored = true
	z2.CanCollide = false
	z2.Position = Vector3.new(0, 9991, 0)
	local z3 = Instance.new("Humanoid", prt)
	z3.Name = "Humanoid"
	player.Character = prt
	wait(5)
	player.Character = ch
	wait(1)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(savedPos)
	end
end

--// Minimize toggle
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
	Title = "FE Invisible Fling";
	Text = "hehe boi get load'd";
	Duration = 11;
})

--// Initialize buttons
refreshButtons()

--// Update canvas size
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)
