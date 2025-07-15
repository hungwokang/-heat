local a=game:GetService(string.char(80,108,97,121,101,114,115))
local b=game:GetService(string.char(82,117,110,83,101,114,118,105,99,101))
local c=a.LocalPlayer
local d=c:WaitForChild(string.char(80,108,97,121,101,114,71,117,105))

local e={
[string.char(66,117,103,32,69,103,103)]={R=string.char(85,110,99,111,109,109,111,110),C=Color3.fromRGB(255,255,0),P={string.char(68,114,97,103,111,110,102,108,121),string.char(71,105,97,110,116,32,65,110,116),string.char(83,110,97,105,108),string.char(80,114,97,121,105,110,103,32,77,97,110,116,105,115),string.char(76,97,100,121,98,117,103),string.char(66,117,116,116,101,114,102,108,121)}},
[string.char(77,121,116,104,105,99,97,108,32,69,103,103)]={R=string.char(85,110,99,111,109,109,111,110),C=Color3.fromRGB(255,255,255),P={string.char(82,101,100,32,71,105,97,110,116,32,65,110,116),string.char(82,101,100,32,70,111,120),string.char(83,113,117,105,114,114,101,108),string.char(71,114,101,121,32,77,111,117,115,101)}},
[string.char(68,105,110,111,115,97,117,114,32,69,103,103)]={R=string.char(82,97,114,101),C=Color3.fromRGB(0,162,255),P={string.char(84,45,82,101,120),string.char(66,114,111,110,116,111,115,97,117,114,117,115),string.char(82,97,112,116,111,114),string.char(83,116,101,103,111,115,97,117,114,117,115),string.char(84,114,105,99,101,114,97,116,111,112,115),string.char(80,116,101,114,111,100,97,99,116,121,108)}},
[string.char(67,111,109,109,111,110,32,69,103,103)]={R=string.char(67,111,109,109,111,110),C=Color3.fromRGB(255,255,255),P={string.char(68,111,103),string.char(71,111,108,100,101,110,32,76,97,98),string.char(66,117,110,110,121),string.char(83,110,97,105,108)}},
[string.char(82,97,114,101,32,83,117,109,109,101,114,32,69,103,103)]={R=string.char(82,97,114,101),C=Color3.fromRGB(255,150,0),P={string.char(70,108,97,109,105,110,103,111),string.char(84,111,117,99,97,110),string.char(79,114,97,110,103,117,116,97,110),string.char(66,101,101),string.char(83,101,97,108)}},
[string.char(66,101,101,32,69,103,103)]={R=string.char(82,97,114,101),C=Color3.fromRGB(255,220,0),P={string.char(72,111,110,101,121,32,66,101,101),string.char(81,117,101,101,110,32,66,101,101),string.char(66,117,116,116,101,114,102,108,121),string.char(77,111,108,101)}},
[string.char(78,105,103,104,116,32,69,103,103)]={R=string.char(68,105,118,105,110,101),C=Color3.fromRGB(255,0,255),P={string.char(82,97,99,99,111,111,110),string.char(77,111,108,101),string.char(78,105,103,104,116,32,79,119,108),string.char(72,101,100,103,101,104,111,103)}},
[string.char(80,114,105,109,97,108,32,69,103,103)]={R=string.char(76,101,103,101,110,100,97,114,121),C=Color3.fromRGB(255,80,0),P={string.char(80,97,114,97,115,97,117,114,111,108,111,112,104,117,115),string.char(73,103,117,97,110,111,100,111,110),string.char(80,97,99,104,121,99,101,112,104,97,108,111,115,97,117,114,117,115),string.char(68,105,108,111,112,104,111,115,97,117,114,117,115),string.char(65,110,107,121,108,111,115,97,117,114,117,115),string.char(83,112,105,110,111,115,97,117,114,117,115)}}
}

local f=Instance.new(string.char(83,99,114,101,101,110,71,117,105),d)
f.Name=string.char(69,103,103,83,101,116,116,105,110,103,115,71,85,73)
f.ResetOnSpawn=false

local g=Instance.new(string.char(70,114,97,109,101),f)
g.Size=UDim2.new(0,140,0,60)
g.Position=UDim2.new(0.02,0,0.5,-30)
g.BackgroundColor3=Color3.fromRGB(0,0,0)
g.BackgroundTransparency=0.4
g.Active=true
g.Draggable=true

local h=Instance.new(string.char(84,101,120,116,76,97,98,101,108),g)
h.Size=UDim2.new(1,0,0,18)
h.BackgroundColor3=Color3.fromRGB(0,0,0)
h.BackgroundTransparency=0.2
h.Text=string.char(69,71,71,32,83,69,84,84,73,78,71,83)
h.TextColor3=Color3.fromRGB(0,255,100)
h.Font=Enum.Font.FredokaOne
h.TextSize=13

local i=Instance.new(string.char(84,101,120,116,66,117,116,116,111,110),g)
i.Size=UDim2.new(0.9,0,0,20)
i.Position=UDim2.new(0.05,0,0,24)
i.Text=string.char(68,101,116,101,99,116,58,32,79,78)
i.BackgroundColor3=Color3.fromRGB(30,30,30)
i.TextColor3=Color3.new(1,1,1)
i.Font=Enum.Font.FredokaOne
i.TextSize=12

local j=Instance.new(string.char(84,101,120,116,76,97,98,101,108),g)
j.Size=UDim2.new(1,0,0,14)
j.Position=UDim2.new(0,0,1,-14)
j.Text=string.char(77,97,100,101,32,98,121,32,83,101,114,118,101,114)
j.TextColor3=Color3.fromRGB(150,150,150)
j.Font=Enum.Font.FredokaOne
j.TextSize=10
j.BackgroundTransparency=1

local k=true
local function l(m)
	local n=e[m.Name]
	if not n then return end
	if m:FindFirstChild(string.char(69,103,103,76,97,98,101,108)) then m.EggLabel:Destroy() end
	if not k then return end
	local o=m:FindFirstChildWhichIsA(string.char(66,97,115,101,80,97,114,116)) or m
	local p=Instance.new(string.char(66,105,108,108,98,111,97,114,100,71,117,105),m)
	p.Name=string.char(69,103,103,76,97,98,101,108)
	p.Size=UDim2.new(0,160,0,30)
	p.StudsOffset=Vector3.new(0,3,0)
	p.AlwaysOnTop=true
	p.Adornee=o

	local q=Instance.new(string.char(84,101,120,116,76,97,98,101,108),p)
	q.Size=UDim2.new(1,0,1,0)
	q.BackgroundTransparency=1
	q.Font=Enum.Font.FredokaOne
	q.TextSize=12
	q.Text="["..n.P[math.random(1,#n.P)].."]"
	q.TextColor3=Color3.new(1,1,1)
	q.TextStrokeColor3=Color3.new(0,0,0)
	q.TextStrokeTransparency=0
end

local function r()
	for _,s in ipairs(workspace:GetDescendants()) do
		if s:IsA(string.char(77,111,100,101,108)) and e[s.Name] then
			l(s)
		end
	end
end

i.MouseButton1Click:Connect(function()
	k=not k
	i.Text=string.char(68,101,116,101,99,116,58,32)..(k and string.char(79,78) or string.char(79,70,70))
	r()
end)

r()
