-- BuildMoonAnims.luau
-- Builds 6 genuine Moon Animator 2 (.moon2) save files in ServerStorage.MoonAnimator2Saves
-- and runs Moon Animator 2's own OpenFile -> ExportRigs -> CloseFile pipeline to export
-- reusable KeyframeSequences (plus Moon Animator 2's built-in R6Walk) into ReplicatedStorage.MoonAnims.

local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MG = assert(_G.MoonGlobal, "Moon Animator 2 plugin (_G.MoonGlobal) is not loaded")
local MAWin = assert(MG.Windows and MG.Windows.MoonAnimator, "MoonAnimator window not found")

-- Clean up any previous build rig / exports
local oldRig = workspace:FindFirstChild("MoonRig")
if oldRig then oldRig:Destroy() end
local oldAnims = ReplicatedStorage:FindFirstChild("MoonAnims")
if oldAnims then oldAnims:Destroy() end

local moonAnims = Instance.new("Folder")
moonAnims.Name = "MoonAnims"
moonAnims.Parent = ReplicatedStorage

local savesRoot = MG.Files.GetRoot()
savesRoot.Parent = ServerStorage

-- Clone Moon Animator 2's R6 template rig into Workspace for authoring & export
local rig = MG.rigs.R6:Clone()
rig.Name = "MoonRig"
rig.HumanoidRootPart.Anchored = true
rig:PivotTo(CFrame.new(0, 3, 0))
rig.Parent = workspace

-- Collect joint metadata from RigHierarchy
local joints = {}
do
	local rh = MG.RigHierarchy(rig)
	local stack = {}
	for _, t in ipairs(rh) do table.insert(stack, t) end
	while #stack > 0 do
		local pop = table.remove(stack, 1)
		if pop.Joint and pop.Joint:IsA("Motor6D") then
			joints[pop.Path] = {
				motor = pop.Joint,
				restC1 = pop.Joint.C1,
			}
		end
		if pop.Attached then
			for _, ch in ipairs(pop.Attached) do table.insert(stack, ch) end
		end
	end
end

local function storeEase(easeParent, easeType, dir)
	local ef = Instance.new("Folder")
	ef.Name = "0"
	ef.Parent = easeParent
	local tv = Instance.new("StringValue")
	tv.Name = "Type"
	tv.Value = easeType or "Linear"
	tv.Parent = ef
	if dir and easeType ~= "Linear" and easeType ~= "Constant" then
		local pf = Instance.new("Folder")
		pf.Name = "Params"
		pf.Parent = ef
		local dv = Instance.new("StringValue")
		dv.Name = "Direction"
		dv.Value = dir
		dv.Parent = pf
	end
end

local function makeMoon2File(name, lengthFrames, looped, jointKeyframes)
	local existing = savesRoot:FindFirstChild(name)
	if existing then existing:Destroy() end

	local file = Instance.new("StringValue")
	file.Name = name
	local data = {
		Information = {
			Length = lengthFrames,
			Looped = looped,
			ExportPriority = "Action",
			FPS = 60,
			Created = os.time(),
			Modified = os.time(),
		},
		Items = {
			{
				Path = {
					Format = "game.Workspace.MoonRig",
					ItemType = "Rig",
					InstanceNames = { "game", "Workspace", "MoonRig" },
					InstanceTypes = { "DataModel", "Workspace", "Model" },
				},
			},
		},
	}
	file.Value = HttpService:JSONEncode(data)

	local itemFolder = Instance.new("Folder")
	itemFolder.Name = "1"
	itemFolder.Parent = file

	local rigFolder = Instance.new("Folder")
	rigFolder.Name = "Rig"
	rigFolder.Parent = itemFolder

	for hierPath, kfList in pairs(jointKeyframes) do
		local jInfo = assert(joints[hierPath], "Unknown R6 RigHierarchy path: " .. hierPath)
		local jf = Instance.new("Folder")
		jf.Name = "_joint"
		jf.Parent = rigFolder

		local hv = Instance.new("StringValue")
		hv.Name = "_hier"
		hv.Value = hierPath
		hv.Parent = jf

		local dv = Instance.new("CFrameValue")
		dv.Name = "default"
		dv.Value = jInfo.restC1
		dv.Parent = jf

		local kfsFolder = Instance.new("Folder")
		kfsFolder.Name = "_keyframes"
		kfsFolder.Parent = jf

		for _, kfSpec in ipairs(kfList) do
			local framePos, desiredTransform, easeType, easeDir = kfSpec[1], kfSpec[2], kfSpec[3], kfSpec[4]
			local kfFolder = Instance.new("Folder")
			kfFolder.Name = tostring(framePos)
			kfFolder.Parent = kfsFolder

			local vals = Instance.new("Folder")
			vals.Name = "Values"
			vals.Parent = kfFolder

			local v0 = Instance.new("CFrameValue")
			v0.Name = "0"
			-- Moon Animator 2 exports Pose.CFrame = keyframeC1:Inverse() * restC1
			-- Setting keyframeC1 = restC1 * desiredTransform:Inverse() yields exact Pose.CFrame == desiredTransform
			v0.Value = jInfo.restC1 * desiredTransform:Inverse()
			v0.Parent = vals

			local eases = Instance.new("Folder")
			eases.Name = "Eases"
			eases.Parent = kfFolder
			storeEase(eases, easeType or "Sine", easeDir or "InOut")
		end
	end

	file.Parent = savesRoot
	return file
end

local A = function(rx, ry, rz)
	return CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
end
local CF = CFrame.new

-- Note on measured R6 Transform axes:
--   Torso (RootJoint): pos +Z = up, -Z = down; rot +X = lean forward, -X = lean back, +Z = yaw left, -Z = yaw right
--   Head  (Neck):      rot +X = nod down, -X = look up, +Y = tilt left, +Z = yaw left
--   Right Arm (RS):    rot +Z = swing forward, -Z = swing back, -X = raise outward (+X world)
--   Left Arm  (LS):    rot -Z = swing forward, +Z = swing back, -X = raise outward (-X world)
--   Right Leg (RH):    rot +Z = forward, -Z = back, -X = outward
--   Left Leg  (LH):    rot -Z = forward, +Z = back, -X = outward

local ANIMS = {
	{
		name = "MA2_Idle",
		frames = 120,
		looped = true,
		tracks = {
			["Torso"] = {
				{ 0,   CF(0, 0, 0)    * A(0, 0, 0),   "Sine", "InOut" },
				{ 60,  CF(0, 0, 0.06) * A(2, 0, 3),   "Sine", "InOut" },
				{ 120, CF(0, 0, 0)    * A(0, 0, 0),   "Sine", "InOut" },
			},
			["Torso.Head"] = {
				{ 0,   A(0, 0, -2),   "Sine", "InOut" },
				{ 60,  A(-3, 2, 4),   "Sine", "InOut" },
				{ 120, A(0, 0, -2),   "Sine", "InOut" },
			},
			["Torso.Right Arm"] = {
				{ 0,   A(-6, 0, 6),   "Sine", "InOut" },
				{ 60,  A(-9, 0, 12),  "Sine", "InOut" },
				{ 120, A(-6, 0, 6),   "Sine", "InOut" },
			},
			["Torso.Left Arm"] = {
				{ 0,   A(-6, 0, -6),  "Sine", "InOut" },
				{ 60,  A(-9, 0, -12), "Sine", "InOut" },
				{ 120, A(-6, 0, -6),  "Sine", "InOut" },
			},
		},
	},
	{
		name = "MA2_Worried",
		frames = 90,
		looped = true,
		tracks = {
			["Torso"] = {
				{ 0,  CF(0, 0, -0.10) * A(10, 0, 0),   "Sine", "InOut" },
				{ 45, CF(0, 0, -0.15) * A(13, 0, -4),  "Sine", "InOut" },
				{ 90, CF(0, 0, -0.10) * A(10, 0, 0),   "Sine", "InOut" },
			},
			["Torso.Head"] = {
				{ 0,  A(12, 0, -10),  "Sine", "InOut" },
				{ 45, A(14, -4, 10),  "Sine", "InOut" },
				{ 90, A(12, 0, -10),  "Sine", "InOut" },
			},
			-- Arms held tense in front of chest, slightly trembling (never clipping head)
			["Torso.Right Arm"] = {
				{ 0,  A(-10, 8, 42),  "Sine", "InOut" },
				{ 45, A(-14, 8, 50),  "Sine", "InOut" },
				{ 90, A(-10, 8, 42),  "Sine", "InOut" },
			},
			["Torso.Left Arm"] = {
				{ 0,  A(-10, -8, -42), "Sine", "InOut" },
				{ 45, A(-14, -8, -50), "Sine", "InOut" },
				{ 90, A(-10, -8, -42), "Sine", "InOut" },
			},
			["Torso.Right Leg"] = {
				{ 0,  A(-6, 0, 10),   "Sine", "InOut" },
				{ 45, A(-6, 0, 12),   "Sine", "InOut" },
				{ 90, A(-6, 0, 10),   "Sine", "InOut" },
			},
			["Torso.Left Leg"] = {
				{ 0,  A(-6, 0, -10),  "Sine", "InOut" },
				{ 45, A(-6, 0, -12),  "Sine", "InOut" },
				{ 90, A(-6, 0, -10),  "Sine", "InOut" },
			},
		},
	},
	{
		name = "MA2_Smug",
		frames = 108,
		looped = true,
		tracks = {
			["Torso"] = {
				{ 0,   CF(0, 0, 0.02) * A(-6, 3, -12), "Sine", "InOut" },
				{ 54,  CF(0, 0, 0.06) * A(-8, 5, -16), "Sine", "InOut" },
				{ 108, CF(0, 0, 0.02) * A(-6, 3, -12), "Sine", "InOut" },
			},
			["Torso.Head"] = {
				{ 0,   A(-7, -7, 12), "Sine", "InOut" },
				{ 54,  A(-10, -9, 15),"Sine", "InOut" },
				{ 108, A(-7, -7, 12), "Sine", "InOut" },
			},
			-- Right arm raised forward-out in a teasing wave/point; left arm cocked behind hip
			["Torso.Right Arm"] = {
				{ 0,   A(-22, 0, 68), "Cubic", "Out" },
				{ 54,  A(-28, 0, 82), "Sine",  "InOut" },
				{ 108, A(-22, 0, 68), "Sine",  "InOut" },
			},
			["Torso.Left Arm"] = {
				{ 0,   A(-24, 0, 18), "Sine", "InOut" },
				{ 54,  A(-28, 0, 22), "Sine", "InOut" },
				{ 108, A(-24, 0, 18), "Sine", "InOut" },
			},
			["Torso.Right Leg"] = {
				{ 0,   A(-5, 0, 12),  "Sine", "InOut" },
				{ 108, A(-5, 0, 12),  "Sine", "InOut" },
			},
			["Torso.Left Leg"] = {
				{ 0,   A(-5, 0, 12),  "Sine", "InOut" },
				{ 108, A(-5, 0, 12),  "Sine", "InOut" },
			},
		},
	},
	{
		name = "MA2_PowerUp",
		frames = 96,
		looped = false,
		tracks = {
			-- Frame 0: coiled crouch -> Frame 26: explosive burst -> Frame 96: settled heroic flare
			["Torso"] = {
				{ 0,  CF(0, 0, -0.35) * A(18, 0, 0),   "Quad", "In" },
				{ 26, CF(0, 0, 0.14)  * A(-12, 0, 0),  "Back", "Out" },
				{ 96, CF(0, 0, 0.08)  * A(-7, 0, -6),  "Sine", "Out" },
			},
			["Torso.Head"] = {
				{ 0,  A(18, 0, 0),    "Quad", "In" },
				{ 26, A(-16, 0, 0),   "Back", "Out" },
				{ 96, A(-6, 0, 5),    "Sine", "Out" },
			},
			-- Safe outward angle (-38 to -46 deg) + forward (+24 to +48 deg) so hands never clip head
			["Torso.Right Arm"] = {
				{ 0,  A(-8, 0, 52),   "Quad", "In" },
				{ 26, A(-44, 0, 22),  "Back", "Out" },
				{ 96, A(-34, 0, 28),  "Sine", "Out" },
			},
			["Torso.Left Arm"] = {
				{ 0,  A(-8, 0, -52),  "Quad", "In" },
				{ 26, A(-44, 0, -22), "Back", "Out" },
				{ 96, A(-34, 0, -28), "Sine", "Out" },
			},
			["Torso.Right Leg"] = {
				{ 0,  A(-10, 0, 26),  "Quad", "In" },
				{ 26, A(-14, 0, -14), "Back", "Out" },
				{ 96, A(-12, 0, -10), "Sine", "Out" },
			},
			["Torso.Left Leg"] = {
				{ 0,  A(-10, 0, -26), "Quad", "In" },
				{ 26, A(-14, 0, 14),  "Back", "Out" },
				{ 96, A(-12, 0, 10),  "Sine", "Out" },
			},
		},
	},
	{
		name = "MA2_Shock",
		frames = 72,
		looped = false,
		tracks = {
			["Torso"] = {
				{ 0,  CF(0, 0, 0)     * A(0, 0, 0),    "Cubic", "Out" },
				{ 14, CF(0, 0.25, 0.1)* A(-16, 0, 6),  "Back",  "Out" },
				{ 72, CF(0, 0.15, 0)  * A(-10, 0, 4),  "Sine",  "InOut" },
			},
			["Torso.Head"] = {
				{ 0,  A(0, 0, 0),     "Cubic", "Out" },
				{ 14, A(-14, 6, -4),  "Back",  "Out" },
				{ 72, A(-10, 4, -2),  "Sine",  "InOut" },
			},
			-- Both hands thrown outward & forward in surprise, safely clear of head
			["Torso.Right Arm"] = {
				{ 0,  A(-6, 0, 10),   "Cubic", "Out" },
				{ 14, A(-36, 0, 88),  "Back",  "Out" },
				{ 72, A(-30, 0, 72),  "Sine",  "InOut" },
			},
			["Torso.Left Arm"] = {
				{ 0,  A(-6, 0, -10),  "Cubic", "Out" },
				{ 14, A(-36, 0, -88), "Back",  "Out" },
				{ 72, A(-30, 0, -72), "Sine",  "InOut" },
			},
			["Torso.Right Leg"] = {
				{ 0,  A(-4, 0, 0),    "Cubic", "Out" },
				{ 14, A(-10, 0, 18),  "Back",  "Out" },
				{ 72, A(-8, 0, 14),   "Sine",  "InOut" },
			},
			["Torso.Left Leg"] = {
				{ 0,  A(-4, 0, 0),    "Cubic", "Out" },
				{ 14, A(-10, 0, -18), "Back",  "Out" },
				{ 72, A(-8, 0, -14),  "Sine",  "InOut" },
			},
		},
	},
	{
		name = "MA2_HeroGrin",
		frames = 96,
		looped = true,
		tracks = {
			["Torso"] = {
				{ 0,  CF(0, 0, 0.03) * A(-5, 0, 14),  "Quad", "InOut" },
				{ 48, CF(0, 0, 0.08) * A(-8, 2, 18),  "Quad", "InOut" },
				{ 96, CF(0, 0, 0.03) * A(-5, 0, 14),  "Quad", "InOut" },
			},
			["Torso.Head"] = {
				{ 0,  A(-4, -3, -12), "Quad", "InOut" },
				{ 48, A(-7, -5, -16), "Quad", "InOut" },
				{ 96, A(-4, -3, -12), "Quad", "InOut" },
			},
			["Torso.Right Arm"] = {
				{ 0,  A(-28, 0, 48),  "Quad", "InOut" },
				{ 48, A(-32, 0, 62),  "Quad", "InOut" },
				{ 96, A(-28, 0, 48),  "Quad", "InOut" },
			},
			["Torso.Left Arm"] = {
				{ 0,  A(-18, 0, -16), "Quad", "InOut" },
				{ 48, A(-20, 0, -24), "Quad", "InOut" },
				{ 96, A(-18, 0, -16), "Quad", "InOut" },
			},
			["Torso.Right Leg"] = {
				{ 0,  A(-8, 0, 10),   "Quad", "InOut" },
				{ 96, A(-8, 0, 10),   "Quad", "InOut" },
			},
			["Torso.Left Leg"] = {
				{ 0,  A(-8, 0, 10),   "Quad", "InOut" },
				{ 96, A(-8, 0, 10),   "Quad", "InOut" },
			},
		},
	},
}

local exportedReport = {}

for _, spec in ipairs(ANIMS) do
	local file = makeMoon2File(spec.name, spec.frames, spec.looped, spec.tracks)
	local opened = MAWin.OpenFile(file, true)
	assert(opened, "Moon Animator 2 failed to OpenFile: " .. spec.name)
	MAWin.ExportRigs(true)
	MAWin.CloseFile()

	local animSaves = rig:FindFirstChild("AnimSaves")
	local seq = animSaves and animSaves:FindFirstChild(spec.name)
	assert(seq and seq:IsA("KeyframeSequence"), "Exported KeyframeSequence missing for: " .. spec.name)
	seq.Parent = moonAnims
	table.insert(exportedReport, string.format("%s: %d keyframes (Loop=%s, Priority=%s)",
		seq.Name, #seq:GetKeyframes(), tostring(seq.Loop), tostring(seq.Priority)))
end

-- Clone Moon Animator 2's built-in R6Walk KeyframeSequence as reusable AnimationTrack
local walkSeq = assert(MG.anis:FindFirstChild("R6Walk"), "Moon Animator 2 built-in R6Walk missing"):Clone()
walkSeq.Name = "MA2_Walk"
walkSeq.Loop = true
walkSeq.Priority = Enum.AnimationPriority.Action
walkSeq.Parent = moonAnims
table.insert(exportedReport, string.format("%s: %d keyframes (Loop=%s, BuiltIn R6Walk)",
	walkSeq.Name, #walkSeq:GetKeyframes(), tostring(walkSeq.Loop)))

-- Clean up temporary UI & rig
pcall(function() MAWin:Close() end)
rig:Destroy()

return "Moon Animator 2 exported " .. #exportedReport .. " animations into ReplicatedStorage.MoonAnims:\n" .. table.concat(exportedReport, "\n")
