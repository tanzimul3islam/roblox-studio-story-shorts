-- Studio_Story_01 "Pet Cloud": the whole take runs here on the client, timed to
-- shorts/Studio_Story_01/audio/narration.wav (t = 0 is the start of that file).
-- Screen is black until the take is triggered (workspace attribute "Go" set on
-- the client) and again after it ends, so the take is easy to cut out.
--
-- SLOW-MOTION CAPTURE: Studio under Wine renders only ~12 fps while OBS records, which
-- looked laggy. The whole take therefore plays SLOW times slower (motion, animation
-- tracks, rain, camera: everything reads story time t below), and render.sh speeds the
-- recording back up by SLOW. 12 fps x 5 = ~60 rendered frames per story second.
local SLOW = 5
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local cam = workspace.CurrentCamera

pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
local black = Instance.new("Frame")
black.Size = UDim2.fromScale(1, 1)
black.BackgroundColor3 = Color3.new(0, 0, 0)
black.BorderSizePixel = 0
black.Parent = gui
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local A = {}
for _, n in ipairs({ "Narrator", "Maya", "Leo", "Patel", "Kid1", "Kid2" }) do A[n] = workspace:WaitForChild(n) end
local set = workspace:WaitForChild("Set")
local grass = set:WaitForChild("Grass")
local garden = set:WaitForChild("Garden")
task.wait(1)

------------------------------------------------------------------ animations
local ANIM = {
	idle = 507766666, walk = 507777826, wave = 507770239, jump = 507765000,
	laugh = 507770818, cheer = 507770677, point = 507770453,
	dance = 507771019, dance2 = 507776043, dance3 = 507777268,
}
local TR = {}
for n, m in pairs(A) do
	local hum = m:WaitForChild("Humanoid")
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
	TR[n] = {}
	for k, id in pairs(ANIM) do
		local a = Instance.new("Animation")
		a.AnimationId = "rbxassetid://" .. id
		local tr = animator:LoadAnimation(a)
		tr.Looped = true
		TR[n][k] = tr
	end
end
local current = {}
local function anim(n, k)
	if current[n] == k then return end
	-- fade times are real seconds and playback speed is real-time, so scale both by SLOW
	for _, tr in pairs(TR[n]) do tr:Stop(0.15 * SLOW) end
	TR[n][k]:Play(0.15 * SLOW, 1, 1 / SLOW)
	current[n] = k
end

local function rootY(m)
	local hum = m:FindFirstChildOfClass("Humanoid")
	return hum.HipHeight + m.HumanoidRootPart.Size.Y / 2
end
local function put(n, x, z, lookX, lookZ)
	local m = A[n]
	local p = Vector3.new(x, rootY(m), z)
	local l = Vector3.new(lookX or x, p.Y, lookZ or (z + 10))
	m:PivotTo(CFrame.lookAt(p, l))
end
local function hide(n) A[n]:PivotTo(CFrame.new(0, -200, 0)) end
local function headTop(n)
	local h = A[n]:FindFirstChild("Head")
	return h.Position + Vector3.new(0, h.Size.Y / 2, 0)
end

------------------------------------------------------------------ clouds + rain
local fx = Instance.new("Folder")
fx.Name = "FX"
fx.Parent = workspace
local PUFFS = { { 0, 0, 0, 4 }, { 2, 0.3, 0, 3.2 }, { -2, 0.2, 0, 3.4 }, { 1, 1.3, 0.2, 3 }, { -0.9, 1.1, 0.4, 2.8 }, { 0.2, 0.4, -0.9, 3 } }
local clouds = {}
local function newCloud(name, color)
	local c = { parts = {}, scale = 0, color = color, owner = nil, pos = Vector3.zero, mode = nil, drops = {} }
	for _, p in ipairs(PUFFS) do
		local b = Instance.new("Part")
		b.Shape = Enum.PartType.Ball
		b.Anchored, b.CanCollide, b.CastShadow = true, false, true
		b.Material = Enum.Material.SmoothPlastic
		b.Color = color
		b.Parent = fx
		table.insert(c.parts, b)
	end
	clouds[name] = c
	return c
end
local function dropPool(c, n, snow)
	for _, d in ipairs(c.drops) do d:Destroy() end
	c.drops = {}
	for k = 1, n do
		local d = Instance.new("Part")
		d.Anchored, d.CanCollide, d.CastShadow = true, false, false
		if snow then
			d.Shape = Enum.PartType.Ball
			d.Size = Vector3.new(0.35, 0.35, 0.35)
			d.Color = Color3.new(1, 1, 1)
			d.Material = Enum.Material.SmoothPlastic
		else
			d.Size = Vector3.new(0.12, 1.1, 0.12)
			d.Color = Color3.fromRGB(150, 200, 255)
			d.Material = Enum.Material.Neon
			d.Transparency = 0.25
		end
		d.Parent = fx
		c.drops[k] = { part = d, rx = math.random(), rz = math.random(), ph = math.random() }
	end
	c.snow = snow
end

local CL = {
	Maya = newCloud("Maya", Color3.fromRGB(250, 250, 255)),
	Leo = newCloud("Leo", Color3.fromRGB(225, 245, 255)),
	Patel = newCloud("Patel", Color3.fromRGB(120, 125, 135)),
	Narrator = newCloud("Narrator", Color3.fromRGB(150, 150, 155)),
}
dropPool(CL.Maya, 30, false)
dropPool(CL.Leo, 40, true)
dropPool(CL.Patel, 30, false)
dropPool(CL.Narrator, 160, false)

local function updateCloud(c, t)
	local center = c.owner and (headTop(c.owner) + Vector3.new(0, 2.6 + c.scale * 0.8, 0)) or c.pos
	for k, p in ipairs(PUFFS) do
		local b = c.parts[k]
		local s = c.scale
		if s < 0.02 then
			b.Transparency = 1
		else
			b.Transparency = 0
			b.Size = Vector3.one * p[4] * s
			b.Color = c.color
			b.CFrame = CFrame.new(center + Vector3.new(p[1], p[2], p[3]) * s
				+ Vector3.new(0, math.sin(t * 1.7 + k) * 0.08 * s, 0))
		end
	end
	local on = c.mode and c.scale > 0.05
	local w = c.rainW or (3.2 * c.scale)
	local dz = c.rainD or (1.6 * c.scale)
	local top = center.Y - 0.6 * c.scale
	local h = math.max(1, top - 0.1)
	local speed = c.snow and 4 or 26
	for _, d in ipairs(c.drops) do
		if on then
			local y = top - ((t * speed / h + d.ph) % 1) * h
			local cx = c.rainCenter and c.rainCenter.X or center.X
			local cz = c.rainCenter and c.rainCenter.Z or center.Z
			local drift = c.snow and math.sin(t * 2 + d.ph * 6) * 0.3 or 0
			d.part.CFrame = CFrame.new(cx + (d.rx - 0.5) * w + drift, y, cz + (d.rz - 0.5) * dz)
			d.part.Transparency = c.snow and 0 or 0.25
		else
			d.part.Transparency = 1
		end
	end
end

------------------------------------------------------------------ lighting looks
local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
local GRASS = grass.Color
local function look(kind)
	if kind == "normal" then
		cc.TintColor, cc.Brightness, cc.Saturation = Color3.new(1, 1, 1), 0, 0.2
		grass.Color = GRASS
		Lighting.ClockTime = 13.5
	elseif kind == "drought" then
		cc.TintColor, cc.Brightness, cc.Saturation = Color3.fromRGB(255, 225, 175), 0.08, 0.05
		grass.Color = Color3.fromRGB(190, 170, 90)
		Lighting.ClockTime = 12.5
	elseif kind == "storm" then
		cc.TintColor, cc.Brightness, cc.Saturation = Color3.fromRGB(200, 210, 235), -0.08, 0.1
		grass.Color = GRASS
	elseif kind == "rain" then
		cc.TintColor, cc.Brightness, cc.Saturation = Color3.fromRGB(225, 235, 255), -0.02, 0.25
		grass.Color = Color3.fromRGB(90, 175, 80)
	end
end
local function tomatoes(wilted)
	for _, p in ipairs(garden:GetChildren()) do
		if p.Name == "Tomato" then
			p.Color = wilted and Color3.fromRGB(120, 70, 50) or Color3.fromRGB(230, 40, 40)
			p.Size = Vector3.one * (wilted and 0.4 or 0.6)
		elseif p.Name == "Bush" then
			p.Color = wilted and Color3.fromRGB(140, 120, 60) or Color3.fromRGB(60, 150, 60)
			p.Size = wilted and Vector3.new(1.4, 1.1, 1.4) or Vector3.new(1.4, 1.8, 1.4)
		end
	end
end
local PATEL_SKIN = A.Patel.Head.Color
local function sunburn(on)
	A.Patel.Head.Color = on and Color3.fromRGB(230, 80, 70) or PATEL_SKIN
end

------------------------------------------------------------------ shots
local function ease(a) return a * a * (3 - 2 * a) end
-- camera that moves from (eye0, look0) to (eye1, look1) over the shot
local function move(e0, e1, l0, l1, fov)
	return function(a) return e0:Lerp(e1, a), l0:Lerp(l1 or l0, a), fov end
end
local V = Vector3.new
local function reset()
	for n in pairs(A) do hide(n) end
	for _, c in pairs(CL) do c.owner, c.mode, c.rainW, c.rainD, c.rainCenter, c.scale = nil, nil, nil, nil, nil, 0 end
	sunburn(false)
end
local function own(n, scale, mode)
	CL[n].owner, CL[n].scale, CL[n].mode = n, scale, mode
end

local SHOTS = {
	-- 0: premise -- birthday, tiny cloud pops in above the narrator
	{ 0.0, function()
		reset(); look("normal"); tomatoes(false)
		CL.Narrator.color = Color3.fromRGB(150, 150, 155)
		put("Narrator", 0, -5); anim("Narrator", "idle")
		own("Narrator", 0, nil)
	end, move(V(0, 6, 11), V(0, 6.5, 8), V(0, 5.5, -5), nil, 50),
	function(t, a) CL.Narrator.scale = 0.5 * math.clamp((t - 1.2) / 0.35, 0, 1) end },
	-- 1: every cloud is different -- line-up
	{ 2.86, function()
		reset()
		put("Maya", -6, -3); put("Leo", -2, -3); put("Narrator", 2, -3); put("Patel", 6.5, -3)
		for _, n in ipairs({ "Maya", "Leo", "Narrator", "Patel" }) do anim(n, "idle") end
		own("Maya", 1, nil); own("Leo", 1, nil); own("Patel", 1.1, nil); own("Narrator", 0.5, nil)
		anim("Maya", "wave")
	end, move(V(0, 9, 30), V(0, 9, 27), V(0, 7.5, -3), nil, 50) },
	-- 2: Maya's cloud waters her tomatoes
	{ 4.03, function()
		reset()
		put("Maya", -31.5, -5, -27, -2); anim("Maya", "cheer")
		CL.Maya.scale, CL.Maya.pos, CL.Maya.mode = 1, V(-27, 8.5, -6.5), "rain"
	end, move(V(-29, 6, 11), V(-29, 5.5, 7.5), V(-28.5, 4.5, -6), nil, 50) },
	-- 3: Leo's cloud snows on him in July
	{ 6.29, function()
		reset()
		put("Leo", 30, -5); anim("Leo", "idle")
		own("Leo", 1.1, "snow")
	end, move(V(30, 7, 13), V(30, 6.5, 10), V(30, 6, -5), nil, 50) },
	-- 4: ...coolest kid in school (close-up)
	{ 7.85, function()
		put("Leo", 30, -5); anim("Leo", "cheer")
		own("Leo", 1.1, "snow")
	end, move(V(30, 5.4, 2.5), V(30, 5.6, 1.5), V(30, 5.2, -5), nil, 42) },
	-- 5: Mr Patel's cloud rains on his bald head
	{ 9.42, function()
		reset()
		anim("Patel", "walk")
		own("Patel", 1.2, "rain")
	end, function(a)
		local x = 52 + a * 7
		local p = V(x, 0, -4)
		return p + V(-4, 9, 13), p + V(0, 5.5, 0), 48
	end,
	function(t, a) put("Patel", 52 + a * 7, -4, 70, -4) end },
	-- 6: "But my cloud?" -- narrator looks up
	{ 12.33, function()
		reset()
		put("Narrator", 0, -5); anim("Narrator", "idle")
		own("Narrator", 0.5, nil)
	end, move(V(0, 4.6, 0.5), V(0, 4.7, 0), V(0, 4.9, -5), nil, 42) },
	-- 7: tiny. grey. never rained. (close on the cloud)
	{ 12.99, function() end, move(V(0, 8.6, 1.6), V(0, 8.7, 0.6), V(0, 8.6, -5), nil, 40) },
	-- 8: not even once (wide, nothing happens)
	{ 15.4, function() anim("Narrator", "idle") end, move(V(0, 6.5, 13), V(0, 6.5, 11), V(0, 6, -5), nil, 48) },
	-- 9: the kids called it the broken cloud
	{ 18.0, function()
		reset()
		put("Narrator", 0, -6); own("Narrator", 0.5, nil); anim("Narrator", "idle")
		put("Kid1", -3.5, -2, 0, -6); put("Kid2", 3.5, -2, 0, -6)
		anim("Kid1", "laugh"); anim("Kid2", "point")
	end, move(V(0, 7, 13), V(0, 6.5, 11), V(0, 5, -4), nil, 48) },
	-- 10: the summer it stopped raining
	{ 19.48, function()
		reset(); look("drought")
	end, move(V(0, 8, 30), V(0, 9, 26), V(0, 30, -60), V(0, 26, -60), 62) },
	-- 11: every cloud dried up and disappeared
	{ 20.75, function()
		reset()
		put("Maya", -5, -3); put("Leo", 0, -3); put("Patel", 5, -3)
		for _, n in ipairs({ "Maya", "Leo", "Patel" }) do anim(n, "idle"); own(n, 1, nil) end
	end, move(V(0, 9, 24), V(0, 9.5, 22), V(0, 8, -3), nil, 50),
	function(t, a)
		local s = 1 - math.clamp((t - 21.3) / 2.3, 0, 1)
		CL.Maya.scale, CL.Leo.scale, CL.Patel.scale = s, s, s * 1.1
	end },
	-- 12: Maya's tomatoes wilted
	{ 24.04, function()
		reset(); tomatoes(true)
		put("Maya", -31.5, -5, -27, -6); anim("Maya", "idle")
	end, move(V(-27, 3.4, 2), V(-27, 3.2, 0.5), V(-27.5, 1.6, -6.5), nil, 45) },
	-- 13: Leo's snow stopped
	{ 25.64, function()
		reset()
		put("Leo", 30, -5); anim("Leo", "idle")
	end, move(V(30, 5.4, 1.5), V(30, 5.4, 1), V(30, 5.1, -5), nil, 42) },
	-- 14: Mr Patel's head got sunburned
	{ 27.1, function()
		reset(); sunburn(true)
		put("Patel", 60, -4); anim("Patel", "idle")
	end, move(V(60, 10.5, 1.5), V(60, 10, 0.5), V(60, 6.6, -4), nil, 40) },
	-- 15: that's when my tiny cloud started to grow
	{ 28.99, function()
		reset(); sunburn(false)
		put("Narrator", 0, -5); anim("Narrator", "idle")
		own("Narrator", 0.5, nil)
	end, move(V(0, 7, 12), V(0, 7.5, 13), V(0, 7, -5), nil, 48),
	function(t, a) CL.Narrator.scale = 0.5 + ease(a) * 1.5 end },
	-- 16: and grow, and grow, until it covered the whole town
	{ 30.64, function()
		look("storm")
		put("Narrator", 0, -5); anim("Narrator", "idle")
		CL.Narrator.owner = nil
	end, move(V(0, 3.5, 22), V(0, 4, 34), V(0, 12, -5), V(0, 22, -8), 66),
	function(t, a)
		local e = ease(a)
		CL.Narrator.scale = 2 + e * 8
		CL.Narrator.pos = V(0, 11 + e * 19, -5 - e * 7)
		local g = 150 - e * 50
		CL.Narrator.color = Color3.fromRGB(g, g, g + 8)
	end },
	-- 17: it was never broken -- saving every drop (aerial over town)
	{ 34.12, function()
		reset(); look("storm")
		CL.Narrator.scale, CL.Narrator.pos = 10, V(0, 30, -12)
	end, move(V(-45, 14, 70), V(-30, 16, 62), V(5, 26, -10), nil, 60) },
	-- 18: when it finally rained, the whole town danced
	{ 37.67, function()
		reset(); look("rain")
		local who = { { "Kid1", -9 }, { "Maya", -5.5 }, { "Narrator", -1.5 }, { "Leo", 2.5 }, { "Patel", 6.5 }, { "Kid2", 10 } }
		local moves = { "dance", "dance2", "cheer", "dance3", "dance", "dance2" }
		for k, w in ipairs(who) do put(w[1], w[2], 1.5 - (k % 2) * 2); anim(w[1], moves[k]) end
		local c = CL.Narrator
		c.scale, c.pos, c.mode = 10, V(0, 30, -12), "rain"
		c.rainW, c.rainD, c.rainCenter = 40, 26, V(0, 0, 4)
	end, move(V(0, 7, 18), V(0, 6.5, 15), V(0, 4.5, 0), nil, 50) },
	-- 19: everyone gets a cloud on their birthday
	{ 39.88, function()
		put("Maya", -4, -3); put("Leo", 0, -3); put("Patel", 4.5, -3)
		for _, n in ipairs({ "Maya", "Leo", "Patel" }) do anim(n, "cheer") end
		hide("Kid1"); hide("Kid2"); hide("Narrator")
		own("Maya", 0.9, nil); own("Leo", 0.9, nil); own("Patel", 1, nil)
	end, move(V(0, 8.5, 18), V(0, 8.5, 16), V(0, 7.5, -3), nil, 48) },
	-- 20: but the whole town got mine
	{ 41.21, function()
		hide("Maya"); hide("Leo"); hide("Patel")
		CL.Maya.owner, CL.Leo.owner, CL.Patel.owner = nil, nil, nil
		CL.Maya.scale, CL.Leo.scale, CL.Patel.scale = 0, 0, 0
		put("Narrator", 0, 1); anim("Narrator", "wave")
	end, move(V(0, 4.2, 9), V(0, 9, 17), V(0, 6, 1), V(0, 12, -6), 55) },
}
local LENGTH = 43.3

------------------------------------------------------------------ run
local T0, live, shotIdx = nil, false, 0
cam.CameraType = Enum.CameraType.Scriptable
RunService:BindToRenderStep("StoryCamera", Enum.RenderPriority.Camera.Value + 1, function()
	cam.CameraType = Enum.CameraType.Scriptable
	black.Visible = not live
	if not live then return end
	local t = (os.clock() - T0) / SLOW -- story time in seconds of narration.wav
	if t >= LENGTH then live = false; return end
	local i = 1
	for k, s in ipairs(SHOTS) do if t >= s[1] then i = k end end
	local s = SHOTS[i]
	if i ~= shotIdx then
		shotIdx = i
		s[2]()
	end
	local stop = SHOTS[i + 1] and SHOTS[i + 1][1] or LENGTH
	local a = math.clamp((t - s[1]) / (stop - s[1]), 0, 1)
	if s[4] then s[4](t, a) end
	for _, c in pairs(CL) do updateCloud(c, t) end
	local eye, target, fov = s[3](ease(a))
	cam.FieldOfView = fov
	cam.CFrame = CFrame.lookAt(eye, target)
end)

-- Start a take: set workspace attribute "Go" (any new value) on the client.
-- The take begins DELAY real seconds later, after black, so recording can spin up.
-- In the recording the take lasts LENGTH * SLOW real seconds.
local DELAY = 6
workspace:GetAttributeChangedSignal("Go"):Connect(function()
	task.wait(DELAY)
	shotIdx = 0
	T0 = os.clock()
	live = true
end)
