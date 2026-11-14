#!/bin/sh
# Serve a scene folder (Server.luau, Story.client.luau) on http://127.0.0.1:8765 so
# Roblox Studio can fetch the scripts with HttpService:GetAsync from execute_luau
# (works with HttpEnabled off: MCP code runs with plugin rights). Restarts the server
# if it is already serving another folder.  Usage: serve_scene.sh <scene_dir>
D=$(cd "$1" && pwd) || exit 1
pkill -f "[h]ttp.server 8765" 2>/dev/null
cd "$D" && nohup python3 -m http.server 8765 --bind 127.0.0.1 >/dev/null 2>&1 &
sleep 1
curl -s -o /dev/null -w "serving $D -> %{http_code}\n" http://127.0.0.1:8765/Server.luau
