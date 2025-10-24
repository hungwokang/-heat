--// Simple Small Tight GUI (Black/Red Minimal Style)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleText = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local ButtonFrame = Instance.new("Frame")

-- Buttons A-F
local buttons = {}
local labels = {"A","B","C","D","E","F"}

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
