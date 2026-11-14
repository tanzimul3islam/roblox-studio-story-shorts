# Studio, MCP, OBS: setup and failure recovery

## Machine facts
- Fedora 44 Sway Atomic host. Claude runs in the `claude-debian` distrobox; reach the host with
  `host-spawn --no-pty ...` (swaymsg, flatpak).
- Roblox Studio runs in Bottles Flatpak `com.usebottles.bottles`, bottle `RobloxStudio__138`,
  runner soda-11.0-10. The MCP server `Roblox_Studio` (user scope in ~/.claude.json) is the
  launcher `/var/home/tanzimul/.local/share/distrobox-homes/chatgpt-ubuntu-test/.codex/bin/roblox-studio-mcp`
  which `flatpak enter`s the **running** Studio's sandbox. Never start the MCP with a new
  `flatpak run` session (conflicting Wine sessions froze Studio).
- Always call `list_roblox_studios` first and use the returned `studio_id`; ids change every
  Studio session.
- ffmpeg/ffprobe: `/var/mnt/sda3/tools/ffmpeg/bin/` (host ffmpeg cannot decode H.264; none in
  the container).
- OBS 32 (Flatpak) is open with a PipeWire full-screen capture; recordings land in
  `/var/mnt/sda3/Roblox_Shorts/studio/obs_recordings/`. obs-websocket on 127.0.0.1:4455 with
  a password, which `scripts/obsws.py` reads from OBS's config by itself.
- Pocket TTS: `~/.venv/bin/python`. faster-whisper: `/var/mnt/sda3/tools/whisper-env/bin/python`.

## Viewport geometry (crop numbers)
Studio window 1910x1032 (tiled, full screen). The playtest viewport is x 291-1733, y 148-965
(1442x818). The 9:16 crop is `crop=460:818:782:148` (centre), upscaled 2.35x to 1080x1920.
If the layout changes (panels moved, different window size), grab one frame of a recording
and re-measure before rendering. Moving the window to another workspace is fine.

## Recording facts
- OBS records the whole screen, so `rec_take.sh` focuses the Studio window: **the user's screen
  switches to that workspace for the whole recording** (about take length + 20 s). Say so
  before each recording.
- The mouse cursor can stay inside the viewport even after `cursor set`. Check a frame; if it
  is inside the crop, pass a delogo box to `render.sh`.
- obs-websocket can take >10 s to answer Start/StopRecord; obsws.py uses a 45 s timeout and
  rec_take.sh retries. If a stop still fails, run `obsws.py status` and `obsws.py stop` again
  (a stopped-late recording only adds black at the end).
- Desktop notifications appear top-right, outside the crop.

## If Studio crashes or MCP disconnects
- Studio sometimes crashes right at playtest start (log just stops while creating the
  server view): 2 of about 8 starts on 2026-11-13/14, with 6 actors and ~600 parts. Batch
  edits so you restart play as rarely as possible (update Server and Client together, then
  one start).
- After a PC restart, Roblox's asset server may refuse downloads (HTTP 403 / "could not
  fetch") even though Studio is signed in: stock animations, the default face decal and the
  default body meshes fail. The modern kit does not depend on them: procedural poses,
  code-built faces and outfits; bodies may look blockier when the meshes fail.
- After a PC restart OBS is closed too: start it with
  `host-spawn --no-pty flatpak run com.obsproject.Studio --minimize-to-tray` and make a
  3 s test recording to confirm the PipeWire capture still works.
- Stop the scene server with `pkill -f "[h]ttp.server 8765"` (the bracket stops pkill from
  matching, and killing, its own shell).
- After a crash the MCP tools report no studios or disconnect.
- Relaunch Studio with the user's OK, using the same command the user's setup used:
  ```bash
  nohup host-spawn --no-pty env FLATPAK_USER_DIR=/var/mnt/sda3/flatpak flatpak run \
    --filesystem=/var/mnt/sda3/Roblox_Shorts --command=bottles-cli com.usebottles.bottles \
    run -b RobloxStudio__138 -e '<...>\Roblox\Versions\<version>\RobloxStudioBeta.exe' \
    -- 'Z:\var\mnt\sda3\Roblox_Shorts\studio\short02\short02.rbxlx' >/dev/null 2>&1 &
  ```
  Find `<version>` with `ls /var/mnt/sda3/bottles-data/data/bottles/bottles/RobloxStudio__138/drive_c/users/tanzimul/AppData/Local/Roblox/Versions/`
  (the folder containing RobloxStudioBeta.exe). Wait for the window title to show a place.
- After a crash Studio may open `short02_AutoRecovery_0.rbxl` instead; that is fine to work
  in (it is a separate file). Pass its title to rec_take.sh if needed.
- If the Claude session's Roblox_Studio MCP server shows "connection closed", the user has to
  reconnect it (restart the session or reconnect MCP servers); its launcher attaches to the
  Studio process that was running when it started.

## Never
- Never `save_place` the user's place with story scripts in it; restore with the RESTORE block
  in `references/install.luau` and leave it unsaved.
- Never hard-code a Studio PID or version folder in scripts.
