local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- auto-pause/resume Spotify on launch/quit of apps with sound
M.aw_spotify = aw.new(function(appName, eventType)
	if
		not u.screenIsUnlocked()
		or not env.isAtHome
		or env.isProjector()
		or not (hs.fnutils.contains(u.videoAndAudioApps, appName))
		or not (eventType == aw.launched or eventType == aw.terminated)
	then
		return
	end
	if M.spotify_task and M.spotify_task:isRunning() then M.spotify_task:terminate() end

	local action = eventType == aw.launched and "pause" or "play"
	local alexaTrigger = os.getenv("HOME")
		.. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/alexa-virtual-trigger"

	M.spotify_task = hs.task.new(alexaTrigger, nil, { "spotify-" .. action }):start()
end):start() --[[@as hs.application.watcher]]

--------------------------------------------------------------------------------
return M
