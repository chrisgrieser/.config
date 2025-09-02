local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- auto-pause/resume Spotify on launch/quit of apps with sound or on Steam games
M.aw_spotify = aw.new(function(appName, event, app)
	-- GUARD
	if not env.isAtHome or env.isProjector() then return end
	if not u.screenIsUnlocked() then return end
	if not (event == aw.launched or event == aw.terminated) then return end
	local audioApp = hs.fnutils.contains(u.videoAndAudioApps, appName)
	local steamGames = (app:path() or ""):find("/Application Support/Steam/steamapps/common/") 
	if not (audioApp or steamGames) then return end

	if M.spotify_task and M.spotify_task:isRunning() then M.spotify_task:terminate() end

	-- using Alexa virtual trigger since it's more reliable than `spotify_player`
	local action = event == aw.launched and "pause" or "play"
	local alexaTrigger = os.getenv("HOME")
		.. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/alexa-virtual-trigger"
	if not u.isExecutable(alexaTrigger) then return end
	print("🎵 Spotify: " .. action)

	M.spotify_task = hs.task.new(alexaTrigger, nil, { "spotify-" .. action }):start()
end) --[[@as hs.application.watcher]]

M.aw_spotify:start()

--------------------------------------------------------------------------------
return M
