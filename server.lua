--//============================\\--
--// Simple Small Tight GUI (Black/Red Minimal Style)
--//============================\\--

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleText = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local ButtonFrame = Instance.new("Frame")

-- Buttons A-F
local buttons = {}
local labels = {"KNIFE","B","C","D","E","F"}

-- Parent
ScreenGui.Parent = game:GetService("CoreGui")

-- MainFrame
MainFrame.Name = "ServerGui"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 160, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.ClipsDescendants = true

-- TitleBar
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.new(0, 0, 0)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 1
TitleBar.BorderColor3 = Color3.fromRGB(255, 0, 0)
TitleBar.Size = UDim2.new(1, 0, 0, 18)

-- TitleText
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 4, 0, 0)
TitleText.Font = Enum.Font.Code
TitleText.Text = "Server"
TitleText.TextSize = 12
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button (-/+)
MinimizeButton.Parent = TitleBar
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.Code
MinimizeButton.TextSize = 12
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BackgroundTransparency = 0.2
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MinimizeButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
MinimizeButton.Size = UDim2.new(0, 18, 1, 0)
MinimizeButton.Position = UDim2.new(1, -18, 0, 0)

-- Button Container
ButtonFrame.Parent = MainFrame
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Size = UDim2.new(1, 0, 1, -18)
ButtonFrame.Position = UDim2.new(0, 0, 0, 18)

-- Create Buttons
for i, label in ipairs(labels) do
	local btn = Instance.new("TextButton")
	btn.Parent = ButtonFrame
	btn.Text = label
	btn.Font = Enum.Font.Code
	btn.TextSize = 12
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.new(0, 0, 0)
	btn.BackgroundTransparency = 0.2
	btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
	btn.Size = UDim2.new(0, 45, 0, 25)
	btn.Position = UDim2.new(0, ((i-1)%3)*52 + 6, 0, math.floor((i-1)/3)*30 + 6)
	buttons[label] = btn
end

-- Minimize Logic
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		ButtonFrame.Visible = false
		MainFrame.Size = UDim2.new(0, 160, 0, 18)
		MinimizeButton.Text = "+"
	else
		ButtonFrame.Visible = true
		MainFrame.Size = UDim2.new(0, 160, 0, 100)
		MinimizeButton.Text = "-"
	end
end)

--//============================\\--
--// KNIFE MODE FUNCTIONS        //--
--//============================\\--

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- simple variable holders
local Knife = nil
local equipped = false

-- unequip function
local function unequip()
	if Knife then
		Knife:Destroy()
		Knife = nil
	end
	equipped = false
end

-- equip function
local function equip()
	if equipped or Knife then return end
	local tool = Instance.new("Tool")
	tool.Name = "Knife"
	tool.RequiresHandle = true

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.3, 1.2, 0.2)
	handle.BrickColor = BrickColor.new("Really red")
	handle.Material = Enum.Material.Metal
	handle.Parent = tool

	local mesh = Instance.new("SpecialMesh", handle)
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://12221720" -- knife blade
	mesh.TextureId = "rbxassetid://12221739"
	mesh.Scale = Vector3.new(1.2, 1.2, 1.2)

	tool.Parent = player.Backpack
	Knife = tool
	equipped = true
end

-- knife mode activation (spawns and equips)
local function knifemode()
	unequip()
	equip()

	local knifeTool = Knife
	if not knifeTool then return end

	-- attack logic
	knifeTool.Activated:Connect(function()
		local handle = knifeTool:FindFirstChild("Handle")
		if handle then
			handle.BrickColor = BrickColor.new("Bright red")
			game:GetService("Debris"):AddItem(handle, 0.2)
		end
	end)
end

--//============================\\--
--// BIND BUTTONS TO KNIFE MODE  //--
--//============================\\--

buttons["A"].MouseButton1Click:Connect(function()
	if equipped then
		unequip()
	else
		knifemode()
	end
end)
