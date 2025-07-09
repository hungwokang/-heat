local v1 = game:GetService("Players")
local v2 = game:GetService("RunService")
local v3 = v1.LocalPlayer
local v4 = v3:WaitForChild("PlayerGui")

local function b64decode(s)
	local t = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	s = s:gsub("[^"..t.."=]", "")
	return (s:gsub(".", function(x)
		if x == "=" then return "" end
		local r,f="",(t:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and "1" or "0") end
		return r
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if #x ~= 8 then return "" end
		local c = 0
		for i = 1, 8 do c = c + (x:sub(i,i)=="1" and 2^(8-i) or 0) end
		return string.char(c)
	end))
end

local d = {
	[b64decode("QnVnIEVnZw==")] = {R="U",C=Color3.fromRGB(255,255,0),P={"RHJhZ29uZmx5","R2lhbnQgQW50","U25haWw=","UHJheWluZyBNYW50aXM=","TGFkeWJ1Zw==","QnV0dGVyZmx5"}},
	[b64decode("TXl0aGljYWwgRWdn")] = {R="U",C=Color3.fromRGB(255,255,255),P={"UmVkIEdpYW50IEFudA==","UmVkIEZveA==","U3F1aXJyZWw=","R3JleSBNb3VzZQ=="}},
	[b64decode("RGlub3NhdXIgRWdn")] = {R="R",C=Color3.fromRGB(0,162,255),P={"VC1SZXg=","QnJvbnRvc2F1cnVz","UmFwdG9y","U3RlZ29zYXVydXM=","VHJpY2VyYXRvcHM=","UHRlcm9kYWN0eWw="}},
	[b64decode("Q29tbW9uIEVnZw==")] = {R="C",C=Color3.fromRGB(255,255,255),P={"RG9n","R29sZGVuIExhYg==","QnVubnk=","U25haWw="}},
	[b64decode("UmFyZSBTdW1tZXIgRWdn")] = {R="R",C=Color3.fromRGB(255,150,0),P={"RmxhbWluZ28=","VG91Y2Fu","T3Jhbmd1dGFu","QmVl","U2VhbA=="}},
	[b64decode("QmVlIEVnZw==")] = {R="R",C=Color3.fromRGB(255,220,0),P={"SG9uZXkgQmVl","UXVlZW4gQmVl","QnV0dGVyZmx5","TW9sZQ=="}},
	[b64decode("TmlnaHQgRWdn")] = {R="D",C=Color3.fromRGB(255,0,255),P={"UmFjY29vbg==","TW9sZQ==","TmlnaHQgT3ds","SGVkZ2Vob2c="}}
}

local function decodeList(t)
	local o = {}
	for i,v in ipairs(t) do o[i] = b64decode(v) end
	return o
end

for k,v in pairs(d) do d[k].P = decodeList(v.P) end

local f = Instance.new("ScreenGui",v4)
f.Name = "e"
f.ResetOnSpawn = false

local g = Instance.new("Frame",f)
g.Size = UDim2.new(0,140,0,85)
g.Position = UDim2.new(0.02,0,0.5,-42)
g.BackgroundColor3 = Color3.fromRGB(0,0,0)
g.BackgroundTransparency = 0.4
g.Active = true
g.Draggable = true

local h = Instance.new("TextLabel",g)
h.Size = UDim2.new(1,0,0,18)
h.BackgroundTransparency = 0.2
h.BackgroundColor3 = Color3.new(0,0,0)
h.Text = "EGG SETTINGS"
h.TextColor3 = Color3.fromRGB(0,255,0)
h.Font = Enum.Font.FredokaOne
h.TextSize = 13

local i = Instance.new("TextButton",g)
i.Size = UDim2.new(0.9,0,0,20)
i.Position = UDim2.new(0.05,0,0,22)
i.Text = "Randomize"
i.BackgroundColor3 = Color3.fromRGB(20,20,20)
i.TextColor3 = Color3.new(1,1,1)
i.Font = Enum.Font.FredokaOne
i.TextSize = 12

local j = Instance.new("TextButton",g)
j.Size = UDim2.new(0.9,0,0,20)
j.Position = UDim2.new(0.05,0,0,48)
j.Text = "Detect: ON"
j.BackgroundColor3 = Color3.fromRGB(30,30,30)
j.TextColor3 = Color3.new(1,1,1)
j.Font = Enum.Font.FredokaOne
j.TextSize = 12

local k = Instance.new("TextLabel",g)
k.Size = UDim2.new(1,0,0,14)
k.Position = UDim2.new(0,0,1,-14)
k.Text = "Made by Server"
k.TextColor3 = Color3.fromRGB(150,150,150)
k.Font = Enum.Font.FredokaOne
k.TextSize = 10
k.BackgroundTransparency = 1

local l = true

local function m(n)
	local o = d[n.Name]
	if not o then return end
	if n:FindFirstChild("EggLabel") then n.EggLabel:Destroy() end
	if not l then return end
	local p = n:FindFirstChildWhichIsA("BasePart") or n
	local q = Instance.new("BillboardGui",n)
	q.Name = "EggLabel"
	q.Size = UDim2.new(0,160,0,30)
	q.StudsOffset = Vector3.new(0,3,0)
	q.AlwaysOnTop = true
	q.Adornee = p
	local r = Instance.new("TextLabel",q)
	r.Size = UDim2.new(1,0,1,0)
	r.BackgroundTransparency = 1
	r.Font = Enum.Font.FredokaOne
	r.TextSize = 12
	r.Text = "["..o.P[math.random(1,#o.P)].."]"
	r.TextColor3 = Color3.new(1,1,1)
	r.TextStrokeColor3 = Color3.new(0,0,0)
	r.TextStrokeTransparency = 0
end

local function s()
	for _,t in ipairs(workspace:GetDescendants()) do
		if t:IsA("Model") and d[t.Name] then
			m(t)
		end
	end
end

i.MouseButton1Click:Connect(s)
j.MouseButton1Click:Connect(function()
	l = not l
	j.Text = "Detect: "..(l and "ON" or "OFF")
	s()
end)

s()
