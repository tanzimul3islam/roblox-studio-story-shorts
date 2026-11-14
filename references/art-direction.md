# Art direction: modern, attractive, inside and outside

The user's standing rule (Nov 2026): **every video uses modern buildings, rooms and dressed
characters, and cuts between outside and inside shots as the story needs; it must look
attractive.** Pet Cloud v1 (pastel boxes on grass, bare default bodies, outdoor-only) is the
look to move away from. Build every scene from `templates/modern_kit/`.

## 1. Plan locations before building (write this down with the shot list)
For each story line, decide **where** it happens and whether we see it from **outside** or
**inside**. A story should normally have:
- 1 exterior "home base" (the street with the narrator's house, school, cafe...)
- 2-4 interiors where the emotional beats happen (living room, bedroom, kitchen, classroom,
  shop, office...). Feelings, secrets and dialogue play best inside; events, crowds and
  big reveals play best outside.
- **Hook first, then establish:** shot 1 (0-2 s) is always the hook close-up (see
  `references/story-formula.md`), even if it is in the middle of the story. After the hook,
  the first visit to a place shows its outside (wide or medium) for 1.5-2.5 s, then cuts
  inside. Re-visits can cut straight inside.
- Don't stay more than ~4 shots in one place; alternate inside/outside and wide/medium/close.

## 2. Kit pieces (templates/modern_kit/Server.luau)
The style target is the user's reference boards (Nov 2026): a modern Roblox city and the
"Roblox aesthetic" avatar look. Everything is built in code as our own versions: never put
real logos, brand names or licensed characters on signs or clothes.
- Street: `street(x0, x1)`, `crosswalk(x)`, `trafficLight(x, z, yaw)`, `tree`, `bench`,
  `streetLight`, skyline `tower`s.
- Vehicles: `vehicle(x, z, kind, yaw, colour)` with kind sedan, sports, suv, police,
  ambulance, bus, truck.
- Buildings (front faces the camera at +Z): `modernHouse`, `shop(x, z, "NAME")`,
  `school(x, z, "NAME")`, `mall(x, z, "NAME")`, `hospital`, `policeStation`, `gasStation`,
  `tower`. Outdoor areas: `park(x, z)` (paths, gazebo, playground, benches, trees),
  `basketballCourt(x, z)`.
- Rooms: `room(x, z, {name, w, d, h, wall, floor, floorMat, windowX, closed, neon})`; `neon =
  {colourA, colourB}` makes a gamer room lit by LED strips. Furniture `K.*`: sofa,
  coffeeTable, rug, tvWall, plant, floorLamp, bed, desk(+laptop), shelf, kitchen, diningSet,
  classroom, whiteboard, wallArt, ledStrip, gamerDesk (3 neon monitors + gaming chair),
  bathroom, bookWall (library).
- Add new pieces in the same style when a story needs a place the kit lacks (airport, beach,
  stadium, castle...) and keep them in the kit. The board's other ideas: restaurants, hotels,
  stores, factories, farms, beaches, caves, space bases.

## 3. Characters: the house style (classic blocky cast) + older presets

**House style since 2026-11-14 (the user's reference shorts, e.g. cooking-class and
playground Roblox story Shorts):** classic blocky R6 bodies with the rounded Roblox head,
BIG hand-drawn 2D faces, clothes painted on the blocks like Roblox shirt textures (knit
sweaters, bold floral prints, chef coat buttons, aprons, denim), chunky sculpted hair, kids
smaller than adults. `STYLE.body = "classic"` routes `actor()` to `CL.build`. This replaces
the earlier chibi/anime pick. Built on ChatGPT's ReferenceCast rig
(`/var/mnt/sda3/Roblox_Shorts/ReferenceCast/`), improved.
- Cast recipes in `REF`: Milo (young cook, apron), Rose (grandma, floral, bun), Lily
  (granddaughter, floral, long hair, denim), Andre (chef, blonde quiff), Noah (parent, all
  black, glasses), Pip (baby, "LITTLE BUDDY" shirt), Claire (blonde bob, knit sweater, collar).
  `actor("Name", {ref = "Rose", shirt = ...})` reuses a recipe with overrides; new people are
  recipes with: skin, shirt, pants, sleeves "short"|"long", hair, hairStyle
  ("tousled"|"swept"|"baby"|"long"|"bob"|"bun"), expression, scale (kids 0.75-0.85, baby
  0.5), iris, glasses, knit, floral = {petal, centre, leaf}, denim, apron = {bib, straps},
  chef, collar, skirt, bow, shoeColor, shirtText (original words only).
- Faces: every expression is pre-drawn on the face plate; switch per shot on the client
  with `face(name, expr)`: smile, grin (big toothy), laugh (^^ + grin), happy, angry, stern,
  worried (gritted teeth), dizzy (spiral eyes), shocked, smug, sad, neutral. Change the
  expression on every story beat, as the references do.
- Shots: close and eye-level, the face big in frame, background blurred with
  `blur(cameraDistance)` (client), like the references.
- Sets for this style: `room()` with SUNNY or CREAM walls + CARPET floors, `K.woodTable`,
  `K.pot`, `K.bowl`, `K.board`, `K.frame`, `K.chalkboard`, `K.doorway`,
  `K.restaurantEntrance`, and `playground(x, z)` (wood chips, red/blue swing set with spots
  Swing1/Swing2, picket fence, low-poly pines, red house, mountains).

### Older options (still in the kit)
`STYLE.body = "chibi"` or `"r15"` uses the R15 "Roblox aesthetic" presets below:
| Preset | Look (from the boards) | Default face |
|---|---|---|
| CoolShadow | messy black hair, black mask, graphic black hoodie, baggy black pants, chain, white sneakers | serious |
| CuteGirl | cat-ear beanie, long wavy brown hair, pink sweater, baggy white pants, pink shoulder bag | closed (^ ^) |
| RichBoy | messy brown hair, sunglasses, black sweater + shirt + tie, white pants, gold watch | smirk |
| GamerBoy | black/white split hair, headset with neon cups, black hoodie + neon details, neon-stripe cargo pants, glowing sneakers | happy |
| ChillGamer | white messy hair, white headphones, white hoodie, black pants, chain | happy |
| FriendlyPro | brown hair, headphones, varsity jacket with a letter (`letter` opt), black pants | happy |
| Beach | brown hair, sunglasses, flower shirt, white shorts, sandals, necklace | happy |
| Cyber | purple spiky hair, neon visor, neon jacket, cargo pants, neon shoes | serious |
| AnimeHero | spiky black hair, long black/red coat (no weapons: kids channel) | serious |
| Minimal | messy black hair, grey sweater, baggy black pants, white shoes | neutral |

- Recolour per character with opts (`hair`, `top`, `pants`, `accent`, `glow`, `hat`,
  `letter`) so two kids with the same preset still look different; override the face with
  `mood` (happy, closed, smirk, neutral, serious, sad).
- Give each main character one preset and keep it in every shot and every episode.
- Pieces for custom looks are in `A2.*` (messyHair, longWavyHair, spikyHair, headphones,
  mask, sunglasses, visor, beanieEars, top(kind = hoodie|jacket|sweater|coat), letter,
  baggyPants, shorts, sneakers, sandals, chain, necklace, watch, shoulderBag, hawaiian) and
  the simpler `OUT.*` set; pass `outfit = function(m) ... end` to `actor`.
- Use varied, natural skin tones across the cast.

## 4. Looks that make it attractive
- Lighting: `lookModern(clock)` (soft sun, atmosphere, light bloom, sun rays). Interiors
  have warm ceiling + lamp PointLights; exteriors have lit windows and street lights. For
  night scenes use clock 19-20 with the same look and switch the room lights on.
- Colour: soft whites and pale walls + **one strong accent per frame** (a door, a sofa, an
  outfit). Avoid the flat saturated pastels of v1.
- Depth: put something in the foreground or background of every shot (plant, lamp, car,
  tree, window view). Never frame a character against a blank wall or empty grass.
- Fill the 9:16 frame: the crop keeps only the centre third of the viewport, so stack
  interest vertically (character + window/lamp/shelf above) instead of spreading sideways.
- Interior camera: look in through the open +Z side (rooms are cut-aways), 10-16 studs from
  the back wall, eye height 4.5-7, fov 45-55. Close-ups 4-6 studs from the face, fov 38-42.
- Performance: every extra part costs Studio frame rate (we capture 5x slow, so it is
  forgiving, but keep a scene under ~2,500 parts and delete kit pieces the story never sees).

## 5. Contact-sheet checklist (step 8)
Reject and fix a take if any frame shows:
- a character without an outfit, or two characters that look alike;
- the camera inside a wall, prop or ceiling, or a room seen from outside its open side;
- an empty background (blank wall, bare grass, sky only) behind a close-up;
- a slow or empty first 2 seconds: the frames at 0, 0.5, 1 and 2 s must each show a face
  or action and a caption word (`scripts/check_hook.sh`);
- a place's interior shown before we ever saw where we are (missing establishing shot,
  except the hook shot);
- more than ~4 consecutive shots in the same place, or all shots at the same distance.
