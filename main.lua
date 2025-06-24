-- Fixed Brainrot Auto-Steal Script
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/hungwokang/-heat/main/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Enhanced remote finder with multiple detection methods
local function FindStealRemote()
    -- Method 1: Check ReplicatedStorage
    for _,v in pairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") and (v.Name:lower():find("steal") or v.Name:lower():find("rob")) then
            return v
        end
    end
    
    -- Method 2: Check game GC
    for _,v in pairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "InvokeServer") then
            if tostring(v):find("Steal") or tostring(v):find("Rob") then
                return v
            end
        end
    end
    
    -- Method 3: Check client scripts
    for _,v in pairs(getscripts()) do
        if v.ClassName == "LocalScript" then
            for _,k in pairs(debug.getconstants(v)) do
                if type(k) == "string" and (k:lower():find("steal") or k:lower():find("rob")) then
                    local consts = debug.getconstants(v)
                    for i,c in pairs(consts) do
                        if c == k then
                            local bytecode = debug.getproto(v, 0).bytecode
                            if bytecode:find("RemoteEvent") or bytecode:find("RemoteFunction") then
                                return getupvalue(v, i)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

local StealRemote = FindStealRemote()

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AutoStealBtn = Instance.new("TextButton")
local Status = Instance.new("TextLabel")

ScreenGui.Name = "BrainrotStealV2"
ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.8, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "CASH MULTIS"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 16

AutoStealBtn.Parent = Frame
AutoStealBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AutoStealBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
AutoStealBtn.Size = UDim2.new(0.8, 0, 0, 30)
AutoStealBtn.Font = Enum.Font.Gotham
AutoStealBtn.Text = "AUTO STEAL: OFF"
AutoStealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoStealBtn.TextSize = 14

Status.Parent = Frame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0.1, 0, 0.7, 0)
Status.Size = UDim2.new(0.8, 0, 0, 30)
Status.Font = Enum.Font.Gotham
Status.Text = StealRemote and "READY" or "FALLBACK MODE"
Status.TextColor3 = StealRemote and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 165, 0)
Status.TextSize = 14

-- Enhanced stealing function with fallback
local function Steal(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return false end
    
    -- Method 1: Use found remote
    if StealRemote then
        if StealRemote:IsA("RemoteEvent") then
            StealRemote:FireServer(target)
            return true
        elseif typeof(StealRemote) == "table" then
            StealRemote:InvokeServer(target)
            return true
        end
    end
    
    -- Method 2: Fallback - touch interest
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local originalPos = hrp.CFrame
        hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
        task.wait(0.1)
        for _,v in pairs(target:GetDescendants()) do
            if v:IsA("BasePart") then
                firetouchinterest(hrp, v, 0)
                firetouchinterest(hrp, v, 1)
            end
        end
        hrp.CFrame = originalPos
        return true
    end
    
    return false
end

-- Auto Steal System
local AutoSteal = false
local Connection

AutoStealBtn.MouseButton1Click:Connect(function()
    AutoSteal = not AutoSteal
    AutoStealBtn.Text = "AUTO STEAL: " .. (AutoSteal and "ON" or "OFF")
    AutoStealBtn.BackgroundColor3 = AutoSteal and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 60)
    
    if AutoSteal then
        Connection = RunService.Heartbeat:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local success = Steal(player.Character)
                    if success then
                        Status.Text = "STEALING: " .. player.Name
                        task.wait(0.15) -- Natural delay
                    end
                end
            end
        end)
    elseif Connection then
        Connection:Disconnect()
        Status.Text = StealRemote and "READY" or "FALLBACK MODE"
    end
end)

-- Auto-reconnect if game updates
game:GetService("ScriptContext").Error:Connect(function(message)
    if message:find("Steal") or message:find("Rob") then
        StealRemote = FindStealRemote()
        Status.Text = StealRemote and "RECONNECTED" or "FALLBACK MODE"
        Status.TextColor3 = StealRemote and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 165, 0)
    end
end)

-- Cleanup
LocalPlayer.OnTeleport:Connect(function()
    ScreenGui:Destroy()
end)
