-- MODERN KIT (server): modern streets, buildings, furnished interiors, and dressed
-- characters, all built from code (no catalog or toolbox assets, so nothing can fail to
-- load or break copyright). Copy this file as a scene's Server.luau, keep the KIT part,
-- and rewrite only the SCENE part at the bottom for the story's locations and cast.
--
-- Coordinates: y = 0 is ground / floor level. Exteriors live around x = -150..150 on a
-- street along X (road at z = 9, sidewalk z = -3.5, building fronts face +Z = the camera).
-- Interiors are separate closed rooms built far away (x >= 400) so exterior shots never see
-- them. Every room and building drops a "spot" (invisible part) in Set/Spots, named, whose
-- CFrame marks a good actor position facing the room's open/camera side; the client reads
-- them: workspace.Set.Spots.LivingRoom.Position etc.
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
Players.CharacterAutoLoads = false

local V, C3, CF = Vector3.new, Color3.fromRGB, CFrame.new
local M = Enum.Material
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
	l.Color, l.Range, l.Brightness, l.Shadows = color or C3(255, 214, 170), range or 16, brightness or 1.2, false
	l.Parent = part
	return l
end
local function sign(part, face, text, bg, fg)
	local g = Instance.new("SurfaceGui")
	g.Face, g.SizingMode = face, Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud = 40
	g.Parent = part
	local t = Instance.new("TextLabel")
	t.Size, t.BackgroundColor3, t.BackgroundTransparency = UDim2.fromScale(1, 1), bg or C3(30, 30, 40), bg and 0 or 1
	t.Text, t.TextColor3, t.TextScaled, t.Font = text, fg or C3(255, 255, 255), true, Enum.Font.GothamBlack
	t.Parent = g
	return g
end
local function spot(name, pos, lookAt)
	local s = P(V(1, 1, 1), CFrame.lookAt(pos, lookAt or (pos + V(0, 0, 10))), C3(255, 0, 0), nil, spots, name)
	s.Transparency = 1
	return s
end

-- palettes: modern, soft, high-contrast accents
local WALL = { C3(232, 226, 216), C3(214, 222, 230), C3(238, 226, 206), C3(208, 222, 214) }
local ACCENT = { C3(255, 120, 90), C3(70, 160, 255), C3(255, 196, 60), C3(120, 210, 170), C3(190, 140, 255) }
local WOOD, DARK, GLASS = C3(196, 150, 105), C3(40, 44, 54), C3(165, 210, 240)

---------------------------------------------------------------- KIT: street pieces
local function tree(x, z, s)
	s = s or 1
	P(V(0.8, 5, 0.8) * s, CF(x, 2.5 * s, z), C3(115, 85, 60), M.Wood)
	P(V(4.5, 4.5, 4.5) * s, CF(x, 6 * s, z), C3(80, 170, 90), M.Grass, nil, "Leaves", Enum.PartType.Ball)
	P(V(3, 3, 3) * s, CF(x + 1 * s, 7.8 * s, z - 0.5), C3(100, 190, 100), M.Grass, nil, "Leaves", Enum.PartType.Ball)
end
local function streetLight(x, z)
	P(V(0.35, 11, 0.35), CF(x, 5.5, z), DARK, M.Metal)
	P(V(0.35, 0.35, 2.5), CF(x, 11, z + 1.1), DARK, M.Metal)
	light(P(V(1.4, 0.3, 0.9), CF(x, 10.8, z + 2.2), C3(255, 236, 200), M.Neon), C3(255, 220, 170), 22, 1.6)
end
local function bench(x, z)
	P(V(4, 0.3, 1.2), CF(x, 1.4, z), WOOD, M.Wood)
	P(V(4, 1.2, 0.25), CF(x, 2.1, z - 0.55), WOOD, M.Wood)
	P(V(0.3, 1.3, 1.2), CF(x - 1.7, 0.65, z), DARK, M.Metal)
	P(V(0.3, 1.3, 1.2), CF(x + 1.7, 0.65, z), DARK, M.Metal)
end
local function car(x, z, color, yaw)
	local base = CF(x, 0, z) * CFrame.Angles(0, yaw or 0, 0)
	local function c(size, off, col, mat, shape) return P(size, base * CF(off), col, mat, nil, nil, shape) end
	c(V(8, 1.6, 3.8), V(0, 1.5, 0), color, M.SmoothPlastic)
	c(V(4.6, 1.4, 3.5), V(-0.3, 2.9, 0), color, M.SmoothPlastic)
	c(V(4.4, 1.15, 3.6), V(-0.3, 2.95, 0), C3(60, 80, 100), M.Glass).Transparency = 0.25
	for _, wx in ipairs({ -2.6, 2.6 }) do
		for _, wz in ipairs({ -1.85, 1.85 }) do
			c(V(0.7, 1.6, 1.6), V(wx, 0.8, wz), C3(25, 25, 28), M.SmoothPlastic, Enum.PartType.Cylinder)
		end
	end
	light(c(V(0.2, 0.4, 0.9), V(4.02, 1.7, 1.2), C3(255, 250, 230), M.Neon), nil, 8, 0.8)
	c(V(0.2, 0.4, 0.9), V(4.02, 1.7, -1.2), C3(255, 250, 230), M.Neon)
	c(V(0.2, 0.35, 0.9), V(-4.02, 1.7, 1.2), C3(230, 40, 40), M.Neon)
	c(V(0.2, 0.35, 0.9), V(-4.02, 1.7, -1.2), C3(230, 40, 40), M.Neon)
end
-- road along X from x0 to x1 (road centre z = 9, sidewalk z = -3.5), grass behind
local function street(x0, x1)
	local L, cx = x1 - x0, (x0 + x1) / 2
	P(V(L, 1, 400), CF(cx, -0.5, -150), C3(110, 175, 90), M.Grass, nil, "Grass")
	P(V(L, 0.1, 16), CF(cx, 0.05, 9), C3(55, 57, 64), M.Asphalt, nil, "Road")
	for x = x0 + 2, x1 - 2, 8 do P(V(3.5, 0.12, 0.35), CF(x, 0.1, 9), C3(250, 250, 250)) end
	P(V(L, 0.35, 7), CF(cx, 0.17, -3.5), C3(214, 214, 218), M.Concrete, nil, "Sidewalk")
	P(V(L, 0.4, 0.4), CF(cx, 0.2, 0.2), C3(180, 180, 185), M.Concrete)
	P(V(L, 0.35, 5), CF(cx, 0.17, 19.5), C3(214, 214, 218), M.Concrete)
	for x = x0 + 10, x1 - 10, 24 do streetLight(x, -0.8) end
end

---------------------------------------------------------------- KIT: buildings (front faces +Z)
-- glassy two-storey house with flat roof, wood panel, garage, lit windows
local function modernHouse(x, z, o)
	o = o or {}
	local w, d, wall, acc = o.w or 16, o.d or 12, o.wall or WALL[1], o.accent or ACCENT[1]
	local h1, h2 = 6.5, 6
	local fz = z + d / 2
	P(V(w, h1, d), CF(x, h1 / 2, z), wall, M.SmoothPlastic)
	P(V(w * 0.7, h2, d * 0.9), CF(x - w * 0.15, h1 + h2 / 2, z - d * 0.05), o.wall2 or C3(60, 64, 74), M.SmoothPlastic)
	P(V(w * 0.75, 0.5, d + 1.5), CF(x - w * 0.15, h1 + h2 + 0.25, z + 0.3), C3(250, 250, 250))       -- roof slab
	P(V(w + 0.6, 0.45, d + 1.2), CF(x, h1 + 0.2, z + 0.4), C3(250, 250, 250))                         -- first-floor slab
	P(V(w * 0.28, h1 - 0.5, 0.3), CF(x + w * 0.33, h1 / 2, fz + 0.05), WOOD, M.WoodPlanks)            -- wood cladding
	-- big ground-floor window (lit), door, garage
	local win = P(V(w * 0.38, 4.2, 0.2), CF(x - w * 0.18, 3, fz + 0.2), GLASS, M.Glass)
	win.Transparency = 0.15
	light(P(V(w * 0.36, 4, 0.1), CF(x - w * 0.18, 3, fz + 0.04), C3(255, 236, 205), M.Neon), C3(255, 214, 170), 14, 0.9)
	P(V(2.6, 4.6, 0.25), CF(x + w * 0.06, 2.3, fz + 0.12), acc)                                       -- front door
	P(V(0.15, 0.6, 0.15), CF(x + w * 0.06 + 0.9, 2.3, fz + 0.3), C3(230, 230, 230), M.Metal)
	-- upstairs window strip
	local win2 = P(V(w * 0.6, 2.4, 0.2), CF(x - w * 0.15, h1 + 3, z + d * 0.4 + 0.12), GLASS, M.Glass)
	win2.Transparency = 0.15
	-- front path + low hedge + planter
	P(V(3, 0.2, 3.2), CF(x + w * 0.06, 0.4, fz + 1.6), C3(200, 200, 205), M.Concrete)
	P(V(w * 0.35, 1.2, 1), CF(x - w * 0.25, 0.6, fz + 2), C3(70, 150, 80), M.Grass)
	return fz
end
-- shop / cafe with glass front, awning and a name sign
local function shop(x, z, name, o)
	o = o or {}
	local w, d, col = o.w or 14, o.d or 10, o.color or ACCENT[2]
	local fz = z + d / 2
	P(V(w, 8, d), CF(x, 4, z), o.wall or C3(240, 240, 236))
	local g = P(V(w - 2, 5, 0.2), CF(x, 2.8, fz + 0.2), GLASS, M.Glass)
	g.Transparency = 0.2
	light(P(V(w - 2.2, 4.8, 0.1), CF(x, 2.8, fz + 0.04), C3(255, 240, 215), M.Neon), C3(255, 220, 180), 16, 1)
	P(V(w, 0.5, 2.2), CF(x, 5.9, fz + 1.1) * CFrame.Angles(math.rad(-12), 0, 0), col)                 -- awning
	local s = P(V(w - 3, 1.4, 0.3), CF(x, 7.1, fz + 0.2), C3(30, 32, 40))
	sign(s, Enum.NormalId.Front, name, C3(30, 32, 40), C3(255, 255, 255))
	return fz
end
-- school: wide, two storeys, coloured stripe, entrance canopy, sign
local function school(x, z, name)
	local w, d = 46, 16
	local fz = z + d / 2
	P(V(w, 13, d), CF(x, 6.5, z), C3(245, 240, 230))
	P(V(w, 1.2, d + 0.2), CF(x, 6.6, z), ACCENT[3])
	for i = -4, 4 do
		for _, y in ipairs({ 3.4, 10 }) do
			local g = P(V(3.6, 3, 0.2), CF(x + i * 5, y, fz + 0.12), GLASS, M.Glass)
			g.Transparency = 0.15
		end
	end
	P(V(9, 0.5, 4), CF(x, 5, fz + 2), C3(250, 250, 250))
	P(V(5, 4.8, 0.25), CF(x, 2.4, fz + 0.15), C3(60, 120, 200), M.Glass)
	local s = P(V(16, 2, 0.3), CF(x, 12, fz + 0.2), C3(250, 250, 250))
	sign(s, Enum.NormalId.Front, name or "SUNNYSIDE SCHOOL", C3(250, 250, 250), C3(40, 90, 170))
	return fz
end
-- glass office / apartment tower for skylines
local function tower(x, z, o)
	o = o or {}
	local w, d, h = o.w or 14, o.d or 14, o.h or 50
	P(V(w, h, d), CF(x, h / 2, z), o.color or C3(120, 160, 200), M.Glass).Transparency = 0.05
	for y = 4, h - 2, 4 do P(V(w + 0.3, 0.4, d + 0.3), CF(x, y, z), C3(235, 238, 242)) end
	P(V(w + 0.6, 1, d + 0.6), CF(x, h + 0.5, z), C3(235, 238, 242))
end

local K = {} -- furniture & interior pieces (defined below; room() uses K.ledStrip)
---------------------------------------------------------------- KIT: interior rooms
-- Closed room centred at (x, z), floor at y = 0, size w (X) by d (Z), height h.
-- The +Z wall is omitted by default ("cutaway") so the camera can look in from +Z the way
-- the exterior camera does; set o.closed = true to include it (camera then inside).
-- A big window on the back wall shows a bright "outside" (sky + far buildings).
local function room(x, z, o)
	o = o or {}
	local w, d, h = o.w or 22, o.d or 16, o.h or 10
	local wall, floorCol = o.wall or WALL[2], o.floor or WOOD
	local f = Instance.new("Folder")
	f.Name = o.name or "Room"
	f.Parent = set
	P(V(w, 0.4, d), CF(x, -0.2, z), floorCol, o.floorMat or M.WoodPlanks, f, "Floor")
	P(V(w, 0.4, d), CF(x, h + 0.2, z), C3(250, 250, 250), M.SmoothPlastic, f, "Ceiling")
	-- back wall with a window opening
	local bz = z - d / 2
	local ww, wh, wy = math.min(10, w * 0.45), 5, h * 0.52
	P(V(w, h, 0.4), CF(x, h / 2, bz), wall, M.SmoothPlastic, f).Name = "BackWall"
	P(V(ww + 0.6, wh + 0.6, 0.45), CF(x + (o.windowX or 0), wy, bz + 0.02), C3(255, 255, 255), M.SmoothPlastic, f)
	local sky = P(V(ww, wh, 0.2), CF(x + (o.windowX or 0), wy, bz + 0.22), C3(150, 205, 255), M.Neon, f, "WindowView")
	for i = -2, 2 do  -- far skyline silhouettes inside the window
		P(V(ww / 6, wh * (0.3 + (i % 3) * 0.15), 0.1), CF(x + (o.windowX or 0) + i * ww / 5.5, wy - wh / 2 + wh * (0.15 + (i % 3) * 0.075), bz + 0.32), C3(110, 150, 200), M.SmoothPlastic, f)
	end
	P(V(ww, 0.2, 0.1), CF(x + (o.windowX or 0), wy, bz + 0.42), C3(255, 255, 255), M.SmoothPlastic, f)  -- mullion
	P(V(0.2, wh, 0.1), CF(x + (o.windowX or 0), wy, bz + 0.42), C3(255, 255, 255), M.SmoothPlastic, f)
	sky.CastShadow = false
	-- side walls (+ optional front wall)
	P(V(0.4, h, d), CF(x - w / 2, h / 2, z), wall, M.SmoothPlastic, f)
	P(V(0.4, h, d), CF(x + w / 2, h / 2, z), wall, M.SmoothPlastic, f)
	if o.closed then P(V(w, h, 0.4), CF(x, h / 2, z + d / 2), wall, M.SmoothPlastic, f) end
	-- skirting + ceiling light
	P(V(w, 0.5, 0.1), CF(x, 0.25, bz + 0.25), C3(255, 255, 255), M.SmoothPlastic, f)
	if o.neon then  -- gamer room: LED strips along the ceiling edges instead of a white lamp
		local a, b = o.neon[1] or C3(170, 80, 255), o.neon[2] or C3(60, 190, 255)
		K.ledStrip(x, h - 0.3, bz + 0.35, w - 1, "x", a)
		K.ledStrip(x - w / 2 + 0.35, h - 0.3, z, d - 1, "z", b)
		K.ledStrip(x + w / 2 - 0.35, h - 0.3, z, d - 1, "z", b)
		light(P(V(1, 0.2, 1), CF(x, h - 0.1, z), C3(120, 100, 160), M.Neon, f), C3(170, 140, 255), math.max(w, d), 0.5)
	else
		local lamp = P(V(4, 0.25, 4), CF(x, h - 0.1, z), C3(255, 240, 220), M.Neon, f)
		light(lamp, C3(255, 228, 190), math.max(w, d) * 1.1, 0.7)
	end
	spot(o.name or "Room", V(x, 0, z + d * 0.15), V(x, 0, z + d))
	return f, bz
end

-- furniture: (x, z) is the piece's centre on the floor, yaw in degrees (0 = faces +Z)
local function piece(x, z, yaw, parts)
	local base = CF(x, 0, z) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	for _, p in ipairs(parts) do
		local q = P(p[1], base * CF(p[2]), p[3], p[4], nil, nil, p[5])
		if p[6] then q.Transparency = p[6] end
	end
end
function K.sofa(x, z, yaw, col)
	col = col or C3(90, 110, 160)
	piece(x, z, yaw, {
		{ V(7, 1.2, 3), V(0, 0.9, 0), col }, { V(7, 2.2, 0.8), V(0, 2, -1.1), col },
		{ V(0.8, 1.8, 3), V(-3.5, 1.4, 0), col }, { V(0.8, 1.8, 3), V(3.5, 1.4, 0), col },
		{ V(2, 1.2, 0.5), V(-1.5, 2.1, -0.5), C3(250, 220, 120) }, { V(2, 1.2, 0.5), V(1.6, 2.1, -0.5), C3(250, 250, 250) },
		{ V(0.3, 0.3, 0.3), V(-3.2, 0.15, 1.2), DARK }, { V(0.3, 0.3, 0.3), V(3.2, 0.15, 1.2), DARK },
	})
end
function K.coffeeTable(x, z, yaw)
	piece(x, z, yaw, { { V(4, 0.25, 2.2), V(0, 1.4, 0), WOOD, M.Wood }, { V(3.6, 1.3, 1.8), V(0, 0.65, 0), C3(60, 64, 74) } })
end
function K.rug(x, z, w, d, col)
	P(V(w or 9, 0.05, d or 6), CF(x, 0.03, z), col or C3(235, 225, 210), M.Fabric)
end
function K.tvWall(x, z, yaw)  -- media unit + wall TV
	piece(x, z, yaw, {
		{ V(8, 1.4, 1.6), V(0, 0.7, 0), C3(250, 250, 250) },
		{ V(6.2, 3.6, 0.25), V(0, 4.4, -0.5), C3(20, 22, 28) },
		{ V(5.9, 3.3, 0.05), V(0, 4.4, -0.35), C3(70, 140, 220), M.Neon },
	})
end
function K.plant(x, z, s)
	s = s or 1
	-- pot: a cylinder's length runs along its X axis, so size X = height, then stand it up
	P(V(1.4, 1.2, 1.2) * s, CF(x, 0.7 * s, z) * CFrame.Angles(0, 0, math.rad(90)), C3(240, 240, 235), M.SmoothPlastic, nil, nil, Enum.PartType.Cylinder)
	P(V(2.2, 2.2, 2.2) * s, CF(x, 2.3 * s, z), C3(70, 160, 85), M.Grass, nil, nil, Enum.PartType.Ball)
end
function K.floorLamp(x, z)
	P(V(0.2, 5, 0.2), CF(x, 2.5, z), DARK, M.Metal)
	light(P(V(1.4, 1.1, 1.4), CF(x, 5.3, z), C3(255, 238, 205), M.Neon), C3(255, 214, 170), 12, 1)
end
function K.bed(x, z, yaw, col)
	col = col or C3(120, 170, 230)
	piece(x, z, yaw, {
		{ V(5, 1, 8), V(0, 0.8, 0), WOOD, M.Wood }, { V(4.8, 0.8, 7.6), V(0, 1.6, 0), C3(250, 250, 250) },
		{ V(4.9, 0.25, 5), V(0, 2.1, 1.2), col }, { V(3.6, 0.6, 1.2), V(0, 2.3, -3), C3(255, 255, 255) },
		{ V(5.2, 3.6, 0.4), V(0, 1.8, -4), WOOD, M.Wood },
	})
end
function K.desk(x, z, yaw, withLaptop)
	piece(x, z, yaw, {
		{ V(5, 0.25, 2.4), V(0, 2.6, 0), C3(250, 250, 250) },
		{ V(0.25, 2.5, 2.2), V(-2.3, 1.25, 0), DARK, M.Metal }, { V(0.25, 2.5, 2.2), V(2.3, 1.25, 0), DARK, M.Metal },
		{ V(1.8, 0.25, 1.8), V(0, 1.6, 2), C3(40, 44, 54) }, { V(1.8, 1.8, 0.25), V(0, 2.6, 2.8), C3(40, 44, 54) },
	})
	if withLaptop then
		piece(x, z, yaw, { { V(1.8, 0.1, 1.2), V(0, 2.78, 0.2), C3(190, 195, 205), M.Metal }, { V(1.8, 1.2, 0.08), V(0, 3.35, -0.4), C3(90, 160, 240), M.Neon } })
	end
end
function K.shelf(x, z, yaw)
	local parts = { { V(4, 6, 1.2), V(0, 3, 0), WOOD, M.Wood } }
	for i, y in ipairs({ 1.6, 3.2, 4.8 }) do
		table.insert(parts, { V(1, 1.1, 0.9), V(-1.2, y, 0.2), ACCENT[i] })
		table.insert(parts, { V(0.6, 1.2, 0.9), V(0.2, y, 0.2), ACCENT[i + 1] })
	end
	piece(x, z, yaw, parts)
end
function K.kitchen(x, z, yaw)  -- counter run + upper cabinets + fridge
	piece(x, z, yaw, {
		{ V(10, 3, 2.4), V(0, 1.5, 0), C3(250, 250, 250) }, { V(10.2, 0.25, 2.6), V(0, 3.1, 0.05), C3(60, 64, 74), M.Marble },
		{ V(10, 2.4, 1.4), V(0, 7, -0.5), C3(250, 250, 250) }, { V(3, 7.5, 2.6), V(6.5, 3.75, 0), C3(220, 224, 230), M.Metal },
		{ V(1.4, 0.5, 1), V(-2, 3.4, 0), C3(200, 200, 205), M.Metal }, { V(2, 0.1, 1.6), V(2.5, 3.25, 0), C3(30, 30, 30) },
	})
end
function K.diningSet(x, z, yaw)
	local parts = { { V(6, 0.25, 3.4), V(0, 2.6, 0), WOOD, M.Wood }, { V(0.3, 2.5, 0.3), V(-2.6, 1.25, 1.4), DARK }, { V(0.3, 2.5, 0.3), V(2.6, 1.25, 1.4), DARK }, { V(0.3, 2.5, 0.3), V(-2.6, 1.25, -1.4), DARK }, { V(0.3, 2.5, 0.3), V(2.6, 1.25, -1.4), DARK } }
	for _, cx in ipairs({ -1.6, 1.6 }) do
		for _, cz in ipairs({ -2.6, 2.6 }) do
			table.insert(parts, { V(1.6, 0.25, 1.6), V(cx, 1.6, cz), C3(250, 250, 250) })
			table.insert(parts, { V(1.6, 1.8, 0.2), V(cx, 2.6, cz + (cz > 0 and 0.7 or -0.7)), C3(250, 250, 250) })
		end
	end
	piece(x, z, yaw, parts)
end
function K.classroom(x, z)  -- rows of desks facing a whiteboard on the back wall (-Z)
	for r = 0, 2 do
		for c = -1, 1 do
			piece(x + c * 5.5, z + r * 4.5, 180, { { V(3.2, 0.2, 2), V(0, 2.4, 0), C3(250, 250, 250) }, { V(3, 2.3, 0.2), V(0, 1.2, 0.8), C3(70, 140, 220) }, { V(1.6, 0.2, 1.6), V(0, 1.5, -1.6), C3(70, 140, 220) } })
		end
	end
end
function K.whiteboard(x, y, z, text)
	local b = P(V(10, 4.5, 0.2), CF(x, y, z), C3(252, 252, 252))
	P(V(10.4, 4.9, 0.15), CF(x, y, z - 0.05), C3(180, 185, 195), M.Metal)
	if text then sign(b, Enum.NormalId.Front, text, C3(252, 252, 252), C3(40, 60, 120)) end
end
function K.wallArt(x, y, z, col)
	P(V(3, 2.2, 0.15), CF(x, y, z), C3(255, 255, 255))
	P(V(2.6, 1.8, 0.1), CF(x, y, z + 0.05), col or ACCENT[5], M.SmoothPlastic)
end

---------------------------------------------------------------- KIT: more city (from the environment board)
-- vehicle(x, z, kind, yaw, color): "sedan" | "sports" | "suv" | "police" | "ambulance" | "bus" | "truck"
local function vehicle(x, z, kind, yaw, color)
	local base = CF(x, 0, z) * CFrame.Angles(0, yaw or 0, 0)
	local function c(size, off, col, mat, shape) return P(size, base * CF(off), col, mat, nil, nil, shape) end
	local glass = C3(50, 70, 95)
	local function wheels(xs, zw, r)
		for _, wx in ipairs(xs) do for _, wz in ipairs({ -zw, zw }) do
			c(V(0.8, r, r), V(wx, r / 2, wz), C3(25, 25, 28), M.SmoothPlastic, Enum.PartType.Cylinder)
			c(V(0.82, r * 0.5, r * 0.5), V(wx, r / 2, wz), C3(190, 195, 200), M.Metal, Enum.PartType.Cylinder)
		end end
	end
	local function lights(len, y, zw)
		c(V(0.2, 0.4, 0.8), V(len / 2 + 0.02, y, zw), C3(255, 250, 230), M.Neon); c(V(0.2, 0.4, 0.8), V(len / 2 + 0.02, y, -zw), C3(255, 250, 230), M.Neon)
		c(V(0.2, 0.35, 0.8), V(-len / 2 - 0.02, y, zw), C3(230, 40, 40), M.Neon); c(V(0.2, 0.35, 0.8), V(-len / 2 - 0.02, y, -zw), C3(230, 40, 40), M.Neon)
	end
	if kind == "bus" then
		c(V(22, 6.5, 5.6), V(0, 4.1, 0), color or C3(50, 130, 230))
		c(V(20, 2.2, 5.7), V(0.4, 5, 0), glass, M.Glass)
		c(V(0.3, 3.6, 4.8), V(11.05, 4.6, 0), glass, M.Glass)
		c(V(22.1, 0.5, 5.65), V(0, 1.6, 0), C3(240, 240, 240))
		wheels({ -7, 7 }, 2.5, 2.4); lights(22, 2.4, 2)
	elseif kind == "truck" then
		c(V(6, 5.2, 5.4), V(7, 3.5, 0), color or C3(240, 240, 240))
		c(V(0.3, 2, 4.6), V(10.05, 4.6, 0), glass, M.Glass)
		c(V(15, 7.5, 5.8), V(-3.6, 4.9, 0), C3(235, 235, 238))
		wheels({ -8, -4, 7 }, 2.4, 2.4); lights(20.2, 2.2, 2)
	else
		local sporty = kind == "sports"
		local tall = kind == "suv" or kind == "police" or kind == "ambulance"
		local body = color or (kind == "police" and C3(245, 245, 245)) or (kind == "ambulance" and C3(250, 250, 250)) or ACCENT[2]
		local len = (kind == "ambulance") and 10 or (sporty and 8.6 or 8.4)
		c(V(len, sporty and 1.3 or 1.8, 4), V(0, sporty and 1.3 or 1.7, 0), body)
		if kind == "ambulance" then
			c(V(6.5, 3.4, 4), V(-1.6, 3.9, 0), body)
			c(V(0.3, 1.3, 3.4), V(1.9, 3.3, 0), glass, M.Glass)
			for _, sz in ipairs({ -2.02, 2.02 }) do
				c(V(1.6, 0.45, 0.05), V(-1.6, 4, sz), C3(220, 40, 50)); c(V(0.45, 1.6, 0.05), V(-1.6, 4, sz), C3(220, 40, 50))
				c(V(len, 0.35, 0.05), V(0, 2.3, sz), C3(220, 40, 50))
			end
		else
			local cab = c(V(sporty and 3.8 or 4.6, sporty and 1.1 or (tall and 1.7 or 1.4), 3.7), V(-0.4, sporty and 2.4 or (tall and 3.4 or 3.1), 0), glass, M.Glass)
			cab.Transparency = 0.15
			c(V(sporty and 3.6 or 4.4, 0.18, 3.75), V(-0.4, sporty and 3.0 or (tall and 4.3 or 3.85), 0), body)
		end
		if kind == "police" then
			c(V(len + 0.02, 0.9, 4.04), V(0.5, 1.8, 0), C3(25, 30, 45))                         -- dark door band
			c(V(0.6, 0.35, 1.2), V(-0.4, 4.55, 0.65), C3(40, 120, 255), M.Neon)                   -- light bar
			c(V(0.6, 0.35, 1.2), V(-0.4, 4.55, -0.65), C3(255, 50, 60), M.Neon)
		elseif kind == "ambulance" then
			c(V(0.6, 0.35, 1), V(1.2, 5.75, 0.6), C3(255, 50, 60), M.Neon); c(V(0.6, 0.35, 1), V(1.2, 5.75, -0.6), C3(40, 120, 255), M.Neon)
		end
		wheels({ -len * 0.3, len * 0.3 }, 1.95, tall and 1.9 or 1.7); lights(len, 1.9, 1.3)
	end
end
local function trafficLight(x, z, yaw)
	local base = CF(x, 0, z) * CFrame.Angles(0, yaw or 0, 0)
	P(V(0.4, 12, 0.4), base * CF(0, 6, 0), C3(45, 48, 55), M.Metal)
	P(V(0.3, 0.3, 6), base * CF(0, 11.6, 3), C3(45, 48, 55), M.Metal)
	P(V(1.2, 3.4, 1.1), base * CF(0, 10.6, 5.6), C3(30, 32, 38))
	for i, col in ipairs({ C3(255, 60, 50), C3(255, 190, 40), C3(60, 230, 110) }) do
		local lit = P(V(0.7, 0.7, 0.2), base * CF(0, 11.8 - i * 1.05, 6.17), col:Lerp(C3(0, 0, 0), i == 3 and 0 or 0.65), i == 3 and M.Neon or M.SmoothPlastic)
		lit.Shape = Enum.PartType.Block
	end
end
local function crosswalk(x)  -- across the road (road centre z = 9, width 16)
	for k = -3, 3 do P(V(1.2, 0.12, 14), CF(x + k * 2.2, 0.11, 9), C3(250, 250, 250)) end
end
-- big public buildings, fronts face +Z
local function hospital(x, z)
	local w, d, fz = 40, 18, z + 9
	P(V(w, 18, d), CF(x, 9, z), C3(240, 244, 248))
	for i = -4, 4 do for _, y in ipairs({ 4, 9.5, 15 }) do
		local g = P(V(3.4, 3, 0.2), CF(x + i * 4.2, y, fz + 0.12), C3(140, 195, 230), M.Glass); g.Transparency = 0.1
	end end
	P(V(w + 0.4, 1, d + 0.4), CF(x, 18.5, z), C3(255, 255, 255))
	P(V(12, 0.6, 6), CF(x, 6.2, fz + 3), C3(250, 250, 250))                                      -- entrance canopy
	P(V(0.5, 6, 0.5), CF(x - 5.5, 3, fz + 5.6), C3(200, 205, 210), M.Metal); P(V(0.5, 6, 0.5), CF(x + 5.5, 3, fz + 5.6), C3(200, 205, 210), M.Metal)
	P(V(6, 5, 0.25), CF(x, 2.5, fz + 0.15), C3(150, 200, 230), M.Glass)
	local cross = P(V(4, 4, 0.3), CF(x + 14, 14, fz + 0.3), C3(255, 255, 255))
	P(V(2.6, 0.8, 0.1), CF(x + 14, 14, fz + 0.5), C3(225, 40, 50), M.Neon); P(V(0.8, 2.6, 0.1), CF(x + 14, 14, fz + 0.5), C3(225, 40, 50), M.Neon)
	local s = P(V(14, 2, 0.3), CF(x - 8, 14, fz + 0.3), C3(255, 255, 255))
	sign(s, Enum.NormalId.Front, "CITY HOSPITAL", C3(255, 255, 255), C3(200, 40, 50))
	return fz
end
local function policeStation(x, z)
	local w, d, fz = 30, 16, z + 8
	P(V(w, 12, d), CF(x, 6, z), C3(232, 234, 238))
	P(V(w + 0.2, 1.4, d + 0.2), CF(x, 8.6, z), C3(30, 60, 140))                                  -- blue band
	for i = -3, 3 do local g = P(V(3, 3, 0.2), CF(x + i * 4, 4, fz + 0.12), C3(140, 180, 220), M.Glass); g.Transparency = 0.1 end
	P(V(5, 5, 0.25), CF(x, 2.5, fz + 0.15), C3(60, 90, 150), M.Glass)
	local s = P(V(12, 1.8, 0.3), CF(x, 10.6, fz + 0.2), C3(30, 60, 140))
	sign(s, Enum.NormalId.Front, "POLICE", C3(30, 60, 140), C3(255, 255, 255))
	light(P(V(0.6, 0.6, 0.6), CF(x - 7, 10.6, fz + 0.4), C3(60, 140, 255), M.Neon), C3(60, 140, 255), 10, 1)
	return fz
end
local function mall(x, z, name)
	local w, d, fz = 50, 20, z + 10
	P(V(w, 16, d), CF(x, 8, z), C3(236, 228, 214))
	local g = P(V(w - 6, 9, 0.2), CF(x, 5, fz + 0.15), C3(150, 200, 235), M.Glass); g.Transparency = 0.15
	light(P(V(w - 6.4, 8.8, 0.1), CF(x, 5, fz + 0.03), C3(255, 238, 210), M.Neon), C3(255, 220, 180), 20, 1)
	for i = -2, 2 do P(V(8, 0.6, 2.6), CF(x + i * 9.5, 9.9, fz + 1.3) * CFrame.Angles(math.rad(-12), 0, 0), ACCENT[(i % 5) + 1]) end
	local s = P(V(18, 2.6, 0.3), CF(x, 13.2, fz + 0.2), C3(40, 40, 50))
	sign(s, Enum.NormalId.Front, name or "SUNNY MALL", C3(40, 40, 50), C3(255, 210, 90))
	return fz
end
local function gasStation(x, z)
	P(V(22, 0.6, 14), CF(x, 10, z + 2), C3(250, 250, 250))                                       -- canopy
	P(V(22.2, 1, 14.2), CF(x, 9.5, z + 2), C3(235, 90, 40))
	for _, px in ipairs({ -6, 6 }) do
		P(V(0.8, 9.4, 0.8), CF(px + x, 4.7, z + 2), C3(220, 220, 225), M.Metal)
		P(V(1.6, 4, 1.2), CF(px + x, 2, z + 4.5), C3(240, 240, 240)); P(V(1.2, 1, 0.1), CF(px + x, 3, z + 5.15), C3(30, 30, 40), M.Neon)
	end
	light(P(V(18, 0.2, 10), CF(x, 9.15, z + 2), C3(255, 250, 240), M.Neon), C3(255, 245, 230), 18, 1)
	P(V(14, 7, 9), CF(x, 3.5, z - 9), C3(240, 240, 238))
	local g = P(V(10, 4, 0.2), CF(x, 3, z - 4.4), C3(150, 200, 235), M.Glass); g.Transparency = 0.15
	local s = P(V(10, 1.6, 0.3), CF(x, 6.2, z - 4.3), C3(235, 90, 40))
	sign(s, Enum.NormalId.Front, "QUICK GAS", C3(235, 90, 40), C3(255, 255, 255))
end
-- park with paths, gazebo, playground and benches; centre (x, z), about 50 x 40
local function park(x, z)
	P(V(50, 0.12, 40), CF(x, 0.06, z), C3(100, 180, 90), M.Grass)
	P(V(50, 0.16, 3.5), CF(x, 0.1, z), C3(215, 200, 170), M.Ground); P(V(3.5, 0.16, 40), CF(x, 0.1, z), C3(215, 200, 170), M.Ground)
	-- gazebo
	local gx, gz = x - 13, z - 10
	P(V(12, 0.6, 12), CF(gx, 0.3, gz), C3(230, 225, 215))
	for _, o in ipairs({ { -5, -5 }, { 5, -5 }, { -5, 5 }, { 5, 5 } }) do P(V(0.6, 7, 0.6), CF(gx + o[1], 3.9, gz + o[2]), C3(250, 250, 250)) end
	P(V(13, 0.6, 13), CF(gx, 7.6, gz), C3(250, 250, 250))
	P(V(9, 2.6, 9), CF(gx, 9.2, gz), C3(70, 110, 90)); P(V(5, 1.6, 5), CF(gx, 11.2, gz), C3(70, 110, 90))
	-- playground: slide tower + slide, swing frame
	local px, pz = x + 13, z - 10
	P(V(16, 0.2, 14), CF(px, 0.15, pz), C3(230, 120, 80), M.Fabric)
	P(V(4, 0.4, 4), CF(px - 3, 5, pz), C3(255, 200, 60)); for _, o in ipairs({ { -1.8, -1.8 }, { 1.8, -1.8 }, { -1.8, 1.8 }, { 1.8, 1.8 } }) do P(V(0.4, 5, 0.4), CF(px - 3 + o[1], 2.5, pz + o[2]), C3(60, 150, 230)) end
	P(V(4.2, 3.2, 4.2), CF(px - 3, 7.6, pz), C3(230, 60, 60), nil, nil, nil).Transparency = 0
	P(V(1.8, 0.3, 8), CF(px + 1, 2.6, pz) * CFrame.Angles(0, math.rad(90), math.rad(-32)), C3(255, 200, 60))
	P(V(0.3, 5, 0.3), CF(px + 5, 2.5, pz + 4), C3(60, 150, 230)); P(V(0.3, 5, 0.3), CF(px + 5, 2.5, pz - 4), C3(60, 150, 230))
	P(V(0.3, 0.3, 8.3), CF(px + 5, 5, pz), C3(60, 150, 230))
	for _, sz in ipairs({ -1.8, 1.8 }) do P(V(1, 0.15, 1.6), CF(px + 5, 1.6, pz + sz), C3(40, 40, 50)) end
	for _, bx in ipairs({ -20, 20 }) do bench(x + bx, z + 4) end
	for _, t in ipairs({ { -22, -18 }, { 22, -18 }, { -22, 16 }, { 22, 16 }, { 0, -18 } }) do tree(x + t[1], z + t[2]) end
	spot("Park", V(x, 0.2, z + 5), V(x, 0.2, z + 20))
end
local function basketballCourt(x, z)
	P(V(28, 0.15, 16), CF(x, 0.08, z), C3(50, 120, 200))
	P(V(26, 0.17, 14), CF(x, 0.09, z), C3(235, 120, 60))
	P(V(0.2, 0.19, 14), CF(x, 0.1, z), C3(255, 255, 255))
	for _, sx in ipairs({ -1, 1 }) do
		P(V(0.4, 9, 0.4), CF(x + sx * 13.6, 4.5, z), C3(220, 220, 225), M.Metal)
		P(V(0.2, 2.6, 4), CF(x + sx * 12.6, 9.2, z), C3(255, 255, 255))
		P(V(1.2, 0.15, 1.2), CF(x + sx * 12, 8.2, z), C3(240, 80, 40), M.Metal)
	end
	spot("Court", V(x, 0.2, z), V(x, 0.2, z + 20))
end

-- interior extras: neon gaming setups, bathroom, library
function K.ledStrip(x, y, z, len, axis, color)  -- axis "x" or "z"
	local p = P(axis == "z" and V(0.12, 0.12, len) or V(len, 0.12, 0.12), CF(x, y, z), color or C3(170, 80, 255), M.Neon)
	light(p, color or C3(170, 80, 255), 10, 0.8)
end
function K.gamerDesk(x, z, yaw, glow)  -- 3 monitors, RGB edge, keyboard, gaming chair
	glow = glow or C3(60, 190, 255)
	piece(x, z, yaw, {
		{ V(7, 0.3, 2.8), V(0, 2.8, 0), C3(25, 25, 30) }, { V(7, 0.08, 0.08), V(0, 2.95, -1.4), glow, M.Neon },
		{ V(0.3, 2.7, 2.4), V(-3.2, 1.35, 0), C3(25, 25, 30) }, { V(0.3, 2.7, 2.4), V(3.2, 1.35, 0), C3(25, 25, 30) },
		{ V(2.4, 1.5, 0.12), V(0, 4.2, 0.9), C3(15, 15, 18) }, { V(2.2, 1.3, 0.05), V(0, 4.2, 0.82), glow, M.Neon },
		{ V(2.2, 1.5, 0.12), V(-2.3, 4.2, 0.6), C3(15, 15, 18) }, { V(2, 1.3, 0.05), V(-2.3, 4.2, 0.52), C3(170, 80, 255), M.Neon },
		{ V(2.2, 1.5, 0.12), V(2.3, 4.2, 0.6), C3(15, 15, 18) }, { V(2, 1.3, 0.05), V(2.3, 4.2, 0.52), C3(255, 80, 180), M.Neon },
		{ V(2.2, 0.1, 0.7), V(0, 3.0, -0.5), C3(30, 30, 36) }, { V(2.1, 0.03, 0.6), V(0, 3.06, -0.5), glow, M.Neon },
		-- chair (faces the desk)
		{ V(2.2, 0.5, 2.2), V(0, 1.9, -2.6), C3(25, 25, 30) }, { V(2.2, 3.2, 0.5), V(0, 3.6, -3.6), C3(25, 25, 30) },
		{ V(1.4, 2.4, 0.1), V(0, 3.7, -3.33), glow, M.Neon }, { V(0.5, 1.6, 0.5), V(0, 0.8, -2.6), C3(60, 60, 66), M.Metal },
	})
end
function K.bathroom(x, z)  -- tub on the back wall, sink + mirror on the left wall (room x, z = centre)
	piece(x - 3, z - 5, 0, { { V(8, 2.4, 3.6), V(0, 1.2, 0), C3(250, 250, 252) }, { V(7.2, 0.2, 2.8), V(0, 2.3, 0), C3(170, 215, 235), M.Glass } })
	piece(x - 8.5, z + 1, 90, { { V(4, 3, 2), V(0, 1.5, 0), C3(250, 250, 250) }, { V(2, 0.4, 1.4), V(0, 3.05, 0), C3(225, 230, 235), M.Marble },
		{ V(4, 3, 0.1), V(0, 5.6, -0.95), C3(200, 225, 240), M.Glass } })
	P(V(2.2, 0.06, 3), CF(x - 5, 0.04, z + 2), C3(120, 190, 220), M.Fabric)
end
function K.bookWall(x, z, yaw, w)  -- tall shelf full of coloured books (library)
	w = w or 10
	local parts = { { V(w, 9, 1.4), V(0, 4.5, 0), C3(150, 105, 65), M.Wood } }
	local rng = Random.new(3)
	for row = 0, 4 do
		local bx = -w / 2 + 0.4
		while bx < w / 2 - 0.5 do
			local bw = rng:NextNumber(0.25, 0.45)
			table.insert(parts, { V(bw, rng:NextNumber(1, 1.4), 1), V(bx + bw / 2, 1 + row * 1.75, 0.3), ACCENT[rng:NextInteger(1, 5)] })
			bx += bw + 0.03
		end
	end
	piece(x, z, yaw, parts)
end

---------------------------------------------------------------- KIT: lighting look
local function lookModern(clock)
	Lighting.ClockTime = clock or 14
	Lighting.Brightness = 2.2
	Lighting.ExposureCompensation = -0.35 -- white walls blew out at 0 (first Studio test)
	Lighting.Ambient = C3(70, 70, 80)
	Lighting.OutdoorAmbient = C3(140, 140, 155)
	Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale = 0.6, 0.5
	Lighting.GlobalShadows = true
	local function fx(class) return Lighting:FindFirstChildOfClass(class) or Instance.new(class, Lighting) end
	local a = fx("Atmosphere"); a.Density, a.Haze, a.Glare = 0.28, 0.8, 0.2
	a.Color, a.Decay = C3(199, 220, 240), C3(120, 150, 190)
	local cc = fx("ColorCorrectionEffect"); cc.Saturation, cc.Contrast, cc.Brightness = 0.22, 0.12, -0.03
	local b = fx("BloomEffect"); b.Intensity, b.Size, b.Threshold = 0.3, 20, 2.2
	local sr = fx("SunRaysEffect"); sr.Intensity, sr.Spread = 0.05, 0.7
end

---------------------------------------------------------------- KIT: house style (user's picks, Nov 2026)
-- The channel's character look. Change here to restyle every actor at once.
--   body: "classic" = blocky R6 cast with drawn faces (the user's reference shorts, the
--         current house style; see CL.build / REF) | "chibi" | "r15" (older R15 + presets)
--   face: "anime" (big eyes, two highlights) | "classic"
--   hair: "spiky" (anime spikes; presets' hair colours kept) | "messy"
local STYLE = { body = "classic", face = "anime", hair = "spiky" }

---------------------------------------------------------------- KIT: classic blocky cast (house style)
-- Matches the user's reference shorts (Nov 2026): classic R6 block bodies with the rounded
-- Roblox head, BIG hand-drawn 2D faces, clothes painted on the blocks like Roblox shirt
-- textures, sculpted chunky hair. Built from ChatGPT's ReferenceCast rig (hand-made R6 with
-- six Motor6Ds), improved: bold switchable faces, sculpted hair, knit/floral fabric.
-- Uses only basic parts + the built-in head mesh: nothing is downloaded.
local INK, TEETH = C3(30, 24, 26), C3(255, 253, 244)
local CL = {}

local function cpart(m, name, size, cf, color, mat)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
	p.Material = mat or M.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.CanCollide, p.Massless, p.CastShadow = false, true, true
	p.Parent = m
	return p
end
-- weld a decoration to a body part at a local offset (front = -Z)
local function deco(m, base, name, size, off, color, shape, mat, class)
	local p = Instance.new(class or "Part")
	p.Name, p.Size, p.Color = name, size, color
	p.Material = mat or M.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.CanCollide, p.Massless, p.CastShadow = false, true, true
	if shape then p.Shape = shape end
	p.CFrame = base.CFrame * off
	local w = Instance.new("Weld")
	w.Part0, w.Part1, w.C0 = base, p, off
	w.Parent = p
	p.Parent = m
	return p
end
local function headMesh(p, scale)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType, mesh.Scale = Enum.MeshType.Head, scale
	mesh.Parent = p
end

-- 2D drawing on a SurfaceGui: px canvas, frames for blobs, rotated bars for lines
local function surf(part, face, w, h, name)
	local g = Instance.new("SurfaceGui")
	g.Name, g.Face, g.CanvasSize, g.LightInfluence = name or "Print", face, Vector2.new(w, h), 0.4
	g.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
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
local function curve(parent, pts, col, th) for i = 1, #pts - 1 do bar(parent, pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], col, th) end end
local function arc(parent, cx, cy, rx, ry, a0, a1, col, th, n)
	local pts = {}
	n = n or 10
	for i = 0, n do local a = a0 + (a1 - a0) * i / n; table.insert(pts, { cx + rx * math.cos(a), cy + ry * math.sin(a) }) end
	curve(parent, pts, col, th)
end
local function ring(parent, x, y, r, col, th)
	local f = blob(parent, x, y, r * 2, r * 2, col, 1)
	f.BackgroundTransparency = 1
	local s = Instance.new("UIStroke"); s.Color, s.Thickness = col, th; s.Parent = f
	return f
end
local function text(parent, s, x, y, w, h, col, size)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency, t.AnchorPoint = 1, Vector2.new(0.5, 0.5)
	t.Position, t.Size, t.Text, t.TextColor3, t.TextSize = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h), s, col, size
	t.Font = Enum.Font.FredokaOne
	t.Parent = parent
	return t
end

---------------------------------------------------------------- faces
-- Canvas 300 x 300 px on a face plate covering the front of the head (1.2 x 1.2 studs).
-- Big features like the references: eyes ~1/7 of the head wide, mouth up to half the head.
local EX = { 98, 202 }  -- eye centres (x), eye line y = 150
local FACE = {}
local function eyes(g, kind, iris)
	for i, x in ipairs(EX) do
		local s = (i == 1) and -1 or 1
		if kind == "closed" then      -- ^ ^ happy
			arc(g, x, 160, 26, 22, math.pi * 1.05, math.pi * 1.95, INK, 9)
		elseif kind == "spiral" then  -- dizzy @ @
			for r = 1, 3 do ring(g, x + r * 2, 148 - r, r * 10 + 2, INK, 5) end
		elseif kind == "round" then   -- shocked: white eye, tiny pupil
			blob(g, x, 150, 52, 60, TEETH, 1); ring(g, x, 150, 28, INK, 6); blob(g, x, 152, 14, 16, INK, 1)
		elseif kind == "half" then    -- smug / stern: eye with a heavy lid
			blob(g, x, 156, 34, 30, INK, 0.5); bar(g, x - 24, 142, x + 24, 142, INK, 9)
			blob(g, x - 6, 152, 9, 9, TEETH, 1)
		else                          -- normal oval eyes with two highlights
			blob(g, x, 150, 32, 52, INK, 1)
			if iris then blob(g, x, 160, 22, 26, iris, 1) end
			blob(g, x - 7, 138, 11, 14, TEETH, 1); blob(g, x + 7, 164, 6, 6, TEETH, 1)
		end
	end
end
local function brows(g, kind)
	for i, x in ipairs(EX) do
		local s = (i == 1) and -1 or 1          -- -1 left eye, +1 right eye (viewer's view)
		-- s = -1 for the left eye: x - 30*s is the INNER end (toward the nose)
		if kind == "angry" then bar(g, x - 30 * s, 114, x + 24 * s, 90, INK, 13)        -- inner end low
		elseif kind == "worried" then bar(g, x - 26 * s, 90, x + 24 * s, 110, INK, 9)    -- inner end high
		elseif kind == "raised" then arc(g, x, 108, 26, 12, math.pi * 1.1, math.pi * 1.9, INK, 8, 6)
		elseif kind == "smug" then if i == 1 then bar(g, x - 26, 106, x + 24, 100, INK, 9) else arc(g, x, 96, 26, 14, math.pi * 1.1, math.pi * 1.9, INK, 8, 6) end
		else bar(g, x - 22, 104, x + 22, 100 + (i == 1 and 4 or 0), INK, 8) end
	end
end
local function mouth(g, kind)
	if kind == "grin" then           -- big toothy D-grin
		local f = blob(g, 150, 228, 150, 62, INK, 0.45)
		blob(g, 150, 220, 132, 30, TEETH, 0.3)
		bar(g, 88, 222, 212, 222, INK, 4)
		for x = 112, 188, 25 do bar(g, x, 207, x, 236, INK, 3) end
	elseif kind == "teeth" then      -- gritted teeth (worried / awkward)
		blob(g, 150, 226, 116, 40, INK, 0.2); blob(g, 150, 226, 104, 30, TEETH, 0.15)
		bar(g, 100, 226, 200, 226, INK, 3); for x = 112, 188, 19 do bar(g, x, 213, x, 239, INK, 3) end
	elseif kind == "smile" then
		arc(g, 150, 196, 58, 38, math.pi * 0.15, math.pi * 0.85, INK, 9)
	elseif kind == "frown" then
		arc(g, 150, 252, 46, 26, math.pi * 1.15, math.pi * 1.85, INK, 9)
	elseif kind == "o" then
		blob(g, 150, 230, 38, 46, INK, 1); blob(g, 150, 236, 22, 20, C3(190, 70, 80), 1)
	elseif kind == "smirk" then
		curve(g, { { 104, 226 }, { 150, 230 }, { 186, 218 }, { 200, 206 } }, INK, 8)
	elseif kind == "wavy" then
		curve(g, { { 106, 228 }, { 124, 216 }, { 142, 230 }, { 160, 216 }, { 178, 230 }, { 196, 218 } }, INK, 7)
	else
		bar(g, 120, 226, 180, 226, INK, 8)
	end
end
local function cheeks(g) for _, x in ipairs({ 60, 240 }) do blob(g, x, 196, 40, 18, C3(240, 150, 150), 1).BackgroundTransparency = 0.25 end end
-- expression = eyes + brows + mouth (+ blush)
local EXPRESSIONS = {
	smile = { "oval", "soft", "smile", true }, grin = { "oval", "raised", "grin", true },
	laugh = { "closed", "raised", "grin", true }, happy = { "closed", "soft", "smile", true },
	angry = { "half", "angry", "frown", false }, stern = { "half", "angry", "flat", false },
	worried = { "oval", "worried", "teeth", false }, dizzy = { "spiral", "worried", "wavy", false },
	shocked = { "round", "raised", "o", false }, smug = { "half", "smug", "smirk", false },
	sad = { "oval", "worried", "frown", false }, neutral = { "oval", "soft", "flat", false },
}
-- builds every expression on the face plate (only the chosen one visible); the client swaps
-- them per shot with face(name, expression)
function CL.face(m, head, default, o)
	local plate = deco(m, head, "FacePlate", V(1.2, 1.2, 0.04), CF(0, -0.02, -0.64), C3(255, 255, 255))
	plate.Transparency, plate.CastShadow = 1, false
	local g = surf(plate, Enum.NormalId.Front, 300, 300, "Face")
	for name, e in pairs(EXPRESSIONS) do
		local layer = Instance.new("Frame")
		layer.Name, layer.BackgroundTransparency, layer.Size, layer.Visible = name, 1, UDim2.fromScale(1, 1), name == default
		layer.Parent = g
		eyes(layer, e[1], o.iris); brows(layer, e[2]); mouth(layer, e[3])
		if e[4] and o.blush ~= false then cheeks(layer) end
	end
	if o.glasses then  -- glasses stay on top of every expression
		for _, x in ipairs(EX) do ring(g, x, 150, 40, INK, 6) end
		bar(g, 138, 146, 162, 146, INK, 6)
	end
	m:SetAttribute("Expression", default)
end

---------------------------------------------------------------- hair
-- A smooth cap (a slightly bigger head mesh pushed up and back, so it never hides the eyes)
-- plus wedge locks: fringe over the forehead, side locks, tousled tips. front = -Z.
local function wedge(m, head, name, size, off, col)
	return deco(m, head, name, size, off, col, nil, M.SmoothPlastic, "WedgePart")
end
function CL.hair(m, head, style, col, rng)
	local cap = deco(m, head, "HairCap", V(2, 1, 1), CF(0, 0.3, 0.07), col)
	headMesh(cap, V(1.34, 0.95, 1.34))
	if style == "tousled" or style == "swept" or style == "baby" then
		local n = (style == "baby") and 4 or 9
		for k = 1, n do  -- fringe locks hanging forward and down (wedge slope faces forward)
			local x = -0.52 + (k - 1) * (1.04 / (n - 1))
			local a = rng:NextNumber(-0.35, 0.35)
			wedge(m, head, "Fringe" .. k, V(0.26, 0.42, 0.3), CF(x, 0.36 + rng:NextNumber(-0.04, 0.05), -0.6) * CFrame.Angles(math.rad(180), 0, a), col)
		end
		local tips = (style == "baby") and 3 or 8
		for k = 1, tips do  -- messy tips on top
			local a = (k / tips) * math.pi * 2
			wedge(m, head, "Tip" .. k, V(0.3, 0.5, 0.36), CF(math.cos(a) * 0.38, 0.72, math.sin(a) * 0.32 + 0.05)
				* CFrame.Angles(math.sin(a) * 0.6, a, -math.cos(a) * 0.6), col)
		end
		if style == "swept" then  -- tall chef quiff swept up and back
			for k = -2, 2 do wedge(m, head, "Quiff" .. k, V(0.3, 0.75, 0.6), CF(k * 0.22, 0.85, -0.2) * CFrame.Angles(math.rad(-25), 0, k * 0.15), col) end
		end
		for _, sx in ipairs({ -1, 1 }) do wedge(m, head, "SideLock", V(0.18, 0.5, 0.5), CF(sx * 0.66, 0.12, 0.02) * CFrame.Angles(math.rad(180), 0, 0), col) end
	else  -- long / bob / bun: smooth parted hair
		for k = 1, 6 do  -- straight fringe
			local x = -0.5 + (k - 1) * 0.2
			deco(m, head, "Fringe" .. k, V(0.24, 0.3, 0.16), CF(x, 0.4 - math.abs(x) * 0.12, -0.6), col)
		end
		local len = (style == "long") and 2.2 or ((style == "bob") and 1.0 or 0)
		if len > 0 then
			for _, sx in ipairs({ -1, 1 }) do
				deco(m, head, "SideHair", V(0.28, len, 0.9), CF(sx * 0.68, 0.45 - len / 2, 0.05), col)
				for j = 0, 3 do  -- wavy strands on the side panels
					deco(m, head, "Strand", V(0.08, len * 0.9, 0.06), CF(sx * 0.83, 0.45 - len / 2, -0.3 + j * 0.2), col:Lerp(INK, 0.15))
				end
			end
			deco(m, head, "BackHair", V(1.36, len, 0.3), CF(0, 0.45 - len / 2, 0.58), col)
		end
		if style == "bun" then
			local bun = deco(m, head, "Bun", V(0.95, 0.75, 0.95), CF(0, 0.85, 0.25), col, Enum.PartType.Ball)
			-- one band around the bun (cylinder axis is X, so stand it up in the weld offset)
			deco(m, head, "BunBand", V(0.1, 0.86, 0.86), CF(0, 0.82, 0.25) * CFrame.Angles(0, 0, math.rad(90)), col:Lerp(INK, 0.12), Enum.PartType.Cylinder)
		end
	end
end

---------------------------------------------------------------- fabric prints
local function paint(part, faces, draw)
	for _, f in ipairs(faces) do draw(surf(part, f, 200, 200, "Print_" .. f.Name)) end
end
local ALLFACES = { Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right }
local function knit(g, col)  -- vertical cable-knit ribs
	for x = 12, 200, 20 do
		local r = blob(g, x, 100, 4, 200, col:Lerp(INK, 0.12), 0.5); r.BackgroundTransparency = 0.7
	end
end
local function floral(g, base, petal, centre, leaf, seed, count)
	local rng = Random.new(seed)
	for _ = 1, count or 16 do
		local x, y = rng:NextInteger(10, 190), rng:NextInteger(10, 190)
		local s = rng:NextNumber(0.8, 1.4)
		blob(g, x - 14 * s, y + 8 * s, 22 * s, 9 * s, leaf, 0.5, -30)
		for k = 0, 4 do local a = k * math.pi * 2 / 5; blob(g, x + math.cos(a) * 8 * s, y + math.sin(a) * 8 * s, 13 * s, 13 * s, petal, 1) end
		blob(g, x, y, 8 * s, 8 * s, centre, 1)
	end
end
local function denim(g, col)
	for y = 8, 200, 9 do local l = blob(g, 100, y, 200, 2, col:Lerp(C3(255, 255, 255), 0.2), 0); l.BackgroundTransparency = 0.6 end
	local seam = blob(g, 60, 100, 3, 200, C3(230, 190, 110), 0); seam.BackgroundTransparency = 0.3
end

---------------------------------------------------------------- the rig + outfits
-- CL.build(name, o): o = { skin, shirt, pants, sleeves ("short"|"long"), hair, hairStyle,
--   expression, scale, iris, glasses, knit, floral = {petal, centre, leaf}, denim, apron,
--   chef, collar, skirt, bow, shoeColor, shirtText }
function CL.build(name, o)
	local m = Instance.new("Model")
	m.Name = name
	local function bp(n, s, pos, c) return cpart(m, n, s, CF(pos), c) end
	local skin, shirt, pants = o.skin or C3(247, 210, 160), o.shirt or C3(240, 240, 240), o.pants or C3(40, 45, 60)
	local hrp = bp("HumanoidRootPart", V(2, 2, 1), V(0, 3, 0), shirt); hrp.Transparency, hrp.Anchored = 1, true
	m.PrimaryPart = hrp
	local torso = bp("Torso", V(2, 2, 1), V(0, 3, 0), shirt)
	torso.Material = (o.knit and M.Fabric) or M.SmoothPlastic
	local head = bp("Head", V(2, 1, 1), V(0, 4.5, 0), skin)
	headMesh(head, V(1.22, 1.25, 1.22))
	local long = o.sleeves == "long"
	local la = bp("Left Arm", V(1, 2, 1), V(-1.5, 3, 0), long and shirt or skin)
	local ra = bp("Right Arm", V(1, 2, 1), V(1.5, 3, 0), long and shirt or skin)
	local ll = bp("Left Leg", V(1, 2, 1), V(-0.5, 1, 0), pants)
	local rl = bp("Right Leg", V(1, 2, 1), V(0.5, 1, 0), pants)
	local function joint(n, a, b, c0, c1) local j = Instance.new("Motor6D"); j.Name, j.Part0, j.Part1, j.C0, j.C1 = n, a, b, c0, c1; j.Parent = a end
	joint("RootJoint", hrp, torso, CF(), CF())
	joint("Neck", torso, head, CF(0, 1, 0), CF(0, -0.5, 0))
	joint("Left Shoulder", torso, la, CF(-1, 1, 0), CF(0.5, 1, 0)); joint("Right Shoulder", torso, ra, CF(1, 1, 0), CF(-0.5, 1, 0))
	joint("Left Hip", torso, ll, CF(-0.5, -1, 0), CF(0, 1, 0)); joint("Right Hip", torso, rl, CF(0.5, -1, 0), CF(0, 1, 0))
	-- sleeves (short sleeves = shirt cuff over the upper arm) and hands for long sleeves
	for _, arm in ipairs({ la, ra }) do
		if long then
			deco(m, arm, "Hand", V(1.02, 0.44, 1.02), CF(0, -0.8, 0), skin)
			deco(m, arm, "Cuff", V(1.05, 0.14, 1.05), CF(0, -0.55, 0), shirt:Lerp(INK, 0.12), nil, o.knit and M.Fabric or nil)
		else
			deco(m, arm, "Sleeve", V(1.05, o.chef and 1.38 or 1.04, 1.05), CF(0, 0.51, 0), shirt, nil, o.knit and M.Fabric or nil)
		end
	end
	local ARMFACES = { Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right }
	for _, leg in ipairs({ ll, rl }) do
		deco(m, leg, "Shoe", V(1.03, 0.34, 1.2), CF(0, -0.84, -0.09), o.shoeColor or C3(40, 40, 45))
		deco(m, leg, "Sole", V(1.05, 0.12, 1.22), CF(0, -0.98, -0.09), C3(235, 228, 213))
	end
	-- prints on the clothes
	if o.knit then
		paint(torso, ALLFACES, function(g) knit(g, shirt) end)
		if long then for _, a in ipairs({ la, ra }) do paint(a, ARMFACES, function(g) knit(g, shirt) end) end end
	end
	if o.floral then
		local f = o.floral
		paint(torso, ALLFACES, function(g) floral(g, shirt, f[1], f[2], f[3], #name * 13, 18) end)
		if long then for i, a in ipairs({ la, ra }) do paint(a, ARMFACES, function(g) floral(g, shirt, f[1], f[2], f[3], i * 31, 9) end) end end
	end
	if o.denim then for _, l in ipairs({ ll, rl }) do paint(l, { Enum.NormalId.Front, Enum.NormalId.Back }, function(g) denim(g, pants) end) end end
	if o.shirtText then
		paint(torso, { Enum.NormalId.Front }, function(g) text(g, o.shirtText, 100, 90, 190, 80, C3(250, 250, 245), 40) end)
	end
	if o.chef then
		paint(torso, { Enum.NormalId.Front }, function(g)
			curve(g, { { 64, 6 }, { 100, 40 }, { 140, 6 } }, C3(150, 148, 130), 4)
			bar(g, 92, 40, 92, 196, C3(180, 178, 160), 3)
			for _, x in ipairs({ 66, 134 }) do for _, y in ipairs({ 62, 100, 140, 178 }) do blob(g, x, y, 11, 11, C3(60, 60, 55), 1) end end
		end)
	end
	if o.apron then
		local ap = o.apron
		deco(m, torso, "ApronBib", V(1.5, 1.5, 0.06), CF(0, -0.2, -0.535), ap[1])
		for _, x in ipairs({ -0.62, 0.62 }) do deco(m, torso, "ApronStrap", V(0.16, 1.7, 0.08), CF(x, 0.2, -0.55), ap[2]) end
		deco(m, torso, "ApronPocket", V(0.7, 0.42, 0.06), CF(0, -0.58, -0.575), ap[1]:Lerp(INK, 0.06))
		for j = 1, 4 do deco(m, torso, "ApronDot", V(0.08, 0.08, 0.04), CF(-0.5 + (j - 1) * 0.33, -0.2, -0.575), j % 2 == 0 and C3(230, 186, 64) or C3(164, 126, 187), Enum.PartType.Ball) end
	end
	if o.collar then for _, x in ipairs({ -0.3, 0.3 }) do deco(m, torso, "Collar", V(0.55, 0.24, 0.08), CF(x, 0.9, -0.54) * CFrame.Angles(0, 0, x * 0.6), o.collar, Enum.PartType.Ball) end end
	if o.skirt then deco(m, torso, "Skirt", V(2.12, 0.85, 1.1), CF(0, -1.25, 0), o.skirt, nil, M.Fabric) end
	if o.bow then
		for _, x in ipairs({ -0.23, 0.23 }) do deco(m, torso, "Bow", V(0.46, 0.26, 0.1), CF(x, 0.55, -0.57) * CFrame.Angles(0, 0, x), o.bow, Enum.PartType.Ball) end
		deco(m, torso, "BowKnot", V(0.16, 0.18, 0.12), CF(0, 0.55, -0.6), o.bow:Lerp(INK, 0.1), Enum.PartType.Ball)
	end
	CL.face(m, head, o.expression or "smile", o)
	CL.hair(m, head, o.hairStyle or "tousled", o.hair or C3(70, 40, 25), Random.new(#name * 17))
	local hum = Instance.new("Humanoid")
	hum.DisplayDistanceType, hum.RequiresNeck = Enum.HumanoidDisplayDistanceType.None, false
	hum.HipHeight = 0
	hum.Parent = m
	m.Parent = workspace
	if o.scale and o.scale ~= 1 then m:ScaleTo(o.scale) end
	m:SetAttribute("RootHeight", 3 * (o.scale or 1))  -- client stands the rig on the floor with this
	m:SetAttribute("Rig", "classic")
	m:PivotTo(CF(0, -200, 0))
	task.wait(0.15)
	return m
end

-- The reference cast (from ChatGPT's ReferenceCast, restyled). Use as-is or as recipes.
local REF = {
	Milo = { skin = C3(247, 210, 151), shirt = C3(255, 249, 232), pants = C3(220, 45, 55), hair = C3(92, 48, 30), hairStyle = "tousled", expression = "grin", scale = 0.94, apron = { C3(255, 240, 225), C3(235, 110, 150) } },
	Rose = { skin = C3(248, 218, 173), shirt = C3(52, 110, 78), pants = C3(33, 31, 41), sleeves = "long", hair = C3(230, 228, 216), hairStyle = "bun", expression = "laugh", scale = 1.06, floral = { C3(240, 232, 170), C3(210, 160, 80), C3(130, 175, 110) }, skirt = C3(33, 31, 41) },
	Lily = { skin = C3(249, 216, 177), shirt = C3(236, 165, 182), pants = C3(110, 135, 160), sleeves = "long", hair = C3(96, 52, 32), hairStyle = "long", expression = "smile", scale = 0.8, floral = { C3(252, 228, 222), C3(220, 150, 160), C3(150, 180, 130) }, denim = true, bow = C3(255, 232, 225) },
	Andre = { skin = C3(137, 88, 48), shirt = C3(250, 247, 230), pants = C3(33, 37, 41), sleeves = "long", hair = C3(232, 178, 42), hairStyle = "swept", expression = "stern", scale = 1.08, chef = true },
	Noah = { skin = C3(241, 209, 167), shirt = C3(28, 32, 42), pants = C3(26, 29, 37), sleeves = "long", hair = C3(24, 24, 30), hairStyle = "tousled", expression = "grin", glasses = true },
	Pip = { skin = C3(250, 222, 190), shirt = C3(32, 37, 46), pants = C3(232, 238, 240), hair = C3(232, 238, 242), hairStyle = "baby", expression = "laugh", scale = 0.5, shirtText = "LITTLE BUDDY", shoeColor = C3(250, 250, 245) },
	Claire = { skin = C3(248, 224, 183), shirt = C3(112, 145, 218), pants = C3(245, 239, 215), sleeves = "long", knit = true, hair = C3(227, 212, 112), hairStyle = "bob", expression = "angry", collar = C3(198, 186, 230) },
}

---------------------------------------------------------------- KIT: cozy story sets (from the reference shorts)
-- Warm cream/yellow rooms with beige carpet and wooden furniture, a restaurant entrance,
-- and a playground (orange wood chips, red/blue swing set, white picket fence, low-poly
-- pines, mountains, a red house). Rooms use room(); these add the props.
local WOOD2, CARPET, CREAM, SUNNY = C3(170, 110, 60), C3(205, 186, 156), C3(246, 232, 196), C3(244, 214, 138)
function K.woodTable(x, z, w, d, h)
	w, d, h = w or 8, d or 4, h or 2.8
	P(V(w, 0.3, d), CF(x, h, z), WOOD2, M.Wood)
	for _, sx in ipairs({ -1, 1 }) do for _, sz in ipairs({ -1, 1 }) do P(V(0.35, h, 0.35), CF(x + sx * (w / 2 - 0.4), h / 2, z + sz * (d / 2 - 0.4)), WOOD2:Lerp(INK, 0.15), M.Wood) end end
end
function K.pot(x, y, z, col, s)  -- cooking pot / mixing bowl (cylinders stood up)
	s = s or 1
	P(V(1.3 * s, 1.8 * s, 1.8 * s), CF(x, y + 0.65 * s, z) * CFrame.Angles(0, 0, math.rad(90)), col or C3(220, 60, 45), M.SmoothPlastic, nil, nil, Enum.PartType.Cylinder)
	P(V(0.08, 1.6 * s, 1.6 * s), CF(x, y + 1.31 * s, z) * CFrame.Angles(0, 0, math.rad(90)), C3(250, 210, 90), M.SmoothPlastic, nil, nil, Enum.PartType.Cylinder)
end
function K.bowl(x, y, z, s)
	s = s or 1
	P(V(0.9 * s, 1.7 * s, 1.7 * s), CF(x, y + 0.45 * s, z) * CFrame.Angles(0, 0, math.rad(90)), C3(250, 250, 248), M.SmoothPlastic, nil, nil, Enum.PartType.Cylinder)
end
function K.board(x, y, z) P(V(2.2, 0.15, 1.4), CF(x, y + 0.08, z), C3(205, 160, 105), M.Wood); P(V(0.6, 0.6, 0.6), CF(x + 0.3, y + 0.45, z), C3(240, 220, 80), nil, nil, nil, Enum.PartType.Ball) end
function K.frame(x, y, z, col, yaw)  -- picture frame on a wall
	local base = CF(x, y, z) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	P(V(3, 2.6, 0.15), base, INK)
	P(V(2.6, 2.2, 0.06), base * CF(0, 0, 0.08), col or C3(110, 170, 220))  -- picture faces +Z (into the room)
end
function K.chalkboard(x, y, z, yaw)
	local base = CF(x, y, z) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	P(V(8.4, 4.4, 0.2), base, WOOD2, M.Wood)
	P(V(8, 4, 0.08), base * CF(0, 0, 0.12), C3(50, 95, 70), M.Slate)
end
function K.doorway(x, z, yaw, col)  -- door frame with a closed door (back or side wall)
	local base = CF(x, 0, z) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	P(V(4.4, 8, 0.3), base * CF(0, 4, 0), C3(245, 245, 240))
	P(V(3.6, 7.4, 0.32), base * CF(0, 3.7, -0.05), col or C3(150, 100, 60), M.Wood)
	P(V(0.2, 0.2, 0.3), base * CF(1.3, 3.6, -0.25), C3(220, 190, 90), M.Metal)
end
-- restaurant entrance: wood panel wall, glass double doors with yellow bar handles, runner
function K.restaurantEntrance(x, z)
	P(V(20, 11, 0.6), CF(x, 5.5, z), C3(120, 70, 40), M.WoodPlanks)
	-- the entrance faces +Z (toward the camera / into the room)
	for _, sx in ipairs({ -1, 1 }) do
		P(V(4, 9, 0.4), CF(x + sx * 2.05, 4.5, z + 0.4), C3(40, 50, 45))
		local g = P(V(3.2, 7.8, 0.1), CF(x + sx * 2.05, 4.6, z + 0.62), C3(200, 225, 170), M.Glass); g.Transparency = 0.35
		P(V(0.25, 3.6, 0.25), CF(x + sx * 0.6, 4.6, z + 0.9), C3(240, 200, 40), M.Metal)
	end
	P(V(6, 0.06, 16), CF(x, 0.04, z + 8), C3(170, 40, 35), M.Fabric)
	for _, sx in ipairs({ -1, 1 }) do P(V(0.35, 0.07, 16), CF(x + sx * 2.6, 0.05, z + 8), C3(240, 190, 50), M.Fabric) end
	light(P(V(1.6, 0.7, 1.6), CF(x + 5, 9.2, z + 3), C3(120, 170, 100), M.SmoothPlastic), C3(255, 220, 170), 14, 0.8)
end
-- low-poly pine: three square tiers turned 45 degrees + trunk
local function pine(x, z, s)
	s = s or 1
	P(V(0.8, 3, 0.8) * s, CF(x, 1.5 * s, z), C3(110, 75, 45), M.Wood)
	for i, w in ipairs({ 5.5, 4.2, 2.8 }) do
		P(V(w, 2.2, w) * s, CF(x, (2.4 + i * 1.7) * s, z) * CFrame.Angles(0, math.rad(45 * i), 0), C3(40, 120, 85):Lerp(C3(70, 160, 100), i / 4))
	end
end
local function picketFence(x0, x1, z)
	P(V(x1 - x0, 0.4, 0.2), CF((x0 + x1) / 2, 1.4, z), C3(245, 245, 245)); P(V(x1 - x0, 0.4, 0.2), CF((x0 + x1) / 2, 2.8, z), C3(245, 245, 245))
	for x = x0, x1, 1.1 do
		P(V(0.7, 3.6, 0.15), CF(x, 1.8, z + 0.15), C3(250, 250, 250))
		P(V(0.5, 0.5, 0.15), CF(x, 3.7, z + 0.15) * CFrame.Angles(0, 0, math.rad(45)), C3(250, 250, 250))
	end
end
local function mountains(x, z)
	for i, mnt in ipairs({ { -60, 70, 55 }, { -10, 95, 70 }, { 45, 80, 60 }, { 95, 65, 50 } }) do
		local w, h = mnt[2], mnt[3]
		local b = P(V(w, h, w * 0.6), CF(x + mnt[1], h / 2 - 4, z) * CFrame.Angles(0, math.rad(45), 0), C3(120, 140, 160))
		b.CastShadow = false
		P(V(w * 0.38, h * 0.3, w * 0.24), CF(x + mnt[1], h * 0.8 - 4, z) * CFrame.Angles(0, math.rad(45), 0), C3(240, 245, 250)).CastShadow = false
	end
end
local function redHouse(x, z)
	P(V(16, 10, 12), CF(x, 5, z), C3(170, 50, 45), M.Brick)
	for _, bx in ipairs({ -7.9, 7.9 }) do P(V(0.4, 10, 0.4), CF(x + bx, 5, z + 6.1), C3(245, 240, 230)) end
	P(V(16.2, 0.5, 0.4), CF(x, 9.8, z + 6.1), C3(245, 240, 230)); P(V(16.2, 0.5, 0.4), CF(x, 5.2, z + 6.1), C3(245, 240, 230))
	for _, wx in ipairs({ -4, 4 }) do
		light(P(V(2.6, 2.8, 0.2), CF(x + wx, 7.4, z + 6.05), C3(255, 220, 90), M.Neon), C3(255, 210, 120), 10, 0.6)
		P(V(0.2, 2.8, 0.25), CF(x + wx, 7.4, z + 6.15), C3(60, 40, 30)); P(V(2.6, 0.2, 0.25), CF(x + wx, 7.4, z + 6.15), C3(60, 40, 30))
	end
	P(V(18, 4, 7), CF(x, 12, z + 3.2) * CFrame.Angles(math.rad(-30), 0, 0), C3(60, 40, 40))
	P(V(18, 4, 7), CF(x, 12, z - 3.2) * CFrame.Angles(math.rad(30), 0, 0), C3(60, 40, 40))
	P(V(0.4, 7, 0.4), CF(x + 10, 3.5, z + 8), C3(40, 40, 45), M.Metal)                                -- lamp post
	light(P(V(1, 1.4, 1), CF(x + 10, 7.4, z + 8), C3(255, 230, 150), M.Neon), C3(255, 220, 150), 12, 0.8)
end
-- playground centred at (x, z): wood chips, swing set (seats at x - 4 and x + 4), fence,
-- pines, red house and mountains behind. Spot "Playground" faces +Z (camera side).
local function playground(x, z)
	P(V(70, 1, 60), CF(x, -0.5, z - 8), C3(110, 175, 90), M.Grass)
	P(V(34, 0.2, 24), CF(x, 0.1, z), C3(214, 118, 68), M.Sand)
	for _, sx in ipairs({ -1, 1 }) do P(V(0.8, 0.6, 24), CF(x + sx * 17, 0.3, z), C3(150, 100, 60), M.Wood) end
	-- swing set along X: red top bar, blue A-frame legs, two swings
	P(V(16, 0.7, 0.7), CF(x, 9, z - 2), C3(210, 40, 40), M.Metal)
	for _, sx in ipairs({ -1, 1 }) do for _, sz in ipairs({ -1, 1 }) do
		P(V(0.5, 9.5, 0.5), CF(x + sx * 7.6, 4.5, z - 2 + sz * 1.6) * CFrame.Angles(math.rad(sz * 10), 0, 0), C3(40, 90, 200), M.Metal)
	end end
	for i, sx in ipairs({ -4, 4 }) do
		for _, cx in ipairs({ -0.9, 0.9 }) do P(V(0.08, 6, 0.08), CF(x + sx + cx, 6, z - 2), C3(150, 155, 165), M.Metal) end
		P(V(2.4, 0.3, 1.3), CF(x + sx, 2.9, z - 2), C3(210, 40, 40))
		spot("Swing" .. i, V(x + sx, 3.05, z - 2), V(x + sx, 3.05, z + 10))
	end
	picketFence(x - 30, x + 30, z - 14)
	for _, p in ipairs({ { -24, -22 }, { -14, -26 }, { -4, -24 }, { 8, -27 }, { 20, -23 }, { 28, -25 } }) do pine(x + p[1], z + p[2], 1 + (p[1] % 3) * 0.1) end
	redHouse(x + 22, z - 32)
	mountains(x, z - 120)
	spot("Playground", V(x, 0.2, z + 4), V(x, 0.2, z + 20))
end

---------------------------------------------------------------- KIT: dressed characters
-- Outfit pieces are parts welded to the R15 limbs, so they move with every animation.
-- The rig FACES -Z in its own space: front pieces (fringe, glasses, tie, zip, cap brim)
-- go at -Z, back pieces (hair back, hood, backpack) at +Z. (First version had these
-- swapped and hair panels covered every face.)
-- body part names: Head, UpperTorso, LowerTorso, Left/RightUpperArm, Left/RightLowerArm,
-- Left/RightHand, Left/RightUpperLeg, Left/RightLowerLeg, Left/RightFoot.
local function wear(m, limb, size, offset, color, mat, shape)
	local b = m:FindFirstChild(limb)
	if not b then return end
	local p = Instance.new("Part")
	p.Anchored, p.CanCollide, p.Massless, p.CastShadow = false, false, true, true
	p.Size, p.Color, p.Material = size, color, mat or M.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	p.CFrame = b.CFrame * (offset or CFrame.identity)
	local w = Instance.new("Weld")
	w.Part0, w.Part1, w.C0 = b, p, offset or CFrame.identity
	w.Parent = p
	p.Parent = m
	return p
end
local function shell(m, limb, color, pad, mat)  -- a clothing layer slightly larger than the limb
	local b = m:FindFirstChild(limb)
	if not b then return end
	pad = pad or 0.08
	return wear(m, limb, b.Size + V(pad, pad * 0.5, pad), CFrame.identity, color, mat)
end
local OUT = {}
-- tops: style "tee" | "long" | "hoodie" | "jacket"
function OUT.top(m, color, style, trim)
	shell(m, "UpperTorso", color)
	shell(m, "LowerTorso", color)
	shell(m, "LeftUpperArm", color); shell(m, "RightUpperArm", color)
	if style ~= "tee" then shell(m, "LeftLowerArm", color); shell(m, "RightLowerArm", color) end
	local t = m.UpperTorso.Size
	if style == "hoodie" then
		wear(m, "UpperTorso", V(t.X * 0.7, 0.5, 0.6), CF(0, t.Y / 2 + 0.05, t.Z / 2 - 0.05), color)        -- hood (back)
		wear(m, "UpperTorso", V(t.X * 0.55, 0.5, 0.06), CF(0, -t.Y * 0.15, -t.Z / 2 - 0.06), trim or color:Lerp(C3(0, 0, 0), 0.15)) -- pocket (front)
	elseif style == "jacket" then
		wear(m, "UpperTorso", V(0.12, t.Y, 0.06), CF(0, 0, -t.Z / 2 - 0.07), trim or C3(240, 240, 240))      -- zip/shirt line (front)
		wear(m, "UpperTorso", V(t.X + 0.15, 0.3, t.Z + 0.15), CF(0, t.Y / 2 - 0.1, 0), color:Lerp(C3(0, 0, 0), 0.2)) -- collar
	elseif trim then
		wear(m, "UpperTorso", V(t.X + 0.1, 0.25, t.Z + 0.1), CF(0, -t.Y * 0.1, 0), trim)                     -- stripe
	end
end
function OUT.pants(m, color, shorts)
	shell(m, "LeftUpperLeg", color); shell(m, "RightUpperLeg", color)
	if not shorts then shell(m, "LeftLowerLeg", color); shell(m, "RightLowerLeg", color) end
end
function OUT.dress(m, color, trim)  -- top + flared skirt over the upper legs
	OUT.top(m, color, "tee", trim)
	local l = m.LowerTorso.Size
	wear(m, "LowerTorso", V(l.X + 0.7, 1.7, l.Z + 0.7), CF(0, -l.Y / 2 - 0.75, 0), color)
	wear(m, "LowerTorso", V(l.X + 0.9, 0.2, l.Z + 0.9), CF(0, -l.Y / 2 - 1.55, 0), trim or color:Lerp(C3(255, 255, 255), 0.4))
end
function OUT.shoes(m, color, sole)
	for _, f in ipairs({ "LeftFoot", "RightFoot" }) do
		local b = m:FindFirstChild(f)
		if b then
			wear(m, f, b.Size + V(0.12, 0.08, 0.25), CF(0, 0.02, -0.08), color or C3(250, 250, 250))
			wear(m, f, V(b.Size.X + 0.14, 0.12, b.Size.Z + 0.3), CF(0, -b.Size.Y / 2 - 0.02, -0.08), sole or C3(240, 240, 240))
		end
	end
end
-- hair: style "short" | "long" | "bun" | "curly" | "spiky"
function OUT.hair(m, color, style)
	local h = m.Head.Size
	local top = V(h.X + 0.12, h.Y * 0.38, h.Z + 0.12)
	wear(m, "Head", top, CF(0, h.Y * 0.36, 0), color)
	wear(m, "Head", V(h.X + 0.12, h.Y * 0.55, 0.22), CF(0, h.Y * 0.12, h.Z / 2 + 0.02), color)     -- back (+Z)
	wear(m, "Head", V(h.X * 0.9, 0.22, 0.14), CF(0, h.Y * 0.2, -h.Z / 2 - 0.02), color)            -- fringe (front, -Z)
	if style == "long" then
		wear(m, "Head", V(h.X + 0.14, h.Y * 1.1, 0.3), CF(0, -h.Y * 0.25, h.Z / 2 + 0.05), color)
		wear(m, "Head", V(0.2, h.Y * 0.9, h.Z * 0.7), CF(-h.X / 2 - 0.05, -h.Y * 0.05, 0.1), color)
		wear(m, "Head", V(0.2, h.Y * 0.9, h.Z * 0.7), CF(h.X / 2 + 0.05, -h.Y * 0.05, 0.1), color)
	elseif style == "bun" then
		wear(m, "Head", V(0.7, 0.7, 0.7), CF(0, h.Y * 0.62, h.Z * 0.2), color, nil, Enum.PartType.Ball)
	elseif style == "curly" then
		for i = -1, 1 do wear(m, "Head", V(0.6, 0.6, 0.6), CF(i * h.X * 0.32, h.Y * 0.55, 0), color, nil, Enum.PartType.Ball) end
	elseif style == "spiky" then
		for i = -1, 1 do wear(m, "Head", V(0.3, 0.45, 0.3), CF(i * h.X * 0.3, h.Y * 0.62, -0.05) * CFrame.Angles(math.rad(15), 0, math.rad(i * -15)), color) end
	end
end
function OUT.cap(m, color)
	local h = m.Head.Size
	wear(m, "Head", V(h.X + 0.16, h.Y * 0.35, h.Z + 0.16), CF(0, h.Y * 0.4, 0), color)
	wear(m, "Head", V(h.X * 0.8, 0.08, 0.7), CF(0, h.Y * 0.24, -h.Z / 2 - 0.3), color)
end
function OUT.glasses(m, color)
	local h = m.Head.Size
	wear(m, "Head", V(h.X * 0.85, 0.1, 0.06), CF(0, h.Y * 0.08, -h.Z / 2 - 0.04), color or C3(30, 30, 35))
	for _, sx in ipairs({ -1, 1 }) do wear(m, "Head", V(0.36, 0.3, 0.05), CF(sx * h.X * 0.2, h.Y * 0.06, -h.Z / 2 - 0.05), color or C3(30, 30, 35)) end
end
function OUT.backpack(m, color)
	local t = m.UpperTorso.Size
	wear(m, "UpperTorso", V(t.X * 0.75, t.Y * 0.95, 0.55), CF(0, -0.05, t.Z / 2 + 0.3), color)
end
function OUT.tie(m, color)
	local t = m.UpperTorso.Size
	wear(m, "UpperTorso", V(0.22, t.Y * 0.75, 0.05), CF(0, -0.05, -t.Z / 2 - 0.07), color or C3(200, 50, 60))
end

-- face built from parts (the default face is a downloaded decal, and asset downloads can
-- fail in Studio: then heads render blank). mood: "happy" (default) | "neutral" | "sad"
function OUT.face(m, mood, eyeColor)
	local h = m.Head.Size
	local fz = -h.Z / 2 - 0.02            -- the face side is -Z
	local ink = C3(30, 30, 38)
	local anime = STYLE.face == "anime"
	local iris = eyeColor or C3(70, 45, 35)
	for _, sx in ipairs({ -1, 1 }) do
		local ex = sx * h.X * (anime and 0.2 or 0.18)
		if mood == "closed" then  -- happy closed eyes (^ ^)
			for _, d in ipairs({ -1, 1 }) do
				wear(m, "Head", V(anime and 0.2 or 0.14, 0.06, 0.04), CF(ex + d * 0.07, h.Y * 0.04, fz) * CFrame.Angles(0, 0, d * -0.6), ink)
			end
		elseif anime then  -- big anime eye: dark outline, coloured iris, two highlights, lash line
			local eh = (mood == "serious") and h.Y * 0.2 or h.Y * 0.34
			local ew = h.X * 0.17
			wear(m, "Head", V(ew, eh, 0.05), CF(ex, -h.Y * 0.02, fz), ink)
			wear(m, "Head", V(ew * 0.78, eh * 0.62, 0.02), CF(ex, -h.Y * 0.06, fz - 0.03), iris)
			wear(m, "Head", V(ew * 0.42, eh * 0.24, 0.02), CF(ex - ew * 0.16, h.Y * 0.06, fz - 0.045), C3(255, 255, 255))
			wear(m, "Head", V(ew * 0.18, eh * 0.11, 0.02), CF(ex + ew * 0.2, -h.Y * 0.11, fz - 0.045), C3(255, 255, 255))
			wear(m, "Head", V(ew * 1.25, 0.06, 0.05), CF(ex, -h.Y * 0.02 + eh / 2, fz - 0.01) * CFrame.Angles(0, 0, sx * -0.12), ink)
		else
			local eh = (mood == "serious") and 0.2 or 0.3
			wear(m, "Head", V(0.2, eh, 0.06), CF(ex, h.Y * 0.06, fz), ink)
			wear(m, "Head", V(0.07, 0.08, 0.02), CF(ex - 0.04, h.Y * 0.12, fz - 0.035), C3(255, 255, 255))
		end
		local tilt = (mood == "sad") and sx * 0.25 or ((mood == "serious") and sx * 0.2 or sx * -0.12)
		wear(m, "Head", V(anime and 0.26 or 0.3, 0.05, 0.04), CF(ex, h.Y * (anime and 0.24 or 0.27), fz) * CFrame.Angles(0, 0, tilt), ink) -- brow
	end
	local mouthY = -h.Y * (anime and 0.27 or 0.2)
	local mw = anime and 0.6 or 1  -- anime mouths are small
	if mood == "smirk" then
		wear(m, "Head", V(0.26 * mw, 0.05, 0.04), CF(0.04, mouthY, fz) * CFrame.Angles(0, 0, 0.18), ink)
	elseif mood == "neutral" or mood == "serious" then
		wear(m, "Head", V(0.3 * mw, 0.05, 0.04), CF(0, mouthY, fz), ink)
	else
		local curve = (mood == "sad") and -1 or 1          -- smile curves up at the ends
		wear(m, "Head", V(0.24 * mw, 0.06, 0.04), CF(0, mouthY - curve * 0.025, fz), ink)
		for _, sx in ipairs({ -1, 1 }) do
			wear(m, "Head", V(0.14 * mw, 0.06, 0.04), CF(sx * 0.16 * mw, mouthY + curve * 0.015, fz) * CFrame.Angles(0, 0, sx * curve * 0.5), ink)
		end
	end
	for _, sx in ipairs({ -1, 1 }) do  -- blush
		wear(m, "Head", V(anime and 0.22 or 0.16, 0.08, 0.02), CF(sx * h.X * 0.32, -h.Y * 0.16, fz + 0.005), C3(255, 150, 150))
	end
end

---------------------------------------------------------------- KIT: "Roblox aesthetic" outfits
-- Modern avatar look from the user's reference boards (Nov 2026): messy fluffy hair,
-- oversized hoodies/jackets, baggy pants, chunky sneakers, and accessories. All original,
-- code-built pieces: never copy logos, brand names or licensed characters onto clothes.
local BLACK, WHITE_C, SILVER = C3(28, 28, 32), C3(245, 245, 245), C3(200, 205, 212)
local A2 = {}
-- messy fluffy hair: a cap plus a seeded cluster of tilted chunks and fringe strands that
-- fall over the forehead (front = -Z). color2 = optional second colour on the right side.
function A2.messyHair(m, color, color2, seed)
	local h = m.Head.Size
	local rng = Random.new(seed or #m.Name * 7)
	wear(m, "Head", V(h.X + 0.16, h.Y * 0.4, h.Z + 0.16), CF(0, h.Y * 0.36, 0.02), color)
	wear(m, "Head", V(h.X + 0.16, h.Y * 0.7, 0.25), CF(0, h.Y * 0.1, h.Z / 2 + 0.06), color)
	for i = 1, 14 do
		local sx = rng:NextNumber(-0.5, 0.5)
		local col = (color2 and sx > 0) and color2 or color
		local s = rng:NextNumber(0.32, 0.5)
		wear(m, "Head", V(s, s * 0.8, s),
			CF(sx * h.X, h.Y * rng:NextNumber(0.42, 0.62), rng:NextNumber(-0.45, 0.45) * h.Z)
			* CFrame.Angles(rng:NextNumber(-0.6, 0.6), rng:NextNumber(-0.8, 0.8), rng:NextNumber(-0.6, 0.6)), col)
	end
	for i = -2, 2 do  -- fringe strands over the forehead
		local col = (color2 and i > 0) and color2 or color
		wear(m, "Head", V(0.26, 0.32, 0.12), CF(i * h.X * 0.17, h.Y * (0.3 - math.abs(i) * 0.02), -h.Z / 2 - 0.06)
			* CFrame.Angles(0.25, 0, i * 0.18), col)
	end
	for _, sx in ipairs({ -1, 1 }) do  -- side tufts
		local col = (color2 and sx > 0) and color2 or color
		wear(m, "Head", V(0.16, h.Y * 0.55, h.Z * 0.75), CF(sx * (h.X / 2 + 0.06), h.Y * 0.12, 0.05), col)
	end
end
function A2.longWavyHair(m, color)
	local h = m.Head.Size
	A2.messyHair(m, color, nil, 3)
	for k = 0, 3 do  -- wavy layers down the back and sides
		local y, wob = -h.Y * (0.15 + k * 0.3), (k % 2 == 0) and 0.06 or -0.06
		wear(m, "Head", V(h.X + 0.24, h.Y * 0.36, 0.32), CF(wob, y, h.Z / 2 + 0.1), color)
		for _, sx in ipairs({ -1, 1 }) do
			wear(m, "Head", V(0.26, h.Y * 0.36, h.Z * 0.6), CF(sx * (h.X / 2 + 0.1 + wob), y, 0.12), color)
		end
	end
end
function A2.spikyHair(m, color, color2)
	local h = m.Head.Size
	local function col(x) return (color2 and x > 0) and color2 or color end
	wear(m, "Head", V(h.X + 0.16, h.Y * 0.42, h.Z + 0.16), CF(0, h.Y * 0.36, 0.02), color)
	wear(m, "Head", V(h.X + 0.16, h.Y * 0.62, 0.26), CF(0, h.Y * 0.12, h.Z / 2 + 0.06), color)        -- back
	local function spike(base, dir, len, w, c)  -- tapered spike: thick base + thin tip along dir
		local up = dir.Unit
		local cf = CFrame.lookAt(base, base + up) * CFrame.Angles(-math.pi / 2, 0, 0)
		wear(m, "Head", V(w, len * 0.6, w), cf * CF(0, len * 0.3, 0), c)
		wear(m, "Head", V(w * 0.5, len * 0.5, w * 0.5), cf * CF(0, len * 0.8, 0), c)
	end
	-- crown: a ring of spikes pointing up and outward, plus a few on top
	for i = 1, 10 do
		local a = (i / 10) * math.pi * 2
		local bx, bz = math.cos(a) * h.X * 0.38, math.sin(a) * h.Z * 0.38
		spike(V(bx, h.Y * 0.5, bz), V(bx * 1.6, h.Y * 0.9, bz * 1.6), h.Y * 0.62, 0.34, col(bx))
	end
	for _, o in ipairs({ { -0.15, 0.05 }, { 0.15, -0.05 }, { 0, 0.18 } }) do
		spike(V(o[1] * h.X, h.Y * 0.56, o[2] * h.Z), V(o[1], 1, o[2] + 0.15), h.Y * 0.55, 0.36, col(o[1]))
	end
	-- fringe: spikes hanging down over the forehead (front = -Z), stopping above the eyes
	for i = -2, 2 do
		spike(V(i * h.X * 0.18, h.Y * 0.42, -h.Z / 2 - 0.04), V(i * 0.25, -1, -0.25), h.Y * 0.3, 0.26, col(i))
	end
	for _, sx in ipairs({ -1, 1 }) do  -- sideburn spikes
		spike(V(sx * (h.X / 2 + 0.04), h.Y * 0.3, -0.05), V(sx * 0.3, -1, 0), h.Y * 0.38, 0.22, col(sx))
	end
end
function A2.headphones(m, color, glow)
	local h = m.Head.Size
	wear(m, "Head", V(h.X + 0.5, 0.16, 0.24), CF(0, h.Y * 0.68, 0), color)
	for _, sx in ipairs({ -1, 1 }) do
		wear(m, "Head", V(0.22, h.Y * 0.5, 0.18), CF(sx * (h.X / 2 + 0.2), h.Y * 0.4, 0), color)
		wear(m, "Head", V(0.3, 0.62, 0.62), CF(sx * (h.X / 2 + 0.16), h.Y * 0.02, 0), color, nil, Enum.PartType.Cylinder)
		if glow then wear(m, "Head", V(0.06, 0.3, 0.3), CF(sx * (h.X / 2 + 0.33), h.Y * 0.02, 0), glow, M.Neon) end
	end
end
function A2.mask(m, color)
	local h = m.Head.Size
	wear(m, "Head", V(h.X + 0.08, h.Y * 0.36, 0.14), CF(0, -h.Y * 0.2, -h.Z / 2 - 0.03), color or BLACK)
end
function A2.sunglasses(m)
	local h = m.Head.Size
	wear(m, "Head", V(h.X + 0.1, 0.08, 0.06), CF(0, h.Y * 0.1, -h.Z / 2 - 0.05), BLACK)
	for _, sx in ipairs({ -1, 1 }) do wear(m, "Head", V(0.42, 0.3, 0.06), CF(sx * h.X * 0.2, h.Y * 0.04, -h.Z / 2 - 0.06), C3(20, 20, 26), M.Glass) end
end
function A2.visor(m, glow)
	local h = m.Head.Size
	wear(m, "Head", V(h.X + 0.14, h.Y * 0.28, 0.1), CF(0, h.Y * 0.06, -h.Z / 2 - 0.05), BLACK)
	wear(m, "Head", V(h.X * 0.8, 0.07, 0.02), CF(0, h.Y * 0.06, -h.Z / 2 - 0.11), glow, M.Neon)
end
function A2.beanieEars(m, color, inner)
	local h = m.Head.Size
	wear(m, "Head", V(h.X + 0.22, h.Y * 0.45, h.Z + 0.22), CF(0, h.Y * 0.38, 0), color, M.Fabric)
	wear(m, "Head", V(h.X + 0.26, h.Y * 0.14, h.Z + 0.26), CF(0, h.Y * 0.14, 0), color, M.Fabric)
	for _, sx in ipairs({ -1, 1 }) do
		wear(m, "Head", V(0.42, 0.42, 0.18), CF(sx * h.X * 0.3, h.Y * 0.68, 0) * CFrame.Angles(0, 0, math.rad(45)), color, M.Fabric)
		wear(m, "Head", V(0.22, 0.22, 0.04), CF(sx * h.X * 0.3, h.Y * 0.66, -0.1) * CFrame.Angles(0, 0, math.rad(45)), inner or C3(255, 175, 200))
	end
end
-- oversized top: hoodie | jacket (open, shows `inner`) | sweater | coat (long, to the knees)
function A2.top(m, kind, color, accent, inner)
	local pad = 0.24
	for _, limb in ipairs({ "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm" }) do
		shell(m, limb, color, pad, M.Fabric)
	end
	local t = m.UpperTorso.Size
	local fz = -t.Z / 2 - pad / 2 - 0.02
	if kind == "hoodie" then
		wear(m, "UpperTorso", V(t.X * 0.8, 0.6, 0.7), CF(0, t.Y / 2 + 0.06, t.Z / 2 + 0.02), color, M.Fabric) -- hood
		for _, sx in ipairs({ -0.18, 0.18 }) do wear(m, "UpperTorso", V(0.06, t.Y * 0.4, 0.04), CF(sx, t.Y * 0.1, fz), WHITE_C) end
		wear(m, "UpperTorso", V(t.X * 0.6, t.Y * 0.3, 0.05), CF(0, -t.Y * 0.32, fz), color:Lerp(BLACK, 0.18))   -- pocket
	elseif kind == "jacket" or kind == "coat" then
		wear(m, "UpperTorso", V(t.X * 0.34, t.Y + 0.05, 0.05), CF(0, 0, fz), inner or WHITE_C)               -- open front
		wear(m, "UpperTorso", V(t.X + 0.4, 0.3, t.Z + 0.4), CF(0, t.Y / 2 + 0.02, 0), color:Lerp(BLACK, 0.2)) -- collar
		if kind == "coat" then
			local l = m.LowerTorso.Size
			wear(m, "LowerTorso", V(l.X + 0.5, 2.2, l.Z + 0.5), CF(0, -l.Y / 2 - 1.05, 0), color, M.Fabric)
			wear(m, "LowerTorso", V(l.X * 0.3, 2.2, 0.06), CF(0, -l.Y / 2 - 1.05, -l.Z / 2 - 0.28), inner or WHITE_C)
		end
	elseif kind == "sweater" then
		wear(m, "UpperTorso", V(t.X * 0.5, 0.12, 0.05), CF(0, t.Y / 2 - 0.12, fz), inner or WHITE_C)          -- shirt collar
	end
	if accent then  -- graphic / neon detail on the chest and sleeve stripes
		local isTable = typeof(accent) == "table"
		local mat = (isTable and accent.Mat == "Neon") and M.Neon or M.SmoothPlastic
		local ac = isTable and accent.Color or accent
		wear(m, "UpperTorso", V(t.X * 0.42, t.Y * 0.36, 0.04), CF(0.05, t.Y * 0.1, fz - 0.01), ac, mat)
		for _, arm in ipairs({ "LeftLowerArm", "RightLowerArm" }) do
			local a = m[arm].Size
			wear(m, arm, V(a.X + pad + 0.04, 0.12, a.Z + pad + 0.04), CF(0, a.Y * 0.2, 0), ac, mat)
		end
	end
end
function A2.letter(m, text, color)  -- varsity letter (any original letter)
	local t = m.UpperTorso.Size
	local p = wear(m, "UpperTorso", V(0.7, 0.7, 0.04), CF(-t.X * 0.22, t.Y * 0.18, -t.Z / 2 - 0.16), color or WHITE_C)
	sign(p, Enum.NormalId.Front, text, nil, BLACK)
end
-- baggy pants: wide shells that flare toward the ankle; cargo adds thigh pockets
function A2.baggyPants(m, color, cargo, stripe)
	for _, side in ipairs({ "Left", "Right" }) do
		shell(m, side .. "UpperLeg", color, 0.3, M.Fabric)
		local ll = m[side .. "LowerLeg"]
		wear(m, side .. "LowerLeg", ll.Size + V(0.45, 0.25, 0.45), CF(0, -0.08, 0), color, M.Fabric)
		if cargo then
			local u = m[side .. "UpperLeg"].Size
			wear(m, side .. "UpperLeg", V(0.08, u.Y * 0.4, u.Z * 0.6), CF((side == "Left" and -1 or 1) * (u.X / 2 + 0.2), -u.Y * 0.1, 0), color:Lerp(BLACK, 0.2))
		end
		if stripe then
			wear(m, side .. "LowerLeg", V(0.06, ll.Size.Y + 0.2, 0.06), CF((side == "Left" and -1 or 1) * (ll.Size.X / 2 + 0.24), -0.08, 0), stripe, M.Neon)
		end
	end
end
function A2.shorts(m, color)
	for _, side in ipairs({ "Left", "Right" }) do shell(m, side .. "UpperLeg", color, 0.28, M.Fabric) end
end
function A2.sneakers(m, color, sole, glow)
	for _, f in ipairs({ "LeftFoot", "RightFoot" }) do
		local b = m:FindFirstChild(f)
		if b then
			wear(m, f, b.Size + V(0.3, 0.22, 0.45), CF(0, 0.05, -0.14), color, M.SmoothPlastic)
			wear(m, f, V(b.Size.X + 0.34, 0.2, b.Size.Z + 0.52), CF(0, -b.Size.Y / 2 - 0.06, -0.14), glow or sole or WHITE_C, glow and M.Neon or nil)
		end
	end
end
function A2.sandals(m, color)
	for _, f in ipairs({ "LeftFoot", "RightFoot" }) do
		local b = m:FindFirstChild(f)
		if b then
			wear(m, f, V(b.Size.X + 0.2, 0.12, b.Size.Z + 0.35), CF(0, -b.Size.Y / 2 - 0.02, -0.1), color or WHITE_C)
			wear(m, f, V(b.Size.X + 0.22, 0.1, 0.14), CF(0, 0, -0.15), color or WHITE_C)
		end
	end
end
function A2.chain(m)
	local l = m.LowerTorso.Size
	for i = 0, 5 do
		wear(m, "LowerTorso", V(0.16, 0.12, 0.05), CF(-l.X * 0.45 + i * 0.16, -0.25 - math.sin(i / 5 * math.pi) * 0.25, -l.Z / 2 - 0.2), SILVER, M.Metal)
	end
end
function A2.necklace(m, color)
	local t = m.UpperTorso.Size
	for i = -2, 2 do wear(m, "UpperTorso", V(0.1, 0.1, 0.04), CF(i * 0.12, t.Y / 2 - 0.2 - (2 - math.abs(i)) * 0.05, -t.Z / 2 - 0.16), color or C3(230, 190, 80), M.Metal) end
end
function A2.watch(m)
	local a = m.LeftLowerArm.Size
	wear(m, "LeftLowerArm", V(a.X + 0.3, 0.16, a.Z + 0.3), CF(0, -a.Y * 0.32, 0), C3(210, 170, 90), M.Metal)
end
function A2.shoulderBag(m, color)
	local t, l = m.UpperTorso.Size, m.LowerTorso.Size
	wear(m, "UpperTorso", V(0.1, t.Y * 1.25, 0.06), CF(0, -0.05, -t.Z / 2 - 0.16) * CFrame.Angles(0, 0, math.rad(35)), color)
	wear(m, "LowerTorso", V(0.7, 0.55, 0.3), CF(l.X / 2 + 0.25, -0.15, -0.1), color)
end
function A2.hawaiian(m, base, flower)
	A2.top(m, "tee", base)
	local t = m.UpperTorso.Size
	local rng = Random.new(5)
	for i = 1, 9 do  -- flower print on the front
		wear(m, "UpperTorso", V(0.22, 0.22, 0.03), CF(rng:NextNumber(-0.42, 0.42) * t.X, rng:NextNumber(-0.42, 0.42) * t.Y, -t.Z / 2 - 0.15) * CFrame.Angles(0, 0, rng:NextNumber(0, 1.5)), flower)
	end
end

local messyHairOriginal = A2.messyHair
A2.messyHair = function(m, color, color2, seed)  -- house style: presets' hair becomes spiky
	if STYLE.hair == "spiky" then return A2.spikyHair(m, color, color2) end
	return messyHairOriginal(m, color, color2, seed)
end

-- PRESETS: one call dresses a character in an archetype from the reference boards.
-- Each returns the face mood that suits it. Colours can be swapped per character with opts.
local PRESET = {}
PRESET.CoolShadow = function(m, o)   -- dark aesthetic: messy black hair, mask, graphic hoodie
	A2.messyHair(m, o.hair or BLACK); A2.mask(m)
	A2.top(m, "hoodie", o.top or C3(30, 30, 36), o.accent or WHITE_C)
	A2.baggyPants(m, o.pants or C3(32, 32, 38)); A2.chain(m); A2.sneakers(m, WHITE_C, C3(220, 220, 220))
	return "serious"
end
PRESET.CuteGirl = function(m, o)     -- soft aesthetic: cat-ear beanie, long wavy hair, pink top, white pants, bag
	A2.longWavyHair(m, o.hair or C3(90, 55, 40)); A2.beanieEars(m, o.hat or C3(250, 245, 245))
	A2.top(m, "sweater", o.top or C3(255, 170, 200), nil, WHITE_C)
	A2.baggyPants(m, o.pants or C3(245, 242, 238)); A2.shoulderBag(m, C3(255, 140, 180)); A2.sneakers(m, WHITE_C)
	return "closed"
end
PRESET.RichBoy = function(m, o)      -- classy: brown messy hair, sunglasses, black sweater over shirt, white pants, watch
	A2.messyHair(m, o.hair or C3(110, 70, 40)); A2.sunglasses(m)
	A2.top(m, "sweater", o.top or C3(26, 26, 30), nil, WHITE_C)
	local t = m.UpperTorso.Size  -- tie on top of the oversized sweater
	wear(m, "UpperTorso", V(0.18, t.Y * 0.6, 0.04), CF(0, -0.02, -t.Z / 2 - 0.16), BLACK)
	A2.baggyPants(m, o.pants or C3(240, 238, 232)); A2.watch(m); A2.sneakers(m, WHITE_C)
	return "smirk"
end
PRESET.GamerBoy = function(m, o)     -- black/white split hair, neon headset, black hoodie with blue neon
	local glow = o.glow or C3(60, 190, 255)
	A2.messyHair(m, BLACK, WHITE_C); A2.headphones(m, C3(30, 30, 36), glow)
	A2.top(m, "hoodie", C3(28, 28, 34), { Color = glow, Mat = "Neon" })
	A2.baggyPants(m, C3(30, 30, 38), true, glow); A2.sneakers(m, C3(30, 30, 36), nil, glow)
	return "happy"
end
PRESET.ChillGamer = function(m, o)   -- white hair, white headphones, white hoodie, black pants
	A2.messyHair(m, o.hair or C3(240, 240, 240)); A2.headphones(m, WHITE_C)
	A2.top(m, "hoodie", o.top or C3(242, 242, 245), C3(60, 60, 70))
	A2.baggyPants(m, C3(30, 30, 36)); A2.chain(m); A2.sneakers(m, BLACK, WHITE_C)
	return "happy"
end
PRESET.FriendlyPro = function(m, o)  -- brown hair, headphones, varsity jacket with a letter
	A2.messyHair(m, o.hair or C3(130, 85, 50)); A2.headphones(m, WHITE_C)
	A2.top(m, "jacket", o.top or C3(26, 26, 32), nil, WHITE_C); A2.letter(m, o.letter or "R")
	A2.baggyPants(m, C3(30, 30, 36)); A2.sneakers(m, BLACK, WHITE_C)
	return "happy"
end
PRESET.Beach = function(m, o)        -- brown hair, sunglasses, flower shirt, white shorts, sandals, necklace
	A2.messyHair(m, o.hair or C3(120, 75, 40)); A2.sunglasses(m)
	A2.hawaiian(m, o.top or C3(60, 150, 230), WHITE_C); A2.shorts(m, C3(245, 245, 240))
	A2.necklace(m); A2.sandals(m)
	return "happy"
end
PRESET.Cyber = function(m, o)        -- purple spiky hair, neon visor, neon jacket, cargo pants, neon shoes
	local glow = o.glow or C3(190, 80, 255)
	A2.spikyHair(m, o.hair or C3(120, 50, 200)); A2.visor(m, glow)
	A2.top(m, "jacket", C3(24, 22, 32), { Color = glow, Mat = "Neon" }, C3(40, 30, 60))
	A2.baggyPants(m, C3(26, 24, 32), true, glow); A2.sneakers(m, C3(30, 26, 40), nil, glow)
	return "serious"
end
PRESET.AnimeHero = function(m, o)    -- spiky black hair, long black/red coat (no weapons: kids channel)
	A2.spikyHair(m, o.hair or BLACK)
	A2.top(m, "coat", o.top or C3(26, 24, 28), { Color = C3(200, 40, 50) }, C3(200, 40, 50))
	A2.baggyPants(m, C3(30, 30, 34)); A2.sneakers(m, BLACK, WHITE_C)
	return "serious"
end
PRESET.Minimal = function(m, o)      -- messy black hair, grey sweater, baggy black pants, white shoes
	A2.messyHair(m, o.hair or BLACK)
	A2.top(m, "sweater", o.top or C3(95, 95, 100), nil, C3(120, 120, 125))
	A2.baggyPants(m, C3(30, 30, 34)); A2.sneakers(m, WHITE_C)
	return "neutral"
end

-- actor("Name", {skin=Color3, scale=1, preset="CoolShadow", mood="happy", outfit=function(m) ... end})
-- presets: CoolShadow, CuteGirl, RichBoy, GamerBoy, ChillGamer, FriendlyPro, Beach, Cyber,
-- AnimeHero, Minimal (extra opts per preset: hair, top, pants, accent, glow, hat, letter).
-- face moods: happy (default), closed, smirk, neutral, serious, sad.
-- Every actor gets a code-built face (OUT.face) unless o.face == false.
local function actor(name, o)
	if (o.body or STYLE.body) == "classic" then  -- house style: blocky R6 cast
		local recipe = {}
		for k, v in pairs(REF[o.ref or name] or {}) do recipe[k] = v end
		for k, v in pairs(o) do recipe[k] = v end
		return CL.build(name, recipe)
	end
	local d = Instance.new("HumanoidDescription")
	local skin = o.skin or C3(255, 205, 160)
	d.HeadColor, d.TorsoColor, d.LeftArmColor, d.RightArmColor, d.LeftLegColor, d.RightLegColor = skin, skin, skin, skin, skin, skin
	local sc = o.scale or 1
	if (o.body or STYLE.body) == "chibi" then  -- big head, short body
		d.HeadScale, d.HeightScale, d.WidthScale, d.DepthScale = 1.5 * sc, 0.82 * sc, 0.95 * sc, 0.95 * sc
	elseif o.scale then
		d.HeightScale, d.WidthScale, d.DepthScale, d.HeadScale = sc, sc, sc, sc
	end
	local m = Players:CreateHumanoidModelFromDescription(d, Enum.HumanoidRigType.R15)
	m.Name = name
	local hum = m:FindFirstChildOfClass("Humanoid")
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local animate = m:FindFirstChild("Animate")
	if animate then animate:Destroy() end
	-- outfit first (a preset returns the face mood that suits it), then the code-built face
	local presetMood
	if o.preset then presetMood = assert(PRESET[o.preset], "unknown preset " .. o.preset)(m, o) end
	if o.outfit then o.outfit(m) end
	if o.face ~= false then  -- remove the downloaded face decal (may be missing anyway)
		local dec = m.Head:FindFirstChild("face")
		if dec then dec:Destroy() end
		OUT.face(m, o.mood or presetMood)
	end
	m.HumanoidRootPart.Anchored = true
	m:PivotTo(CF(0, -200, 0))
	m.Parent = workspace
	task.wait(0.2)
	return m
end

---------------------------------------------------------------- SCENE (rewrite per story)
-- LOOKBOOK example in the house style: the reference cast in a playground, a cooking class,
-- a cozy living room and a restaurant entrance. The modern city pieces (street, mall,
-- hospital, vehicles...) are still in the kit for stories that need them.
lookModern(13.5)
playground(0, 0)
task.wait()
-- cooking class (x = 400): sunny walls, carpet, two wooden tables with pots, bowls, boards
room(400, 0, { name = "CookingClass", w = 26, d = 18, wall = SUNNY, floor = CARPET, floorMat = M.Fabric })
K.chalkboard(400, 6, -8.6); K.frame(392, 6.5, -8.7, C3(240, 160, 120)); K.frame(408, 6.5, -8.7, C3(130, 190, 150))
K.woodTable(396, -1, 8, 4); K.pot(394, 2.95, -1, C3(220, 60, 45)); K.bowl(398, 2.95, -1); K.board(396, 2.95, 0.2)
K.woodTable(406, 3, 8, 4); K.bowl(404, 2.95, 3, 0.8); K.pot(408, 2.95, 3, C3(245, 245, 240), 0.8)
task.wait()
-- cozy living room (x = 440): cream walls, carpet, sofa, framed pictures, a door
room(440, 0, { name = "CozyRoom", wall = CREAM, floor = CARPET, floorMat = M.Fabric })
K.sofa(440, -4.5, 0, C3(170, 120, 95)); K.rug(440, 1, 9, 5, C3(200, 120, 110)); K.frame(436, 6.5, -7.7, C3(110, 170, 220)); K.frame(444, 6.5, -7.7, C3(230, 190, 110))
K.doorway(450.6, -2, -90); K.plant(431, -6)
task.wait()
-- restaurant entrance (x = 480)
room(480, 0, { name = "Restaurant", w = 22, d = 18, wall = C3(236, 222, 190), floor = C3(150, 110, 70), floorMat = M.WoodPlanks })
K.restaurantEntrance(480, -8.4)
task.wait()

-- the reference cast (recipes in REF): Milo the young cook, Rose the grandma, Lily the
-- granddaughter, Andre the chef, Noah the parent, Pip the baby, Claire from the playground
for _, n in ipairs({ "Milo", "Rose", "Lily", "Andre", "Noah", "Pip", "Claire" }) do actor(n, {}) end
