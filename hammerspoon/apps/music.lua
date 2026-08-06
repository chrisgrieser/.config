local M = {} -- persist from garbage collector

local env = require("meta.environment")
local aw = hs.application.watcher
--------------------------------------------------------------------------------

---@param action "pause"|"play"
M.music_trigger = function(action)
	local alexaTrigger = os.getenv("HOME")
		.. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/alexa/virtual-trigger"
	if not U.isExecutableFile(alexaTrigger) then return end
	print("🎵 Music: " .. action)

	if M.music_task and M.music_task:isRunning() then M.music_task:terminate() end
	M.music_task = hs.task.new(alexaTrigger, nil, { "music-" .. action }):start()
end

-- auto-pause/resume music on launch/quit of apps with sound or on Steam games
M.aw_music = aw.new(function(appName, event, app)
	-- GUARD
	if env.hasProjector() or not env.isAtHome then return end
	if not U.screenIsUnlocked() then return end
	if not (event == aw.launched or event == aw.terminated) then return end

	local audioApp = hs.fnutils.contains(U.videoAndAudioApps, appName)
	local steamGames = (app:path() or ""):find("/Application Support/Steam/steamapps/common/")
	local otherGames = (app:path() or ""):find("/Applications/StarCraft II/")
	if not (audioApp or steamGames or otherGames) then return end

	local action = event == aw.launched and "pause" or "play"
	M.music_trigger(action)
end)

M.aw_music:start()

--------------------------------------------------------------------------------
return M
