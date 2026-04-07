local M = {}

local u = require("meta.utils")
local newMenubar = hs.menubar.new
local timerEverySecs = hs.timer.doEvery
local aw = hs.application.watcher

---CONFIG-----------------------------------------------------------------------
local config = {
	reminderIcon = "✔ ",
	githubNotifIcon = "⊙ ",
}

---REMINDER COUNT---------------------------------------------------------------
M.reminderCount = newMenubar(true, "reminderCount")
	:setTitle(config.reminderIcon) ---@diagnostic disable-line: undefined-field
	:setClickCallback(function() hs.application.open("Reminders") end)

local function updateReminderCount()
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
				M.reminderCount:returnToMenuBar():setTitle(config.reminderIcon .. count)
			end
		end)
		:start()
end

--------------------------------------------------------------------------------

M.githubNotifCount = newMenubar(true, "githubNotifCount")
	:setTitle(config.githubNotifIcon) ---@diagnostic disable-line: undefined-field
	:setClickCallback(function() hs.urlevent.openURL("https://github.com/notifications") end)

local function updateGithubNotifCount()
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
			if count == 0 then
				M.githubNotifCount:removeFromMenuBar()
			else
				M.githubNotifCount:returnToMenuBar():setTitle(config.githubNotifIcon .. count)
			end
		end)
		:start()
end

--------------------------------------------------------------------------------

M.winsToProjectorButton = newMenubar(false, "moveAllWinsToProjectorScreen")
	:setTitle("Ⱅ ") ---@diagnostic disable-line: undefined-field
	:setClickCallback(function()
		local projectorScreen = hs.screen.primaryScreen()
		for _, win in pairs(hs.window:orderedWindows()) do
			win:moveToScreen(projectorScreen, true)
		end
	end)

---TRIGGERS---------------------------------------------------------------------

-- 0. initialize
updateReminderCount()
updateGithubNotifCount()

-- 1. timer
M.timer = timerEverySecs(360, function()
	updateReminderCount()
	updateGithubNotifCount()
end):start()

-- 2. app watcher
M.appWatcher = aw.new(function(appName, event, _appObj)
	if event == aw.deactivated and (appName == "Reminders" or appName == "Calendar") then
		updateReminderCount()
	end
	if event == aw.deactivated and appName == "Brave Browser" then updateGithubNotifCount() end
end):start()

-- 3. URI
hs.urlevent.bind("menubar-reminders-update", updateReminderCount)
hs.urlevent.bind("menubar-github-notifications-update", updateGithubNotifCount)

-- 4. screen count
local function showOrHideItems()
	if #hs.screen.allScreens() == 2 then
		M.winsToProjectorButton:returnToMenuBar()
		M.reminderCount:removeFromMenuBar()
		M.githubNotifCount:removeFromMenuBar()
	else
		M.winsToProjectorButton:removeFromMenuBar()
		updateReminderCount()
	end
end
showOrHideItems() -- initialize

local prevScreenCount = #hs.screen.allScreens()
M.displayCountWatcher = hs.screen.watcher
	.new(function()
		local currentScreenCount = #hs.screen.allScreens()
		if prevScreenCount == currentScreenCount then return end -- Dock changes also trigger the screenwatcher
		prevScreenCount = currentScreenCount

		showOrHideItems()
	end)
	:start()

--------------------------------------------------------------------------------
return M
