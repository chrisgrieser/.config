require("lua.utils")
local cons = hs.console
--------------------------------------------------------------------------------
-- Hammerspoon settings
hs.allowAppleScript(false)
hs.consoleOnTop(true)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.window.animationDuration = 0

--------------------------------------------------------------------------------

-- `hammerspoon://hs-reload` for reloading via Build System
hs.urlevent.bind("hs-reload", function()
	if cons.hswindow() then cons.hswindow():close() end -- close console
	hs.execute("touch ./is-reloading")
	hs.reload()
end)

--------------------------------------------------------------------------------
-- CONSOLE
cons.titleVisibility("hidden")
cons.toolbar(nil)

cons.consoleFont {name = "JetBrainsMonoNL Nerd Font", size = 20}

cons.darkMode(false)
cons.outputBackgroundColor {white = 0.9}

-- copy last command to clipboard
-- `hammerspoon://copy-last-command` for Karabiner Elements (⌘⇧C)
hs.urlevent.bind("copy-last-command", function()
	consoleHistory = cons.getHistory()
	lastcommand = consoleHistory[#consoleHistory]
	lastcommand = trim(lastcommand)
	hs.pasteboard.setContents(lastcommand)
	notify("Copied: '" .. lastcommand .. "'")
end)

-- `hammerspoon://clear-console` for Karabiner Elements (⌘K)
hs.urlevent.bind("clear-console", cons.clearConsole)
