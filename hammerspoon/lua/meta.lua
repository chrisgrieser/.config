require("lua.utils")
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
	if hs.console.hswindow() then hs.console.hswindow():close() end -- close console
	hs.execute("touch ./is-reloading")
	hs.reload()
end)

--------------------------------------------------------------------------------
-- CONSOLE

hs.console.titleVisibility("hidden")
hs.console.toolbar(nil)

hs.console.consoleFont({name = "JetBrainsMonoNL Nerd Font", size = 19})

hs.console.darkMode(false)
hs.console.outputBackgroundColor{ white = 0.9 }

-- copy last command to clipboard
-- `hammerspoon://copy-last-command` for Karabiner Elements (⌘⇧C)
hs.urlevent.bind("copy-last-command", function()
	consoleHistory = hs.console.getHistory()
	lastcommand = consoleHistory[#consoleHistory]
	lastcommand = trim(lastcommand)
	hs.pasteboard.setContents(lastcommand)
	notify("Copied: '"..lastcommand.."'")
end)

-- `hammerspoon://clear-console` for Karabiner Elements (⌘K)
hs.urlevent.bind("clear-console",hs.console.clearConsole)

-- aliases
i = hs.inspect -- to inspect tables in the console
a = hs.application

