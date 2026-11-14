# roblox-studio-story-shorts

A Claude Code skill that makes narrated Roblox story Shorts (1080x1920) by building and
filming scenes live in Roblox Studio through the Roblox Studio MCP server, recording the
playtest with OBS, and rendering with ffmpeg.

- **Look:** classic blocky Roblox characters with big drawn faces that change every beat,
  printed clothes, chunky hair; cozy homes, cooking class, restaurant and playground sets;
  close eye-level shots with a blurred background; word-by-word captions.
- **Hook:** every short grabs attention in the first 2 seconds (hook line at ~0.1 s, a
  moving close-up of the strongest moment, a sting under the first word).
- **Smooth capture:** takes play 5x slower in Studio and are sped back up, so Studio's low
  frame rate under Wine still gives a smooth 30 fps video.
- **Everything is built in code** (characters, faces, clothes, sets, poses): nothing depends
  on Roblox asset downloads.

Start with `SKILL.md`. Scene templates are in `templates/modern_kit/`, helper scripts in
`scripts/`, and the style and pipeline notes in `references/`.

Written for one specific Linux setup (Fedora Sway host, distrobox, Roblox Studio in Bottles,
OBS Flatpak, Pocket TTS, faster-whisper); paths in the docs refer to that machine.
