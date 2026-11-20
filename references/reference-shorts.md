# The user's reference shorts (the target look, Nov 2026)

The user shared phone screenshots of popular Roblox story Shorts (family/school comedy
channels, 3.8K-66K likes per Short; titles like "I Signed Up For Cooking Class", "A Karen
tried to steal my baby SISTER's swing!", "A Food Critic Came to Our Restaurant") and said:
**"these are the reference characters, I want this kind of characters, environments and cast
in my stories."** Every story follows this look. A filmed example of our matching cast is
`assets/house_style_contact_sheet.png` (the kit's `REF` cast, 2026-11-14).

## Characters (what to copy in spirit, never copy exactly)
- **Pure R6 dressed UGC avatars (`templates/moon_aura_kit/`) or classic blocky R6 bodies (`templates/modern_kit/`)**:
  block torso, arms, legs (no elbows or knees) with the rounded classic head. Kids clearly
  smaller than adults; babies tiny.
- **UGC layered streetwear & accessories (`moon_aura_kit`)**: chunky sculpted UGC hair meshes
  (messy brown curls, blonde anime locks), baseball caps tilted clear of the eyebrows, 3D hoodie
  hoods and knit scarves (`NeckAccessory`), crossbody bags (`FrontAccessory`), 3D backpacks
  (`BackAccessory`), Classic hoodie/sweater `Shirt` + jeans `Pants`, and 3D sneakers.
- **Poses & walks from Moon Animator 2 (`moon_aura_kit`)**: keyframes posed with Moon Animator 2
  easing (`Sine`, `Cubic`, `Back`, `Quad`) and exported via the installed Moon Animator 2 plugin
  (`_G.MoonGlobal`) as reusable Roblox `AnimationTrack`s (plus Moon Animator 2's built-in `R6Walk`).
- **Glowing Roblox `ParticleEmitter` auras (`moon_aura_kit`)**: multi-layer rising energy flames,
  sparkles, and radial core glow (`LightEmission = 1`, `TimeScale = 1 / SLOW`) plus a matching
  torso `PointLight`.
- **Big drawn 2D faces** that fill the head and swap every 1-2 s beat: huge toothy grins,
  angry slanted brows with a frown, spiral "dizzy" eyes with a wobbly mouth, round glasses,
  smug half-lidded eyes, closed laughing eyes (^^), wide shocked O-mouths, gritted-teeth worry.
- **Clothes printed on the blocks (`modern_kit`)**, like Roblox shirt textures: knit sweaters, bold floral
  blouses, a chef coat with buttons and a collar line, aprons with straps and dots, jeans,
  black hoodies, a baby onesie with a short slogan.
- **Chunky hair**: messy brown locks over the forehead, grey/white grandma buns, long brown
  hair, a blonde bob, a spiky blonde chef quiff, a fluffy white baby tuft.
- **The cast types** that recur: a kid narrator (often a young cook or student), a
  grandma or group of grandmas, a granddaughter / little sister, a baby, a parent in black
  with glasses, a strict chef dad, a "Karen"-style rude adult (comic antagonist), teachers,
  a food critic. Each has one fixed outfit and colour so viewers recognise them instantly.
- Kit: `REF` recipes (Milo, Rose, Lily, Andre, Noah, Pip, Claire) and `CL.build` for new
  people in the same style (`references/art-direction.md` section 3).

## Environments
- **Cozy home interiors**: warm yellow or cream walls, beige carpet, wooden tables and
  chairs, framed pictures, a door frame, soft warm light.
- **Cooking class / kitchen**: wooden worktables with mixing bowls, pots, cutting boards,
  fruit; a green board; grandmas cooking side by side.
- **Restaurant**: wood-panel entrance with glass double doors and yellow bar handles, a red
  runner carpet with yellow stripes, a hanging lamp.
- **Playground**: orange wood-chip ground, a red and blue swing set, white picket fence,
  low-poly pine trees, snowy mountains far behind, a red timber house with lit yellow
  windows and a street lamp.
- Kit: `room()` with SUNNY/CREAM walls + CARPET, `K.woodTable/pot/bowl/board/frame/
  chalkboard/doorway/restaurantEntrance`, `playground()`. Add new places (school hallway,
  classroom, supermarket, birthday party, bedroom...) in the same warm, simple style.

## Camera and editing
- **Close, eye-level shots**: a face or two faces fill the vertical frame; wides are rare
  and short. Background softly blurred (`blur(distance)` on the client).
- A cut every 1-2 s; expression changes on almost every line.
- **Captions**: one big word at a time, white with a thick black outline, in the middle
  or lower-middle of the frame (our `make_captions.py` style). One word can be a hook on its
  own ("STUCK", "BABY").
- Comedy beats: a reaction close-up right after the joke (shocked, dizzy, smug).

## How they open (why the first 2 seconds matter)
Every reference opens mid-action: an angry face on a swing, a chef glaring into the lens, a
dizzy kid in the kitchen. Nothing slow comes first. See the hook rules in
`references/story-formula.md`.
