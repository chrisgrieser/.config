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
uriScheme("hs-reload", function()
	if cons.hswindow() then cons.hswindow():close() end -- close console
	hs.execute("touch ./is-reloading")
	hs.reload()
	-- INFO will also run the systemStart function due to reload
end)

--------------------------------------------------------------------------------
-- CONSOLE
cons.titleVisibility("hidden")
cons.toolbar(nil)

cons.consoleFont {name = "JetBrainsMonoNL Nerd Font", size = 20}

---@param toDark boolean
function setConsoleColors(toDark)
	if toDark then
		cons.darkMode(true)
		cons.outputBackgroundColor {white = 0.1}
		cons.consolePrintColor {white = 0.9}
		cons.consoleCommandColor {white = 0.5}
	else
		cons.darkMode(false)
		cons.outputBackgroundColor {white = 0.9}
		cons.consolePrintColor {white = 0.1}
		cons.consoleCommandColor {white = 0.5}
	end
end

-- initialize
local isDark = hs.execute[[defaults read -g AppleInterfaceStyle]] == "Dark\n"
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
