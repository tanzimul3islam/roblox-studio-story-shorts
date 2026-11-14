#!/bin/sh
# Record the Roblox Studio window with OBS (PipeWire full-screen capture) for N seconds.
# Focuses the Studio window (switching the user's screen to its workspace), parks the
# mouse, starts OBS, waits, stops (retrying), then returns to the workspace the user was on.
# Prints the recording path last. Run it in the background, then set the "Go" attribute.
# Usage: rec_take.sh <seconds> [title-substring]   (default title: "- Roblox Studio")
SEC=${1:-62}
TITLE=${2:-"- Roblox Studio"}
K=$(dirname "$(readlink -f "$0")")
OBS="python3 -I $K/obsws.py"
CUR=$(host-spawn --no-pty swaymsg -t get_workspaces | python3 -c "import json,sys;print([w['num'] for w in json.load(sys.stdin) if w['focused']][0])")
host-spawn --no-pty swaymsg "[title=\"$TITLE\"] focus" >/dev/null
host-spawn --no-pty swaymsg seat - cursor set 1900 1075 >/dev/null
$OBS start || { sleep 3; $OBS start; }
echo "recording started $(date +%T)"
sleep "$SEC"
$OBS stop || { sleep 3; $OBS stop; } || { sleep 5; $OBS stop; }
host-spawn --no-pty swaymsg workspace number "$CUR" >/dev/null
$OBS status
ls -t /var/mnt/sda3/Roblox_Shorts/studio/obs_recordings/*.mp4 | head -1
