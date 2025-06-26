local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local ToggleContainer = Instance.new("Frame")
local HighJump = Instance.new("TextButton")
local ESP = Instance.new("TextButton")

-- Main GUI setup
ScreenGui.Name = "SimpleCheatMenu"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 150) -- Adjusted height for two buttons
MainFrame.Active = true
MainFrame.Draggable = true

-- Title bar with minimize button
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundTransparency = 1
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)

-- Title text
Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Size = UDim2.new(0.7, 0, 1, -10)
Title.Font = Enum.Font.Gotham
Title.Text = "Game Tools"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize button
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -30, 0, 5)
MinimizeButton.Size = UDim2.new(0, 25, 0, 20)
MinimizeButton.Font = Enum.Font.Gotham
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = MinimizeButton

-- Toggle container
ToggleContainer.Name = "ToggleContainer"
ToggleContainer.Parent = MainFrame
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Position = UDim2.new(0, 10, 0, 40)
ToggleContainer.Size = UDim2.new(1, -20, 0, 100)

-- Function to create clean toggle buttons
local function createToggleButton(name, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = ToggleContainer
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(1, 0, 0, 40) -- Taller buttons for better touch
    button.Font = Enum.Font.Gotham
    button.Text = name .. ": OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    return button
end

-- Create toggle buttons
HighJump = createToggleButton("High Jump", UDim2.new(0, 0, 0, 0))
ESP = createToggleButton("ESP", UDim2.new(0, 0, 0, 50))

-- Toggle functionality
local function toggleButton(button)
    if button.Text:find("OFF") then
        button.Text = button.Text:gsub("OFF", "ON")
        button.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
    else
        button.Text = button.Text:gsub("ON", "OFF")
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end

-- Minimize functionality
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 200, 0, 30)
        ToggleContainer.Visible = false
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 200, 0, 150)
        ToggleContainer.Visible = true
        MinimizeButton.Text = "-"
    end
end)

-- High Jump functionality
HighJump.MouseButton1Click:Connect(function()
    toggleButton(HighJump)
    local Player = game.Players.LocalPlayer
    if HighJump.Text:find("ON") then
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 120
            humanoid.UseJumpPower = true
        end
    else
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
    end
end)

-- ESP functionality
ESP.MouseButton1Click:Connect(function()
    toggleButton(ESP)
    local Player = game.Players.LocalPlayer
    
    if ESP.Text:find("ON") then
        -- Create ESP for existing players
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= Player and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "EnhancedESP"
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.FillTransparency = 0.4
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = player.Character
            end
        end

        -- ESP for new players
        local playerAdded
        playerAdded = game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                if ESP.Text:find("ON") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "EnhancedESP"
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0
                    highlight.FillTransparency = 0.4
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = char
                end
            end)
        end)

        -- Cleanup when toggled off
        coroutine.wrap(function()
            repeat task.wait() until ESP.Text:find("OFF")
            playerAdded:Disconnect()
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local esp = player.Character:FindFirstChild("EnhancedESP")
                    if esp then esp:Destroy() end
                end
            end
        end)()
    else
        -- Turn off ESP immediately
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= Player and player.Character then
                local esp = player.Character:FindFirstChild("EnhancedESP")
                if esp then esp:Destroy() end
            end
        end
    end
end)

-- Cleanup on character respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if HighJump.Text:find("ON") then
        local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
        humanoid.JumpPower = 120
        humanoid.UseJumpPower = true
    end
end)
