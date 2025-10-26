game.StarterGui:SetCore("SendNotification", {
    Title = "FE Invisible Fling";
    Text = "hehe boi get load'd";
    Duration = 11;
})

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "FlingGUI"

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.5, -100, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local enableButton = Instance.new("TextButton")
enableButton.Parent = frame
enableButton.Size = UDim2.new(1, 0, 0.5, 0)
enableButton.Position = UDim2.new(0, 0, 0, 0)
enableButton.Text = "Enable Fling"
enableButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
enableButton.TextColor3 = Color3.fromRGB(255, 255, 255)
enableButton.Font = Enum.Font.SourceSansBold
enableButton.TextSize = 18

local respawnButton = Instance.new("TextButton")
respawnButton.Parent = frame
respawnButton.Size = UDim2.new(1, 0, 0.5, 0)
respawnButton.Position = UDim2.new(0, 0, 0.5, 0)
respawnButton.Text = "Respawn"
respawnButton.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
respawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
respawnButton.Font = Enum.Font.SourceSansBold
respawnButton.TextSize = 18

-- Respawn function
local function respawn()
    spawn(function()
        local message = Instance.new("Message", workspace)
        message.Text = "Respawning, don't spam"
        wait(1)
        message:Destroy()
    end)
    
    local saved = player.Character.HumanoidRootPart.Position
    
    local ch = player.Character
    local prt = Instance.new("Model", workspace)
    local z1 = Instance.new("Part", prt)
    z1.Name = "Torso"
    z1.CanCollide = false
    z1.Anchored = true
    local z2 = Instance.new("Part", prt)
    z2.Name = "Head"
    z2.Anchored = true
    z2.CanCollide = false
    local z3 = Instance.new("Humanoid", prt)
    z3.Name = "Humanoid"
    z1.Position = Vector3.new(0, 9999, 0)
    z2.Position = Vector3.new(0, 9991, 0)
    player.Character = prt
    wait(5)
    player.Character = ch
    local poop = nil
    repeat wait() poop = player.Character:FindFirstChild("Head") until poop ~= nil
    wait(1)
    player.Character.HumanoidRootPart.CFrame = CFrame.new(saved)
end

-- Enable function
local function enableFling()
    spawn(function()
        local message = Instance.new("Message", workspace)
        message.Text = "FE Invisible Fling By Diemiers#4209 Loaded (wait 11 seconds to load)"
        wait(3)
        message:Destroy()
    end)
    
    local ch = player.Character
    local prt = Instance.new("Model", workspace)
    local z1 = Instance.new("Part", prt)
    z1.Name = "Torso"
    z1.CanCollide = false
    z1.Anchored = true
    local z2 = Instance.new("Part", prt)
    z2.Name = "Head"
    z2.Anchored = true
    z2.CanCollide = false
    local z3 = Instance.new("Humanoid", prt)
    z3.Name = "Humanoid"
    z1.Position = Vector3.new(0, 9999, 0)
    z2.Position = Vector3.new(0, 9991, 0)
    player.Character = prt
    wait(5)
    player.Character = ch
    wait(6)
    
    local root = player.Character.HumanoidRootPart
    local hum = player.Character.Humanoid
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    
    -- Prevent certain states to avoid damage/death
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    
    local physicsService = game:GetService("PhysicsService")
    
    local selfGroup = "SelfCharacter"
    local flingerGroup = "Flinger"
    
    if not physicsService:CollisionGroupNameToId(selfGroup) then
        physicsService:CreateCollisionGroup(selfGroup)
    end
    if not physicsService:CollisionGroupNameToId(flingerGroup) then
        physicsService:CreateCollisionGroup(flingerGroup)
    end
    
    physicsService:CollisionGroupSetCollidable(selfGroup, flingerGroup, false)
    
    -- Set character parts to self group
    for _, v in pairs(player.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            physicsService:SetPartCollisionGroup(v, selfGroup)
        end
    end
    
    -- Create invisible flinging object in front of the player
    local flinger = Instance.new("Part")
    flinger.Name = "Flinger"
    flinger.Transparency = 1
    flinger.CanCollide = true
    flinger.Size = Vector3.new(2, 2, 2)
    flinger.Anchored = false
    flinger.Position = root.Position + root.CFrame.LookVector * 3
    flinger.CustomPhysicalProperties = PhysicalProperties.new(1000, 0, 0, 0, 0)
    flinger.Parent = workspace
    
    physicsService:SetPartCollisionGroup(flinger, flingerGroup)
    
    local se = Instance.new("SelectionBox", flinger)
    se.Adornee = flinger
    
    power = 999999 -- change this to make it more or less powerful
    
    -- Replace BodyThrust with BodyAngularVelocity for spinning fling
    local bav = Instance.new("BodyAngularVelocity")
    bav.Parent = flinger
    bav.MaxTorque = Vector3.new(0, math.huge, 0)
    bav.AngularVelocity = Vector3.new(0, power, 0)
    
    -- Attachment on character root for front position
    local frontAttach = Instance.new("Attachment")
    frontAttach.Parent = root
    frontAttach.Position = Vector3.new(0, 0, -3) -- Adjust offset as needed
    
    local flingerAttach = Instance.new("Attachment")
    flingerAttach.Parent = flinger
    
    -- AlignPosition to follow
    local alignPos = Instance.new("AlignPosition")
    alignPos.Parent = flinger
    alignPos.Attachment0 = flingerAttach
    alignPos.Attachment1 = frontAttach
    alignPos.MaxForce = math.huge
    alignPos.Responsiveness = 200 -- Fast following
end

-- Connect buttons
enableButton.MouseButton1Click:Connect(enableFling)
respawnButton.MouseButton1Click:Connect(respawn)
