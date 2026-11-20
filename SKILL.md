---
name: roblox-studio-story-shorts
description: Make a narrated Roblox story Short (vertical 1080x1920, 60 fps) in the style of the user's reference shorts - pure R6 dressed UGC avatars (chunky sculpted hair meshes, baseball caps, backpacks, hoodies/scarves, Classic Shirts/Pants) or classic blocky cast, big drawn 2D faces that swap per beat (grin, worried, smug, shocked, sad), reusable Moon Animator 2 plugin AnimationTracks (eased keyframes + built-in R6Walk), glowing Roblox ParticleEmitter auras (TimeScale = 1/SLOW), high-quality Future lighting (Level21, soft shadows, warm sunset fog, Bloom, DepthOfField background blur, color grading), rapid 1-2 s close-up push-in shots, word-by-word captions, and a 2-second hook - by building and filming live in Roblox Studio through the Roblox_Studio MCP, recording with OBS, and rendering with ffmpeg.
---

# Roblox Studio story Shorts (reference style + Moon Animator 2 & R6 UGC Aura pipeline)

A narrated story Short filmed in real Roblox Studio. The narration is made first, and its
timings drive a scripted shot list that plays on the Studio client while OBS records the
screen. Then the take is cut, cropped to 9:16, captioned word by word and mixed.
Proven end to end on `shorts/Studio_Story_01` ("Pet Cloud", 43 s) through `Studio_Story_09`,
and upgraded in `shorts/Studio_Test_MoonAura` (Nov 2026) with **Moon Animator 2 `AnimationTrack`s,
pure R6 dressed UGC avatars, and `ParticleEmitter` auras**.

**Viewer feedback on Pet Cloud (fixed in this version, do not regress):** "very laggy and a
little bit fast". Studio under Wine rendered only ~12 fps while OBS recorded, so every picture
showed 2-3 times; and the narrator ran at 233 wpm. Now the take plays **5x slower in Studio**
(`SLOW = 5` in the client template) and `render.sh` speeds it back up, giving ~40-60 rendered
unique frames per story second; and the narrator default is **~200 wpm** (`speed = 0.88-0.96`).

**The two standing rules from the user:**
1. **Look like the reference shorts.** Characters, cast and environments follow the user's
   reference Roblox story Shorts: read `references/reference-shorts.md` before planning, and
   see `assets/moon_aura_contact_sheet.png` (pure R6 UGC + Moon Animator 2 + particle aura)
   and `assets/house_style_contact_sheet.png` (code-built classic cast).
2. **The first 2 seconds must grab attention.** Line 1 is the hook and starts at ~0.1 s; shot 1
   is a moving close-up of the strongest moment; a sting plays at 0.0 s. Rules in
   `references/story-formula.md` (THE HOOK); checked with `scripts/check_hook.sh`.

Project root: `/var/mnt/sda3/Roblox_Shorts` (call it `$P`). Skill scripts: `$K/scripts`
(this skill's folder). Read these when you get to the matching step:
- `references/reference-shorts.md`: **the target look**: pure R6 UGC avatars, Moon Animator 2
  tracks, particle auras, cast types, environments, camera and captions.
- `references/story-formula.md`: THE HOOK rules, the family/school comedy format (default),
  the "In this world" format, word budget, kid-safe rules, TTS pitfalls.
- `references/shot-engine.md`: how the scene scripts work, Moon Animator 2 `.moon2` authoring
  and `AnimationTrack` runtime sync, `ParticleEmitter` aura `TimeScale = 1/SLOW`, 9:16 framing.
- `references/studio-setup.md`: machine facts, crop numbers, OBS, crash recovery.
- `references/install.luau`: install and restore snippets for execute_luau.
- `references/youtube-upload.md`: roxpus channel, upload copy under 10 MB, upload form, tags.
- `references/art-direction.md`: how to build the look: pure R6 UGC avatars (`buildR6UGC`),
  hat/hair weld clearance over `FacePlate`, classic cast (`REF`, `CL.build`), sets, high-quality
  `Level21` lighting + fog + Bloom + DoF, contact-sheet checklist.
- `templates/moon_aura_kit/`: **start here for R6 UGC + Moon Animator 2 + Particle Aura shorts**:
  - `BuildMoonAnims.luau`: authors genuine `.moon2` save files in `ServerStorage.MoonAnimator2Saves`
    with Moon Animator 2 easing curves (`Sine`, `Cubic`, `Back`, `Quad`) and invokes the
    installed Moon Animator 2 plugin (`_G.MoonGlobal.Windows.MoonAnimator` `OpenFile` ->
    `ExportRigs` -> `CloseFile`) to export reusable `KeyframeSequence`s + built-in `R6Walk`
    into `ReplicatedStorage.MoonAnims`.
  - `Server.luau`: pure R6 dressed UGC avatar builder (`Players:CreateHumanoidModelFromDescription`,
    sculpted hair meshes, caps, backpacks, 3D neck/front accessories, Classic Shirts/Pants, 3D
    sneakers), switchable 300x300 `FacePlate` expressions, multi-layer `ParticleEmitter` auras
    (`TimeScale = 1/SLOW`), and golden-hour courtyard with `Level21` lighting, soft shadows,
    warm `Atmosphere` fog, `BloomEffect` (`Threshold = 1.95`), `DepthOfFieldEffect`, and
    `ColorCorrectionEffect`.
  - `Story.client.luau`: registers & loads Moon Animator 2 `KeyframeSequence`s as real Roblox
    `AnimationTrack`s locked to story time, swaps `face(name, expr)` and `aura(name, mode)`
    per beat, and films rapid 1-2 s close-up push-in shots in `ROTATE_90 = true` mode.
- `templates/modern_kit/`: code-built classic blocky cast (`CL.build`), cozy rooms, playground,
  and modern city pieces (use when you want 100% offline code-built outfits or interior sets).
- `templates/pet_cloud/`: the first short (kept only as an example of time-driven clouds/rain).

## Decisions already made (keep unless the user changes them)
- Wholesome, kid-safe content (original premises, no brands or real games). On YouTube upload, set Audience to **"No, it's not made for kids"** and let the user drag the full-quality MP4 into YouTube Studio (`references/youtube-upload.md`).
- **Spacing & no Z-fighting (2026-11-17):** Keep `>= 4.5–6` studs between characters and clear of furniture/props, cap sideways arm raises so hands never clip heads, and never leave coplanar overlapping faces on ground/mountains/props (`references/art-direction.md`).
- **Pure R6 UGC + Moon Animator 2 + Particle Aura style (2026-11-20):**
  - **Avatars:** Pure R6 rigs (`Enum.HumanoidRigType.R6`) dressed with UGC Catalog accessories (`HatAccessory`, `HairAccessory`, `BackAccessory`, `NeckAccessory`, `FrontAccessory`, Classic `Shirt` & `Pants`; note `WrapLayer` cage clothing drops on R6, so use rigid 3D UGC accessories + Classic Shirt/Pants). Always nudge `hatOffset`/`hairOffset` on `AccessoryWeld` *after* parenting to `workspace` so cap brims and bangs stay above the 2D `FacePlate` eyebrows.
  - **Poses & Walks:** Reusable `AnimationTrack`s exported through the installed **Moon Animator 2** plugin (`_G.MoonGlobal`) into `ReplicatedStorage.MoonAnims`, registered at runtime via `KeyframeSequenceProvider:RegisterKeyframeSequence(seq)` (use the raw 32-char hex hash directly on `Animation.AnimationId` — never prepend `rbxassetid://`!) and played at `1 / SLOW` speed.
  - **Auras:** Multi-layer Roblox `ParticleEmitter`s (`AuraFlames`, `AuraSparks`, `AuraCore` + `AuraLight`) mounted on `Torso` attachments (`AuraBackAttach` at `V(0, -0.35, 0.45)` so flames frame the shoulders/head without covering the face) with `TimeScale = 1 / SLOW` (`0.2`) and immediate `:Emit()` on shot cuts so frame 1 of a 1-second shot is already glowing.
  - **High-quality lighting & post FX:** Set `settings().Rendering.QualityLevel = Enum.QualityLevel.Level21` (`EditQualityLevel = Level21`), `Lighting.GlobalShadows = true`, `ShadowSoftness = 0.6`, warm `Atmosphere` fog (`Density = 0.42`, `Haze = 2.4`), `BloomEffect` (`Threshold = 1.95`, `Intensity = 0.42` — keeps `LightEmission = 1` particles and `Neon` lamps glowing without blowing out blonde hair or faces), `DepthOfFieldEffect` (`blur(focusDist, radius, far)`), and warm `ColorCorrectionEffect`.
  - **Rapid 1–2 s close-up shots:** Each shot is 1.0–2.0 s (`put(character)`, `pose(character, track)`, `face(character, expr)`, `aura(character, mode)`, `blur(dist)`, and a close-up camera push-in `on(character, off0, off1, fov)`). Hide off-camera characters (`hideAll()`) on single close-ups so a neighbour's sleeve never clips the lens.
- **Always attractive, inside and outside:** furnished warm rooms, glowing courtyard/street lamps (which turn into warm bokeh orbs in DoF close-ups), and dressed characters.
- **Hook in the first 2 seconds, every short** (see the rule above). Never open on a slow
  wide shot, black, a title card or a greeting.
- One kid narrator: Pocket TTS voice `jean`, +2 semitones, speed `0.88–0.96` (about 200 wpm; 190-210
  is the target). Note: run `narrate.py`, `story_qa.py`, and `make_story_score.py` inside the
  `claude-debian` distrobox (`distrobox enter claude-debian -- ...`) where Python 3.11 + `scipy` +
  `pocket_tts` + `faster-whisper` live.
- Slow-motion capture with `SLOW = 5` and **90° rotated vertical capture (`ROTATE_90 = true`)**. Every moving thing must read story time (see `references/shot-engine.md`); never drive motion with real-time waits, and set `ParticleEmitter.TimeScale = 1 / SLOW`. With `ROTATE_90 = true` (client) and `ROTATE_90=1` (`render.sh` & `sheet.sh`), Studio films sideways across the full viewport (`crop=1314:746:419:188,transpose=1`) before scaling to `1080x1920` at `60 fps`.
- Captions: one word at a time, Arial Black 96, white with a black outline, centred at
  y = 1240 (`make_captions.py`).
- Score: original, generated by `$P/scripts/make_story_score.py`, at volume 0.22 under the voice.
- Loudness -14 LUFS, H.264 CRF 18, AAC 192k, 60 fps (or 30 fps), and smooth: `check_smooth.sh`
  must show ~28-45+ unique fps and 0 frozen gaps over 70 ms (`Studio_Test_MoonAura` measured
  41.9 unique fps with 0 frozen gaps > 70 ms).
- Length: the user asked for a *test* at 43 s; flookus hits are 2-2.5 min. Ask which length
  if the request doesn't say.

## Pipeline
Name the short `Studio_Story_NN` (next free number) and the scene `studio/storyNN_<slug>`.

1. **Story.** Default to the family/school comedy format with the reference cast types;
   write it with the beats in `references/story-formula.md`. **Write the hook first**: line 1
   is the most surprising or funniest moment (or a question it answers), under ~8 words, and
   say which shot will show it. Show the user the full script (it is cheap to change now,
   expensive later) and go ahead when they're happy, or right away if they said to just make it.
2. **Narration.** Write `$P/shorts/<Short>/script.json`, then:
   ```bash
   ~/.venv/bin/python $K/scripts/narrate.py $P/shorts/<Short>
   /var/mnt/sda3/tools/whisper-env/bin/python $K/scripts/story_qa.py $P/shorts/<Short>
   ```
   narrate.py prints length, wpm and each line's start/end. story_qa.py flags lines Whisper
   mishears and writes `audio/words.json` (word times for captions). Fix flagged lines by
   rewording the sentence in script.json and re-running narrate.py (it regenerates only lines
   whose text changed), then run story_qa.py again. Short one-word questions and digits are the
   usual culprits.
3. **Score.** Add a `STORY<ID>` section table to `$P/scripts/make_story_score.py` (copy the
   `STORYS1` entry; section kinds box/pad/drone/swell/silence follow the story's mood at the
   line times) and its entry in `main()`'s dict, then
   `~/.venv/bin/python $P/scripts/make_story_score.py <ID>` → `$P/audio/music/story<ID>_score.wav`.
   The `S1` branch returns before rewriting the shared SFX; make a new ID do the same.
4. **Scene & Moon Animator 2 Animations.** First write a location plan: for each line, the place and whether it is
   inside or outside (`references/art-direction.md` section 1). Copy `templates/moon_aura_kit/`
   (or `templates/modern_kit/` for code-built outfits) to `$P/studio/<scene>/`.
   - If using Moon Animator 2 `AnimationTrack`s (`templates/moon_aura_kit/`), edit `BuildMoonAnims.luau`
     with any custom poses and execute it in Studio (`Edit` datamodel via `execute_luau`) so
     `_G.MoonGlobal.Windows.MoonAnimator` exports all `KeyframeSequence`s + `R6Walk` into
     `ReplicatedStorage.MoonAnims`.
   - In `Server.luau`, configure the high-quality lighting/fog/Bloom/DoF, build the sets, and
     build the dressed pure R6 UGC cast (`buildR6UGC` with `hatOffset`/`hairOffset` and
     `ParticleEmitter` auras at `TimeScale = 1 / SLOW`).
   - In `Story.client.luau`, keep the ENGINE and RUN parts and rewrite CAST, SHOTS and LENGTH
     (read `references/shot-engine.md`). One shot every 1-2 s (per line or half-line), starting
     at the line/word times from `timings.json` / `words.json`; set `LENGTH` to the narration
     length + 0.35. **SHOTS[1] at 0.0 is the hook shot** (moving close-up, strong expression,
     glowing aura, blur) and SHOTS[2] starts by 2.0 s (`references/shot-engine.md`, "The hook shot").
     Use `pose(name, track)`, `face(name, expr)`, `aura(name, mode)`, and `blur(dist)` on every beat.
5. **Install in Studio & Set Level21 Quality.** `list_roblox_studios` → studio_id. Bump rendering quality:
   `pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21; settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level21 end)`.
   Start the local HTTP server (`$K/scripts/serve_scene.sh $P/studio/<scene>`, or run `python3 -m http.server 8765 --bind 127.0.0.1` as a daemon in `$P/studio/<scene>`)
   and run the install snippet from `references/install.luau` with `execute_luau` (`Edit`). It
   fetches both scripts from localhost (no pasting of long sources) and disables the place's
   own scripts. After any edit to the `.luau` files, re-run the same snippet (play stopped).
6. **Playtest check.** `start_stop_play` true, wait ~4 seconds, then on the `Client` datamodel:
   - Register every `KeyframeSequence` in `ReplicatedStorage.MoonAnims` via `KeyframeSequenceProvider:RegisterKeyframeSequence(ks)`, cache `ks:SetAttribute("RegisteredId", rawId)` (raw 32-char hash, never `rbxassetid://`), and set `workspace:SetAttribute("AnimsReady", os.clock())`.
   - Check that all actors, accessories, `FacePlate`, `ParticleEmitter`s (`TimeScale == 0.2`), and `Set` exist and `LogService` has 0 errors.
   - Optionally preview close-ups via `screen_capture` (temporarily set `PlayerGui.ScreenGui.Enabled = false` without unbinding `StoryCamera`, check cap/hair clearance over eyebrows and Bloom threshold, then restore `ScreenGui.Enabled = true` and hide actors to `y = -200`).
7. **Record.** Ensure OBS is running (`flatpak run com.obsproject.Studio --minimize-to-tray` and verify `obsws.py status`). The take lasts `LENGTH x SLOW` real seconds. Tell
   the user their screen will switch to Studio for about `LENGTH x SLOW + 20` s. Run
   `$K/scripts/rec_take.sh <LENGTH*SLOW+20>` **in the background**, then immediately run on the
   Client datamodel:
   ```lua
   task.wait(3) workspace:SetAttribute("Go", os.clock()) return "go"
   ```
   The take starts 6 s after Go (black until then), so OBS is already rolling.
8. **Check the take.** When the recording finishes:
   ```bash
   $K/scripts/find_take.sh "<recording>"             # take <start> <end> <len>  (len = LENGTH*SLOW)
   ROTATE_90=1 $K/scripts/sheet.sh "<recording>" <start> <LENGTH> /tmp/.../sheet.png   # LENGTH in story seconds
   ```
   If the take length is not `LENGTH x SLOW` (within a second), something in the client used
   real time; fix that before rendering.
   Look at the sheet against the checklist in `references/art-direction.md` (hook in the first
   2 s, pure R6 UGC outfits & unobstructed faces, particle aura glow without blowout, depth/DoF blur) and for: camera inside or behind a
   prop or wall, an off-camera character's sleeve clipping into frame (forgot `hideAll()`), a face seen from
   behind, a shot showing the wrong moment. Fix the scene, re-install (step 5), and record
   again. Also look at one full uncropped frame for the mouse cursor inside the crop.
9. **Render.**
   ```bash
   ROTATE_90=1 FPS=60 HOOK_SFX=$P/audio/sfx/glow_swell.wav $K/scripts/render.sh $P/shorts/<Short> "<recording>" <start> <LENGTH> $P/audio/music/story<ID>_score.wav [delogo x:y:w:h]
   $K/scripts/check_hook.sh $P/shorts/<Short>/<Short>.mp4 /tmp/.../hook.png
   ```
   (`SLOW` defaults to 5; pass `SLOW=1` only for old real-time takes. Pick the hook sting from
   `$P/audio/sfx/`: glow_swell, whoosh, sting, boing, pop, scratch, zap... to match the hook.) Look at the
   hook frames: 0, 0.5, 1 and 2 s must each show a face or action plus a caption word, sound
   must start by ~0.1 s, and the first 2 s must not be quieter than the rest. If not, fix
   the opening (line 1, shot 1) before anything else.
   Output `$P/shorts/<Short>/<Short>.mp4`. Verify with ffprobe (`1080x1920`, `60 fps`, duration),
   ebur128 (about `-14 LUFS`) and `$K/scripts/check_smooth.sh <mp4>` (about 28-45+ unique fps,
   0 frozen gaps over 70 ms). Make a contact sheet of the final, look at it, then send the video to the user.
10. **Clean up.** `start_stop_play` false, run the RESTORE block from `references/install.luau`,
    and never save the place. Stop the local server: `pkill -f "[h]ttp.server 8765"`.

11. **Upload** (when the user asks): follow `references/youtube-upload.md`.

## Report
Tell the user the hook (what is on screen and said in the first 2 s), the story beats with
times, what was fixed between takes, anything still
weak (shots, mispronounced lines, wpm, unique fps), and the files: the MP4,
script.json, the scene folder, and the score entry.
