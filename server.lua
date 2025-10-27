-- PART 1: Main GUI (unchanged) + GG opener
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

-- Super Ring overlay handler forward-declare
local SuperRingOverlay = nil

-- Open overlay function (shows the overlay frame; creates it once)
local function openSuperRingOverlay()
    if SuperRingOverlay and SuperRingOverlay.Parent then
        SuperRingOverlay.Visible = true
        return
    end
    -- We'll create the overlay in Part 2 (script continues there).
    -- This placeholder exists so refreshButtons can reference the function.
    -- Actual overlay creation code is appended in Part 2.
    if _G.CreateSuperRingOverlay then
        _G.CreateSuperRingOverlay(gui, frame) -- call Part2 function to create overlay
    end
    if SuperRingOverlay and SuperRingOverlay.Parent then
        SuperRingOverlay.Visible = true
    end
end

local function refreshButtons()
	-- Remove only buttons, keep layout
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	makeButton("KILL ALL", killAll)

	-- ADD GG BUTTON (matches your GUI style)
	makeButton("GG", function()
		openSuperRingOverlay()
	end)

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


-- PART 2: Super Ring Overlay (restyled, uses original Super Ring logic)
-- This code expects to be run in the same environment as Part 1.
-- We expose a creation function to be called from Part 1.

-- Wrap in a function so Part1 can call it
_G.CreateSuperRingOverlay = function(parentGui, mainFrame)
    -- if already created, don't duplicate
    if parentGui:FindFirstChild("SuperRingOverlay") then
        SuperRingOverlay = parentGui:FindFirstChild("SuperRingOverlay")
        SuperRingOverlay.Visible = true
        return
    end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local SoundService = game:GetService("SoundService")
    local StarterGui = game:GetService("StarterGui")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer

    -- Sound Effects (kept identical)
    local function playSound(soundId)
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundId
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end

    playSound("2865227271")

    -- Overlay ScreenGui/Frame (overlay style matches main GUI)
    local overlayFrame = Instance.new("Frame")
    overlayFrame.Name = "SuperRingOverlay"
    overlayFrame.Size = UDim2.new(0, 300, 0, 500)
    -- position overlay centered over mainFrame (overlay)
    overlayFrame.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset - 90, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset - 200)
    overlayFrame.BorderSizePixel = 0
    overlayFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- black
    overlayFrame.BackgroundTransparency = 0.2
    overlayFrame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- red border color
    overlayFrame.Parent = parentGui

    -- Blocky red border: create an Outline Frame (thin)
    local outline = Instance.new("Frame")
    outline.Size = UDim2.new(1, 2, 1, 2)
    outline.Position = UDim2.new(0, -1, 0, -1)
    outline.BorderSizePixel = 0
    outline.BackgroundTransparency = 1
    outline.Parent = overlayFrame
    local outlineStroke = Instance.new("UIStroke")
    outlineStroke.Color = Color3.fromRGB(255,0,0)
    outlineStroke.Thickness = 2
    outlineStroke.Parent = outline

    -- Title (styled)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 28)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Text = "Super Ring Parts V6 by lukas"
    Title.TextColor3 = Color3.fromRGB(255, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.Parent = overlayFrame

    -- Minimize/Close for overlay
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -26, 0, 2)
    CloseBtn.Text = "x"
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 14
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Color3.fromRGB(255,0,0)
    CloseBtn.Parent = overlayFrame

    CloseBtn.MouseButton1Click:Connect(function()
        overlayFrame.Visible = false
    end)

    -- Make overlay draggable (blocky style)
    overlayFrame.Active = true
    overlayFrame.Draggable = true

    -- Main content container (scroll-like)
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -10, 1, -40)
    content.Position = UDim2.new(0, 5, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = overlayFrame

    -- Config table (kept identical with load/save)
    local config = {
        radius = 50,
        height = 100,
        rotationSpeed = 10,
        attractionStrength = 1000,
    }

    local function saveConfig()
        local ok, err = pcall(function()
            local configStr = HttpService:JSONEncode(config)
            if writefile then writefile("SuperRingPartsConfig.txt", configStr) end
        end)
        -- ignore errors silently
    end

    local function loadConfig()
        if isfile and isfile("SuperRingPartsConfig.txt") then
            local ok, data = pcall(function() return readfile("SuperRingPartsConfig.txt") end)
            if ok and data then
                local success, t = pcall(function() return HttpService:JSONDecode(data) end)
                if success and t then
                    config = t
                end
            end
        end
    end

    loadConfig()

    -- Create controls (restyled to match)
    local function createControl(name, posY, color, labelText, defaultValue, callback)
        -- Label
        local Display = Instance.new("TextLabel")
        Display.Size = UDim2.new(0.8, 0, 0, 22)
        Display.Position = UDim2.new(0.1, 0, 0, posY)
        Display.Text = labelText .. ": " .. defaultValue
        Display.BackgroundColor3 = Color3.fromRGB(20,20,20)
        Display.BorderSizePixel = 1
        Display.BorderColor3 = Color3.fromRGB(255,0,0)
        Display.TextColor3 = Color3.fromRGB(255,255,255)
        Display.Font = Enum.Font.Code
        Display.TextSize = 13
        Display.Parent = content

        -- Decrease
        local DecreaseButton = Instance.new("TextButton")
        DecreaseButton.Size = UDim2.new(0.15, 0, 0, 22)
        DecreaseButton.Position = UDim2.new(0.01, 0, 0, posY)
        DecreaseButton.Text = "-"
        DecreaseButton.BackgroundColor3 = Color3.new(0,0,0)
        DecreaseButton.BorderColor3 = Color3.fromRGB(255,0,0)
        DecreaseButton.TextColor3 = Color3.fromRGB(255,255,255)
        DecreaseButton.Font = Enum.Font.Code
        DecreaseButton.TextSize = 14
        DecreaseButton.Parent = content

        -- Increase
        local IncreaseButton = Instance.new("TextButton")
        IncreaseButton.Size = UDim2.new(0.15, 0, 0, 22)
        IncreaseButton.Position = UDim2.new(0.84, 0, 0, posY)
        IncreaseButton.Text = "+"
        IncreaseButton.BackgroundColor3 = Color3.new(0,0,0)
        IncreaseButton.BorderColor3 = Color3.fromRGB(255,0,0)
        IncreaseButton.TextColor3 = Color3.fromRGB(255,255,255)
        IncreaseButton.Font = Enum.Font.Code
        IncreaseButton.TextSize = 14
        IncreaseButton.Parent = content

        -- TextBox (input)
        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(0.98, 0, 0, 22)
        TextBox.Position = UDim2.new(0.01, 0, 0, posY + 24)
        TextBox.PlaceholderText = "Enter " .. labelText
        TextBox.BackgroundColor3 = Color3.fromRGB(15,15,15)
        TextBox.BorderColor3 = Color3.fromRGB(255,0,0)
        TextBox.TextColor3 = Color3.fromRGB(255,255,255)
        TextBox.Font = Enum.Font.Code
        TextBox.TextSize = 13
        TextBox.Parent = content

        -- Button callbacks
        DecreaseButton.MouseButton1Click:Connect(function()
            local value = tonumber(Display.Text:match("%d+")) or defaultValue
            value = math.max(0, value - 10)
            Display.Text = labelText .. ": " .. value
            callback(value)
            playSound("12221967")
            saveConfig()
        end)

        IncreaseButton.MouseButton1Click:Connect(function()
            local value = tonumber(Display.Text:match("%d+")) or defaultValue
            value = math.min(10000, value + 10)
            Display.Text = labelText .. ": " .. value
            callback(value)
            playSound("12221967")
            saveConfig()
        end)

        TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local newValue = tonumber(TextBox.Text)
                if newValue then
                    newValue = math.clamp(newValue, 0, 10000)
                    Display.Text = labelText .. ": " .. newValue
                    TextBox.Text = ""
                    callback(newValue)
                    playSound("12221967")
                    saveConfig()
                else
                    TextBox.Text = ""
                end
            end
        end)
    end

    -- Track vertical position for controls
    local curY = 0

    -- Create controls exactly like original but restyled
    createControl("Radius", curY + 0, Color3.fromRGB(153,153,0), "Radius", config.radius, function(value)
        config.radius = value
        saveConfig()
    end)
    curY = curY + 60

    createControl("Height", curY + 0, Color3.fromRGB(153,0,153), "Height", config.height, function(value)
        config.height = value
        saveConfig()
    end)
    curY = curY + 60

    createControl("RotationSpeed", curY + 0, Color3.fromRGB(0,153,153), "Rotation Speed", config.rotationSpeed, function(value)
        config.rotationSpeed = value
        saveConfig()
    end)
    curY = curY + 60

    createControl("AttractionStrength", curY + 0, Color3.fromRGB(153,0,0), "Attraction Strength", config.attractionStrength, function(value)
        config.attractionStrength = value
        saveConfig()
    end)
    curY = curY + 60

    -- Minimize button (overlay)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
    MinimizeButton.Text = "-"
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
    MinimizeButton.BorderColor3 = Color3.fromRGB(255,0,0)
    MinimizeButton.TextColor3 = Color3.fromRGB(255,0,0)
    MinimizeButton.Font = Enum.Font.Code
    MinimizeButton.TextSize = 14
    MinimizeButton.Parent = overlayFrame

    local minimizedOverlay = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimizedOverlay = not minimizedOverlay
        if minimizedOverlay then
            overlayFrame.Size = UDim2.new(0, 300, 0, 36)
            MinimizeButton.Text = "+"
            for _, child in ipairs(overlayFrame:GetChildren()) do
                if child:IsA("GuiObject") and child ~= Title and child ~= MinimizeButton and child ~= CloseBtn then
                    child.Visible = false
                end
            end
        else
            overlayFrame.Size = UDim2.new(0, 300, 0, 500)
            MinimizeButton.Text = "-"
            for _, child in ipairs(overlayFrame:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.Visible = true
                end
            end
        end
        playSound("12221967")
    end)

    -- Dragging overlay (already set as Draggable)

    -- Ring Parts logic (kept identical behavior)
    local Workspace = game:GetService("Workspace")
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local Folder = Instance.new("Folder", Workspace)
    local Part = Instance.new("Part", Folder)
    local Attachment1 = Instance.new("Attachment", Part)
    Part.Anchored = true
    Part.CanCollide = false
    Part.Transparency = 1

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
            LocalPlayer.ReplicationFocus = Workspace
            RunService.Heartbeat:Connect(function()
                pcall(function()
                    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                end)
                for _, Part in pairs(Network.BaseParts) do
                    if Part:IsDescendantOf(Workspace) then
                        Part.Velocity = Network.Velocity
                    end
                end
            end)
        end

        EnablePartControl()
    end

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
            AlignPosition.MaxForce = 9999999999999999999999999999999
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 200
            AlignPosition.Attachment0 = Attachment2
            AlignPosition.Attachment1 = Attachment1
        end
    end

    local ringPartsEnabled = false

    local function RetainPart(Part)
        if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
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

    for _, part in pairs(workspace:GetDescendants()) do
        addPart(part)
    end

    workspace.DescendantAdded:Connect(addPart)
    workspace.DescendantRemoving:Connect(removePart)

    RunService.Heartbeat:Connect(function()
        if not ringPartsEnabled then return end

        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
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
                    local ok, dir = pcall(function() return (targetPos - part.Position).unit end)
                    if ok and dir then
                        part.Velocity = dir * config.attractionStrength
                    end
                end
            end
        end
    end)

    -- Toggle button (restyled)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 28)
    ToggleButton.Position = UDim2.new(0.1, 0, 0, curY + 10)
    ToggleButton.Text = "Ring Off"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
    ToggleButton.BorderColor3 = Color3.fromRGB(255,0,0)
    ToggleButton.TextColor3 = Color3.fromRGB(255,0,0)
    ToggleButton.Font = Enum.Font.Code
    ToggleButton.TextSize = 14
    ToggleButton.Parent = content

    ToggleButton.MouseButton1Click:Connect(function()
        ringPartsEnabled = not ringPartsEnabled
        ToggleButton.Text = ringPartsEnabled and "Tornado On" or "Tornado Off"
        if ringPartsEnabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
            ToggleButton.TextColor3 = Color3.fromRGB(0,255,0)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
            ToggleButton.TextColor3 = Color3.fromRGB(255,0,0)
        end
        playSound("12221967")
    end)

    -- Thumbnail + notices (kept)
    local ok, userId = pcall(function() return Players:GetUserIdFromNameAsync("Robloxlukasgames") end)
    if ok and userId then
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
        StarterGui:SetCore("SendNotification", {
            Title = "Hey",
            Text = "Enjoy the Script!",
            Icon = content,
            Duration = 5
        })
        StarterGui:SetCore("SendNotification", {
            Title = "TIPS",
            Text = "Click Textbox To edit Any of them",
            Icon = content,
            Duration = 5
        })
        StarterGui:SetCore("SendNotification", {
            Title = "Credits",
            Text = "On scriptblox!",
            Icon = content,
            Duration = 5
        })
    end

    -- Rainbow background & title text (kept behavior but subtle)
    local hue = 0
    local textHue = 0
    local bgConn = RunService.Heartbeat:Connect(function()
        hue = (hue + 0.005) % 1
        -- subtle HSV on black -> keep very dim saturation
        overlayFrame.BackgroundColor3 = Color3.fromHSV(hue, 0.2, 0.06)
        textHue = (textHue + 0.01) % 1
        Title.TextColor3 = Color3.fromHSV(textHue, 0.6, 1)
    end)

    -- Add Back button (closes overlay)
    local BackBtn = Instance.new("TextButton")
    BackBtn.Size = UDim2.new(0.8, 0, 0, 24)
    BackBtn.Position = UDim2.new(0.1, 0, 0, 440)
    BackBtn.Text = "Back"
    BackBtn.BackgroundColor3 = Color3.new(0,0,0)
    BackBtn.BorderColor3 = Color3.fromRGB(255,0,0)
    BackBtn.TextColor3 = Color3.fromRGB(255,0,0)
    BackBtn.Font = Enum.Font.Code
    BackBtn.TextSize = 14
    BackBtn.Parent = overlayFrame

    BackBtn.MouseButton1Click:Connect(function()
        overlayFrame.Visible = false
    end)

    -- Save SuperRingOverlay ref globally so Part1 can toggle it
    SuperRingOverlay = overlayFrame
end
