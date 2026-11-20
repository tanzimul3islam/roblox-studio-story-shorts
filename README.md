# roblox-studio-story-shorts

A skill that makes narrated Roblox story Shorts (vertical 1080x1920, 60 fps) by building and
filming scenes live in Roblox Studio through the Roblox_Studio MCP server, authoring & exporting
reusable R6 `AnimationTrack`s with the installed **Moon Animator 2** plugin, recording the
playtest with OBS at 5x slow motion (`ROTATE_90` portrait capture), and rendering with ffmpeg.

- **Look:** pure R6 dressed UGC avatars (chunky sculpted hair meshes, baseball caps, 3D hoodie
  hoods/scarves, crossbody bags, backpacks, Classic Shirts/Pants, 3D sneakers) or code-built
  classic blocky characters; big drawn 2D faces that swap every 1-2 s beat (`grin`, `worried`,
  `smug`, `shocked`, `sad`); glowing multi-layer Roblox `ParticleEmitter` auras (`TimeScale = 1/SLOW`);
  high-quality `Level21` `Future` lighting with soft shadows, warm sunset `Atmosphere` fog,
  `BloomEffect` (`Threshold = 1.95`), `DepthOfFieldEffect` background blur, and warm color grading.
- **Moon Animator 2:** poses and walks are authored as `.moon2` files and exported through the
  installed Moon Animator 2 plugin (`_G.MoonGlobal`) into `ReplicatedStorage.MoonAnims`, then
  played as real `AnimationTrack`s synchronized to story time.
- **Hook:** every short grabs attention in the first 2 seconds (hook line at ~0.1 s, a
  moving close-up push-in of the strongest moment, a sting under the first word).
- **Smooth capture:** takes play 5x slower in Studio (`SLOW = 5`) and are sped back up by
  `render.sh`, giving ~42-60 unique rendered frames per story second with 0 frozen gaps > 70 ms.

Start with `SKILL.md`. Scene templates are in `templates/moon_aura_kit/` (R6 UGC + Moon Animator 2 +
Particle Aura) and `templates/modern_kit/` (code-built classic cast & interior/city sets), helper
scripts in `scripts/`, and style/pipeline notes in `references/`.
