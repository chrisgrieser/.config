require("lua.utils")
local cons = hs.console
--------------------------------------------------------------------------------

-- HAMMERSPOON SETTINGS
hs.consoleOnTop(false)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.window.animationDuration = 0

--------------------------------------------------------------------------------

-- `hammerspoon://hs-reload` for reloading via Build System
local reloadIndicator = "/tmp/hs-is-reloading"
uriScheme("hs-reload", function()
	if cons.hswindow() then cons.hswindow():close() end -- close console
	hs.execute("touch " .. reloadIndicator)
	hs.reload()
	-- INFO will also run the systemStart function due to reload
end)

function SystemStart()
	-- prevent commit spam when updating hammerspoon config regularly
	local _, isReloading = hs.execute("[[ -e " .. reloadIndicator .. " ]]")
	if isReloading then
		os.remove(reloadIndicator)
		-- use neovim automation to display the notification in neovim
		hs.execute([[echo 'vim.notify("✅ Hammerspoon reloaded.")' > /tmp/nvim-automation]])
		return
	else
		if app("Finder") and #app("Finder"):allWindows() == 0 then app("Finder"):kill() end
		notify("Hammerspoon started.")
		syncAllGitRepos()
		notify("Sync finished.")
	end
end

--------------------------------------------------------------------------------
-- CONSOLE
cons.titleVisibility("hidden")
cons.toolbar(nil)
cons.consoleFont { name = "JetBrainsMonoNL Nerd Font", size = 21 }

---@param mode string "dark"|"light""
function setConsoleColors(mode)
	if mode == "dark" then
		cons.darkMode(true)
		cons.outputBackgroundColor { white = 0.1 }
		cons.consolePrintColor { white = 0.9 }
		cons.consoleCommandColor { white = 0.5 }
	else
		cons.darkMode(false)
		cons.outputBackgroundColor { white = 0.9 }
		cons.consolePrintColor { white = 0.1 }
		cons.consoleCommandColor { white = 0.5 }
	end
end

-- initialize
local isDark = hs.execute([[defaults read -g AppleInterfaceStyle]]):find("Dark") and "dark" or "light"
setConsoleColors(isDark)

-- copy last command to clipboard
-- `hammerspoon://copy-last-command` for Karabiner Elements (⌘⇧C)
uriScheme("copy-last-command", function()
	consoleHistory = cons.getHistory()
	lastcommand = consoleHistory[#consoleHistory]
	lastcommand = trim(lastcommand)
	hs.pasteboard.setContents(lastcommand)
	notify("Copied: '" .. lastcommand .. "'")
end)

-- `hammerspoon://clear-console` for Karabiner Elements (⌘K)
uriScheme("clear-console", cons.clearConsole)
