--//==============================\\--
--// CLEAN RED ROUNDED WEAPON GUI //--
--//==============================\\--

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Destroy previous GUI if re-executed
if playerGui:FindFirstChild("WeaponPanel") then
	playerGui.WeaponPanel:Destroy()
end

-- Main ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "WeaponPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 180)
frame.Position = UDim2.new(0.5, -120, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Parent = gui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 12)
tbCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Weapon Menu"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Minimize button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 30, 1, 0)
toggleButton.Position = UDim2.new(1, -35, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleButton.Text = "-"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.Parent = titleBar

local tbCorner2 = Instance.new("UICorner")
tbCorner2.CornerRadius = UDim.new(0, 8)
tbCorner2.Parent = toggleButton

-- Container for buttons
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 0, 120)
buttonContainer.Position = UDim2.new(0, 10, 0, 50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = buttonContainer

-- Active tracker
local activeWeapon = nil

-- Helper function
local function createButton(name, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.BackgroundColor3 = color
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Parent = buttonContainer

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.15)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = color
	end)

	return btn
end

-- Buttons
local knifeBtn = createButton("Knife", Color3.fromRGB(255, 70, 70))
local gunBtn = createButton("Gun", Color3.fromRGB(255, 100, 100))
local katanaBtn = createButton("Katana", Color3.fromRGB(255, 130, 130))

-- Toggle Logic
local function activateWeapon(weapon)
	if activeWeapon == weapon then
		if unequip then unequip() end
		activeWeapon = nil
		return
	end

	activeWeapon = weapon
	if equip then equip() end

	if weapon == "Knife" and knifemode then
		knifemode()
	elseif weapon == "Gun" and gunmode then
		gunmode()
	elseif weapon == "Katana" and katanamode then
		katanamode()
	end
end

knifeBtn.MouseButton1Click:Connect(function() activateWeapon("Knife") end)
gunBtn.MouseButton1Click:Connect(function() activateWeapon("Gun") end)
katanaBtn.MouseButton1Click:Connect(function() activateWeapon("Katana") end)

-- Minimize / Expand
local minimized = false
toggleButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	toggleButton.Text = minimized and "+" or "-"
	buttonContainer.Visible = not minimized
	frame.Size = minimized and UDim2.new(0, 240, 0, 40) or UDim2.new(0, 240, 0, 180)
end)
