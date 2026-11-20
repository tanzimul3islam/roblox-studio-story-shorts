-- STUDIO_TEST_MOONAURA (Server.luau)
-- Pure R6 dressed UGC avatars (Jason & Maya) with big beat-swapped 2D faces,
-- multi-layer Roblox ParticleEmitter auras (TimeScale = 0.2 for SLOW = 5),
-- warm golden-hour sunset courtyard with soft shadows, fog, bloom, DoF, and color grading.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
Players.CharacterAutoLoads = false

local SLOW = 5
local V, C3, CF = Vector3.new, Color3.fromRGB, CFrame.new
local M = Enum.Material

-- Clear previous Set or actors if re-installed
for _, oldName in ipairs({ "Set", "Jason", "Maya" }) do
	local inst = workspace:FindFirstChild(oldName)
	if inst then inst:Destroy() end
end

local set = Instance.new("Folder")
set.Name = "Set"
set.Parent = workspace
local spots = Instance.new("Folder")
spots.Name = "Spots"
spots.Parent = set

---------------------------------------------------------------- KIT: primitives
local function P(size, cf, color, mat, parent, name, shape)
	local p = Instance.new("Part")
	p.Anchored, p.CanCollide, p.CastShadow = true, false, true
	p.Size, p.CFrame, p.Color = size, cf, color
	p.Material = mat or M.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	if name then p.Name = name end
	p.Parent = parent or set
	return p
end

local function light(part, color, range, brightness)
	local l = Instance.new("PointLight")
	l.Color = color or C3(255, 208, 145)
	l.Range = range or 18
	l.Brightness = brightness or 1.4
	l.Shadows = false
	l.Parent = part
	return l
end

local function spot(name, pos, lookAt)
	local s = P(V(1, 1, 1), CFrame.lookAt(pos, lookAt or (pos + V(0, 0, 10))), C3(255, 0, 0), nil, spots, name)
	s.Transparency = 1
	s.CastShadow = false
	return s
end

---------------------------------------------------------------- HIGH-QUALITY LIGHTING + FOG + BLOOM + COLOR GRADING
local function setupLighting()
	Lighting.ClockTime = 16.75
	Lighting.Brightness = 2.05
	Lighting.ExposureCompensation = -0.32
	Lighting.Ambient = C3(80, 68, 66)
	Lighting.OutdoorAmbient = C3(135, 118, 106)
	Lighting.ColorShift_Top = C3(255, 222, 175)
	Lighting.ColorShift_Bottom = C3(95, 82, 115)
	Lighting.EnvironmentDiffuseScale = 0.55
	Lighting.EnvironmentSpecularScale = 0.45
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.6

	local function fx(className)
		return Lighting:FindFirstChildOfClass(className) or Instance.new(className, Lighting)
	end

	local atmo = fx("Atmosphere")
	atmo.Density = 0.42
	atmo.Offset = 0.15
	atmo.Haze = 2.4
	atmo.Glare = 0.35
	atmo.Color = C3(255, 212, 165)
	atmo.Decay = C3(170, 125, 108)

	local bloom = fx("BloomEffect")
	bloom.Enabled = true
	bloom.Intensity = 0.42
	bloom.Size = 24
	bloom.Threshold = 1.95

	local cc = fx("ColorCorrectionEffect")
	cc.Enabled = true
	cc.TintColor = C3(255, 240, 222)
	cc.Saturation = 0.22
	cc.Contrast = 0.14
	cc.Brightness = -0.04

	local sr = fx("SunRaysEffect")
	sr.Enabled = true
	sr.Intensity = 0.12
	sr.Spread = 0.75

	local dof = fx("DepthOfFieldEffect")
	dof.Enabled = true
	dof.FocusDistance = 5.5
	dof.InFocusRadius = 3.2
	dof.FarIntensity = 0.72
	dof.NearIntensity = 0
end

setupLighting()

---------------------------------------------------------------- SET: Golden-Hour Courtyard (Zero Z-fighting)
local function buildCourtyard()
	-- Distinct elevations so surfaces never coplanar-overlap
	local grass = P(V(260, 1, 240), CF(0, -0.55, -80), C3(95, 148, 76), M.Grass, set, "Grass")
	grass.CastShadow = false

	-- Paved courtyard walkway (top at y = 0)
	local walk = P(V(180, 0.5, 14), CF(0, -0.25, 0), C3(206, 198, 186), M.Cobblestone, set, "Walkway")
	walk.CastShadow = false
	P(V(180, 0.3, 0.7), CF(0, -0.05, -7.2), C3(176, 168, 158), M.Concrete, set, "CurbBack")
	P(V(180, 0.3, 0.7), CF(0, -0.05, 7.2), C3(176, 168, 158), M.Concrete, set, "CurbFront")

	-- Subtle paving stone accents along the path (proud by 0.02 studs, non-overlapping)
	for x = -28, 28, 4 do
		P(V(0.18, 0.04, 13.4), CF(x, 0.01, 0), C3(184, 176, 166), M.Concrete)
	end

	-- Low iron & brick fence at z = -10
	P(V(72, 0.9, 0.7), CF(0, 0.45, -10), C3(165, 148, 132), M.Brick)
	for x = -34, 34, 6 do
		P(V(1.1, 3.2, 1.1), CF(x, 1.6, -10), C3(175, 156, 138), M.Brick)
		P(V(1.3, 0.3, 1.3), CF(x, 3.3, -10), C3(215, 206, 194), M.Concrete)
	end
	for x = -33, 33, 1.5 do
		P(V(0.14, 2.2, 0.14), CF(x, 1.9, -10), C3(42, 46, 54), M.Metal)
	end
	P(V(68, 0.16, 0.18), CF(0, 2.75, -10), C3(42, 46, 54), M.Metal)

	-- Vintage warm street lamps (glowing bokeh orbs in DoF close-ups)
	local function lantern(x, z)
		P(V(0.7, 0.9, 0.7), CF(x, 0.45, z), C3(42, 46, 54), M.Metal)
		P(V(0.32, 9.5, 0.32), CF(x, 5.2, z), C3(42, 46, 54), M.Metal)
		P(V(0.9, 0.25, 0.9), CF(x, 9.9, z), C3(42, 46, 54), M.Metal)
		local bulb = P(V(1.1, 1.35, 1.1), CF(x, 10.65, z), C3(255, 218, 135), M.Neon)
		bulb.CastShadow = false
		light(bulb, C3(255, 200, 120), 24, 1.8)
		P(V(1.4, 0.35, 1.4), CF(x, 11.4, z), C3(42, 46, 54), M.Metal)
	end
	for _, lx in ipairs({ -12, -3.2, 4.5, 14 }) do
		lantern(lx, -6.2)
	end
	for _, lx in ipairs({ -8, 1.5, 10 }) do
		lantern(lx, -16)
	end

	-- Wooden park benches (placed well behind walking actors, at z = -4.8)
	local function bench(x, z)
		P(V(4.6, 0.25, 1.3), CF(x, 1.35, z), C3(168, 112, 68), M.Wood)
		P(V(4.6, 1.15, 0.25), CF(x, 2.05, z - 0.55), C3(168, 112, 68), M.Wood)
		P(V(0.28, 1.3, 1.25), CF(x - 1.9, 0.65, z), C3(42, 46, 54), M.Metal)
		P(V(0.28, 1.3, 1.25), CF(x + 1.9, 0.65, z), C3(42, 46, 54), M.Metal)
	end
	bench(-9, -4.8)
	bench(8.5, -4.8)

	-- Background trees staggered in Z & X for rich DoF layers
	local function tree(x, z, s, leafCol)
		P(V(1.1 * s, 6.0 * s, 1.1 * s), CF(x, 3.0 * s, z), C3(112, 76, 48), M.Wood)
		P(V(5.8 * s, 5.2 * s, 5.8 * s), CF(x, 7.2 * s, z), leafCol or C3(92, 152, 72), M.Grass, nil, nil, Enum.PartType.Ball)
		P(V(4.2 * s, 3.8 * s, 4.2 * s), CF(x + 1.4 * s, 9.0 * s, z - 0.8 * s), C3(135, 168, 76), M.Grass, nil, nil, Enum.PartType.Ball)
	end
	tree(-16, -14, 1.15, C3(120, 150, 72))
	tree(-6.5, -18, 1.05, C3(198, 134, 62)) -- warm autumn/sunset foliage accent
	tree(7.5, -15, 1.1, C3(95, 152, 74))
	tree(17.5, -17, 1.25, C3(188, 118, 56))
	tree(-24, -28, 1.3, C3(85, 138, 68))
	tree(24, -27, 1.35, C3(105, 148, 72))

	-- Background warm brick & timber school / cafe building at z = -28 (with glowing warm windows)
	local function backdropBuilding(x, z, w, h, d, wallCol)
		local fz = z + d / 2
		P(V(w, h, d), CF(x, h / 2, z), wallCol, M.Brick)
		P(V(w + 0.8, 0.8, d + 0.8), CF(x, h + 0.4, z), C3(228, 220, 208), M.Concrete)
		for ix = -2, 2 do
			for _, wy in ipairs({ 4.2, 10.2 }) do
				local win = P(V(3.2, 3.6, 0.22), CF(x + ix * 5.4, wy, fz + 0.08), C3(255, 214, 130), M.Neon)
				win.CastShadow = false
				if ix == 0 and wy < 6 then
					light(win, C3(255, 205, 130), 22, 1.2)
				end
				P(V(0.22, 3.6, 0.3), CF(x + ix * 5.4, wy, fz + 0.14), C3(54, 42, 38))
				P(V(3.2, 0.22, 0.3), CF(x + ix * 5.4, wy, fz + 0.14), C3(54, 42, 38))
			end
		end
	end
	backdropBuilding(-14, -30, 26, 15, 12, C3(196, 128, 102))
	backdropBuilding(16, -32, 28, 17, 12, C3(226, 210, 186))

	-- Distant blurred sunset skyline silhouettes (staggered in Z so zero Z-fighting)
	local towers = {
		{ -55, -92, 18, 52, 14, C3(165, 138, 132) },
		{ -28, -108, 22, 68, 16, C3(154, 128, 126) },
		{ 4,   -98, 20, 58, 15, C3(172, 144, 134) },
		{ 34,  -114, 24, 72, 16, C3(148, 124, 124) },
		{ 62,  -100, 18, 48, 14, C3(162, 136, 130) },
	}
	for _, t in ipairs(towers) do
		local b = P(V(t[3], t[4], t[5]), CF(t[1], t[4] / 2 - 2, t[2]), t[6], M.SmoothPlastic)
		b.CastShadow = false
	end

	-- Ambient golden sunset dust motes across the courtyard
	local dustPart = P(V(32, 12, 20), CF(0, 6, -3), C3(255, 220, 150), M.SmoothPlastic, set, "DustMotes")
	dustPart.Transparency = 1
	dustPart.CastShadow = false
	local dust = Instance.new("ParticleEmitter")
	dust.Texture = "rbxasset://textures/sparkle.png"
	dust.Color = ColorSequence.new(C3(255, 225, 145), C3(255, 185, 95))
	dust.LightEmission = 1
	dust.LightInfluence = 0
	dust.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.3, 0.14),
		NumberSequenceKeypoint.new(1, 0),
	})
	dust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.25, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	dust.Lifetime = NumberRange.new(2.0, 3.6)
	dust.Rate = 24
	dust.Speed = NumberRange.new(0.2, 0.7)
	dust.SpreadAngle = Vector2.new(180, 180)
	dust.TimeScale = 1 / SLOW
	dust.Parent = dustPart
	dust:Emit(16)

	-- Spots (faces +Z by default; Maya walks from MayaStart toward MayaSpot facing Jason)
	spot("JasonSpot", V(-2.5, 0, 1.0), V(-2.5, 0, 12))
	spot("MayaStart", V(8.5, 0, -3.5), V(2.8, 0, 0.5))
	spot("MayaSpot", V(2.8, 0, 0.5), V(-2.5, 0, 1.0))
end

buildCourtyard()

---------------------------------------------------------------- BIG DRAWN 2D FACES (per-beat switching)
local INK, TEETH = C3(26, 22, 26), C3(255, 253, 245)

local function deco(m, base, name, size, off, color, shape, mat)
	local p = Instance.new("Part")
	p.Name, p.Size, p.Color = name, size, color
	p.Material = mat or M.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.CanCollide, p.Massless, p.CastShadow, p.Anchored = false, true, false, false
	if shape then p.Shape = shape end
	p.CFrame = base.CFrame * off
	local w = Instance.new("Weld")
	w.Part0, w.Part1, w.C0 = base, p, off
	w.Parent = p
	p.Parent = m
	return p
end

local function surf(part, face, w, h, name)
	local g = Instance.new("SurfaceGui")
	g.Name, g.Face, g.CanvasSize, g.LightInfluence = name or "Face", face, Vector2.new(w, h), 0.25
	g.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	g.AlwaysOnTop = false
	g.Parent = part
	return g
end

local function blob(parent, x, y, w, h, col, round, rot)
	local f = Instance.new("Frame")
	f.BorderSizePixel, f.AnchorPoint = 0, Vector2.new(0.5, 0.5)
	f.Position, f.Size, f.BackgroundColor3 = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h), col
	f.Rotation = rot or 0
	if round then local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(round, 0); c.Parent = f end
	f.Parent = parent
	return f
end

local function bar(parent, x1, y1, x2, y2, col, th)
	local dx, dy = x2 - x1, y2 - y1
	return blob(parent, (x1 + x2) / 2, (y1 + y2) / 2, math.sqrt(dx * dx + dy * dy) + th * 0.6, th, col, 0.5, math.deg(math.atan2(dy, dx)))
end

local function curve(parent, pts, col, th)
	for i = 1, #pts - 1 do bar(parent, pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], col, th) end
end

local function arc(parent, cx, cy, rx, ry, a0, a1, col, th, n)
	local pts = {}
	n = n or 10
	for i = 0, n do
		local a = a0 + (a1 - a0) * i / n
		table.insert(pts, { cx + rx * math.cos(a), cy + ry * math.sin(a) })
	end
	curve(parent, pts, col, th)
end

local function ring(parent, x, y, r, col, th)
	local f = blob(parent, x, y, r * 2, r * 2, col, 1)
	f.BackgroundTransparency = 1
	local s = Instance.new("UIStroke")
	s.Color, s.Thickness = col, th
	s.Parent = f
	return f
end

local EX = { 98, 202 }
local EXPRESSIONS = {
	smile   = { "oval",   "soft",    "smile", true },
	grin    = { "oval",   "raised",  "grin",  true },
	laugh   = { "closed", "raised",  "grin",  true },
	happy   = { "closed", "soft",    "smile", true },
	angry   = { "half",   "angry",   "frown", false },
	stern   = { "half",   "angry",   "flat",  false },
	worried = { "oval",   "worried", "teeth", false },
	dizzy   = { "spiral", "worried", "wavy",  false },
	shocked = { "round",  "raised",  "o",     false },
	smug    = { "half",   "smug",    "smirk", false },
	sad     = { "oval",   "worried", "frown", false },
	neutral = { "oval",   "soft",    "flat",  false },
}

local function drawEyes(g, kind, iris)
	for _, x in ipairs(EX) do
		if kind == "closed" then
			arc(g, x, 160, 26, 22, math.pi * 1.05, math.pi * 1.95, INK, 9)
		elseif kind == "spiral" then
			for r = 1, 3 do ring(g, x + r * 2, 148 - r, r * 10 + 2, INK, 5) end
		elseif kind == "round" then
			blob(g, x, 150, 56, 64, TEETH, 1)
			ring(g, x, 150, 30, INK, 6)
			blob(g, x, 152, 16, 18, INK, 1)
		elseif kind == "half" then
			blob(g, x, 156, 36, 32, INK, 0.5)
			bar(g, x - 26, 142, x + 26, 142, INK, 9)
			blob(g, x - 6, 152, 10, 10, TEETH, 1)
		else
			blob(g, x, 150, 34, 54, INK, 1)
			if iris then blob(g, x, 160, 22, 26, iris, 1) end
			blob(g, x - 7, 138, 12, 15, TEETH, 1)
			blob(g, x + 7, 164, 7, 7, TEETH, 1)
		end
	end
end

local function drawBrows(g, kind)
	for i, x in ipairs(EX) do
		local s = (i == 1) and -1 or 1
		if kind == "angry" then
			bar(g, x - 30 * s, 114, x + 24 * s, 90, INK, 13)
		elseif kind == "worried" then
			bar(g, x - 26 * s, 90, x + 24 * s, 110, INK, 9)
		elseif kind == "raised" then
			arc(g, x, 108, 26, 12, math.pi * 1.1, math.pi * 1.9, INK, 8, 6)
		elseif kind == "smug" then
			if i == 1 then
				bar(g, x - 26, 108, x + 24, 100, INK, 9)
			else
				arc(g, x, 94, 26, 14, math.pi * 1.1, math.pi * 1.9, INK, 8, 6)
			end
		else
			bar(g, x - 22, 104, x + 22, 100 + (i == 1 and 4 or 0), INK, 8)
		end
	end
end

local function drawMouth(g, kind)
	if kind == "grin" then
		blob(g, 150, 228, 154, 64, INK, 0.45)
		blob(g, 150, 220, 136, 32, TEETH, 0.3)
		bar(g, 86, 222, 214, 222, INK, 4)
		for x = 112, 188, 25 do bar(g, x, 207, x, 236, INK, 3) end
	elseif kind == "teeth" then
		blob(g, 150, 226, 120, 42, INK, 0.2)
		blob(g, 150, 226, 108, 32, TEETH, 0.15)
		bar(g, 98, 226, 202, 226, INK, 3)
		for x = 112, 188, 19 do bar(g, x, 213, x, 239, INK, 3) end
	elseif kind == "smile" then
		arc(g, 150, 196, 58, 38, math.pi * 0.15, math.pi * 0.85, INK, 9)
	elseif kind == "frown" then
		arc(g, 150, 252, 46, 26, math.pi * 1.15, math.pi * 1.85, INK, 9)
	elseif kind == "o" then
		blob(g, 150, 230, 40, 48, INK, 1)
		blob(g, 150, 236, 24, 22, C3(190, 70, 80), 1)
	elseif kind == "smirk" then
		curve(g, { { 102, 226 }, { 150, 230 }, { 188, 216 }, { 204, 202 } }, INK, 9)
	elseif kind == "wavy" then
		curve(g, { { 106, 228 }, { 124, 216 }, { 142, 230 }, { 160, 216 }, { 178, 230 }, { 196, 218 } }, INK, 7)
	else
		bar(g, 120, 226, 180, 226, INK, 8)
	end
end

local function attachFacePlate(m, defaultExpr, iris)
	local head = m:WaitForChild("Head")
	local dec = head:FindFirstChild("face")
	if dec then dec:Destroy() end
	local plate = deco(m, head, "FacePlate", V(1.22, 1.22, 0.04), CF(0, -0.02, -0.635), C3(255, 255, 255))
	plate.Transparency = 1
	local g = surf(plate, Enum.NormalId.Front, 300, 300, "Face")
	for name, e in pairs(EXPRESSIONS) do
		local layer = Instance.new("Frame")
		layer.Name = name
		layer.BackgroundTransparency = 1
		layer.Size = UDim2.fromScale(1, 1)
		layer.Visible = (name == defaultExpr)
		layer.Parent = g
		drawEyes(layer, e[1], iris)
		drawBrows(layer, e[2])
		drawMouth(layer, e[3])
		if e[4] then
			for _, x in ipairs({ 60, 240 }) do
				blob(layer, x, 196, 40, 18, C3(240, 150, 150), 1).BackgroundTransparency = 0.25
			end
		end
	end
	m:SetAttribute("Expression", defaultExpr)
end

---------------------------------------------------------------- PARTICLE EMITTER AURAS
local function attachAura(m, colMain, colTip)
	local torso = m:WaitForChild("Torso")
	local backAttach = Instance.new("Attachment")
	backAttach.Name = "AuraBackAttach"
	backAttach.Position = V(0, -0.35, 0.45)
	backAttach.Parent = torso

	local centerAttach = Instance.new("Attachment")
	centerAttach.Name = "AuraCenterAttach"
	centerAttach.Position = V(0, -0.2, 0)
	centerAttach.Parent = torso

	local flames = Instance.new("ParticleEmitter")
	flames.Name = "AuraFlames"
	flames.Texture = "rbxasset://textures/particles/fire_main.dds"
	flames.Color = ColorSequence.new(colMain, colTip)
	flames.LightEmission = 1
	flames.LightInfluence = 0
	flames.Brightness = 3.2
	flames.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.5),
		NumberSequenceKeypoint.new(0.4, 2.4),
		NumberSequenceKeypoint.new(1, 0.35),
	})
	flames.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.22),
		NumberSequenceKeypoint.new(1, 1),
	})
	flames.Speed = NumberRange.new(2.2, 4.4)
	flames.Acceleration = V(0, 3.0, 0)
	flames.Drag = 1.2
	flames.Lifetime = NumberRange.new(0.65, 1.2)
	flames.SpreadAngle = Vector2.new(32, 32)
	flames.Rate = 30
	flames.TimeScale = 1 / SLOW
	flames.Enabled = false
	flames.Parent = backAttach

	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "AuraSparks"
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(C3(255, 255, 235), colMain)
	sparks.LightEmission = 1
	sparks.LightInfluence = 0
	sparks.Brightness = 4.6
	sparks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.6, 0.32),
		NumberSequenceKeypoint.new(1, 0),
	})
	sparks.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	sparks.Speed = NumberRange.new(3.0, 6.4)
	sparks.Acceleration = V(0, 1.8, 0)
	sparks.Lifetime = NumberRange.new(0.6, 1.15)
	sparks.SpreadAngle = Vector2.new(45, 45)
	sparks.Rate = 22
	sparks.TimeScale = 1 / SLOW
	sparks.Enabled = false
	sparks.Parent = centerAttach

	local core = Instance.new("ParticleEmitter")
	core.Name = "AuraCore"
	core.Texture = "rbxasset://textures/glow.png"
	core.Color = ColorSequence.new(colMain, colTip)
	core.LightEmission = 1
	core.LightInfluence = 0
	core.Brightness = 2.1
	core.LockedToPart = true
	core.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 3.4),
		NumberSequenceKeypoint.new(0.5, 4.3),
		NumberSequenceKeypoint.new(1, 3.0),
	})
	core.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.4, 0.52),
		NumberSequenceKeypoint.new(1, 1),
	})
	core.Speed = NumberRange.new(0.15, 0.45)
	core.Lifetime = NumberRange.new(0.7, 1.1)
	core.Rate = 6
	core.TimeScale = 1 / SLOW
	core.Enabled = false
	core.Parent = backAttach

	local auraLight = Instance.new("PointLight")
	auraLight.Name = "AuraLight"
	auraLight.Color = colMain
	auraLight.Range = 14
	auraLight.Brightness = 0
	auraLight.Shadows = false
	auraLight.Parent = torso
end

---------------------------------------------------------------- PURE R6 DRESSED UGC AVATARS
local function buildR6UGC(name, cfg)
	local d = Instance.new("HumanoidDescription")
	local skin = cfg.skin
	d.HeadColor, d.TorsoColor = skin, skin
	d.LeftArmColor, d.RightArmColor = skin, skin
	d.LeftLegColor, d.RightLegColor = skin, skin
	if cfg.hat then d.HatAccessory = cfg.hat end
	if cfg.hair then d.HairAccessory = cfg.hair end
	if cfg.back then d.BackAccessory = cfg.back end
	if cfg.neck then d.NeckAccessory = cfg.neck end
	if cfg.front then d.FrontAccessory = cfg.front end
	if cfg.shirt then d.Shirt = cfg.shirt end
	if cfg.pants then d.Pants = cfg.pants end

	local m = Players:CreateHumanoidModelFromDescription(d, Enum.HumanoidRigType.R6)
	m.Name = name

	local animate = m:FindFirstChild("Animate")
	if animate then animate:Destroy() end

	local hum = m:FindFirstChildOfClass("Humanoid")
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.AutoRotate = false
	hum.PlatformStand = false
	if not hum:FindFirstChildOfClass("Animator") then
		Instance.new("Animator", hum)
	end

	-- Root anchored; all limbs and accessory handles unanchored + massless so Moon Animator 2 AnimationTracks drive cleanly
	m.HumanoidRootPart.Anchored = true
	for _, dsc in ipairs(m:GetDescendants()) do
		if dsc:IsA("BasePart") and dsc ~= m.HumanoidRootPart then
			dsc.Anchored = false
			dsc.CanCollide = false
			dsc.Massless = true
			dsc.CastShadow = true
		end
	end

	-- Add crisp 3D sneakers so R6 legs have clean footwear silhouette
	for _, legName in ipairs({ "Left Leg", "Right Leg" }) do
		local leg = m:FindFirstChild(legName)
		if leg then
			deco(m, leg, "Shoe", V(1.04, 0.34, 1.18), CF(0, -0.84, -0.07), cfg.shoeColor or C3(34, 36, 44))
			deco(m, leg, "Sole", V(1.06, 0.12, 1.22), CF(0, -0.96, -0.07), C3(242, 240, 236))
		end
	end

	attachFacePlate(m, cfg.face or "smile", cfg.iris)
	attachAura(m, cfg.auraMain, cfg.auraTip)

	m:SetAttribute("RootHeight", 3)
	m:SetAttribute("Rig", "R6_UGC")
	m.Parent = workspace
	task.wait(0.1)

	-- Nudge hat/hair welds upward slightly after workspace insertion so AccessoryWeld exists and brows read clearly
	local head = m:FindFirstChild("Head")
	if head and (cfg.hatOffset or cfg.hairOffset) then
		for _, acc in ipairs(m:GetChildren()) do
			if acc:IsA("Accessory") then
				local off = (acc.AccessoryType == Enum.AccessoryType.Hat and cfg.hatOffset)
					or (acc.AccessoryType == Enum.AccessoryType.Hair and cfg.hairOffset)
				if off then
					local handle = acc:FindFirstChild("Handle")
					local w = handle and handle:FindFirstChildOfClass("Weld")
					if w then
						if w.Part0 == head then
							w.C0 = off * w.C0
						elseif w.Part1 == head then
							w.C1 = off * w.C1
						end
					end
				end
			end
		end
	end

	m:PivotTo(CF(0, -200, 0))
	task.wait(0.1)
	return m
end

-- Jason: Red baseball cap, messy curly brown hair, hoodie + 3D hoodie hood, crossbody bag, backpack, jeans, golden aura
buildR6UGC("Jason", {
	skin = C3(247, 210, 160),
	hat = "14510395236",
	hair = "13433327568",
	back = "18166247145",
	neck = "16095109571",
	front = "8084645500",
	shirt = 6920575635,
	pants = 7019335834,
	shoeColor = C3(205, 48, 48),
	hatOffset = CF(0, 0.20, 0.08) * CFrame.Angles(math.rad(14), 0, 0),
	hairOffset = CF(0, 0.03, 0.06),
	face = "worried",
	auraMain = C3(255, 225, 90),
	auraTip = C3(255, 145, 30),
})

-- Maya: Blonde sculpted anime hair, hoodie + 3D scarf, white backpack, jeans, electric cyan-violet aura
buildR6UGC("Maya", {
	skin = C3(249, 218, 178),
	hair = "18899378507",
	back = "139196487384313",
	neck = "16467566865",
	shirt = 5101436051,
	pants = 8020998573,
	shoeColor = C3(240, 236, 245),
	hairOffset = CF(0, 0.07, 0.06),
	face = "smug",
	auraMain = C3(100, 235, 255),
	auraTip = C3(160, 95, 255),
})
