--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
playerScroll.Size = UDim2.new(1, -10, 0, 100) -- Increased size for better visibility without button
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

local selectedTarget = nil -- Single target only
local listHidden = false
local lockConnection = nil -- For continuous lock

--// Continuous camera lock function with smooth lerping and slanted overhead view
local function startLock()
	if lockConnection then
		lockConnection:Disconnect()
	end
	local lerpAlpha = 0.1 -- Lerp factor for smoothness (0.05 = smoother/slower, 0.2 = snappier)
	lockConnection = RunService.Heartbeat:Connect(function()
		if selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
			local targetPos = selectedTarget.Character.HumanoidRootPart.Position
			local cameraHeight = 30 -- Height above target
			local slantOffset = 70 -- Horizontal distance behind for slant
			local cameraPos = targetPos + Vector3.new(0, cameraHeight, -slantOffset) -- Slightly behind for slanted view below
			local targetCFrame = CFrame.lookAt(cameraPos, targetPos)
			-- Smooth lerp towards target CFrame
			Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, lerpAlpha)
		else
			-- If target invalid, stop lock
			if lockConnection then
				lockConnection:Disconnect()
				lockConnection = nil
			end
			selectedTarget = nil
		end
	end)
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
			btn.Text = (selectedTarget == p and (p.Name .. " ✓")) or p.Name
			btn.TextColor3 = (selectedTarget == p and Color3.fromRGB(0, 255, 0)) or Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.Code
			btn.TextSize = 10
			btn.TextXAlignment = Enum.TextXAlignment.Left

			btn.MouseButton1Click:Connect(function()
				if selectedTarget == p then
					-- Deselect
					selectedTarget = nil
					if lockConnection then
						lockConnection:Disconnect()
						lockConnection = nil
					end
					game.StarterGui:SetCore("SendNotification", {
						Title = "hung",
						Text = "Lock off",
						Duration = 2,
					})
				else
					-- Select this one (deselects previous automatically)
					selectedTarget = p
					startLock()
					game.StarterGui:SetCore("SendNotification", {
						Title = "hung",
						Text = "Locking to " .. p.Name .. " (smooth slanted overhead view)",
						Duration = 2,
					})
				end
				updatePlayerList() -- Refresh UI
			end)
		end
	end
	playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y)
	updateScrollCanvas()
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(p)
	if selectedTarget == p then
		selectedTarget = nil
		if lockConnection then
			lockConnection:Disconnect()
			lockConnection = nil
		end
		game.StarterGui:SetCore("SendNotification", {
			Title = "hung",
			Text = "Target left - Lock off",
			Duration = 2,
		})
	end
	updatePlayerList()
end)

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

--// Notification
game.StarterGui:SetCore("SendNotification", {
	Title = "hung",
	Text = "Player List GUI Loaded - Select one target to continuously lock camera (smooth slanted overhead view)!",
	Duration = 4,
})

--// Basic bypass notes (implement at your own risk):
-- Continuous updates via Heartbeat with CFrame:Lerp for smooth, natural movement.
-- Lerp alpha (0.1) provides balanced smoothness; adjust for preference.
-- Slanted overhead view: camera 50 studs up and 20 studs behind target, looking down to show ground.
-- For stronger bypasses in Strongest Battlegrounds, consider:
-- - Dynamic alpha based on distance/speed.
-- - Adding random offsets to mimic human input.
-- - Obfuscate the script before injecting.
-- Test in a private server; anti-cheats evolve quickly.
