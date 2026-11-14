---
name: roblox-studio-story-shorts
description: Make a narrated Roblox story Short (vertical 1080x1920) in the style of the user's reference shorts - classic blocky Roblox characters with big drawn faces (kid narrator, grandma, little sister, baby, chef dad, rude "Karen"), cozy homes, cooking class, restaurant and playground sets, close shots, word-by-word captions, an attention-grabbing hook in the first 2 seconds - by building and filming the scene live in Roblox Studio through the Roblox_Studio MCP, recording with OBS, and rendering with ffmpeg. Also does "In this world..." concept stories. Use whenever the user wants a Roblox story short, a family/school/cooking/restaurant/playground Roblox story, a short like their references or like Pet Cloud, or wants to re-record, re-time, re-voice, re-caption or re-render one, even if they only say "make a Roblox story short". Not for the Blender-made Story_01/02 shorts or the 10 s Noob vs Pro skits.
---

# Roblox Studio story Shorts (reference style)

A narrated story Short filmed in real Roblox Studio. The narration is made first, and its
timings drive a scripted shot list that plays on the Studio client while OBS records the
screen. Then the take is cut, cropped to 9:16, captioned word by word and mixed.
Proven end to end on `shorts/Studio_Story_01` ("Pet Cloud", 43 s, Nov 2026).

**Viewer feedback on Pet Cloud (fixed in this version, do not regress):** "very laggy and a
little bit fast". Studio under Wine rendered only ~12 fps while OBS recorded, so every picture
showed 2-3 times; and the narrator ran at 233 wpm. Now the take plays **5x slower in Studio**
(`SLOW = 5` in the client template) and `render.sh` speeds it back up, giving ~60 rendered
frames per story second; and the narrator default is **~200 wpm**.

**The two standing rules from the user (2026-11-14):**
1. **Look like the reference shorts.** Characters, cast and environments follow the user's
   reference Roblox story Shorts: read `references/reference-shorts.md` before planning, and
   see `assets/house_style_contact_sheet.png` for our matching cast.
2. **The first 2 seconds must grab attention.** Line 1 is the hook and starts at ~0.1 s; shot 1
   is a moving close-up of the strongest moment; a sting plays at 0.0 s. Rules in
   `references/story-formula.md` (THE HOOK); checked with `scripts/check_hook.sh`.

Project root: `/var/mnt/sda3/Roblox_Shorts` (call it `$P`). Skill scripts: `$K/scripts`
(this skill's folder). Read these when you get to the matching step:
- `references/reference-shorts.md`: **the target look**: the user's reference characters,
  cast types, environments, camera and captions.
- `references/story-formula.md`: THE HOOK rules, the family/school comedy format (default),
  the "In this world" format, word budget, kid-safe rules, TTS pitfalls.
- `references/shot-engine.md`: how the scene scripts work, shot list format, 9:16 framing.
- `references/studio-setup.md`: machine facts, crop numbers, OBS, crash recovery.
- `references/install.luau`: install and restore snippets for execute_luau.
- `references/youtube-upload.md`: roxpus channel, upload copy under 10 MB, upload form, tags.
- `references/art-direction.md`: how to build the look in the kit: location plan, the
  classic cast (`REF`, `CL.build`, faces), sets, lighting, contact-sheet checklist.
- `templates/modern_kit/`: **start every scene here**: the classic blocky cast builder, cozy
  sets, playground, modern city pieces (Server.luau) and the shot engine with poses, face
  switching, background blur and an example hook opening (Story.client.luau).
- `templates/pet_cloud/`: the first short (old outdoor-only pastel look); use only as an
  example of props like clouds and rain.

## Decisions already made (keep unless the user changes them)
- Kid-safe "Made for Kids" content. Original premises, no brands or real games.
- **Character house style (user's reference shorts, 2026-11-14):** classic blocky Roblox
  bodies, big drawn 2D faces that change per beat, printed clothes, chunky hair, cozy warm
  sets, close shots with a blurred background (`references/art-direction.md` section 3).
- **Always attractive, inside and outside:** furnished warm rooms and modern buildings, every
  character dressed (hair, printed clothes, shoes), shots both outside and inside as the
  story needs; after the hook, establish a place's outside before going in.
- **Hook in the first 2 seconds, every short** (see the rule above). Never open on a slow
  wide shot, black, a title card or a greeting.
- One kid narrator: Pocket TTS voice `jean`, +2 semitones, speed 0.96 (about 200 wpm; 190-210
  is the target). Don't chase flookus' 240-275 wpm: this channel's young viewers found 233 too fast.
- Slow-motion capture with `SLOW = 5`. Every moving thing must read story time (see
  `references/shot-engine.md`); never drive motion with real-time waits.
- Captions: one word at a time, Arial Black 96, white with a black outline, centred at
  y = 1240 (`make_captions.py`, unchanged from the Blender story shorts).
- Score: original, generated by `$P/scripts/make_story_score.py`, at volume 0.22 under the voice.
- Loudness -14 LUFS, H.264 CRF 18, AAC 192k, 30 fps, and smooth: `check_smooth.sh` must show
  about 28-30 unique fps (Pet Cloud v1 measured 12.4).
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
4. **Scene.** First write a location plan: for each line, the place and whether it is
   inside or outside (`references/art-direction.md` section 1). Copy `templates/modern_kit/`
   to `$P/studio/<scene>/`. In Server.luau keep the KIT part and rewrite the SCENE part: the
   street and buildings, the rooms the story visits, and the dressed cast. In
   Story.client.luau keep the ENGINE and RUN parts and rewrite CAST, SHOTS and LENGTH (read
   `references/shot-engine.md`). One shot per line or half-line, starting at the line times
   printed by narrate.py; set `LENGTH` to the narration length + 0.4. **SHOTS[1] at 0.0 is
   the hook shot** (moving close-up, strong expression, blur) and SHOTS[2] starts by 2.0 s
   (`references/shot-engine.md`, "The hook shot"). Use `face(name, expr)` on every beat.
5. **Install in Studio.** `list_roblox_studios` → studio_id. Then:
   ```bash
   $K/scripts/serve_scene.sh $P/studio/<scene>
   ```
   and run the install snippet from `references/install.luau` with execute_luau (Edit). It
   fetches both scripts from localhost (no pasting of long sources) and disables the place's
   own scripts. After any edit to the .luau files, re-run the same snippet (play stopped).
6. **Playtest check.** `start_stop_play` true, wait a few seconds, then on the Client datamodel
   check that all actors and the `Set`/`FX` folders exist and LogService has no errors.
   There is no cheap preview of the moving shots; record a take and judge the contact sheet.
7. **Record.** The take lasts LENGTH x SLOW real seconds (43 s story = about 3.6 min). Tell
   the user their screen will switch to Studio for about LENGTH x SLOW + 20 s. Run
   `$K/scripts/rec_take.sh <LENGTH*SLOW+20>` **in the background**, then immediately run on the
   Client datamodel:
   ```lua
   task.wait(3) workspace:SetAttribute("Go", os.clock()) return "go"
   ```
   The take starts 6 s after Go (black until then), so OBS is already rolling.
8. **Check the take.** When the recording finishes:
   ```bash
   $K/scripts/find_take.sh "<recording>"             # take <start> <end> <len>  (len = LENGTH*SLOW)
   $K/scripts/sheet.sh "<recording>" <start> <LENGTH> /tmp/.../sheet.png   # LENGTH in story seconds
   ```
   If the take length is not LENGTH x SLOW (within a second), something in the client used
   real time; fix that before rendering.
   Look at the sheet against the checklist in `references/art-direction.md` (hook in the first
   2 s, outfits, establishing shots, depth, inside/outside variety) and for: camera inside or behind a
   prop or wall, subject outside the centre third (it gets cropped away), a face seen from
   behind, a shot showing the wrong moment. Fix the scene, re-install (step 5), and record
   again. Also look at one full frame for the mouse cursor inside the crop.
9. **Render.**
   ```bash
   HOOK_SFX=$P/audio/sfx/whoosh.wav $K/scripts/render.sh $P/shorts/<Short> "<recording>" <start> <LENGTH> $P/audio/music/story<ID>_score.wav [delogo x:y:w:h]
   $K/scripts/check_hook.sh $P/shorts/<Short>/<Short>.mp4 /tmp/.../hook.png
   ```
   (`SLOW` defaults to 5; pass `SLOW=1` only for old real-time takes. Pick the hook sting from
   `$P/audio/sfx/`: whoosh, sting, boing, pop, scratch, zap... to match the hook.) Look at the
   hook frames: 0, 0.5, 1 and 2 s must each show a face or action plus a caption word, sound
   must start by ~0.1 s, and the first 2 s must not be quieter than the rest. If not, fix
   the opening (line 1, shot 1) before anything else.
   Output `$P/shorts/<Short>/<Short>.mp4`. Verify with ffprobe (1080x1920, 30 fps, duration),
   ebur128 (about -14 LUFS) and `$K/scripts/check_smooth.sh <mp4>` (about 28-30 unique fps,
   few frozen gaps over 70 ms; static shots lower it legitimately). Make a 1 frame per 2 s
   contact sheet of the final, look at it, then send the video to the user.
10. **Clean up.** `start_stop_play` false, run the RESTORE block from `references/install.luau`,
    and never save the place. Stop the local server: `pkill -f "[h]ttp.server 8765"`.

11. **Upload** (when the user asks): follow `references/youtube-upload.md`.

## Report
Tell the user the hook (what is on screen and said in the first 2 s), the story beats with
times, what was fixed between takes, anything still
weak (shots, mispronounced lines, wpm, unique fps), and the files: the MP4,
script.json, the scene folder, and the score entry.
