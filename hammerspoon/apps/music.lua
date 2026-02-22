local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- auto-pause/resume music on launch/quit of apps with sound or on Steam games
M.aw_music = aw.new(function(appName, event, app)
	-- GUARD
	if not env.isAtHome or env.isProjector() then return end
	if not u.screenIsUnlocked() then return end
	if not (event == aw.launched or event == aw.terminated) then return end

	local audioApp = hs.fnutils.contains(u.videoAndAudioApps, appName)
	local steamGames = (app:path() or ""):find("/Application Support/Steam/steamapps/common/")
	local otherGames = (app:path() or ""):find("/Applications/StarCraft II/")
	if not (audioApp or steamGames or otherGames) then return end

	if M.music_task and M.music_task:isRunning() then M.music_task:terminate() end

	local action = event == aw.launched and "pause" or "play"
	local alexaTrigger = os.getenv("HOME")
		.. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/alexa-virtual-trigger"
	if not u.isExecutableFile(alexaTrigger) then return end
	print("🎵 Music: " .. action)

	M.music_task = hs.task.new(alexaTrigger, nil, { "music-" .. action }):start()
end)

M.aw_music:start()

--------------------------------------------------------------------------------
return M
