-- Paste into execute_luau (datamodel_type "Edit") after scripts/serve_scene.sh <scene_dir>.
-- Disables the place's own scripts (remembered in attribute "StoryDisabled" so they can be
-- restored), then installs/refreshes StoryServer + StoryClient from the local server.
local HS = game:GetService("HttpService")
local SSS, SPS = game.ServerScriptService, game.StarterPlayer.StarterPlayerScripts
local function get(f) return HS:GetAsync("http://127.0.0.1:8765/" .. f, true) end
local server, client = get("Server.luau"), get("Story.client.luau")

local disabled = {}
for _, svc in ipairs({ SSS, SPS }) do
	for _, s in ipairs(svc:GetChildren()) do
		if s:IsA("BaseScript") and s.Name ~= "StoryServer" and s.Name ~= "StoryClient" and not s.Disabled then
			s.Disabled = true
			table.insert(disabled, s:GetFullName())
		end
	end
end
if #disabled > 0 then workspace:SetAttribute("StoryDisabled", table.concat(disabled, ";")) end

local function put(parent, class, name, src)
	local s = parent:FindFirstChild(name) or Instance.new(class)
	s.Name, s.Source, s.Parent = name, src, parent
end
put(SSS, "Script", "StoryServer", server)
put(SPS, "LocalScript", "StoryClient", client)
return ("installed: server %d bytes, client %d bytes; disabled: %s"):format(#server, #client,
	workspace:GetAttribute("StoryDisabled") or "none")

--[[ RESTORE (separate execute_luau call, Edit datamodel, play stopped):
local SSS, SPS = game.ServerScriptService, game.StarterPlayer.StarterPlayerScripts
for _, n in ipairs({ "StoryServer", "StoryClient" }) do
	for _, svc in ipairs({ SSS, SPS }) do local s = svc:FindFirstChild(n); if s then s:Destroy() end end
end
for path in string.gmatch(workspace:GetAttribute("StoryDisabled") or "", "[^;]+") do
	local inst = game
	for part in string.gmatch(path, "[^.]+") do inst = inst and inst:FindFirstChild(part) end
	if inst and inst ~= game then inst.Disabled = false end
end
workspace:SetAttribute("StoryDisabled", nil)
workspace:SetAttribute("AnimsReady", nil)
workspace:SetAttribute("Go", nil)
for _, svc in ipairs({ game:GetService("ReplicatedStorage"), game:GetService("ServerStorage") }) do
	for _, n in ipairs({ "MoonAnims", "MoonAnimator2Saves" }) do
		local f = svc:FindFirstChild(n)
		if f then f:Destroy() end
	end
end
return "restored"
]]
