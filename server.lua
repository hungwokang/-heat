local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ✅ Real updated egg pet names and rarities (Grow a Garden accurate)
local eggPetNames = {
["Common Egg"] = {
Rarity = "Common", Color = Color3.fromRGB(255, 255, 255),
Pets = {"Dog", "Golden Lab", "Bunny"}
},
["Uncommon Egg"] = {
Rarity = "Uncommon", Color = Color3.fromRGB(180, 255, 180),
Pets = {"Black Bunny", "Chicken", "Cat", "Deer"}
},
["Rare Egg"] = {
Rarity = "Rare", Color = Color3.fromRGB(255, 170, 0),
Pets = {"Orange Tabby", "Spotted Deer", "Pig", "Rooster", "Monkey"}
},
["Legendary Egg"] = {
Rarity = "Legendary", Color = Color3.fromRGB(255, 120, 0),
Pets = {"Cow", "Silver Monkey", "Sea Otter", "Turtle", "Polar Bear"}
},
["Mythical Egg"] = {
Rarity = "Mythical", Color = Color3.fromRGB(200, 200, 255),
Pets = {"Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox"}
},
["Bug Egg"] = {
Rarity = "Rare", Color = Color3.fromRGB(255, 255, 0),
Pets = {"Snail", "Giant Ant", "Caterpillar", "Praying Mantis", "Dragonfly"}
},
["Exotic Bug Egg"] = {
Rarity = "Rare", Color = Color3.fromRGB(255, 215, 0),
Pets = {"Snail", "Giant Ant", "Caterpillar", "Praying Mantis", "Dragonfly"}
},
["Common Summer Egg"] = {
Rarity = "Common", Color = Color3.fromRGB(255, 220, 180),
Pets = {"Starfish", "Seagull", "Crab"}
},
["Rare Summer Egg"] = {
Rarity = "Rare", Color = Color3.fromRGB(255, 150, 0),
Pets = {"Flamingo", "Toucan", "Sea Turtle", "Orangutan", "Seal"}
},
["Paradise Egg"] = {
Rarity = "Legendary", Color = Color3.fromRGB(255, 80, 120),
Pets = {"Ostrich", "Peacock", "Capybara", "Scarlet Macaw", "Mini Octopus"}
},
["Oasis Egg"] = {
Rarity = "Legendary", Color = Color3.fromRGB(210, 180, 140),
Pets = {"Meerkat", "Sand Snake", "Axolotl", "Hyacinth Macaw", "Fennec Fox"}
},
["Bee Egg"] = {
Rarity = "Rare", Color = Color3.fromRGB(255, 220, 0),
Pets = {"Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"}
},
["Anti Bee Egg"] = {
Rarity = "Rare", Color = Color3.fromRGB(255, 120, 120),
Pets = {"Wasp", "Tarantula Hawk", "Moth", "Butterfly", "Disco Bee"}
},
["Night Egg"] = {
Rarity = "Divine", Color = Color3.fromRGB(155, 0, 255),
Pets = {"Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon"}
},
["Premium Night Egg"] = {
Rarity = "Divine", Color = Color3.fromRGB(155, 0, 255),
Pets = {"Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon"}
},
["Dinosaur Egg"] = {
Rarity = "Rare", Color = Color3.fromRGB(0, 162, 255),
Pets = {"Raptor", "Triceratops", "Stegosaurus", "Pterodactyl", "Brontosaurus", "T-Rex"}
},
["Primal Egg"] = {
Rarity = "Legendary", Color = Color3.fromRGB(255, 80, 0),
Pets = {"Parasaurolophus", "Iguanodon", "Pachycephalosaurus", "Dilophosaurus", "Ankylosaurus", "Spinosaurus"}
}
}

-- 🌈 GUI Setup
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "EggSettingsGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 160, 0, 160)
frame.Position = UDim2.new(0.02, 0, 0.5, -72)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

-- 🌈 Rainbow title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 22)
title.BackgroundTransparency = 1
title.Text = "🌈 EGG SETTINGS ✨"
title.Font = Enum.Font.Arcade
title.TextSize = 14
task.spawn(function()
local hue = 0
while true do
hue = (hue + 0.005) % 1
title.TextColor3 = Color3.fromHSV(hue, 1, 1)
RunService.Heartbeat:Wait()
end
end)

-- Info & footer
local infoText = Instance.new("TextLabel", frame)
infoText.Size = UDim2.new(1, -12, 0, 45)
infoText.Position = UDim2.new(0, 6, 0, 25)
infoText.Font = Enum.Font.Arcade
infoText.TextSize = 11
infoText.TextWrapped = true
infoText.TextColor3 = Color3.new(1, 1, 1)
infoText.BackgroundTransparency = 1
infoText.Visible = false
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top

local footer = Instance.new("TextLabel", frame)
footer.Size = UDim2.new(1, 0, 0, 12)
footer.Position = UDim2.new(0, 0, 1, -12)
footer.BackgroundTransparency = 1
footer.Text = "made by server"
footer.Font = Enum.Font.Arcade
footer.TextSize = 10
footer.TextColor3 = Color3.fromRGB(200, 200, 200)
footer.TextTransparency = 0.3
footer.TextXAlignment = Enum.TextXAlignment.Center

-- Variables
local showLabels = true
local buttonHeight, spacing = 18, 2
local buttons = {}

-- Button helper
local function createButton(txt, order, onClick)
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -12, 0, buttonHeight)
btn.Position = UDim2.new(0, 6, 0, 25 + (order - 1) * (buttonHeight + spacing))
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.Arcade
btn.TextSize = 11
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.Text = txt
btn.BorderSizePixel = 0
btn.MouseButton1Click:Connect(function() if onClick then onClick(btn) end end)
buttons[#buttons + 1] = btn
return btn
end

-- Attach label
local function attachLabelToEgg(egg)
local info = eggPetNames[egg.Name]
if not info or not showLabels then return end
if egg:FindFirstChild("EggLabel") then egg.EggLabel:Destroy() end
local adornee = egg:FindFirstChildWhichIsA("BasePart") or egg
local gui2 = Instance.new("BillboardGui", egg)
gui2.Name = "EggLabel"
gui2.Size = UDim2.new(0, 160, 0, 30)
gui2.StudsOffset = Vector3.new(0, 3, 0)
gui2.AlwaysOnTop = true
gui2.Adornee = adornee
local petText = Instance.new("TextLabel", gui2)
petText.Size = UDim2.new(1, 0, 1, 0)
petText.BackgroundTransparency = 1
petText.Font = Enum.Font.FredokaOne
petText.TextSize = 12
petText.Text = info.Pets[math.random(1, #info.Pets)]
petText.TextColor3 = Color3.new(1, 1, 1)
petText.TextStrokeColor3 = Color3.new(0, 0, 0)
petText.TextStrokeTransparency = 0
end

-- Initialize existing eggs
for _, egg in ipairs(Workspace:GetDescendants()) do
if egg:IsA("Model") and eggPetNames[egg.Name] then
attachLabelToEgg(egg)
end
end

-- Detect new eggs
Workspace.DescendantAdded:Connect(function(obj)
if obj:IsA("Model") and showLabels and eggPetNames[obj.Name] then
task.wait(0.1)
attachLabelToEgg(obj)
end
end)

-- GUI Buttons
createButton(" 👁️ Detect: ON", 1, function(btn)
showLabels = not showLabels
btn.Text = " 👁️ Detect: " .. (showLabels and "ON" or "OFF")
for _, egg in ipairs(Workspace:GetDescendants()) do
local lbl = egg:FindFirstChild("EggLabel")
if lbl then lbl.Enabled = showLabels end
end
end)
createButton(" 🌀 Randomize Egg", 2, function(btn)
infoText.Text = "Coming soon: Shuffle pet displays or stats."
infoText.Visible = true
for _, b in ipairs(buttons) do b.Visible = false end
task.wait(2)
infoText.Visible = false
for _, b in ipairs(buttons) do b.Visible = true end
end)
createButton(" 💦 AFK Farm Egg: OFF", 3, function(btn)
infoText.Text = "Coming soon: Automatically buys all eggs in the shop loops."
infoText.Visible = true
for _, b in ipairs(buttons) do b.Visible = false end
task.wait(2)
infoText.Visible = false
for _, b in ipairs(buttons) do b.Visible = true end
end)
createButton(" 🍁 AFK Farm Fruit: OFF", 4, function(btn)
infoText.Text = "Coming soon: Automatically collects fruits the in shop loops. you can choose rarity."
infoText.Visible = true
for _, b in ipairs(buttons) do b.Visible = false end
task.wait(2)
infoText.Visible = false
for _, b in ipairs(buttons) do b.Visible = true end
end)
createButton(" 🐾 All Pet Mid: OFF", 5, function(btn)
infoText.Text = "Coming soon!"
infoText.Visible = true
for _, b in ipairs(buttons) do b.Visible = false end
task.wait(2)
infoText.Visible = false
for _, b in ipairs(buttons) do b.Visible = true end
end)

