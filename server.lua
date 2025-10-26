local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")

-- GUI setup (your original code)
main.Name = "main"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)

-- (Setup buttons like you already did)
-- ... Copy all button setup from your original code here ...

-- Fly variables
local flying = false
local speeds = 1
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local ctrl = {f=0,b=0,l=0,r=0,u=0,d=0}
local lastctrl = {f=0,b=0,l=0,r=0,u=0,d=0}
local bv, bg

local function startFly()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	flying = true
	hum.PlatformStand = true

	bg = Instance.new("BodyGyro", hrp)
	bg.P = 9e4
	bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bg.CFrame = hrp.CFrame

	bv = Instance.new("BodyVelocity", hrp)
	bv.MaxForce = Vector3.new(9e9,9e9,9e9)
	bv.Velocity = Vector3.new(0,0,0)

	local function updateControl(input, state)
		local val = state == Enum.UserInputState.Begin and 1 or 0
		if input.KeyCode == Enum.KeyCode.W then ctrl.f = val
		elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = val
		elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = val
		elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = val
		elseif input.KeyCode == Enum.KeyCode.Space then ctrl.u = val
		elseif input.KeyCode == Enum.KeyCode.LeftControl then ctrl.d = val
		end
	end

	uis.InputBegan:Connect(function(input, gpe)
		if not gpe then updateControl(input, Enum.UserInputState.Begin) end
	end)
	uis.InputEnded:Connect(function(input, gpe)
		if not gpe then updateControl(input, Enum.UserInputState.End) end
	end)

	rs.RenderStepped:Connect(function()
		if not flying then return end
		local cf = workspace.CurrentCamera.CFrame
		local dir = (cf.LookVector*(ctrl.f - ctrl.b)) + (cf.RightVector*(ctrl.r - ctrl.l)) + Vector3.new(0,(ctrl.u - ctrl.d),0)
		if dir.Magnitude > 0 then dir = dir.Unit end
		bv.Velocity = dir * speeds * 10
		bg.CFrame = cf
	end)
end

local function stopFly()
	flying = false
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

-- Button events
onof.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

plus.MouseButton1Click:Connect(function()
	speeds = speeds + 1
	speed.Text = speeds
end)

mine.MouseButton1Click:Connect(function()
	if speeds > 1 then
		speeds = speeds - 1
		speed.Text = speeds
	end
end)

up.MouseButton1Down:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	while up:IsMouseButtonPressed() and hrp do
		hrp.CFrame = hrp.CFrame + Vector3.new(0,1,0)
		wait()
	end
end)

down.MouseButton1Down:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	while down:IsMouseButtonPressed() and hrp do
		hrp.CFrame = hrp.CFrame + Vector3.new(0,-1,0)
		wait()
	end
end)

closebutton.MouseButton1Click:Connect(function()
	main:Destroy()
end)

mini.MouseButton1Click:Connect(function()
	up.Visible = false
	down.Visible = false
	onof.Visible = false
	plus.Visible = false
	speed.Visible = false
	mine.Visible = false
	mini.Visible = false
	mini2.Visible = true
	Frame.BackgroundTransparency = 1
	closebutton.Position = UDim2.new(0,0,-1,57)
end)

mini2.MouseButton1Click:Connect(function()
	up.Visible = true
	down.Visible = true
	onof.Visible = true
	plus.Visible = true
	speed.Visible = true
	mine.Visible = true
	mini.Visible = true
	mini2.Visible = false
	Frame.BackgroundTransparency = 0
	closebutton.Position = UDim2.new(0,0,-1,27)
end)
