require("lua.utils")
local cons = hs.console
--------------------------------------------------------------------------------

-- HAMMERSPOON SETTINGS
hs.consoleOnTop(false)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.application.enableSpotlightForNameSearches(false)
hs.window.animationDuration = 0

--------------------------------------------------------------------------------

-- `hammerspoon://hs-reload` for reloading via Build System
local reloadIndicator = "/tmp/hs-is-reloading"
UriScheme("hs-reload", function()
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
		-- to make reloads clearer in the console
		print("\n---------------------------------------------------------------\n") 
	else
		QuitFinderIfNoWindow()
		Notify("Hammerspoon started.")
		SyncAllGitRepos("notify")

		-- HACK for https://github.com/FelixKratz/SketchyBar/issues/322
		hs.execute([[osascript -l JavaScript "$DOTFILE_FOLDER/utility-scripts/dismiss-notification.js"]])
	end
end

--------------------------------------------------------------------------------
-- CONSOLE
cons.titleVisibility("hidden")
cons.toolbar(nil)
cons.consoleFont { name = "JetBrainsMonoNL Nerd Font", size = 21 }

---@param mode string "dark"|"light""
function SetConsoleColors(mode)
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
SetConsoleColors(isDark)

-- copy last command to clipboard
-- `hammerspoon://copy-last-command` for Karabiner Elements (⌘⇧C)
UriScheme("copy-last-command", function()
	local consoleHistory = cons.getHistory()
	if not consoleHistory then return end
	local lastcommand = consoleHistory[#consoleHistory]
	lastcommand = Trim(lastcommand)
	hs.pasteboard.setContents(lastcommand)
	Notify("Copied: '" .. lastcommand .. "'")
end)

-- `hammerspoon://clear-console` for Karabiner Elements (⌘K)
UriScheme("clear-console", cons.clearConsole)

