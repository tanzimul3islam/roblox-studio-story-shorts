-- Studio_Story_01 "Pet Cloud": static town set + actors (server). All motion,
-- clouds, rain, lighting changes and camera run on the client (Story.client.luau),
-- because server-driven motion falls far behind through replication under Wine.
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
Players.CharacterAutoLoads = false

local set = Instance.new("Folder")
set.Name = "Set"
set.Parent = workspace

local function part(size, cf, color, material, class)
	local p = Instance.new(class or "Part")
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = set
	return p
end

local grass = part(Vector3.new(500, 1, 300), CFrame.new(0, -0.5, -40), Color3.fromRGB(110, 180, 80), Enum.Material.Grass)
grass.Name = "Grass"
part(Vector3.new(500, 0.1, 16), CFrame.new(0, 0.05, 9), Color3.fromRGB(70, 70, 78), Enum.Material.Asphalt)
for x = -240, 240, 8 do
	part(Vector3.new(3, 0.12, 0.4), CFrame.new(x, 0.08, 9), Color3.fromRGB(245, 230, 120))
end
part(Vector3.new(500, 0.3, 7), CFrame.new(0, 0.15, -3.5), Color3.fromRGB(205, 205, 210), Enum.Material.Concrete)

-- Houses along the street
local HOUSE = {
	Color3.fromRGB(255, 190, 190), Color3.fromRGB(190, 220, 255), Color3.fromRGB(255, 235, 170),
	Color3.fromRGB(200, 240, 200), Color3.fromRGB(230, 200, 255),
}
local i = 0
for x = -90, 100, 17 do
	i += 1
	local c = HOUSE[(i % #HOUSE) + 1]
	part(Vector3.new(12, 9, 10), CFrame.new(x, 4.5, -16), c)
	local roof = Color3.fromRGB(190, 80, 70)
	part(Vector3.new(12.6, 4, 5.6), CFrame.new(x, 11, -13.2), roof, nil, "WedgePart")
	part(Vector3.new(12.6, 4, 5.6), CFrame.new(x, 11, -18.8) * CFrame.Angles(0, math.pi, 0), roof, nil, "WedgePart")
	part(Vector3.new(2.6, 4.4, 0.4), CFrame.new(x, 2.2, -10.9), Color3.fromRGB(120, 80, 50))
	part(Vector3.new(2.4, 2.4, 0.3), CFrame.new(x - 3.6, 5, -10.9), Color3.fromRGB(170, 220, 255), Enum.Material.Glass)
	part(Vector3.new(2.4, 2.4, 0.3), CFrame.new(x + 3.6, 5, -10.9), Color3.fromRGB(170, 220, 255), Enum.Material.Glass)
	-- tree between houses
	part(Vector3.new(1, 5, 1), CFrame.new(x + 8.5, 2.5, -9), Color3.fromRGB(110, 75, 45), Enum.Material.Wood)
	local leaf = part(Vector3.new(5, 5, 5), CFrame.new(x + 8.5, 6.5, -9), Color3.fromRGB(70, 160, 70), Enum.Material.Grass, "Part")
	leaf.Shape = Enum.PartType.Ball
	leaf.Name = "Leaves"
end

-- Maya's tomato garden
local garden = Instance.new("Folder")
garden.Name = "Garden"
garden.Parent = set
local soil = part(Vector3.new(7, 0.5, 3.5), CFrame.new(-27, 0.25, -6.5), Color3.fromRGB(110, 75, 50), Enum.Material.Ground)
soil.Parent = garden
for k = 0, 3 do
	local px = -29.6 + k * 1.75
	local bush = part(Vector3.new(1.4, 1.8, 1.4), CFrame.new(px, 1.4, -6.5), Color3.fromRGB(60, 150, 60), Enum.Material.Grass)
	bush.Name = "Bush"
	bush.Parent = garden
	for j = 0, 1 do
		local t = part(Vector3.new(0.6, 0.6, 0.6), CFrame.new(px + (j - 0.5) * 0.7, 1.6 + j * 0.4, -5.8), Color3.fromRGB(230, 40, 40))
		t.Shape = Enum.PartType.Ball
		t.Name = "Tomato"
		t.Parent = garden
	end
end

Lighting.ClockTime = 13.5
Lighting.Brightness = 3
Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 165)
Lighting.GlobalShadows = true
local atmo = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
atmo.Density = 0.25
atmo.Haze = 1
local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
cc.Saturation, cc.Contrast = 0.2, 0.08

local function actor(name, c, scale)
	local d = Instance.new("HumanoidDescription")
	d.HeadColor, d.TorsoColor = c.skin, c.torso
	d.LeftArmColor, d.RightArmColor = c.skin, c.skin
	d.LeftLegColor, d.RightLegColor = c.leg, c.leg
	if scale then d.HeightScale, d.WidthScale, d.DepthScale, d.HeadScale = scale, scale, scale, scale end
	local m = Players:CreateHumanoidModelFromDescription(d, Enum.HumanoidRigType.R15)
	m.Name = name
	local hum = m:FindFirstChildOfClass("Humanoid")
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	m:FindFirstChild("HumanoidRootPart").Anchored = true
	local animate = m:FindFirstChild("Animate")
	if animate then animate:Destroy() end
	m:PivotTo(CFrame.new(0, -200, 0))
	m.Parent = workspace
	task.wait(0.2)
end

actor("Narrator", { skin = Color3.fromRGB(245, 205, 48), torso = Color3.fromRGB(240, 120, 40), leg = Color3.fromRGB(40, 60, 140) })
actor("Maya", { skin = Color3.fromRGB(160, 110, 80), torso = Color3.fromRGB(255, 110, 180), leg = Color3.fromRGB(120, 60, 140) })
actor("Leo", { skin = Color3.fromRGB(255, 220, 190), torso = Color3.fromRGB(80, 200, 230), leg = Color3.fromRGB(30, 40, 60) })
actor("Patel", { skin = Color3.fromRGB(150, 100, 70), torso = Color3.fromRGB(110, 110, 120), leg = Color3.fromRGB(50, 50, 60) }, 1.2)
actor("Kid1", { skin = Color3.fromRGB(255, 205, 160), torso = Color3.fromRGB(60, 170, 80), leg = Color3.fromRGB(40, 40, 40) })
actor("Kid2", { skin = Color3.fromRGB(120, 80, 60), torso = Color3.fromRGB(230, 60, 60), leg = Color3.fromRGB(40, 50, 90) })
