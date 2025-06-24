-- ¢heat v2 - Premium Menu
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/hungwokang/-heat/main/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- ===== GUI CREATION =====
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TabButtons = Instance.new("Frame")
local TabList = Instance.new("UIListLayout")
local Pages = Instance.new("Frame")
local PageList = Instance.new("UIPageLayout")

ScreenGui.Name = "CheatV2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Window
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

-- Top Bar
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 30)

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "¢heat v2"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 16

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab System
TabButtons.Name = "TabButtons"
TabButtons.Parent = MainFrame
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TabButtons.BorderSizePixel = 0
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.Size = UDim2.new(1, 0, 0, 30)

TabList.Name = "TabList"
TabList.Parent = TabButtons
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.SortOrder = Enum.SortOrder.LayoutOrder

Pages.Name = "Pages"
Pages.Parent = MainFrame
Pages.BackgroundTransparency = 1
Pages.Position = UDim2.new(0, 5, 0, 65)
Pages.Size = UDim2.new(1, -10, 1, -70)

PageList.Name = "PageList"
PageList.Parent = Pages
PageList.Animated = true
PageList.EasingStyle = Enum.EasingStyle.Quint
PageList.ScrollWheelInputEnabled = false

-- ===== TAB CREATION =====
local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name.."Tab"
    TabButton.BackgroundTransparency = 1
    TabButton.Size = UDim2.new(0, 70, 1, 0)
    TabButton.Font = Enum.Font.Gotham
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.TextSize = 14
    TabButton.Parent = TabButtons
    
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name.."Page"
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 3
    Page.Parent = Pages
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Name = "PageLayout"
    PageLayout.Parent = Page
    PageLayout.Padding = UDim.new(0, 5)
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        PageList:JumpTo(Page)
        for _, btn in pairs(TabButtons:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        TabButton.TextColor3 = Color3.fromRGB(255, 215, 0)
    end)
    
    return Page
end

-- ===== UTILITY FUNCTIONS =====
local function CreateButton(parent, text, color)
    local Button = Instance.new("TextButton")
    Button.Name = text.."Button"
    Button.BackgroundColor3 = color or Color3.fromRGB(45, 45, 50)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 30)
    Button.Font = Enum.Font.Gotham
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button
    
    return Button
end

local function CreateToggle(parent, text, default)
    local Toggle = Instance.new("TextButton")
    Toggle.Name = text.."Toggle"
    Toggle.BackgroundColor3 = default and Color3.fromRGB(70, 120, 70) or Color3.fromRGB(60, 60, 65)
    Toggle.BorderSizePixel = 0
    Toggle.Size = UDim2.new(1, 0, 0, 30)
    Toggle.Font = Enum.Font.Gotham
    Toggle.Text = text .. ": " .. (default and "ON" or "OFF")
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextSize = 14
    Toggle.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Toggle
    
    return Toggle
end

-- ===== CREATE TABS =====
local MovementTab = CreateTab("Movement")
local VisualsTab = CreateTab("Visuals")
local AutoFarmTab = CreateTab("AutoFarm")

-- ===== MOVEMENT FEATURES =====
local originalSpeed = Humanoid.WalkSpeed
local originalJump = Humanoid.JumpPower

-- Speed Toggle
local SpeedToggle = CreateToggle(MovementTab, "Speed", false)
local speedEnabled = false

SpeedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        Humanoid.WalkSpeed = 50
        SpeedToggle.Text = "Speed: ON (50)"
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(70, 120, 70)
    else
        Humanoid.WalkSpeed = originalSpeed
        SpeedToggle.Text = "Speed: OFF ("..originalSpeed..")"
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

-- Jump Toggle
local JumpToggle = CreateToggle(MovementTab, "Jump", false)
local jumpEnabled = false

JumpToggle.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        Humanoid.JumpPower = 100
        JumpToggle.Text = "Jump: ON (100)"
        JumpToggle.BackgroundColor3 = Color3.fromRGB(70, 120, 70)
    else
        Humanoid.JumpPower = originalJump
        JumpToggle.Text = "Jump: OFF ("..originalJump..")"
        JumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

-- Noclip Toggle
local NoclipToggle = CreateToggle(MovementTab, "Noclip", false)
local noclipEnabled = false
local noclipConnection

NoclipToggle.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        NoclipToggle.Text = "Noclip: ON"
        NoclipToggle.BackgroundColor3 = Color3.fromRGB(120, 70, 70)
        
        noclipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        NoclipToggle.Text = "Noclip: OFF"
        NoclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

-- Fly Toggle
local FlyToggle = CreateToggle(MovementTab, "Fly", false)
local flyEnabled = false
local flySpeed = 50
local flyConnection

local function Fly()
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    
    local RootPart = Character.HumanoidRootPart
    local Control = {F = 0, B = 0, L = 0, R = 0}
    local LastControl = {F = 0, B = 0, L = 0, R = 0}
    local MaxSpeed = flySpeed
    
    local BV = Instance.new("BodyVelocity")
    BV.Name = "FlyBV"
    BV.Parent = RootPart
    BV.MaxForce = Vector3.new(100000, 100000, 100000)
    BV.Velocity = Vector3.new(0, 0, 0)
    
    local BG = Instance.new("BodyGyro")
    BG.Name = "FlyBG"
    BG.Parent = RootPart
    BG.MaxTorque = Vector3.new(100000, 100000, 100000)
    BG.P = 10000
    BG.D = 500
    BG.CFrame = RootPart.CFrame
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not Character or not RootPart or not flyEnabled then return end
        
        Control.F = 0
        Control.B = 0
        Control.L = 0
        Control.R = 0
        
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
            Control.F = 1
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
            Control.B = -1
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
            Control.L = -1
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
            Control.R = 1
        end
        
        if (Control.L + Control.R) ~= 0 or (Control.F + Control.B) ~= 0 then
            BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (Control.F + Control.B)) + 
                          ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(Control.L + Control.R, (Control.F + Control.B) * 0.2, 0).p) - 
                          workspace.CurrentCamera.CoordinateFrame.p)) * MaxSpeed
            LastControl = {F = Control.F, B = Control.B, L = Control.L, R = Control.R}
        else
            BV.Velocity = Vector3.new(0, 0, 0)
        end
        
        BG.CFrame = workspace.CurrentCamera.CoordinateFrame
    end)
end

FlyToggle.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        FlyToggle.Text = "Fly: ON (WASD)"
        FlyToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
        Fly()
    else
        FlyToggle.Text = "Fly: OFF"
        FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = Character.HumanoidRootPart
            if RootPart:FindFirstChild("FlyBV") then RootPart.FlyBV:Destroy() end
            if RootPart:FindFirstChild("FlyBG") then RootPart.FlyBG:Destroy() end
        end
        
        if flyConnection then
            flyConnection:Disconnect()
        end
    end
end)

-- Speed Slider
local SpeedSlider = Instance.new("TextLabel")
SpeedSlider.Name = "SpeedSlider"
SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Size = UDim2.new(1, 0, 0, 40)
SpeedSlider.Font = Enum.Font.Gotham
SpeedSlider.Text = "Speed: 50"
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.TextSize = 14
SpeedSlider.Parent = MovementTab

local SpeedValue = Instance.new("TextButton")
SpeedValue.Name = "SpeedValue"
SpeedValue.BackgroundTransparency = 1
SpeedValue.Size = UDim2.new(0, 40, 0, 40)
SpeedValue.Position = UDim2.new(1, -40, 0, 0)
SpeedValue.Font = Enum.Font.GothamBold
SpeedValue.Text = "50"
SpeedValue.TextColor3 = Color3.fromRGB(255, 215, 0)
SpeedValue.TextSize = 14
SpeedValue.Parent = SpeedSlider

local Slider = Instance.new("Frame")
Slider.Name = "Slider"
Slider.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Slider.BorderSizePixel = 0
Slider.Position = UDim2.new(0, 10, 0, 25)
Slider.Size = UDim2.new(1, -60, 0, 5)
Slider.Parent = SpeedSlider

local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
SliderFill.BorderSizePixel = 0
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.Parent = Slider

local SliderButton = Instance.new("TextButton")
SliderButton.Name = "SliderButton"
SliderButton.BackgroundTransparency = 1
SliderButton.Size = UDim2.new(1, 0, 1, 0)
SliderButton.Text = ""
SliderButton.Parent = Slider

SliderButton.MouseButton1Down:Connect(function()
    local MouseMove, MouseKill
    local XSize = Slider.AbsoluteSize.X
    
    MouseMove = game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local X = math.clamp(input.Position.X - Slider.AbsolutePosition.X, 0, XSize)
            local Ratio = X / XSize
            SliderFill.Size = UDim2.new(Ratio, 0, 1, 0)
            local NewSpeed = math.floor(16 + (Ratio * (100 - 16)))
            SpeedValue.Text = tostring(NewSpeed)
            flySpeed = NewSpeed
            if speedEnabled then
                Humanoid.WalkSpeed = NewSpeed
                SpeedToggle.Text = "Speed: ON ("..NewSpeed..")"
            else
                SpeedToggle.Text = "Speed: OFF ("..originalSpeed..")"
            end
        end
    end)
    
    MouseKill = game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            MouseMove:Disconnect()
            MouseKill:Disconnect()
        end
    end)
end)

-- ===== VISUALS FEATURES =====
-- ESP Toggle
local ESPToggle = CreateToggle(VisualsTab, "Player ESP", false)
local espEnabled = false
local espBoxes = {}

local function CreateESP(player)
    if espBoxes[player] then return end
    
    local Box = Instance.new("BoxHandleAdornment")
    Box.Name = player.Name.."ESP"
    Box.Adornee = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    Box.AlwaysOnTop = true
    Box.ZIndex = 10
    Box.Size = Vector3.new(3, 6, 3)
    Box.Transparency = 0.7
    Box.Color3 = player.TeamColor.Color
    Box.Parent = player.Character and player.Character.HumanoidRootPart
    
    espBoxes[player] = Box
    
    player.CharacterAdded:Connect(function(char)
        if not espEnabled then return end
        task.wait(1)
        if char:FindFirstChild("HumanoidRootPart") then
            Box.Adornee = char.HumanoidRootPart
            Box.Parent = char.HumanoidRootPart
        end
    end)
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.Text = "Player ESP: ON"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(120, 70, 120)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                CreateESP(player)
            end
        end
        
        Players.PlayerAdded:Connect(function(player)
            if espEnabled then
                player.CharacterAdded:Connect(function()
                    CreateESP(player)
                end)
            end
        end)
    else
        ESPToggle.Text = "Player ESP: OFF"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        
        for _, box in pairs(espBoxes) do
            box:Destroy()
        end
        espBoxes = {}
    end
end)

-- Fullbright Toggle
local FullbrightToggle = CreateToggle(VisualsTab, "Fullbright", false)
local fullbrightEnabled = false
local originalLighting = {}

FullbrightToggle.MouseButton1Click:Connect(function()
    fullbrightEnabled = not fullbrightEnabled
    if fullbrightEnabled then
        FullbrightToggle.Text = "Fullbright: ON"
        FullbrightToggle.BackgroundColor3 = Color3.fromRGB(120, 120, 70)
        
        originalLighting.Ambient = game:GetService("Lighting").Ambient
        originalLighting.Brightness = game:GetService("Lighting").Brightness
        originalLighting.GlobalShadows = game:GetService("Lighting").GlobalShadows
        
        game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").GlobalShadows = false
    else
        FullbrightToggle.Text = "Fullbright: OFF"
        FullbrightToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        
        game:GetService("Lighting").Ambient = originalLighting.Ambient or Color3.new(0.5, 0.5, 0.5)
        game:GetService("Lighting").Brightness = originalLighting.Brightness or 1
        game:GetService("Lighting").GlobalShadows = originalLighting.GlobalShadows or true
    end
end)

-- ===== AUTO FARM FEATURES =====
local AutoFarmToggle = CreateToggle(AutoFarmTab, "Auto Farm", false)
local autofarmEnabled = false
local autofarmConnection

-- Example auto-farm function (customize for your game)
local function AutoFarm()
    while autofarmEnabled and Character and Humanoid.Health > 0 do
        -- Find nearest target (customize this for your game)
        local nearest = nil
        local nearestDist = math.huge
        
        for _, npc in pairs(workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local dist = (npc:FindFirstChild("HumanoidRootPart").Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearest = npc
                    nearestDist = dist
                end
            end
        end
        
        if nearest then
            -- Move to target
            Humanoid:MoveTo(nearest.HumanoidRootPart.Position)
            Humanoid.Jump = true
            task.wait(0.5)
            
            -- Attack (customize for your game)
            if nearest:FindFirstChild("Humanoid") then
                nearest.Humanoid:TakeDamage(10)
            end
        end
        
        task.wait(0.1)
    end
end

AutoFarmToggle.MouseButton1Click:Connect(function()
    autofarmEnabled = not autofarmEnabled
    if autofarmEnabled then
        AutoFarmToggle.Text = "Auto Farm: ON"
        AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(70, 120, 120)
        autofarmConnection = task.spawn(AutoFarm)
    else
        AutoFarmToggle.Text = "Auto Farm: OFF"
        AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        if autofarmConnection then
            task.cancel(autofarmConnection)
        end
    end
end)

-- ===== CHARACTER HANDLING =====
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    
    if speedEnabled then
        Humanoid.WalkSpeed = tonumber(SpeedValue.Text) or 50
    else
        Humanoid.WalkSpeed = originalSpeed
    end
    
    if jumpEnabled then
        Humanoid.JumpPower = 100
    else
        Humanoid.JumpPower = originalJump
    end
    
    if flyEnabled then
        Fly()
    end
    
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- Initialize first tab
PageList:JumpTo(MovementTab)
for _, btn in pairs(TabButtons:GetChildren()) do
    if btn:IsA("TextButton") then
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end
TabButtons:FindFirstChild("MovementTab").TextColor3 = Color3.fromRGB(255, 215, 0)

return "¢heat v2 successfully loaded!"
