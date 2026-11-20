-- STUDIO_TEST_MOONAURA (Story.client.luau)
-- Plays exported Moon Animator 2 AnimationTracks on pure R6 UGC avatars (Jason & Maya),
-- swaps big 2D drawn faces per beat, triggers multi-layer ParticleEmitter auras,
-- and films 8 crisp 1-2 s close-up / push-in shots in ROTATE_90 portrait capture at SLOW = 5.

local SLOW = 5
local ROTATE_90 = true
local DELAY = 6

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local UserInputService = game:GetService("UserInputService")

local cam = workspace.CurrentCamera
local V = Vector3.new
local C3 = Color3.fromRGB

pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
pcall(function() UserInputService.MouseIconEnabled = (SLOW == 1) end)

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
local black = Instance.new("Frame")
black.Size = UDim2.fromScale(1, 1)
black.BackgroundColor3 = Color3.new(0, 0, 0)
black.BorderSizePixel = 0
black.Parent = gui
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------- CAST & SPOTS
local CAST = { "Jason", "Maya" }
local A = {}
for _, n in ipairs(CAST) do A[n] = workspace:WaitForChild(n) end
local spots = workspace:WaitForChild("Set"):WaitForChild("Spots")
local moonAnimsFolder = ReplicatedStorage:WaitForChild("MoonAnims")
task.wait(0.8)

---------------------------------------------------------------- MOON ANIMATOR 2 TRACK LOADER
-- Ensure every ParticleEmitter runs at 1 / SLOW speed
for _, desc in ipairs(workspace:GetDescendants()) do
	if desc:IsA("ParticleEmitter") then
		desc.TimeScale = 1 / SLOW
	end
end

local ANIM_IDS = {}
local TRACKS = {}

local function resolveAnimId(seq)
	local cached = seq:GetAttribute("RegisteredId")
	if typeof(cached) == "string" and cached ~= "" then
		return cached
	end
	local ok, rawId = pcall(function()
		return KeyframeSequenceProvider:RegisterKeyframeSequence(seq)
	end)
	if ok and typeof(rawId) == "string" and rawId ~= "" then
		return rawId
	end
	return nil
end

local function loadAllTracks()
	for _, seq in ipairs(moonAnimsFolder:GetChildren()) do
		if seq:IsA("KeyframeSequence") then
			local id = resolveAnimId(seq)
			if id then
				ANIM_IDS[seq.Name] = id
			end
		end
	end

	for _, name in ipairs(CAST) do
		TRACKS[name] = TRACKS[name] or {}
		local model = A[name]
		local hum = model:FindFirstChildOfClass("Humanoid")
		local animator = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
		if animator then
			for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do tr:Stop(0) end
			for animName, id in pairs(ANIM_IDS) do
				if not TRACKS[name][animName] then
					local animObj = Instance.new("Animation")
					animObj.Name = animName
					animObj.AnimationId = id
					local ok, tr = pcall(function() return animator:LoadAnimation(animObj) end)
					if ok and tr then
						tr.Priority = Enum.AnimationPriority.Action
						TRACKS[name][animName] = tr
					end
				end
			end
		end
	end
end

loadAllTracks()
workspace:GetAttributeChangedSignal("AnimsReady"):Connect(loadAllTracks)

local ACTIVE_TRACK = {}
local ACTIVE_SPEC = {}

-- Play a Moon Animator 2 AnimationTrack in story time
local function pose(actorName, animName, looped, startOffset)
	if not TRACKS[actorName] or not TRACKS[actorName][animName] then
		loadAllTracks()
	end
	local cur = ACTIVE_TRACK[actorName]
	local nextTr = TRACKS[actorName] and TRACKS[actorName][animName]
	if cur and cur ~= nextTr then
		cur:Stop(0)
	end
	ACTIVE_TRACK[actorName] = nextTr
	ACTIVE_SPEC[actorName] = { name = animName, looped = looped ~= false, offset = startOffset or 0 }
	if nextTr then
		nextTr.Looped = (looped ~= false)
		nextTr:Play(0, 1, 1 / SLOW)
		nextTr.TimePosition = math.clamp(startOffset or 0, 0, math.max(0.01, nextTr.Length - 0.01))
		nextTr:AdjustSpeed(1 / SLOW)
	end
end

local function syncTrackTime(actorName, shotElapsed)
	local tr = ACTIVE_TRACK[actorName]
	local spec = ACTIVE_SPEC[actorName]
	if not tr or not spec or tr.Length <= 0 then return end
	local targetPos = spec.offset + shotElapsed
	if spec.looped then
		targetPos = targetPos % tr.Length
	else
		targetPos = math.min(targetPos, math.max(0.01, tr.Length - 0.02))
	end
	if not tr.IsPlaying then
		tr:Play(0, 1, 1 / SLOW)
	end
	if math.abs(tr.TimePosition - targetPos) > 0.08 then
		tr.TimePosition = targetPos
	end
	tr:AdjustSpeed(1 / SLOW)
end

---------------------------------------------------------------- FACE, AURA, POSITION & CAMERA HELPERS
local function face(n, expr)
	local m = A[n]
	local plate = m and m:FindFirstChild("FacePlate")
	local g = plate and plate:FindFirstChild("Face")
	if not g then return end
	for _, layer in ipairs(g:GetChildren()) do
		if layer:IsA("Frame") and layer.BackgroundTransparency == 1 and layer.Size == UDim2.fromScale(1, 1) then
			layer.Visible = (layer.Name == expr)
		end
	end
	m:SetAttribute("Expression", expr)
end

local function aura(n, mode)
	local torso = A[n] and A[n]:FindFirstChild("Torso")
	if not torso then return end
	local flames = torso:FindFirstChild("AuraFlames", true)
	local sparks = torso:FindFirstChild("AuraSparks", true)
	local core = torso:FindFirstChild("AuraCore", true)
	local auraLight = torso:FindFirstChild("AuraLight")

	if mode == "off" then
		if flames then flames.Enabled = false; flames:Clear() end
		if sparks then sparks.Enabled = false; sparks:Clear() end
		if core then core.Enabled = false; core:Clear() end
		if auraLight then auraLight.Brightness = 0 end
	elseif mode == "tiny" then
		if flames then flames.Enabled = false; flames:Clear() end
		if core then core.Enabled = false; core:Clear() end
		if sparks then
			sparks.Rate = 6
			sparks.Enabled = true
			sparks:Clear()
			sparks:Emit(4)
		end
		if auraLight then auraLight.Brightness = 0.45 end
	elseif mode == "full" then
		if flames then flames.Rate = 30; flames.Enabled = true; flames:Emit(14) end
		if sparks then sparks.Rate = 24; sparks.Enabled = true; sparks:Emit(10) end
		if core then core.Rate = 6; core.Enabled = true; core:Emit(3) end
		if auraLight then auraLight.Brightness = 1.15 end
	elseif mode == "burst" then
		if flames then flames.Rate = 42; flames.Enabled = true; flames:Emit(28) end
		if sparks then sparks.Rate = 34; sparks.Enabled = true; sparks:Emit(22) end
		if core then core.Rate = 8; core.Enabled = true; core:Emit(5) end
		if auraLight then auraLight.Brightness = 1.8 end
	end
end

local function rootY(m)
	return m:GetAttribute("RootHeight") or 3
end

local function put(n, pos, look)
	local m = A[n]
	local p = V(pos.X, pos.Y + rootY(m), pos.Z)
	local l = look and V(look.X, p.Y, look.Z) or (p + V(0, 0, 10))
	m:PivotTo(CFrame.lookAt(p, l))
end

local function hide(n)
	A[n]:PivotTo(CFrame.new(0, -200, 0))
	aura(n, "off")
end

local function hideAll()
	for _, n in ipairs(CAST) do hide(n) end
end

local function S(name) return spots[name].Position end
local function headOf(n) return A[n].Head.Position end
local function ease(a) return a * a * (3 - 2 * a) end

local function on(n, off0, off1, fov, lookOff)
	return function(a)
		local root = A[n].HumanoidRootPart.CFrame
		local h = headOf(n) + (lookOff or V(0, -0.35, 0))
		return h + root:VectorToWorldSpace(off0:Lerp(off1 or off0, a)), h, fov
	end
end

local dofFx = Lighting:FindFirstChildOfClass("DepthOfFieldEffect") or Instance.new("DepthOfFieldEffect", Lighting)
local bloomFx = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect", Lighting)
local ccFx = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)

local function blur(focus, radius, far)
	dofFx.Enabled = focus ~= nil
	if focus then
		dofFx.FocusDistance = focus
		dofFx.InFocusRadius = radius or 3.2
		dofFx.FarIntensity = far or 0.72
		dofFx.NearIntensity = 0
	end
end

local function setMoodGrade(warmBoost, bloomInt)
	bloomFx.Intensity = bloomInt or 0.42
	if warmBoost then
		ccFx.TintColor = C3(255, 236, 206)
		ccFx.Contrast = 0.18
		ccFx.Saturation = 0.26
	else
		ccFx.TintColor = C3(255, 240, 222)
		ccFx.Contrast = 0.14
		ccFx.Saturation = 0.22
	end
end

---------------------------------------------------------------- SHOTS (10.6 s, 8 crisp 1-2 s beats)
local burstDone = false

local SHOTS = {
	-- 1. HOOK (0.00 - 1.95s): Golden aura shocked close-up push-in on Jason
	{ 0.00, function()
		hideAll()
		setMoodGrade(true, 0.50)
		put("Jason", S("JasonSpot"), S("JasonSpot") + V(0, 0, 12))
		pose("Jason", "MA2_PowerUp", false, 0.45)
		face("Jason", "shocked")
		aura("Jason", "full")
		blur(5.2, 3.0, 0.75)
	end, on("Jason", V(0.55, 0.05, -6.2), V(0.25, 0.0, -4.4), 40) },

	-- 2. FLASHBACK (1.95 - 3.30s): "Five seconds earlier..." worried close-up push-in
	{ 1.95, function()
		hideAll()
		setMoodGrade(false, 0.35)
		put("Jason", S("JasonSpot"), S("JasonSpot") + V(0, 0, 12))
		pose("Jason", "MA2_Worried", true, 0.0)
		face("Jason", "worried")
		aura("Jason", "tiny")
		blur(5.6, 3.2, 0.70)
	end, on("Jason", V(-0.65, 0.12, -6.4), V(-0.4, 0.05, -5.0), 40) },

	-- 3. ZERO POWER BEAT (3.30 - 4.45s): "...I had zero power." tighter low/side close-up
	{ 3.30, function()
		face("Jason", "sad")
		aura("Jason", "tiny")
		blur(4.8, 2.8, 0.76)
	end, on("Jason", V(1.3, 0.35, -5.4), V(0.9, 0.2, -4.3), 39, V(0, -0.5, 0)) },

	-- 4. MAYA WALKS OVER (4.45 - 5.70s): "She walked over..." Moon Animator 2 built-in R6Walk track
	{ 4.45, function()
		hideAll()
		setMoodGrade(false, 0.38)
		put("Maya", S("MayaStart"), S("MayaSpot"))
		pose("Maya", "MA2_Walk", true, 0.0)
		face("Maya", "smug")
		aura("Maya", "full")
		blur(7.2, 3.8, 0.65)
	end, function(a)
		local root = A.Maya.HumanoidRootPart.CFrame
		local h = headOf("Maya") + V(0, -0.35, 0)
		return h + root:VectorToWorldSpace(V(0.7, 0.2, -7.8 + a * 1.4)), h, 42
	end, function(t, a)
		local p = S("MayaStart"):Lerp(S("MayaSpot"), a)
		put("Maya", p, S("JasonSpot"))
	end },

	-- 5. MAYA SMIRK CLOSE-UP (5.70 - 6.75s): "...smirking at my tiny spark."
	{ 5.70, function()
		put("Maya", S("MayaSpot"), S("JasonSpot"))
		pose("Maya", "MA2_Smug", true, 0.0)
		face("Maya", "smug")
		aura("Maya", "full")
		blur(5.0, 3.0, 0.75)
	end, on("Maya", V(0.55, 0.05, -5.8), V(0.3, 0.0, -4.5), 39) },

	-- 6. LOCK IN & BOOM (6.75 - 8.25s): "I took one breath, boom!"
	{ 6.75, function()
		hideAll()
		burstDone = false
		setMoodGrade(false, 0.38)
		put("Jason", S("JasonSpot"), S("JasonSpot") + V(0, 0, 12))
		pose("Jason", "MA2_PowerUp", false, 0.0)
		face("Jason", "worried")
		aura("Jason", "tiny")
		blur(5.4, 3.2, 0.72)
	end, on("Jason", V(-0.45, -0.25, -6.4), V(-0.15, 0.0, -4.5), 40), function(t, a)
		if a >= 0.45 and not burstDone then
			burstDone = true
			face("Jason", "grin")
			aura("Jason", "burst")
			setMoodGrade(true, 0.60)
		end
	end },

	-- 7. MAYA RECOIL (8.25 - 9.15s): "Now nobody messes..." Maya shocked close-up
	{ 8.25, function()
		hideAll()
		setMoodGrade(true, 0.42)
		put("Maya", S("MayaSpot"), S("JasonSpot"))
		pose("Maya", "MA2_Shock", false, 0.0)
		face("Maya", "shocked")
		aura("Maya", "off")
		blur(5.0, 3.0, 0.75)
	end, on("Maya", V(-0.45, 0.1, -5.8), V(-0.2, 0.05, -4.4), 39) },

	-- 8. HERO PAYOFF (9.15 - 10.60s): "...with my backpack again!" 3/4 close-up showing cap, hair, hoodie & backpack
	{ 9.15, function()
		hideAll()
		setMoodGrade(true, 0.50)
		put("Jason", S("JasonSpot"), S("JasonSpot") + V(0, 0, 12))
		pose("Jason", "MA2_HeroGrin", true, 0.0)
		face("Jason", "grin")
		aura("Jason", "full")
		blur(5.4, 3.2, 0.74)
	end, on("Jason", V(3.3, 0.2, -4.5), V(2.5, 0.15, -3.8), 40, V(0, -0.45, 0)) },
}

local LENGTH = 10.6

---------------------------------------------------------------- RUNNER
local T0, live, shotIdx = nil, false, 0
cam.CameraType = Enum.CameraType.Scriptable

RunService:BindToRenderStep("StoryCamera", Enum.RenderPriority.Camera.Value + 1, function()
	cam.CameraType = Enum.CameraType.Scriptable
	black.Visible = not live
	if not live then return end

	local t = (os.clock() - T0) / SLOW
	if t >= LENGTH then
		live = false
		return
	end

	local i = 1
	for k, s in ipairs(SHOTS) do
		if t >= s[1] then i = k end
	end
	local s = SHOTS[i]
	if i ~= shotIdx then
		shotIdx = i
		s[2]()
	end

	local shotElapsed = t - s[1]
	local stop = SHOTS[i + 1] and SHOTS[i + 1][1] or LENGTH
	local a = math.clamp(shotElapsed / (stop - s[1]), 0, 1)
	if s[4] then s[4](t, a) end

	for _, n in ipairs(CAST) do
		if A[n].HumanoidRootPart.Position.Y > -100 then
			syncTrackTime(n, shotElapsed)
		end
	end

	local eye, target, fov = s[3](ease(a))
	if ROTATE_90 then
		cam.FieldOfView = math.clamp(fov * 0.65, 24, 42)
		cam.CFrame = CFrame.lookAt(eye, target) * CFrame.Angles(0, 0, math.rad(-90))
	else
		cam.FieldOfView = fov
		cam.CFrame = CFrame.lookAt(eye, target)
	end
end)

workspace:GetAttributeChangedSignal("Go"):Connect(function()
	task.wait(DELAY)
	shotIdx = 0
	T0 = os.clock()
	live = true
end)
