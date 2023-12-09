local M = {} -- persist from garbage collector

local u = require("lua.utils")
local wu = require("lua.window-utils")
local c = hs.caffeinate.watcher
local env = require("lua.environment-vars")

--------------------------------------------------------------------------------

-- keep the iMac display brightness low when projector is connected
M.caff_projectorScreensaver = c.new(function(event)
	if env.isAtOffice then return end
	if
		event == c.screensaverDidStop
		or event == c.screensaverDidStart
		or event == c.screensDidWake
		or event == c.systemDidWake
		or event == c.screensDidSleep
	then
		u.runWithDelays({ 0, 1, 3 }, function()
			if env.isProjector() then wu.iMacDisplay:setBrightness(0) end
		end)
	end
end):start()

-- on Mondays shortly before 10:00, open #fg-organisation Slack Channel
M.timer_JourFixe = hs.timer
	.doAt("09:59", "01d", function()
		if not (os.date("%a") == "Mon" and u.screenIsUnlocked()) then return end

		hs.alert.show("Jour Fixe")
		local fgOrganisationChannel = "slack://channel?team=T010A5PEMBQ&id=CV95T641Y"
		hs.urlevent.openURL(fgOrganisationChannel)
	end)
	:start()

--------------------------------------------------------------------------------
-- BACKUP / MAINTENANCE

-- Backup Vault, Dotfiles, Bookmarks
M.timer_nightlyMaintenance = hs.timer
	.doAt("01:00", "01d", function()
		if os.date("%a") == "Sun" then hs.loadSpoon("EmmyLua") end

		-- GUARD
		local isSunTueThuSat = os.date("%w") % 2 == 0
		if isSunTueThuSat then return end

		-- stylua: ignore start
		M.task_bookmarksBackup = hs.task.new("./helpers/bookmark-bkp.sh", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Bookmark Backup successful" or "⚠️ Bookmark Backup failed: " .. stdErr
			u.notify(msg)
		end):start()
		M.task_dotfileBackup = hs.task.new("./helpers/dotfile-bkp.sh", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Dotfile Backup successful" or "⚠️ Dotfile Backup failed: " .. stdErr
			u.notify(msg)
		end):start()
		print("Reminder Backup starting…")
		M.task_reminderBackup = hs.task.new("./helpers/reminders-bkp.js", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Reminder Backup successful" or "⚠️ Reminder Backup failed: " .. stdErr
			u.notify(msg)
		end):start()
		u.applescript([[tell application id "com.runningwithcrayons.Alfred" to run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"]])
		-- stylua: ignore end
	end, true)
	:start()

--------------------------------------------------------------------------------
return M
