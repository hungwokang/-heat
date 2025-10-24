-- Full fixed LocalScript: Small Black/Red GUI + Full Knife spawn/equip logic
-- Put this in a LocalScript (StarterPlayerScripts or a LocalScript that runs on client)

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
if not player then
    -- Not running in a client context (LocalPlayer nil) — stop to avoid errors
    return
end

-- GUI creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerGui_UI"
local playerGui = player:WaitForChild("PlayerGui")
ScreenGui.Parent = playerGui -- safe: put GUI in PlayerGui

local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleText = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local ButtonFrame = Instance.new("Frame")

-- Buttons A-F
local buttons = {}
local labels = {"A","B","C","D","E","F"}

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

-- =========================================
-- KNIFE MODE: full knife spawn/equip logic
-- =========================================

-- State
local KnifeTool = nil
local knifeEquipped = false

-- Utility: ensure Backpack exists
local backpack = player:WaitForChild("Backpack")

-- Clean up function
local function destroyKnife()
    if KnifeTool and KnifeTool.Parent then
        KnifeTool:Destroy()
    end
    KnifeTool = nil
    knifeEquipped = false
end

-- Create & equip the Knife tool (spawn parts + basic behavior)
local function createAndEquipKnife()
    -- destroy existing
    destroyKnife()

    -- Build tool
    local tool = Instance.new("Tool")
    tool.Name = "Knife"
    tool.RequiresHandle = true
    tool.CanBeDropped = true
    tool.Parent = backpack

    -- Create handle (actual visible piece)
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.23, 1.19, 0.1)
    handle.BrickColor = BrickColor.new("Dark stone grey")
    handle.Material = Enum.Material.Metal
    handle.CanCollide = false
    handle.Parent = tool

    -- A thin blade mesh (if you prefer no mesh, comment out)
    -- Using a simple wedge construction would be more similar to original; here we add a simple mesh.
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Brick
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = handle

    -- Example: add a thin "blade" part welded to handle for nicer visuals (optional)
    local blade = Instance.new("Part")
    blade.Name = "BladePart"
    blade.Size = Vector3.new(0.23, 1.19, 0.05)
    blade.BrickColor = BrickColor.new("Institutional white")
    blade.Material = Enum.Material.Metal
    blade.CanCollide = false
    blade.Parent = tool

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = blade
    weld.Parent = handle
    blade.CFrame = handle.CFrame * CFrame.new(0.5, 0, 0)

    -- Equip state
    KnifeTool = tool
    knifeEquipped = true

    -- Connect attack (Activated) - replicate the original handling in simplified form
    tool.Activated:Connect(function()
        -- brief visual flash
        if handle and handle.Parent then
            handle.BrickColor = BrickColor.new("Bright red")
            Debris:AddItem(handle, 0.2) -- optional short-lived visual change (keeps code simple)
            -- recreate handle after debris removal if you'd rather not destroy it:
            -- we are just changing the color then letting Debris remove the original handle;
            -- in production you might tween color instead of Debris:AddItem.
            wait(0.18)
            if tool and tool.Parent then
                -- restore a handle if it was removed; but here we simply re-create minimal handle if missing:
                if not tool:FindFirstChild("Handle") then
                    local h2 = Instance.new("Part")
                    h2.Name = "Handle"
                    h2.Size = Vector3.new(0.23, 1.19, 0.1)
                    h2.BrickColor = BrickColor.new("Dark stone grey")
                    h2.Material = Enum.Material.Metal
                    h2.CanCollide = false
                    h2.Parent = tool
                end
            end
        end
    end)
end

-- Toggle knife: spawn/equip/unequip
local function toggleKnife()
    if knifeEquipped then
        destroyKnife()
    else
        createAndEquipKnife()
    end
end

-- Ensure we cleanup & rebind on respawn
local function onCharacterAdded(char)
    -- nothing special needed here for current simple tool, but we ensure state resets
    destroyKnife()
end

-- Listen for respawn
player.CharacterAdded:Connect(function(char)
    onCharacterAdded(char)
end)

-- Button binding: A toggles knife
if buttons["A"] then
    buttons["A"].MouseButton1Click:Connect(function()
        toggleKnife()
    end)
else
    warn("Button A missing")
end

-- Optional: cleanup when player leaves / GUI removed
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        destroyKnife()
    end
end)

-- End of LocalScript
