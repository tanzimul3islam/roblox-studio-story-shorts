-- MODERN KIT (client): the shot engine. Everything that moves runs here, in story time.
-- Keep the ENGINE part; rewrite CAST, SHOTS and LENGTH per story (see
-- references/shot-engine.md and references/art-direction.md).
--
-- SLOW-MOTION CAPTURE: Studio under Wine renders ~12 fps while OBS records, so the take plays
-- SLOW times slower and render.sh speeds it back up (~60 rendered frames per story second).
-- Screen is black until "Go" is set on the client, and again after the take.
local SLOW = 5
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local cam = workspace.CurrentCamera
local V = Vector3.new

pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset, gui.DisplayOrder = true, 100
local black = Instance.new("Frame")
black.Size, black.BackgroundColor3, black.BorderSizePixel = UDim2.fromScale(1, 1), Color3.new(0, 0, 0), 0
black.Parent = gui
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------- CAST (names built by Server.luau)
local CAST = { "Milo", "Rose", "Lily", "Andre", "Noah", "Pip", "Claire" }

---------------------------------------------------------------- ENGINE
local A = {}
for _, n in ipairs(CAST) do A[n] = workspace:WaitForChild(n) end
local spots = workspace:WaitForChild("Set"):WaitForChild("Spots")
task.wait(1)

-- PROCEDURAL POSES (no animation assets): Roblox's stock animation IDs started returning
-- HTTP 403 in Studio (Nov 2026), so bodies are posed here by setting Motor6D.Transform
-- every frame from story time. Deterministic, never fails to load, and slows down
-- correctly with SLOW. Measured R15 axes: the rig faces -Z; RightShoulder +Z raises the arm
-- sideways (Left is mirrored, -Z); shoulders/hips +X swing forward; knees bend with -X;
-- elbows bend with +X; Waist -X leans forward; Neck -X nods down, Y turns the head.
local R, PI = CFrame.Angles, math.pi
local function sn(x) return math.sin(x) end
local POSE = {}
POSE.idle = function(t) return { Waist = R(0.02 * sn(t * 2), 0, 0), Neck = R(0, 0.12 * sn(t * 0.7), 0),
	RS = R(0, 0, 0.06 + 0.02 * sn(t * 2)), LS = R(0, 0, -0.06 - 0.02 * sn(t * 2)) } end
POSE.talk = function(t) return { Waist = R(0.02 * sn(t * 2), 0, 0), Neck = R(-0.05 + 0.06 * sn(t * 5), 0.1 * sn(t), 0),
	RS = R(0.4 + 0.2 * sn(t * 3), 0, 0.15), RE = R(0.9 + 0.2 * sn(t * 3.4), 0, 0), LS = R(0.1, 0, -0.1) } end
POSE.walk = function(t)
	local w = t * 2 * PI * 0.9
	local s, c = sn(w), math.cos(w)
	return { Root = CFrame.new(0, 0.08 * math.abs(s), 0), Waist = R(-0.05, 0.08 * s, 0),
		RH = R(0.55 * s, 0, 0), LH = R(-0.55 * s, 0, 0),
		RK = R(-0.15 - 0.55 * math.max(0, -c), 0, 0), LK = R(-0.15 - 0.55 * math.max(0, c), 0, 0),
		RS = R(-0.45 * s, 0, 0.06), LS = R(0.45 * s, 0, -0.06), RE = R(0.35, 0, 0), LE = R(0.35, 0, 0) }
end
POSE.run = function(t)
	local w = t * 2 * PI * 1.5
	local s, c = sn(w), math.cos(w)
	return { Root = CFrame.new(0, 0.18 * math.abs(s), 0), Waist = R(-0.18, 0.1 * s, 0),
		RH = R(0.9 * s, 0, 0), LH = R(-0.9 * s, 0, 0),
		RK = R(-0.3 - 1.0 * math.max(0, -c), 0, 0), LK = R(-0.3 - 1.0 * math.max(0, c), 0, 0),
		RS = R(-0.8 * s, 0, 0.1), LS = R(0.8 * s, 0, -0.1), RE = R(1.2, 0, 0), LE = R(1.2, 0, 0) }
end
POSE.wave = function(t) return { Neck = R(0, -0.15, 0.08), Waist = R(0.02, 0, 0),
	RS = R(0.2, 0, 2.5 + 0.25 * sn(t * 8)), RE = R(0.4 + 0.3 * sn(t * 8), 0, 0), LS = R(0, 0, -0.08) } end
POSE.cheer = function(t)
	local b = math.abs(sn(t * 5))
	return { Root = CFrame.new(0, 0.35 * b, 0), RS = R(0, 0, 2.75 + 0.15 * sn(t * 10)), LS = R(0, 0, -2.75 - 0.15 * sn(t * 10)),
		RE = R(0.2, 0, 0), LE = R(0.2, 0, 0), RK = R(-0.4 * (1 - b), 0, 0), LK = R(-0.4 * (1 - b), 0, 0), Neck = R(0.15, 0, 0) }
end
POSE.point = function(t) return { RS = R(1.5, 0, 0.1), RE = R(0.05, 0, 0), Waist = R(-0.03, -0.12, 0), LS = R(0, 0, -0.08),
	Neck = R(0, -0.1, 0) } end
POSE.laugh = function(t)
	local k = math.abs(sn(t * 11))
	return { Waist = R(-0.18 - 0.1 * k, 0, 0), Neck = R(0.25 + 0.08 * k, 0, 0),
		RS = R(0.5, 0, 0.15), RE = R(1.3, 0, 0), LS = R(0.5, 0, -0.15), LE = R(1.3, 0, 0), Root = CFrame.new(0, 0.05 * k, 0) }
end
POSE.sad = function(t) return { Neck = R(-0.4, 0, 0), Waist = R(-0.12, 0, 0), RS = R(0.05, 0, -0.04), LS = R(0.05, 0, 0.04) } end
POSE.think = function(t) return { Neck = R(0.15, 0.2, 0.1), RS = R(1.1, 0, 0.5), RE = R(1.9, 0, 0), LS = R(0.6, 0, -0.3), LE = R(1.4, 0, 0) } end
POSE.sit = function(t) return { Root = CFrame.new(0, -1.15, 0.3), RH = R(1.5, 0, 0), LH = R(1.5, 0, 0), RK = R(-1.5, 0, 0), LK = R(-1.5, 0, 0),
	RS = R(0.35, 0, 0.05), LS = R(0.35, 0, -0.05), RE = R(0.5, 0, 0), LE = R(0.5, 0, 0), Waist = R(0.02 * sn(t * 2), 0, 0) } end
POSE.jump = function(t)
	local h = math.abs(sn(t * PI * 1.2))
	return { Root = CFrame.new(0, 1.4 * h, 0), RK = R(-0.9 * (1 - h), 0, 0), LK = R(-0.9 * (1 - h), 0, 0),
		RH = R(0.5 * (1 - h), 0, 0), LH = R(0.5 * (1 - h), 0, 0), RS = R(0, 0, 0.6 + 1.6 * h), LS = R(0, 0, -0.6 - 1.6 * h) }
end
POSE.dance = function(t)
	local b, s = math.abs(sn(t * 4)), sn(t * 4)
	return { Root = CFrame.new(0, 0.22 * b, 0), Waist = R(0, 0.25 * sn(t * 2), 0.12 * s),
		RS = R(0, 0, 1.3 + 0.8 * s), LS = R(0, 0, -1.3 + 0.8 * s), RE = R(0.6, 0, 0), LE = R(0.6, 0, 0),
		RH = R(0.2 * s, 0, 0), LH = R(-0.2 * s, 0, 0), RK = R(-0.3 * b, 0, 0), LK = R(-0.3 * b, 0, 0) }
end
POSE.dance2 = function(t)
	local s = sn(t * 6)
	return { Root = CFrame.new(0, 0.15 * math.abs(s), 0), Waist = R(-0.05, 0.2 * s, 0),
		RS = R(1.2 + 0.6 * s, 0, 0.2), LS = R(1.2 - 0.6 * s, 0, -0.2), RE = R(1.1, 0, 0), LE = R(1.1, 0, 0),
		RK = R(-0.35 * math.abs(s), 0, 0), LK = R(-0.35 * math.abs(s), 0, 0) }
end
POSE.dance3 = function(t)
	local s = sn(t * 2 * PI * 0.6)
	return { Root = CFrame.new(0.45 * s, 0.15 * math.abs(sn(t * 4)), 0), Waist = R(0, 0, -0.1 * s),
		RS = R(0, 0, 2.3 + 0.4 * sn(t * 4)), LS = R(0, 0, -2.3 - 0.4 * sn(t * 4)), RE = R(0.3, 0, 0), LE = R(0.3, 0, 0),
		RH = R(0, 0, 0.12 * s), LH = R(0, 0, 0.12 * s) }
end
local JOINT = { Root = { "LowerTorso", "Root" }, Waist = { "UpperTorso", "Waist" }, Neck = { "Head", "Neck" },
	RS = { "RightUpperArm", "RightShoulder" }, RE = { "RightLowerArm", "RightElbow" },
	LS = { "LeftUpperArm", "LeftShoulder" }, LE = { "LeftLowerArm", "LeftElbow" },
	RH = { "RightUpperLeg", "RightHip" }, RK = { "RightLowerLeg", "RightKnee" },
	LH = { "LeftUpperLeg", "LeftHip" }, LK = { "LeftLowerLeg", "LeftKnee" } }
-- classic blocky (R6) rigs: Motor6Ds live in their Part0; no waist, elbows or knees, so the
-- waist rotation is folded into the root and elbow/knee poses are simply ignored
local JOINT6 = { Root = { "HumanoidRootPart", "RootJoint" }, Neck = { "Torso", "Neck" },
	RS = { "Torso", "Right Shoulder" }, LS = { "Torso", "Left Shoulder" },
	RH = { "Torso", "Right Hip" }, LH = { "Torso", "Left Hip" } }
local MOTORS, STATE, CLASSIC = {}, {}, {}
for n, m in pairs(A) do
	MOTORS[n] = {}
	CLASSIC[n] = m:FindFirstChild("Torso") ~= nil
	for j, path in pairs(CLASSIC[n] and JOINT6 or JOINT) do
		local part = m:FindFirstChild(path[1])
		MOTORS[n][j] = part and part:FindFirstChild(path[2])
	end
	local hum = m:FindFirstChildOfClass("Humanoid")
	local animator = hum and hum:FindFirstChildOfClass("Animator")
	if animator then for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do tr:Stop(0) end end
	STATE[n] = { k = "idle", prev = "idle", since = -10, phase = #n * 0.37 }
end
local storyT = 0 -- updated by the runner every frame
-- anim(name, pose): switch pose with a 0.25 s (story time) blend
local function anim(n, k)
	local st = STATE[n]
	if st.k == k then return end
	assert(POSE[k], "unknown pose " .. tostring(k))
	st.prev, st.k, st.since = st.k, k, storyT
end
local function applyPoses(t)
	for n, m in pairs(A) do
		if m.HumanoidRootPart.Position.Y > -100 then
			local st = STATE[n]
			local tt = t + st.phase
			local cur = POSE[st.k](tt)
			local w = math.clamp((t - st.since) / 0.25, 0, 1)
			local old = w < 1 and POSE[st.prev](tt) or nil
			if CLASSIC[n] then  -- fold the waist into the root (R6 has no waist joint)
				cur.Root = (cur.Root or CFrame.identity) * (cur.Waist or CFrame.identity)
				if old then old.Root = (old.Root or CFrame.identity) * (old.Waist or CFrame.identity) end
			end
			for j, mo in pairs(MOTORS[n]) do
				local c = cur[j] or CFrame.identity
				if old then c = (old[j] or CFrame.identity):Lerp(c, w) end
				mo.Transform = c
			end
		end
	end
end
local function rootY(m)
	local h = m:GetAttribute("RootHeight")  -- classic rigs say how high their root sits
	if h then return h end
	return m:FindFirstChildOfClass("Humanoid").HipHeight + m.HumanoidRootPart.Size.Y / 2
end
-- face(name, expression): classic rigs carry every expression on the face plate; show one.
-- smile, grin, laugh, happy, angry, stern, worried, dizzy, shocked, smug, sad, neutral
local function face(n, expr)
	local plate = A[n]:FindFirstChild("FacePlate")
	local g = plate and plate:FindFirstChild("Face")
	if not g then return end
	for _, layer in ipairs(g:GetChildren()) do
		if layer:IsA("Frame") and layer.BackgroundTransparency == 1 and layer.Size == UDim2.fromScale(1, 1) then
			layer.Visible = (layer.Name == expr)
		end
	end
end
-- put(name, position, lookAtPoint): stands the rig on the floor at position.Y (0 = ground)
local function put(n, pos, look)
	local m = A[n]
	local p = V(pos.X, pos.Y + rootY(m), pos.Z)
	local l = look and V(look.X, p.Y, look.Z) or (p + V(0, 0, 10))
	m:PivotTo(CFrame.lookAt(p, l))
end
local function hide(n) A[n]:PivotTo(CFrame.new(0, -200, 0)) end
local function hideAll() for n in pairs(A) do hide(n) end end
local function S(name) return spots[name].Position end           -- spot position (floor level)
local function headOf(n) return A[n].Head.Position end
local function ease(a) return a * a * (3 - 2 * a) end
-- camera that moves from (eye0, look0) to (eye1, look1) over the shot
local function move(e0, e1, l0, l1, fov)
	return function(a) return e0:Lerp(e1, a), l0:Lerp(l1 or l0, a), fov end
end
-- camera framed on an actor's face. Offsets are in the ACTOR's own frame: -Z is in front of
-- the face, +X is the actor's right. on("Leo", V(1, 0.3, -6)) = 6 studs in front, a bit to
-- his right, slightly above eye level, so faces are always seen whichever way they stand.
local function on(n, off0, off1, fov, lookOff)
	return function(a)
		local root = A[n].HumanoidRootPart.CFrame
		local h = headOf(n) + (lookOff or V(0, -0.3, 0))
		return h + root:VectorToWorldSpace(off0:Lerp(off1 or off0, a)), h, fov
	end
end

---------------------------------------------------------------- SHOTS (rewrite per story)
-- { start (story s), setup(), camera(a) -> eye, look, fov, perFrame(t, a)? }
-- House style (the user's reference shorts): close, eye-level shots, faces big in frame,
-- the background softly blurred (blur(focusDistance)) and a new expression per beat (face()).
local dofFx = Lighting:FindFirstChildOfClass("DepthOfFieldEffect") or Instance.new("DepthOfFieldEffect", Lighting)
local function blur(focus)  -- focus = camera-to-subject distance; nil turns it off
	dofFx.Enabled = focus ~= nil
	if focus then dofFx.FocusDistance, dofFx.InFocusRadius, dofFx.FarIntensity, dofFx.NearIntensity = focus, 4, 0.55, 0 end
end
local function lineup(spacing, poses)
	local base = S("Playground") + V(0, 0, 3)
	for i, n in ipairs(CAST) do put(n, base + V((i - 4) * spacing, 0, 0)); anim(n, poses and poses[i] or "idle") end
end
local SHOTS = {
	-- HOOK (0-2 s, mandatory): open on the strongest moment, already moving. Here: Claire's
	-- angry face on the swing with a fast push-in and a blurred background.
	{ 0.0, function()
		hideAll()
		-- seated: root = seat top + torso half-height + sit drop (1.15) - standing root height (3)
		put("Claire", S("Swing1") + V(0, -0.85, 0.2), S("Swing1") + V(0, 0, 10)); anim("Claire", "sit"); face("Claire", "angry")
		put("Noah", S("Playground") + V(3, 0, 1), S("Swing1")); anim("Noah", "point"); face("Noah", "shocked")
		put("Pip", S("Playground") + V(4.5, 0, 2.5), S("Swing1")); anim("Pip", "idle"); face("Pip", "laugh")
		blur(6)
	end, on("Claire", V(0.8, 0.3, -12), V(0.4, 0.15, -5.5), 40, V(0, -0.4, 0)) },
	{ 2.0, function() blur(nil) end, move(V(-2, 7, 24), V(-1, 6.5, 21), V(0, 3.5, -2), nil, 52) },  -- then establish
	{ 3.5, function() blur(7) end, on("Noah", V(-0.6, 0.2, -7), V(-0.5, 0.15, -6), 40, V(0, -0.5, 0)) },   -- Noah shocked
	{ 5.0, function() face("Noah", "grin"); anim("Noah", "talk") end, on("Noah", V(-0.8, 0.2, -7.5), V(-0.6, 0.15, -6.5), 40, V(0, -0.5, 0)) },
	{ 7.0, function()  -- cooking class
		hideAll(); blur(nil)
		local c = S("CookingClass")
		put("Milo", c + V(-4, 0, -3.6), c + V(-4, 0, 10)); anim("Milo", "talk"); face("Milo", "grin")
		put("Rose", c + V(1, 0, -3.6), c + V(1, 0, 10)); anim("Rose", "laugh"); face("Rose", "laugh")
		put("Lily", c + V(5.5, 0, 0.4), c + V(5.5, 0, 10)); anim("Lily", "wave"); face("Lily", "smile")
	end, move(V(400, 6.5, 17), V(401, 6, 14), V(400, 3.5, -3), nil, 55) },
	{ 10.0, function() face("Milo", "dizzy"); anim("Milo", "sad"); blur(7) end, on("Milo", V(0.5, 0.2, -6.5), V(0.4, 0.15, -5.8), 40, V(0, -0.4, 0)) },
	{ 12.0, function() face("Rose", "laugh"); face("Lily", "happy"); blur(9) end,  -- grandma + granddaughter two-shot
		function(a)
			local mid = (A.Rose.Head.Position + A.Lily.Head.Position) / 2
			return mid + V(-0.5, 0.5, 9.5 - a), mid - V(0, 0.6, 0), 45
		end },
	{ 14.5, function()  -- restaurant: the chef
		hideAll()
		local r = S("Restaurant")
		put("Andre", r + V(0, 0, -4), r + V(0, 0, 10)); anim("Andre", "idle"); face("Andre", "stern"); blur(7)
	end, on("Andre", V(0, 0.1, -7), V(0, 0.05, -6), 42, V(0, -0.8, 0)) },
	{ 17.0, function()  -- cozy room: Noah and Pip
		hideAll(); blur(nil)
		local c = S("CozyRoom")
		put("Noah", c + V(-1.5, 0, -1)); anim("Noah", "wave"); face("Noah", "smile")
		put("Pip", c + V(1.5, 0, 0)); anim("Pip", "dance"); face("Pip", "laugh")
	end, move(V(440, 5.5, 14), V(440, 5, 11), V(440, 3, -2), nil, 50) },
	{ 19.5, function() hideAll(); blur(nil); lineup(4, { "wave", "laugh", "cheer", "idle", "talk", "dance", "point" }) end,
		move(V(0, 6, 25), V(0, 5.5, 21), V(0, 3.2, 3), nil, 55) },
}
-- one close-up per character, each with a different expression (0.8 s each)
local EXPR = { "grin", "laugh", "smile", "angry", "smug", "laugh", "worried" }
for i, n in ipairs(CAST) do
	table.insert(SHOTS, { 22.0 + (i - 1) * 0.8, function()
		hideAll(); lineup(4); face(n, EXPR[i]); anim(n, "talk"); blur(6.5)
	end, on(n, V(0.4, 0.15, -6.5), V(0.35, 0.1, -6), 40, V(0, -0.5, 0)) })
end
local LENGTH = 27.8

---------------------------------------------------------------- RUN (keep)
local T0, live, shotIdx = nil, false, 0
cam.CameraType = Enum.CameraType.Scriptable
RunService:BindToRenderStep("StoryCamera", Enum.RenderPriority.Camera.Value + 1, function()
	cam.CameraType = Enum.CameraType.Scriptable
	black.Visible = not live
	if not live then return end
	local t = (os.clock() - T0) / SLOW -- story time in seconds of narration.wav
	if t >= LENGTH then live = false; return end
	storyT = t
	local i = 1
	for k, s in ipairs(SHOTS) do if t >= s[1] then i = k end end
	local s = SHOTS[i]
	if i ~= shotIdx then
		shotIdx = i
		s[2]()
		for _, st in pairs(STATE) do st.since = math.min(st.since, t - 1) end -- hard cut: no blend across shots
	end
	local stop = SHOTS[i + 1] and SHOTS[i + 1][1] or LENGTH
	local a = math.clamp((t - s[1]) / (stop - s[1]), 0, 1)
	if s[4] then s[4](t, a) end
	applyPoses(t)
	local eye, target, fov = s[3](ease(a))
	cam.FieldOfView = fov
	cam.CFrame = CFrame.lookAt(eye, target)
end)

-- Start a take: set workspace attribute "Go" on the client. The take begins DELAY real
-- seconds later (black until then); in the recording it lasts LENGTH * SLOW seconds.
local DELAY = 6
workspace:GetAttributeChangedSignal("Go"):Connect(function()
	task.wait(DELAY)
	shotIdx = 0
	T0 = os.clock()
	live = true
end)
