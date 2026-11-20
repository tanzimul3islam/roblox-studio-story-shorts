# Scene scripts, Moon Animator 2 tracks, and the shot engine

Start from `templates/moon_aura_kit/` (for **pure R6 UGC avatars + Moon Animator 2 `AnimationTrack`s +
Roblox `ParticleEmitter` auras**) or `templates/modern_kit/` (for code-built classic rigs + procedural
Motor6D poses). Copy the folder to `/var/mnt/sda3/Roblox_Shorts/studio/<scene_name>/` and edit;
do not start from scratch. Modern-kit / Moon-Aura helpers on the client: `put(name, pos, lookAt)`
with Vector3 positions (y = floor), `S("SpotName")` for a spot's position, `on(name, off0,
off1, fov)` for a camera framed on an actor's head, `move(...)` for a moving camera, `pose(name,
animName, looped, startOffset)` for Moon Animator 2 `AnimationTrack`s, `face(name, expr)` for
per-beat 2D face switching, `aura(name, mode)` for particle auras, and `blur(focus, radius, far)`
for `DepthOfFieldEffect`.

## Split of work (important)
- **BuildMoonAnims.luau** (Edit mode, before playtest): uses the installed **Moon Animator 2**
  plugin (`_G.MoonGlobal`) to author `.moon2` save files in `ServerStorage.MoonAnimator2Saves`
  and run Moon Animator 2's own `OpenFile` -> `ExportRigs(true)` -> `CloseFile()` pipeline,
  exporting eased 60 FPS `KeyframeSequence`s (plus Moon Animator 2's built-in `R6Walk`) into
  `ReplicatedStorage.MoonAnims`.
- **Server.luau** builds static things: high-quality lighting (`Level21`, `Future`, soft shadows,
  warm `Atmosphere` fog, `BloomEffect` with `Threshold = 1.95`, `ColorCorrectionEffect`,
  `SunRaysEffect`, `DepthOfFieldEffect`), the set (parts in a `Set` folder), and the actors
  (`Players:CreateHumanoidModelFromDescription(..., Enum.HumanoidRigType.R6)` for pure R6 UGC
  avatars or `CL.build` for code-built rigs, `HumanoidRootPart.Anchored = true`, limbs and
  accessory handles unanchored & massless, `Animate` script removed, `FacePlate` and `ParticleEmitter`
  auras attached, parked at y = -200). Actor creation must stay on the server; it fails on the client.
- **Story.client.luau** does everything that moves or changes: actor placement, Moon Animator 2
  `AnimationTrack` playback (or procedural poses), `face(name, expr)`, `aura(name, mode)`,
  `blur(focus)`, lighting grade tweaks, and the camera.

Why: in Studio under Wine, server-driven motion replicated to the client 30+ s late, so the camera
filmed a frozen scene. Client-side changes render immediately and are never replicated, which is
exactly what a recording needs.

## Moon Animator 2 plugin pipeline (`BuildMoonAnims.luau` + `AnimationTrack` sync)
The installed Moon Animator 2 plugin (`/home/tanzimul/.tuxblox/roblox/Plugins/RobloxMoonAnim.rbxmx`)
exposes `_G.MoonGlobal` in Studio:
1. **R6 hierarchy & C1 keyframe math:**
   - Moon Animator 2's built-in R6 rig is `_G.MoonGlobal.rigs.R6`, and its built-in R6 walk is
     `_G.MoonGlobal.anis.R6Walk` (22 keyframes, `0.667 s` loop).
   - `_G.MoonGlobal.RigHierarchy(rig)` paths for R6 are: `"Torso"` (`RootJoint`), `"Torso.Head"`
     (`Neck`), `"Torso.Right Arm"` (`Right Shoulder`), `"Torso.Left Arm"` (`Left Shoulder`),
     `"Torso.Right Leg"` (`Right Hip`), `"Torso.Left Leg"` (`Left Hip`).
   - In `.moon2` files, `MotorTrack` animates `Motor6D.C1` and `_G.MoonGlobal.ExportItemObject`
     computes `Pose.CFrame = value:toObjectSpace(defaultValue) = keyframeC1:Inverse() * restC1`.
     Therefore, to get a desired `Motor6D.Transform` in the exported `KeyframeSequence`, store:
     ```lua
     v0.Value = restC1 * desiredTransform:Inverse()
     ```
   - Measured standard R6 `Transform` axes:
     - `Torso` (`RootJoint`): pos `+Z` = up, `-Z` = crouch down; rot `+X` = lean forward, `-X` = lean back, `+Z` = yaw left.
     - `Head` (`Neck`): rot `+X` = nod down, `-X` = look up, `+Y` = tilt left, `+Z` = turn left.
     - `Right Arm` (`Right Shoulder`): rot `+Z` = swing forward, `-Z` = swing back, `-X` = raise outward (`+X` world).
     - `Left Arm` (`Left Shoulder`): rot `-Z` = swing forward, `+Z` = swing back, `-X` = raise outward (`-X` world).
     - `Right Leg` (`Right Hip`): rot `+Z` = swing forward, `-Z` = swing back, `-X` = widen outward.
     - `Left Leg` (`Left Hip`): rot `-Z` = swing forward, `+Z` = swing back, `-X` = widen outward.
2. **Runtime `AnimationTrack` registration & playback on Client:**
   - Register each `KeyframeSequence` in `ReplicatedStorage.MoonAnims` with
     `KeyframeSequenceProvider:RegisterKeyframeSequence(seq)`.
   - **Important:** `RegisterKeyframeSequence` returns a 32-character hex hash (e.g.
     `"a970fbdda1998499e9d5db6f8931fdc7"`). Assign that raw hash **directly** to
     `anim.AnimationId = id`. Never prepend `"rbxassetid://"` to a 32-char hash (Roblox sanitizes
     `"rbxassetid://1b72..."` into `"rbxassetid://1"`, causing asset-not-found errors).
   - Play tracks at `1 / SLOW` speed (`track:Play(0, 1, 1 / SLOW)`) and lock `track.TimePosition`
     to `shotElapsed` in `RenderStepped` (`if math.abs(tr.TimePosition - targetPos) > 0.08 then tr.TimePosition = targetPos end`)
     so animations never drift from story time under Wine frame rate fluctuations.

## ParticleEmitter auras & `TimeScale = 1 / SLOW`
Roblox `ParticleEmitter`s run in real time by default. When capturing at `SLOW = 5`:
- Set **`pe.TimeScale = 1 / SLOW` (`0.2`)** on every `ParticleEmitter` in the scene (character
  auras and ambient sunset dust motes). When `render.sh` speeds the video up 5x, the particles
  move at exact 1x natural speed at 60 fps!
- Mount `AuraFlames` (`rbxasset://textures/particles/fire_main.dds`) and `AuraCore`
  (`rbxasset://textures/glow.png`) on a `Torso` attachment offset slightly behind the torso
  (`AuraBackAttach`, `Position = Vector3.new(0, -0.35, 0.45)`) so the glowing aura frames the
  character's shoulders and head without covering the 2D `FacePlate`. Mount `AuraSparks`
  (`rbxasset://textures/particles/sparkles_main.dds`) at `AuraCenterAttach` (`Vector3.new(0, -0.2, 0)`).
- On every shot cut that enables an aura (`aura(name, "full"|"burst"|"tiny")`), immediately call
  `pe:Emit(14..28)` so frame 1 of a 1-second shot already has a rich glowing aura.

## Client structure (keep these parts as they are)
1. Hide CoreGui and the top bar; a full-screen **black Frame** shown whenever no take is live.
   The black before and after the take is how `find_take.sh` finds the cut points.
2. `A[name]` actor table, `TR[name][anim]` looped AnimationTracks, `anim(name, key)` (no-op if
   already playing), `put(name, x, z, lookX, lookZ)` (stands the rig on y = 0 using HipHeight;
   faces +Z by default, i.e. towards a camera on the road), `hide(name)`, `headTop(name)`.
3. `SHOTS`, then the RenderStepped runner and the `Go` trigger:
   ```lua
   workspace:GetAttributeChangedSignal("Go"):Connect(function()
       task.wait(DELAY)          -- 6 s of black so OBS is surely recording
       shotIdx = 0; T0 = os.clock(); live = true
   end)
   ```
   The take is triggered by setting `Go` **on the Client datamodel** with execute_luau. It
   is not a loop, so each recording holds exactly one take, timed to the narration.

## Slow-motion capture (story time)
Studio under Wine renders only about 12 fps while OBS records, and Pet Cloud v1 looked laggy
because of it. The client plays the take `SLOW` (5) times slower: the runner computes story
time `t = (os.clock() - T0) / SLOW`, `anim()` plays tracks with `Play(0.15 * SLOW, 1, 1 / SLOW)`
and stops them with `Stop(0.15 * SLOW)`, and `render.sh` speeds the cut back up by SLOW.
Rules that keep it working:
- Everything that moves must be a function of story time `t` (shot camera functions,
  `perFrame(t, a)`, rain, bobbing). Never `task.wait`, `TweenService`, physics, particles or
  `os.clock()` deltas for motion: those run in real time and would play 5x too fast.
- Any new AnimationTrack must be started through `anim()` (or with speed `1 / SLOW`).
- One-shot (non-looped) animations also need `AdjustSpeed(1 / SLOW)` if played directly.
- `find_take.sh` should report a take of LENGTH x SLOW seconds; if not, something used real time.

## Shot list
Each entry: `{ start, setup(), camera(a), perFrame(t, a)? }`
- `start`: seconds in narration.wav. Take these from the narrator line starts in
  `audio/timings.json` (a line can be split into 2 shots at a word time from words.json).
- `setup()`: runs once when the shot begins: `reset()` (hides everyone, clears props), then
  place actors, start animations, set props/looks. A shot that continues the last one's
  staging can skip `reset()` (e.g. close-up after a wide of the same moment).
- `camera(a)`: returns `eye, target, fov` for eased progress a in 0..1. Use
  `move(eye0, eye1, look0, look1, fov)` for a slow push or pull, or a custom function to follow
  an actor.
- `perFrame(t, a)`: optional animation during the shot (growing a prop, walking someone).
- `LENGTH` = narration length + about 0.4 s.

## The hook shot (0-2 s)
The first entry in SHOTS always starts at 0.0 and is the hook: a close-up of the most
dramatic or funniest moment (it may come from later in the story: a cold open), with a
moving camera from the first frame, e.g. a push-in `on(name, V(0.8, 0.3, -12), V(0.4, 0.15,
-5.5), 40)` plus `blur(6)`, a strong expression (`face(name, "shocked"|"angry"|"dizzy")`)
and a gesture pose. The next shot starts by 2.0 s at the latest. If the hook is a
flash-forward, the shot at ~2 s goes back to the start of the story (stage it in that shot's
setup). See the modern_kit template's first three shots.

## Framing for the 9:16 crop (and `ROTATE_90` high-res mode)
- **Standard (`ROTATE_90 = false`):** The recording is cropped to the middle 460x818 of the 1442x818 viewport, so only the central third survives.
- **High-res 90° rotated capture (`ROTATE_90 = true`, default):** The client rolls the camera `-90°` (`cam.CFrame = CFrame.lookAt(eye, target) * CFrame.Angles(0, 0, math.rad(-90))`) and scales FOV (`math.clamp(fov * 0.65, 24, 42)`) so the full `1442x818` viewport records sideways (`818x1442` native portrait pixels, ~2x sharper). Passing `ROTATE_90=1` to `render.sh` crops `1442:818:291:148` and applies `transpose=1` before scaling to `1080x1920`.
- Keep subjects on the camera's line of sight (target = subject), and keep wide groups within about +/-6 studs at 25-30 studs distance (fov 50).
- Close-up of a face: eye about 6 studs in front at head height, fov 40-42.
- Medium: 10-13 studs, fov 48-50. Wide street: 24-30 studs, fov 50-55.
- Big props must stay smaller than the camera distance: a 24x cloud put the camera inside it
  (7 s of dark blobs); 10x at 30 studs up worked.
- The default face only shows from the front; camera above head height hides it.

## Props pattern (from Pet Cloud)
Clouds = 6 Ball parts scaled by `scale`, following an owner's head or at a fixed `pos`. Rain
or snow = a fixed pool of parts whose y is computed from time (`top - ((t*speed/h + phase) % 1)
* h`). No physics, no particles (default particle textures look wrong), so it is
deterministic and cheap.

## Lighting looks
Change `ColorCorrectionEffect` TintColor/Brightness/Saturation, `Lighting.ClockTime`, and
key part colours (grass) on the client per shot: e.g. normal, drought (warm tint, yellow
grass), storm (cool, darker), rain (cool, saturated).
