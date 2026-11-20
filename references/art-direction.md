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

## 3. Characters: Pure R6 Dressed UGC Avatars + Classic Blocky Cast

### A. Pure R6 Dressed UGC Avatars (`templates/moon_aura_kit/Server.luau`, Nov 2026)
Matches the high-production R6 UGC shorts style (see `assets/moon_aura_contact_sheet.png`):
- **Standard R6 Rig (`Enum.HumanoidRigType.R6`):** Created via
  `Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)`. Uses standard
  Roblox R6 `Motor6D` orientations (`RootJoint`, `Neck`, `Right Shoulder`, `Left Shoulder`,
  `Right Hip`, `Left Hip`), so Moon Animator 2 `AnimationTrack`s (`R6Walk` and custom `.moon2`
  exports) play natively.
- **Root anchored, limbs unanchored:** Set `HumanoidRootPart.Anchored = true`, and ensure all
  limbs and accessory `Handle` parts have `Anchored = false`, `CanCollide = false`,
  `Massless = true`. Remove the default `Animate` LocalScript and `Head.face` decal.
- **UGC Catalog Accessories & Layered Look on R6:**
  - Discover live catalog IDs in Studio via `AvatarEditorService:SearchCatalog(params)` —
    **always pass `params.Limit = 10`** (passing `Limit = 8` throws `HTTP 400`).
  - Note: Roblox drops R15 `WrapLayer` cage layered clothing on pure R6 rigs (`WrapLayer` has no
    R15 cage target on R6). Achieve the 3D layered outfit look on pure R6 by combining Classic
    `Shirt` + `Pants` textures with rigid 3D UGC accessories:
    - `HatAccessory` (e.g. red baseball cap `14510395236` or black cap `18221906655`)
    - `HairAccessory` (chunky sculpted hair meshes, e.g. messy curly brown hair `13433327568`,
      blonde anime hair `18899378507`)
    - `NeckAccessory` (3D hoodie hood `16095109571`, knit scarf `16467566865`)
    - `FrontAccessory` (3D crossbody bag `8084645500`)
    - `BackAccessory` (3D backpacks `18166247145`, `139196487384313`, `76674853264828`)
    - Welded 3D sneakers (`Shoe` + `Sole` parts on `Left Leg` / `Right Leg`).
- **Hat & Hair Weld Clearance Over the 2D `FacePlate` (critical):**
  - Chunky UGC hair bangs and baseball cap brims often hang slightly over the upper forehead where
    the 2D `FacePlate` draws eyebrows.
  - **After** `m.Parent = workspace; task.wait(0.1)` (so `AccessoryWeld` exists on each `Handle`),
    nudge `Hat` and `Hair` welds upward/back in `Head` space (`hatOffset = CF(0, 0.20, 0.08) *
    CFrame.Angles(math.rad(14), 0, 0)`, `hairOffset = CF(0, 0.03..0.07, 0.06)`). Verify with a
    close-up `screen_capture` that eyebrows and eyes are 100% unobstructed and the cap sits cleanly
    above the hair crown.

### B. Code-Built Classic Blocky Cast (`templates/modern_kit/Server.luau`)
**House style since 2026-11-14 (e.g. cooking-class and playground Roblox story Shorts):** classic blocky R6 bodies with the rounded Roblox head,
BIG hand-drawn 2D faces, clothes painted on the blocks like Roblox shirt textures (knit
sweaters, bold floral prints, chef coat buttons, aprons, denim), chunky sculpted hair, kids
smaller than adults. `STYLE.body = "classic"` routes `actor()` to `CL.build`. Built on ChatGPT's ReferenceCast rig
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

## 4. Looks that make it attractive (High-Quality Future Lighting, Fog, Bloom & DoF)
- **High-quality Studio rendering (`Level21`):** Set `settings().Rendering.QualityLevel = Enum.QualityLevel.Level21`
  and `EditQualityLevel = Enum.QualityLevel.Level21` in Studio (`test02.rbxlx` uses
  `Lighting.Technology = Future` and `PrioritizeLightingQuality = true`).
- **Soft shadows & golden-hour warm lighting:** `Lighting.GlobalShadows = true`,
  `Lighting.ShadowSoftness = 0.6`, `ClockTime = 16.75`, `Brightness = 2.05`,
  `ExposureCompensation = -0.32`, warm `ColorShift_Top = C3(255, 222, 175)`.
- **Volumetric depth fog (`Atmosphere`):** `Density = 0.42`, `Offset = 0.15`, `Haze = 2.4`,
  `Glare = 0.35`, `Color = C3(255, 212, 165)`, `Decay = C3(170, 125, 108)`. Separates close-up
  characters from background trees, buildings, and skyline silhouettes.
- **Bloom without face/hair blowout (`BloomEffect`):** Set `Threshold = 1.95`, `Intensity = 0.42`,
  `Size = 24`, and keep character `AuraLight.Brightness` around `1.15–1.8`. A threshold of `1.1`
  blows out blonde hair and pale faces in direct sun; at `1.95`, skin and hair stay crisp while
  `LightEmission = 1` aura particles and `Neon` street lamps still glow richly.
- **Background blur (`DepthOfFieldEffect`):** Controlled per shot via `blur(focusDist, radius, far)`
  (e.g. `blur(5.2, 3.0, 0.75)` on close-ups). Place warm `Neon` street lamps (`z = -6` and `z = -16`)
  and lit building windows in the background so they blur into creamy golden bokeh orbs.
- **Color grading (`ColorCorrectionEffect`):** `TintColor = C3(255, 240, 222)`,
  `Saturation = 0.22–0.26`, `Contrast = 0.14–0.18`, `Brightness = -0.04`.
- **Colour & depth:** Put something in the foreground or background of every shot (street lamp,
  tree, fence, warm window view). Never frame a character against a blank wall or empty grass.
- Fill the 9:16 frame: the crop keeps only the centre third of the viewport, so stack
  interest vertically (character + window/lamp/shelf above) instead of spreading sideways.
- Interior camera: look in through the open +Z side (rooms are cut-aways), 10-16 studs from
  the back wall, eye height 4.5-7, fov 45-55. Close-ups 4-6 studs from the face, fov 38-42.
- Performance: every extra part costs Studio frame rate (we capture 5x slow, so it is
  forgiving, but keep a scene under ~2,500 parts and delete kit pieces the story never sees).
- **Spacing & self-clipping (standing rule, Nov 2026):** Keep at least `4.5–6` studs between
  actors in group shots, and keep actors well clear of furniture (`K.woodTable`, `K.bed`),
  walls, and FX beams so bodies never overlap. Cap sideways arm-raise poses (`Z <= 2.05` rad
  plus forward `+0.25..0.35 X`) so hands never clip into blocky heads or hair.
- **No Z-fighting / flickering (standing rule, Nov 2026):** Never place two parts with
  coplanar faces or identical widths overlapping on the same axis (e.g., stagger background
  mountains' `Z` and depth, and give multi-part props like trains distinct widths/offsets).

## 5. Contact-sheet checklist (step 8)
Reject and fix a take if any frame shows:
- a character without an outfit, or two characters that look alike;
- actors overlapping each other, furniture, or props, or hands clipping into heads;
- Z-fighting / flickering on overlapping coplanar parts (mountains, vehicles, walls);
- the camera inside a wall, prop or ceiling, or a room seen from outside its open side;
- an empty background (blank wall, bare grass, sky only) behind a close-up;
- a slow or empty first 2 seconds: the frames at 0, 0.5, 1 and 2 s must each show a face
  or action and a caption word (`scripts/check_hook.sh`);
- a place's interior shown before we ever saw where we are (missing establishing shot,
  except the hook shot);
- more than ~4 consecutive shots in the same place, or all shots at the same distance.
