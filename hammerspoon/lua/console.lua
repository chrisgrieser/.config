require("lua.utils")
require("lua.window-utils")
local cons = hs.console
--------------------------------------------------------------------------------

-- Font & Color
local baseFont = { name = "JetBrainsMonoNL Nerd Font", size = 22 }
local red = hs.drawing.color.hammerspoon.osx_red
local yellowLight = { red = 0.6, green = 0.6, blue = 0, alpha = 1 }
local yellowDark = { red = 1, green = 1, blue = 0, alpha = 1 }
local printColorLight = { white = 0.9 }
local printColorDark = { white = 0.1 }

---converts string into hs.styledtext (+ the basefont)
---@param str string
---@param color hs.drawing.color
---@return hs.styledtext|nil
local function colorizeString(str, color)
	local colored = hs.styledtext.new(str, { color = color, font = baseFont })
	if colored then
		return colored
	else
		return nil
	end
end

-- console settings
cons.titleVisibility("hidden")
cons.toolbar(nil)
cons.consoleFont(baseFont)

--------------------------------------------------------------------------------

---filter console entries, removing logging for enabling/disabling hotkeys,
---useless layout info or warnings, or info on extension loading.
-- HACK to fix https://www.reddit.com/r/hammerspoon/comments/11ao9ui/how_to_suppress_logging_for_hshotkeyenable/
function CleanupConsole()
	local consoleOutput = tostring(cons.getConsole())
	hs.console.clearConsole()
	local layoutLinesCount = 0

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
		-- line = line
		-- 	:gsub("%*%*%* ERROR:", "ERROR")
		-- 	:gsub("%d%d:%d%d:%d%d %*%* Warning: ", "WARN")
		if line:find("ERROR") then
			cons.printStyledtext(colorizeString(line, red))
		elseif line:find("Warning") then
			cons.printStyledtext(colorizeString(line, yellowDark))
		else
			cons.printStyledtext(colorizeString(line, printColorLight))
		end
	end
end

-- clean up console as soon as it is opened
Wf_hsConsole = Wf.new("Hammerspoon"):subscribe(Wf.windowCreated, CleanupConsole)

-- close console when unfocused. Using appwatcher, since window filter for
-- window unfocussing is not working reliably
ConsoleWatcher = Aw.new(function(appName, event)
	if
		appName == "Hammerspoon"
		and event == Aw.deactivated
		and FrontAppName() ~= "Alfred" -- Alfred Compatibility Mode
	then
		hs.closeConsole()
	end
end):start()

---@param mode string "dark"|"light""
function SetConsoleColors(mode)
	if mode == "dark" then
		cons.darkMode(true)
		cons.outputBackgroundColor { white = 0.1 }
		cons.consolePrintColor(printColorLight)
		cons.consoleCommandColor { white = 0.6 }
	else
		cons.darkMode(false)
		cons.outputBackgroundColor { white = 0.9 }
		cons.consolePrintColor(printColorDark)
		cons.consoleCommandColor { white = 0.4 }
	end
end

-- initialize
local mode = hs.execute([[defaults read -g AppleInterfaceStyle]]):find("Dark") and "dark" or "light"
SetConsoleColors(mode)

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
