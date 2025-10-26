game.StarterGui:SetCore("SendNotification", {
    Title = "FE Invisible Fling";
    Text = "hehe boi get load'd";
    Duration = 3;
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
    
    -- Destroy unnecessary parts for true invisibility and to reduce physics interactions
    for _, v in pairs(player.Character:GetChildren()) do
        if v:IsA("BasePart") and v ~= root then
            v:Destroy()
        elseif v:IsA("Decal") and v.Name == "face" then
            v:Destroy()
        elseif v:IsA("Accessory") then
            v:Destroy()
        end
    end
    
    -- Set root properties
    root.Transparency = 100
    root.CanCollide = true  -- Enable collision for flinging
    root.CustomPhysicalProperties = PhysicalProperties.new(1000, 0, 0, 0, 0)  -- High density for high mass, low friction/elasticity to prevent backlash
    
    workspace.CurrentCamera.CameraSubject = root
    
    local se = Instance.new("SelectionBox", root)
    se.Adornee = root
    
    power = 999999 -- change this to make it more or less powerful
    
    -- Replace BodyThrust with BodyAngularVelocity for spinning fling
    local bav = Instance.new("BodyAngularVelocity")
    bav.Parent = root
    bav.MaxTorque = Vector3.new(0, math.huge, 0)
    bav.AngularVelocity = Vector3.new(0, power, 0)
    
    local torso = root
    local flying = true
    local ctrl = {f = 0, b = 0, l = 0, r = 0}
    local lastctrl = {f = 0, b = 0, l = 0, r = 0}
    local maxspeed = 50
    local speed = 50
    
    local function Fly()
        hum.PlatformStand = true  -- Set to platform stand to prevent walking and potential damage
        local bg = Instance.new("BodyGyro", torso)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = torso.CFrame
        local bv = Instance.new("BodyVelocity", torso)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        repeat wait()
            bg.CFrame = workspace.CurrentCamera.CFrame
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = speed + 0
                if speed > maxspeed then
                    speed = maxspeed
                end
            elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                speed = speed - 50
                if speed < 0 then
                    speed = 0
                end
            end
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                bv.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * speed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0)
            end
            -- Robust velocity clamping to prevent unexpected flings
            torso.AssemblyLinearVelocity = bv.Velocity
        until not flying
        ctrl = {f = 0, b = 0, l = 0, r = 0}
        lastctrl = {f = 0, b = 0, l = 0, r = 0}
        speed = 0
        hum.PlatformStand = false
        bg:Destroy()
        bv:Destroy()
    end
    
    mouse.KeyDown:Connect(function(key)
        if key:lower() == "e" then
            if flying then flying = false
            else
                flying = true
                Fly()
            end
        elseif key:lower() == "w" then
            ctrl.f = 1
        elseif key:lower() == "s" then
            ctrl.b = -1
        elseif key:lower() == "a" then
            ctrl.l = -1
        elseif key:lower() == "d" then
            ctrl.r = 1
        end
    end)
    
    mouse.KeyUp:Connect(function(key)
        if key:lower() == "w" then
            ctrl.f = 0
        elseif key:lower() == "s" then
            ctrl.b = 0
        elseif key:lower() == "a" then
            ctrl.l = 0
        elseif key:lower() == "d" then
            ctrl.r = 0
        end
    end)
    
    Fly()  -- Start flying automatically
end

-- Connect buttons
enableButton.MouseButton1Click:Connect(enableFling)
respawnButton.MouseButton1Click:Connect(respawn)
