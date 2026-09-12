local M = {} -- persist from garbage collector

local env = require("meta.environment")
local timerAt = hs.timer.doAt
local timerEverySecs = hs.timer.doEvery

---FORCE REMINDERS SYNC ON STARTUP----------------------------------------------
if U.isSystemStart() then
	print("📅 Syncing Reminders")
	hs.execute("open -g -a Reminders") -- `-g` to open in background
	U.defer({ 5, 10 }, function() U.quitApps("Reminders") end)
end

---CLOCK------------------------------------------------------------------------
-- Show clock every full hour
M.timer_clock = timerEverySecs(60, function()
	local isFullHour = os.date("%M") == "00"
	if isFullHour and U.screenIsUnlocked() and not env.hasProjector() then
		local hour = tostring(os.date("%H:%M"))
		hs.alert(hour, 3)
	end
end):start()

-- MAINTENANCE------------------------------------------------------------------
do
	local cronjobDir = "./system/cronjobs" -- CONFIG

	local function runEveryFileIn(dir)
		for file in hs.fs.dir(dir) do
			if file == "." or file == ".." then goto continue end -- special UNIX locations
			local ext = file:match("%.%w+$")
			if ext ~= ".sh" and ext ~= ".applescript" then goto continue end
			local jobfile = dir .. "/" .. file
			if not U.isExecutableFile(jobfile) then
				print("⚠️ " .. jobfile .. " is not executable.")
				goto continue
			end
			local task = hs.task.new
			M["cronjob_" .. file] = task(jobfile, function(code, stdout, stderr)
				local output = (stdout .. "\n" .. stderr):gsub("%s+$", "")
				local fileShort = file:gsub("%.%w+$", "")
				local msg = "🕑 " .. fileShort .. (output ~= "" and ": " .. output or "")
				if code ~= 0 then return U.notify("❌ " .. msg) end
				print(msg)
			end):start()
			::continue::
		end
	end

	M.timer_hourlyCronjobs = timerEverySecs(
		3600,
		function() runEveryFileIn(cronjobDir .. "/hourly") end
	):start()

	M.timer_biweeklyCronjobs = timerAt("01:00", "01d", function()
		if os.date("%w") % 3 == 0 then runEveryFileIn(cronjobDir .. "/biweekly") end
	end, true):start()
end

---LUA TYPINGS FOR HAMMERSPOON--------------------------------------------------

-- URI for Justfile
hs.urlevent.bind("update-emmylua-types", function() hs.loadSpoon("EmmyLua") end)

---UPTIME CHECK-----------------------------------------------------------------
local maxUptimeDays = 30 -- CONFIG
M.timer_uptime = timerAt("01:30", "01d", function()
	local stdout = hs.execute("uptime") or ""
	local uptimeDays = tonumber(stdout:match("up (%d+) days,") or 0)
	if uptimeDays > maxUptimeDays then
		U.createReminderToday("🖥️ Uptime is over " .. maxUptimeDays .. " days")
	end
end):start()

---SLEEP TIMER------------------------------------------------------------------
-- When projector is connected, check every x min if device has been idle for y
-- minutes. If so, alert and wait for z secs. If still idle then, quit
-- all video apps.
local config = {
	checkIntervalMins = 15,
	idleMins = 50,
	timeToReactSecs = 20,
}

local doEvery = hs.timer.doEvery
M.sleepTimer = doEvery(config.checkIntervalMins * 60, function()
	-- triggering conditions
	if not env.hasProjector() then return end
	local userIsActive = (hs.host.idleTime() / 60) < config.idleMins
	if userIsActive then return end

	-- only quit if any video app is running
	for _, app in pairs(U.videoAndAudioApps) do
		if U.app(app) then return end
	end
	-----------------------------------------------------------------------------

	-- inform user about upcoming sleep
	local alertMsg = ("💤 Will sleep in %ds if idle."):format(config.timeToReactSecs)
	U.alertAndLog(alertMsg, config.timeToReactSecs)
	U.sound("Submarine", 0.6)

	-- remove alert earlier if user did something
	local halfTime = math.ceil(config.timeToReactSecs / 2)
	U.defer(halfTime, function()
		local userDidSth = hs.host.idleTime() < (config.timeToReactSecs / 2)
		if userDidSth then hs.alert.closeAll() end
	end)

	-- abort if user did something
	U.defer(config.timeToReactSecs, function()
		local userDidSth = hs.host.idleTime() < config.timeToReactSecs
		if userDidSth then return end

		-- close if user idle
		U.closeBrowserTabsWith("all")
		U.closeVideoApps()
		U.quitFullscreenSpaces()

		U.notify("💤 Sleep timer triggered")
		U.notifyOnPhone("💤 Sleep timer", "triggered at " .. os.date("%H:%M"))
	end)
end):start()

--------------------------------------------------------------------------------
return M
