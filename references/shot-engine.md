# Scene scripts and the shot engine

Start from `templates/modern_kit/` (Server.luau = kit + SCENE, Story.client.luau = engine +
CAST/SHOTS). Copy the folder to `/var/mnt/sda3/Roblox_Shorts/studio/<scene_name>/` and edit;
do not start from scratch. `templates/pet_cloud/` is the first short, kept as an example of
time-driven props (clouds, rain). Modern-kit helpers on the client: `put(name, pos, lookAt)`
with Vector3 positions (y = floor), `S("SpotName")` for a spot's position, `on(name, off0,
off1, fov)` for a camera framed on an actor's head, `move(...)` for a moving camera.

## Split of work (important)
- **Server.luau** builds only static things: the set (parts in a `Set` folder) and the actors
  (`Players:CreateHumanoidModelFromDescription`, R15, root anchored, `Animate` script removed,
  parked at y = -200). Actor creation must stay on the server; it fails on the client.
- **Story.client.luau** does everything that moves or changes: actor placement, animations,
  props (clouds, rain), lighting looks, part colours, and the camera.

Why: in Studio under Wine, server-driven motion (PivotTo every frame on R15 rigs) replicated to
the client 30+ s late, so the camera filmed a frozen scene. Client-side changes render
immediately and are never replicated, which is exactly what a recording needs.

Space actor creation (`task.wait(0.2)` after each) and keep the effects light (no
DepthOfField, a few hundred moving parts at most): a heavy playtest start crashed Studio once.

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

## Framing for the 9:16 crop
The recording is cropped to the middle 460x818 of the 1442x818 viewport, so only the central
third of the frame survives. Keep subjects on the camera's line of sight (target = subject),
and keep wide groups within about +/-6 studs at 25-30 studs distance (fov 50).
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
