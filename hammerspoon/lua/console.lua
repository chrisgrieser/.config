local u = require("lua.utils")
require("lua.window-utils")
local cons = hs.console
--------------------------------------------------------------------------------

-- Font & Color
local baseFont = { name = "JetBrainsMonoNL Nerd Font", size = 22 }
local darkRed = { red = 0.7, green = 0, blue = 0, alpha = 1 }
local lightRed = { red = 1, green = 0, blue = 0, alpha = 1 }
local darkYellow = { red = 0.7, green = 0.5, blue = 0, alpha = 1 }
local lightYellow = { red = 1, green = 1, blue = 0, alpha = 1 }
local white = { white = 0.9 }
local black = { white = 0.1 }
local darkGrey = { white = 0.45 }
local lightGrey = { white = 0.55 }

-- console settings
cons.titleVisibility("hidden")
cons.toolbar(nil)
cons.consoleFont(baseFont)
hs.consoleOnTop(false)

--------------------------------------------------------------------------------

---filter console entries, removing logging for enabling/disabling hotkeys,
---useless layout info or warnings, or info on extension loading.
-- HACK to fix https://www.reddit.com/r/hammerspoon/comments/11ao9ui/how_to_suppress_logging_for_hshotkeyenable/
-- selene: allow(high_cyclomatic_complexity)
function CleanupConsole()
	local consoleOutput = tostring(cons.getConsole())
	hs.console.clearConsole()
	local layoutLinesCount = 0
	local isDark = u.isDarkMode()

	local cleanLines = {}
	for line in string.gmatch(consoleOutput, "[^\n]+") do -- split by new lines
		local ignore = line:find("Warning:.*LuaSkin: hs.canvas:delete")
			or line:find("hotkey: .*abled hotkey")
			or line:find("Loading extensions?: ")
			or line:find("Loading Spoon: RoundedCorners")
			or line:find("Lazy extension loading enabled")
			or line:find("%-%- Loading .*/init.lua$")
			or line:find("%-%- Done.$")

		local layoutInfo = line:find("No windows matched, skipping.")
		if not ignore and not layoutInfo and layoutLinesCount == 0 then
			table.insert(cleanLines, line)
		-- skip multiline-log messages from applying a layout without a window open
		elseif layoutLinesCount > 3 then
			layoutLinesCount = 0
		elseif layoutInfo or layoutLinesCount > 0 then
			layoutLinesCount = layoutLinesCount + 1
		end
	end
	for _, line in pairs(cleanLines) do
		-- FIX double-timestamp displayed sometimes
		line = line:gsub("(%d%d:%d%d:%d%d: )%d%d:%d%d:%d%d ?", "%1")

		-- colorize certain messages
		local color
		if line:find("^> ") then -- user input
			color = isDark and lightGrey or darkGrey
		elseif line:lower():find("error") then
			line = line:gsub("%s+", " ")
			color = isDark and lightRed or darkRed
		elseif
			line:lower():find("warning")
			or line:find("WARN")
			or line:find("⚠️️")
			or line:find("stack traceback")
			or line:find("^<.*>$")
			or line:find("%.%.%.")
			or line:find("in upvalue")
			or line:find("in function")
		then
			line = line:gsub("%*%* Warning:%s*", "WARN: ")
			color = isDark and lightYellow or darkYellow
		else
			color = isDark and white or black
		end
		local coloredLine = hs.styledtext.new(line, { color = color, font = baseFont })
		cons.printStyledtext(coloredLine)
	end
end

--------------------------------------------------------------------------------

-- clean up console as soon as it is opened
-- close console as soon as unfocused
Wf_hsConsole = u.wf.new("Hammerspoon")
	:subscribe(u.wf.windowCreated, function(newWin)
		if newWin:title() == "Hammerspoon Console" then
			CleanupConsole()
			local pos = hs.fnutils.copy(wu.centered)
			pos.h = 0.95 -- leave some space at the bottom for tab completions
			newWin:moveToUnit(pos)
		end
	end)
	:subscribe(u.wf.windowUnfocused, function(win)
		if win:title() == "Hammerspoon Console" and not (u.isFront("Alfred")) then hs.closeConsole() end
	end)

--------------------------------------------------------------------------------

function SetConsoleColors()
	if u.isDarkMode() then
		cons.darkMode(true)
		cons.outputBackgroundColor(black)
		cons.consolePrintColor(white)
		cons.consoleCommandColor(lightGrey)
	else
		cons.darkMode(false)
		cons.outputBackgroundColor(white)
		cons.consolePrintColor(black)
		cons.consoleCommandColor(darkGrey)
	end
end

-- initialize
SetConsoleColors()

-- copy last command to clipboard
-- `hammerspoon://copy-last-command` for Karabiner Elements (⌘⇧C)
u.urischeme("copy-last-command", function()
	local consoleHistory = cons.getHistory()
	if not consoleHistory then return end
	local lastcommand = consoleHistory[#consoleHistory]
	lastcommand = u.trim(lastcommand)
	hs.pasteboard.setContents(lastcommand)
	u.notify("Copied: '" .. lastcommand .. "'")
end)

-- `hammerspoon://clear-console` for Karabiner Elements (⌘K)
u.urischeme("clear-console", cons.clearConsole)
