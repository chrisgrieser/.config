require("utils")

-- `hammerspoon://hs-reload` for reloading via Sublime Build System or Karabiner
hs.urlevent.bind("hs-reload", function()
	print("Reloading Config...")
	hs.reload()
end)

--------------------------------------------------------------------------------
-- CONSOLE
-- https://www.hammerspoon.org/docs/hs.console.html#getHistory

hs.console.titleVisibility("hidden")
hs.console.toolbar(nil)

hs.console.consoleFont({name = "JetBrainsMonoNL Nerd Font", size = 17})

hs.console.darkMode(false)
hs.console.outputBackgroundColor{ white = 0.92 }

-- copy last command to clipboard
function lc ()
	consoleHistory = hs.console.getHistory()
	lastcommand = consoleHistory[#consoleHistory-1] -- -1 to not copy this itself
	hs.pasteboard.setContents(lastcommand)
	print ("Copied: '"..lastcommand.."'")
end

-- `hammerspoon://clear-console` for Karabiner Elements
hs.urlevent.bind("clear-console", function()
	hs.console.clearConsole()
end)
