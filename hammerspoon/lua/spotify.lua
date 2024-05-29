local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- auto-pause/resume Spotify on launch/quit of apps with sound
M.aw_spotify = aw.new(function(appName, eventType)
	if
		not u.screenIsUnlocked()
		or not (env.isAtHome)
		or env.isProjector()
		or u.betweenTime(22, 7)
		or not (hs.fnutils.contains(env.videoAndAudioApps, appName))
		or not (eventType == aw.launched or eventType == aw.terminated)
	then
		return
	end

	if M.spotify_task and M.spotify_task:isRunning() then M.spotify_task:terminate() end

	local action = eventType == aw.launched and "pause" or "play"
	local homebrewPrefix = env.isAtMother and "/usr/local" or "/opt/homebrew"
	local binary = homebrewPrefix .. "/bin/spotify_player"
	M.spotify_task = hs.task.new(binary, nil, { "playback", action }):start()
end):start()

--------------------------------------------------------------------------------
return M
