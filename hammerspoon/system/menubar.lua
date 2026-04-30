local M = {}

local u = require("meta.utils")
local aw = hs.application.watcher

---CONFIG-----------------------------------------------------------------------
local config = {
	reminderIcon = "✔ ",
	githubNotifIcon = "● ", -- ⦿◉●○
	winToProjectorIcon = "Ⱅ ",
}

---REMINDER COUNT---------------------------------------------------------------
M.reminderCount = hs.menubar.new(false, "reminderCount") --[[@as hs.menubar]]

local function updateReminderCount()
	if #hs.screen.allScreens() == 2 then
		M.reminderCount:removeFromMenuBar()
		return
	end
	if M.updateReminders and M.updateReminders:isRunning() then return end
	M.updateReminders = hs.task
		.new("./system/menubar/count-reminders.swift", function(code, stdout, stderr)
			if code ~= 0 then
				u.notify("❌ Could not update reminders count: " .. stderr)
				return
			end
			local count = tonumber(stdout)
			if count == 0 then
				M.reminderCount:removeFromMenuBar()
			else
				M
					.reminderCount
					:returnToMenuBar()
					:setTitle(config.reminderIcon .. count) ---@diagnostic disable-line: undefined-field
					:setClickCallback(function() hs.application.open("Reminders") end)
			end
		end)
		:start()
end

--------------------------------------------------------------------------------

M.githubNotifCount = hs.menubar.new(false, "githubNotifCount") --[[@as hs.menubar]]

local function updateGithubNotifCount()
	if #hs.screen.allScreens() == 2 then
		M.githubNotifCount:removeFromMenuBar()
		return
	end
	if M.updateGithubNotifCount and M.updateGithubNotifCount:isRunning() then return end

	-- running `curl` request in a shell script, since hammerspoons's
	-- `hs.http` seems to be buggy and automatically caches request results with
	-- no way of updating them?
	M.updateGithubNotifCount = hs.task
		.new("./system/menubar/github-notif-count.sh", function(code, stdout, stderr)
			if code ~= 0 then
				u.notify("❌ Could not update github notifications count: " .. stderr)
				return
			end
			local count = tonumber(stdout)
			if count == 0 or count == nil then
				M.githubNotifCount:removeFromMenuBar()
			else
				M
					.githubNotifCount
					:returnToMenuBar()
					:setTitle(config.githubNotifIcon .. count) ---@diagnostic disable-line: undefined-field
					:setClickCallback(
						function() hs.urlevent.openURL("https://github.com/notifications") end
					)
			end
		end)
		:start()
end

--------------------------------------------------------------------------------

M.winsToProjectorButton = hs.menubar.new(false, "winsToProjectorButton") --[[@as hs.menubar]]

local function updateWinsToProjectorButton()
	if #hs.screen.allScreens() == 2 then
		M
			.winsToProjectorButton
			:returnToMenuBar()
			:setTitle(config.winToProjectorIcon) ---@diagnostic disable-line: undefined-field
			:setClickCallback(function()
				-- move all windows to projector
				local projectorScreen = hs.screen.primaryScreen()
				for _, win in pairs(hs.window:orderedWindows()) do
					win:moveToScreen(projectorScreen, true)
				end
				-- darken display
				require("appearance.dark-mode").darkenDisplay()
			end)
	else
		M.winsToProjectorButton:removeFromMenuBar()
	end
end

---TRIGGERS---------------------------------------------------------------------

-- 0. initialize
updateReminderCount()
if u.isSystemStart() then u.defer({ 3, 10 }, updateReminderCount) end -- wait for sync
updateGithubNotifCount()
updateWinsToProjectorButton()

-- 1. timer
M.timer = hs.timer
	.doEvery(360, function()
		updateReminderCount()
		updateGithubNotifCount()
	end)
	:start()

-- 2. app watcher
M.appWatcher = aw.new(function(appName, event, _appObj)
	if event == aw.terminated or event == aw.deactivated then
		if appName == "Reminders" or appName == "Calendar" then updateReminderCount() end
		if appName == "Brave Browser" then updateGithubNotifCount() end
	end
end):start()

-- 3. URI (used by Alfred workflows)
hs.urlevent.bind("menubar-reminders-update", updateReminderCount)
hs.urlevent.bind("menubar-github-notifications-update", updateGithubNotifCount)

-- 4. screen count change
M.displayCountWatcher = hs.screen.watcher
	.new(function()
		updateReminderCount()
		updateGithubNotifCount()
		updateWinsToProjectorButton()
	end)
	:start()

--------------------------------------------------------------------------------
return M
