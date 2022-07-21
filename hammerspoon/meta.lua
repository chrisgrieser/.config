require("utils")

-- `hammerspoon://hs-reload` for reloading via Sublime Build System
hs.urlevent.bind("hs-reload", function()
	print("Reloading Config...")
	hs.reload()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
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

-- info on current window
function cwin ()
	print(hs.window.orderedWindows()[1]
	hs.window.orderedWindows()[1]
end

-- `hammerspoon://clear-console` for Karabiner Elements
hs.urlevent.bind("clear-console", function()
	hs.console.clearConsole()
	-- no hiding needed, since Hammerspoon already frontmost
end)
