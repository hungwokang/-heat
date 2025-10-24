--//==============================\\--
--// CLEAN SMALL BLACK & RED GUI  //--
--//==============================\\--

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old UI if re-run
if playerGui:FindFirstChild("WeaponPanel") then
	playerGui.WeaponPanel:Destroy()
end

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "WeaponPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 140)
frame.Position = UDim2.new(0, 30, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.AnchorPoint = Vector2.new(0, 0.5)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 25)
header.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
header.BorderSizePixel = 0
header.Parent = frame

local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0, 10)
hc.Parent = header

local title = Instance.new("TextLabel")
title.Text = "Weapons"
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 0, 0)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Minimize Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 20, 0, 20)
toggleButton.Position = UDim2.new(1, -25, 0.5, -10)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
toggleButton.Text = "-"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.Parent = header

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 6)
tbCorner.Parent = toggleButton

-- Container for buttons
local buttons = Instance.new("Frame")
buttons.Size = UDim2.new(1, -10, 1, -35)
buttons.Position = UDim2.new(0, 5, 0, 30)
buttons.BackgroundTransparency = 1
buttons.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = buttons

-- Helper for button creation
local function makeButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.AutoButtonColor = true
	btn.Parent = buttons

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
	end)

	return btn
end

-- Buttons
local knifeBtn = makeButton("Knife")
local gunBtn = makeButton("Gun")
local katanaBtn = makeButton("Katana")

-- Weapon logic
local activeWeapon = nil
local function deactivate()
	pcall(function() if unequip then unequip() end end)
	activeWeapon = nil
end

local function activate(weapon)
	if activeWeapon == weapon then
		deactivate()
		return
	end
	deactivate()
	activeWeapon = weapon
	pcall(function()
		if equip then equip() end
		if weapon == "Knife" and knifemode then knifemode() end
		if weapon == "Gun" and gunmode then gunmode() end
		if weapon == "Katana" and katanamode then katanamode() end
	end)
end

knifeBtn.MouseButton1Click:Connect(function() activate("Knife") end)
gunBtn.MouseButton1Click:Connect(function() activate("Gun") end)
katanaBtn.MouseButton1Click:Connect(function() activate("Katana") end)

-- Minimize logic
local minimized = false
toggleButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	toggleButton.Text = minimized and "+" or "-"
	buttons.Visible = not minimized
	frame.Size = minimized and UDim2.new(0, 150, 0, 35) or UDim2.new(0, 150, 0, 140)
end)
