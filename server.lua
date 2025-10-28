--//  GUI + Auto Collision Setup + Float/Bob Toggle + Super-Fling Throw (NDS-Optimized, No Fly)
--//  LocalScript (paste in StarterPlayerScripts)

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local Workspace      = game.Workspace
local StarterGui     = game:GetService("StarterGui")
local LocalPlayer    = Players.LocalPlayer

--// -------------------------------------------------
--// 1. AUTO CREATE SERVER SCRIPT & REMOTE EVENT
--// -------------------------------------------------
local REMOTE_NAME = "SetupCollisionGroups"

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage

	-- Auto-create ServerScript to handle the event
	local serverScript = Instance.new("Script")
	serverScript.Name = "CollisionGroupHandler"
	serverScript.Source = [[
		local PhysicsService = game:GetService("PhysicsService")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local remote = ReplicatedStorage:WaitForChild("SetupCollisionGroups")

		local done = false
		remote.OnServerEvent:Connect(function()
			if done then return end
			done = true

			local thrown = "ThrownParts"
			local target = "TargetPlayers"

			if not PhysicsService:IsCollisionGroupRegistered(thrown) then
				PhysicsService:RegisterCollisionGroup(thrown)
			end
			if not PhysicsService:IsCollisionGroupRegistered(target) then
				PhysicsService:RegisterCollisionGroup(target)
			end

			PhysicsService:CollisionGroupSetCollidable(thrown, "Default", false)
			PhysicsService:CollisionGroupSetCollidable(thrown, target, true)
		end)
	]]
	serverScript.Parent = game:GetService("ServerScriptService")
	print("[GUI] Server collision handler injected")
end

-- Fire once to trigger server setup
remote:FireServer()

--// -------------------------------------------------
--// 2. CONSTANTS
--// -------------------------------------------------
local THROWN_GROUP = "ThrownParts"
local TARGET_GROUP = "TargetPlayers"

--// -------------------------------------------------
--// 3. FIXED PART COLLECTION (NDS-STYLE)
--// -------------------------------------------------
local function getUnanchoredParts()
	local parts = {}
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj.Anchored then
			if obj.Name ~= "Baseplate" 
				and not obj.Parent:FindFirstChildOfClass("Humanoid")
				and obj.Transparency < 1
				and obj.Size.Magnitude > 0.1 then
				table.insert(parts, obj)
			end
		end
	end
	print("[NDS Debug] Found " .. #parts .. " unanchored parts")
	return parts
end

--// -------------------------------------------------
--// 4. GUI SETUP
--// -------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "ServerGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,120,0,160)  -- Back to original size (no fly button)
frame.Position = UDim2.new(0.5,-60,0.5,-80)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.BackgroundTransparency = 0.4
frame.BorderColor3 = Color3.fromRGB(255,0,0)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,20)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Code
title.Text = "hung"
title.TextColor3 = Color3.fromRGB(255,0,0)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,20,0,20)
minimize.Position = UDim2.new(1,-22,0,0)
minimize.Text = "-"
minimize.Font = Enum.Font.Code
minimize.TextSize = 14
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.fromRGB(255,0,0)
minimize.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0,0,0,22)
scroll.Size = UDim2.new(1,0,1,-42)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,5)
layout.Parent = scroll

local function updateCanvas()
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1,0,0,20)
footer.Position = UDim2.new(0,0,1,-20)
footer.BackgroundTransparency = 1
footer.Font = Enum.Font.Code
footer.Text = "published by server"
footer.TextColor3 = Color3.fromRGB(255,0,0)
footer.TextSize = 10
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = frame

-- Player List
local header = Instance.new("TextButton")
header.Size = UDim2.new(1,-10,0,20)
header.BackgroundTransparency = 1
header.Font = Enum.Font.Code
header.TextColor3 = Color3.fromRGB(255,255,255)
header.TextSize = 12
header.Text = "Select Target"
header.TextXAlignment = Enum.TextXAlignment.Center
header.Parent = scroll

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1,-10,0,60)
playerScroll.Position = UDim2.new(0,5,0,0)
playerScroll.BackgroundColor3 = Color3.new(0,0,0)
playerScroll.BackgroundTransparency = 0.6
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 2
playerScroll.Parent = scroll

local playerLayout = Instance.new("UIListLayout")
playerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0,1)
playerLayout.Parent = playerScroll

local selectedTargets = {}
local listHidden = false

local function refreshPlayers()
	for _,c in ipairs(playerScroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Name = p.Name
			btn.Size = UDim2.new(0.95,0,0,16)
			btn.BackgroundTransparency = 1
			btn.Font = Enum.Font.Code
			btn.TextSize = 10
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Text = selectedTargets[p.Name] and (p.Name.." [Checkmark]") or p.Name
			btn.TextColor3 = selectedTargets[p.Name] and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
			btn.Parent = playerScroll

			btn.MouseButton1Click:Connect(function()
				if selectedTargets[p.Name] then
					selectedTargets[p.Name] = nil
					btn.Text = p.Name
					btn.TextColor3 = Color3.fromRGB(255,255,255)
				else
					selectedTargets[p.Name] = p
					btn.Text = p.Name.." [Checkmark]"
					btn.TextColor3 = Color3.fromRGB(0,255,0)
				end
			end)
		end
	end
	playerScroll.CanvasSize = UDim2.new(0,0,0,playerLayout.AbsoluteContentSize.Y)
	updateCanvas()
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

header.MouseButton1Click:Connect(function()
	listHidden = not listHidden
	playerScroll.Visible = not listHidden
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	local target = minimized and UDim2.new(0,120,0,25) or UDim2.new(0,120,0,160)
	TweenService:Create(frame,TweenInfo.new(0.25,Enum.EasingStyle.Sine), {Size = target}):Play()
	scroll.Visible = not minimized
	footer.Visible = not minimized
	minimize.Text = minimized and "+" or "-"
end)

StarterGui:SetCore("SendNotification", {Title="hung", Text="GUI Loaded (Super Fling! Try during disaster)", Duration=4})

--// -------------------------------------------------
--// 5. FLOAT & BOB (unchanged)
--// -------------------------------------------------
local blobButton = Instance.new("TextButton")
blobButton.Size = UDim2.new(1,-10,0,20)
blobButton.BackgroundTransparency = 1
blobButton.Font = Enum.Font.Code
blobButton.TextColor3 = Color3.fromRGB(255,0,0)
blobButton.TextSize = 12
blobButton.Text = "grab"
blobButton.TextXAlignment = Enum.TextXAlignment.Center
blobButton.Parent = scroll

local blobActive = false
local blobParts = {}
local blobConns = {}

local function stopBlob()
	if not blobActive then return end
	blobActive = false
	blobButton.Text = "grab"
	for _,part in ipairs(blobParts) do
		part.Anchored = false
	end
	for _,conn in ipairs(blobConns) do
		if conn.Connected then conn:Disconnect() end
	end
	blobParts = {}
	blobConns = {}
end

local function startBlob()
	if blobActive then return end

	local allParts = getUnanchoredParts()
	if #allParts == 0 then
		StarterGui:SetCore("SendNotification", {Title="No Parts!", Text="Wait for a disaster (e.g., Earthquake) for debris.", Duration=3})
		return
	end

	local count = math.min(100, #allParts)
	blobParts = {}
	local used = {}
	for i = 1, count do
		local idx = math.random(1, #allParts)
		while used[idx] do 
			idx = math.random(1, #allParts)
		end
		used[idx] = true
		table.insert(blobParts, allParts[idx])
	end

	local char = LocalPlayer.Character
	if not char then stopBlob(); return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then stopBlob(); return end

	local base = Vector3.new(0, 15, 0)
	local offsets = {}

	for i, part in ipairs(blobParts) do
		local offset = Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
		table.insert(offsets, offset)
		TweenService:Create(part, TweenInfo.new(2), {Position = hrp.Position + base + offset}):Play()
	end
	task.wait(2.5)

	blobActive = true
	blobButton.Text = "stop"

	for i, part in ipairs(blobParts) do
		part.Anchored = true
		local offset = offsets[i]
		local conn = RunService.Heartbeat:Connect(function()
			if not (char and hrp and part and part.Parent) then stopBlob(); return end
			local t = tick()
			local bob = Vector3.new(0, math.sin(t * math.pi) * 3, 0)
			part.Position = hrp.Position + base + offset + bob
		end)
		table.insert(blobConns, conn)
	end
end

blobButton.MouseButton1Click:Connect(function()
	if blobActive then stopBlob() else startBlob() end
end)

--// -------------------------------------------------
--// 6. SUPER FLING THROW (TOUCHED EVENT + HIGH VELOCITY)
--// -------------------------------------------------
local throwButton = Instance.new("TextButton")
throwButton.Size = UDim2.new(1,-10,0,20)
throwButton.BackgroundTransparency = 1
throwButton.Font = Enum.Font.Code
throwButton.TextColor3 = Color3.fromRGB(255,0,0)
throwButton.TextSize = 12
throwButton.Text = "start throw"
throwButton.TextXAlignment = Enum.TextXAlignment.Center
throwButton.Parent = scroll

throwButton.MouseButton1Click:Connect(function()
	task.wait(0.5)

	local srcParts = getUnanchoredParts()
	if #srcParts == 0 then
		StarterGui:SetCore("SendNotification", {Title="No Parts!", Text="Wait for a disaster for debris to fling.", Duration=3})
		return
	end

	local myChar = LocalPlayer.Character
	if not myChar then return end
	local myHrp = myChar:FindFirstChild("HumanoidRootPart")
	if not myHrp then return end

	local base = Vector3.new(0, 10, 0)

	for _,targetPlr in pairs(selectedTargets) do
		local tgtChar = targetPlr.Character
		if not tgtChar then continue end

		-- Tag target
		for _,p in ipairs(tgtChar:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CollisionGroup = TARGET_GROUP
			end
		end

		local tgtHrp = tgtChar:FindFirstChild("HumanoidRootPart")
		if not tgtHrp then continue end

		local src = srcParts[math.random(1, #srcParts)]
		local clone = src:Clone()
		clone.Anchored = true
		clone.CanCollide = false
		clone.CollisionGroup = THROWN_GROUP
		clone.Massless = false  -- Heavy for impact
		if clone.Size.Magnitude < 4 then
			clone.Size = clone.Size * 4  -- Bigger for better hits
		end
		clone.Parent = Workspace

		local offset = Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
		clone.Position = myHrp.Position + base + offset

		-- 3-second bob above YOU
		task.spawn(function()
			local start = tick()
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if tick() - start >= 1.5 then
					conn:Disconnect()
					clone.Anchored = false
					clone.CanCollide = true
					-- HIGH VELOCITY LAUNCH
					local dir = (tgtHrp.Position - clone.Position).Unit
					local flingVel = dir * 500 + Vector3.new(0, 500, 0)  -- Ultra-boosted
					clone.AssemblyLinearVelocity = flingVel
					clone.Velocity = flingVel
					print("[Fling Debug] Launched at " .. targetPlr.Name .. " with " .. flingVel.Magnitude .. " speed")

					-- Touched event for extra impulse on hit
					local touchConn
					touchConn = clone.Touched:Connect(function(hit)
						local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
						if humanoid and hit.Parent ~= myChar then
							-- Apply extra fling force
							local bodyVel = Instance.new("BodyVelocity")
							bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)  -- Massive force
							bodyVel.Velocity = flingVel * 2  -- Double for ragdoll
							bodyVel.Parent = hit
							game:GetService("Debris"):AddItem(bodyVel, 0.5)
							print("[Fling Debug] Direct hit & extra impulse on " .. hit.Parent.Name)
							touchConn:Disconnect()  -- One-time per part
						end
					end)

					return
				end
				local t = tick()
				local bob = Vector3.new(0, math.sin(t * math.pi) * 3, 0)
				clone.Position = myHrp.Position + base + offset + bob
			end)
		end)
	end
end)

updateCanvas()
