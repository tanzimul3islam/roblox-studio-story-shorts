# Uploading to the roxpus channel

Channel **roxpus** (@roxpus), `https://studio.youtube.com/channel/UCwhxWQE5AoAXNvJuJCZAmfQ`.
Brand files and their generator: `/var/mnt/sda3/Roblox_Shorts/channel/` (`make_brand.py`,
`logo_800.png`, `banner_2560x1440.png`). Logo and banner are drawn (mascot = blocky yellow
head with a pet cloud); the user rejected brand art cut from video frames.

## Browser & Upload Method
Browser subagent (user is already signed in on `https://studio.youtube.com/channel/UCwhxWQE5AoAXNvJuJCZAmfQ`).
**Standing rule (Nov 2026):** The user drags the **full-quality `<Short>.mp4`** directly into the YouTube Studio upload dialog! Do **not** create a compressed `<10 MB` `_upload.mp4` or use `file_upload` unless the user explicitly asks for it.

## Upload flow (Studio upload dialog, `/videos/upload?d=ud`)
1. Open `https://studio.youtube.com/channel/UCwhxWQE5AoAXNvJuJCZAmfQ/videos/upload?d=ud` so the "Upload videos" dialog is ready, then tell the user to drag `<Short>.mp4` into the window. Wait for them to confirm it's dropped.
2. Title: triple-click the title box, ctrl+a, type. Description: click, type. Title style:
   "In This World, <Premise> <emoji>" (like flookus / Ryex). Description: 1-2 teaser lines,
   "A short story filmed in Roblox Studio. New story every week!", `#roblox #robloxstory
   #shorts`, then "Unofficial fan content, not affiliated with or endorsed by Roblox Corporation."
3. Audience: **No, it's not made for kids** (standing channel upload setting, Nov 2026 — keep stories wholesome, but set "No, it's not made for kids" on YouTube).
4. "Show more" → **AI use** question: this is the user's own declaration. Leave it for the
   user (the permission layer blocks Claude from answering it). Facts to give them: Pocket TTS
   narration (AI voice) of a fictional kid; cartoon Roblox visuals; procedural background
   music. None of YouTube's four listed cases obviously apply.
5. Tags (in Show more): click the Tags box, type the comma-separated list ending with a comma,
   press Enter; check the `N/500` counter and the "Saved as private" badge.
6. Next x3 to Visibility; set what the user approved. Ask before Publish if anything on the
   form is still unanswered.

## Tags (research Nov 2026)
YouTube says tags play a minimal role; many top Roblox story videos have none, and flookus
pastes one generic block. Use relevant terms people actually search (YouTube autocomplete):
- Format: `in this world`, `in this world roblox`, `in this world roblox story`,
  `in this world shorts`, `in this town`
- Niche: `roblox story`, `roblox stories`, `roblox storytime`, `roblox story shorts`,
  `roblox shorts`, `roblox animation`, `roblox animation story`, `roblox story animation`,
  `roblox short story`, `robloxstory`, `roblox`
- Audience: `wholesome roblox story`, `roblox story for kids`
- Per video: 2-3 premise terms (e.g. `pet cloud`, `everyone gets a pet cloud`)
- Channel: `roxpus`
Stay under 500 characters (multi-word tags count their quotes). Never use misleading popular
terms (Brookhaven, Berry Avenue, "sus", romance terms): wrong for the content and for kids.
Re-check autocomplete with
`https://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q=<term>` and
competitor tags from the watch page's `<meta name="keywords">` (a value of "video, sharing,
camera phone, ..." means the video has no tags).
