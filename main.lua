-- ¢heat v2 - Premium Menu (Pet Spawner Edition)
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
local PetsTab = CreateTab("Pets")

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

-- ===== PET SPAWNER =====
local petFolder = Instance.new("Folder", workspace)
petFolder.Name = "SpawnedPets"

local petModels = {
    ["Dragon"] = "rbxassetid://YOUR_DRAGON_MODEL_ID",
    ["Dog"] = "rbxassetid://YOUR_DOG_MODEL_ID",
    ["Cat"] = "rbxassetid://YOUR_CAT_MODEL_ID"
}

local currentPet = nil

local function SpawnPet(petName)
    -- Remove existing pet
    if currentPet then
        currentPet:Destroy()
        currentPet = nil
    end

    -- Load and clone pet model
    local model = game:GetService("InsertService"):LoadAsset(petModels[petName]):GetChildren()[1]
    local pet = model:Clone()
    pet.Parent = petFolder
    pet:SetPrimaryPartCFrame(Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3))
    
    -- Make pet follow player
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = Character.HumanoidRootPart
    weld.Part1 = pet.PrimaryPart
    weld.Parent = pet
    
    currentPet = pet
end

-- Create pet buttons
for petName, _ in pairs(petModels) do
    local petButton = CreateButton(PetsTab, "Spawn "..petName, Color3.fromRGB(80, 120, 80))
    petButton.MouseButton1Click:Connect(function()
        SpawnPet(petName)
    end)
end

-- Remove Pet button
local removePetButton = CreateButton(PetsTab, "Remove Pet", Color3.fromRGB(120, 80, 80))
removePetButton.MouseButton1Click:Connect(function()
    if currentPet then
        currentPet:Destroy()
        currentPet = nil
    end
end)

-- ===== CHARACTER HANDLING =====
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    
    if speedEnabled then
        Humanoid.WalkSpeed = 50
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
end)

-- Initialize first tab
PageList:JumpTo(MovementTab)
for _, btn in pairs(TabButtons:GetChildren()) do
    if btn:IsA("TextButton") then
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end
TabButtons:FindFirstChild("MovementTab").TextColor3 = Color3.fromRGB(255, 215, 0)

return "¢heat v2 (Pet Edition) loaded successfully!"
