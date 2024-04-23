local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")

local cons = hs.console
local wf = hs.window.filter
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- CONFIG
-- CONSOLE APPEARANCE
local baseFont = { name = env.codeFont, size = 22 }

local function red(isDark)
	if isDark then return { red = 0.7, green = 0, blue = 0 } end
	return { red = 1, green = 0, blue = 0 }
end
local function yellow(isDark)
	if isDark then return { red = 0.7, green = 0.5, blue = 0 } end
	return { red = 1, green = 1, blue = 0 }
end
local function base(isDark)
	if isDark then return { white = 0.9 } end
	return { white = 0.1 }
end
local function grey(isDark)
	if isDark then return { white = 0.45 } end
	return { white = 0.55 }
end
local function blue(isDark)
	if isDark then return { red = 0, green = 0.7, blue = 1 } end
	return { red = 0, green = 0.1, blue = 0.5 }
end
-- CONSOLE SETTINGS
cons.titleVisibility("hidden")
cons.toolbar(nil)
cons.consoleFont(baseFont)
hs.consoleOnTop(false)

-- quicker console usage
I = hs.inspect

--------------------------------------------------------------------------------

---filter console entries, removing logging for enabling/disabling hotkeys,
---useless layout info or warnings, or info on extension loading.
-- HACK to fix https://www.reddit.com/r/hammerspoon/comments/11ao9ui/how_to_suppress_logging_for_hshotkeyenable/
local function cleanupConsole()
	local consoleOutput = tostring(cons.getConsole())
	cons.clearConsole()
	local lines = hs.fnutils.split(consoleOutput, "\n+")
	if not lines then return end

	local isDark = u.isDarkMode()

	for _, line in ipairs(lines) do
		-- remove some lines
		local ignore = line:find("Loading extensions?: ")
			or line:find("Lazy extension loading enabled$")
			or line:find("Loading Spoon: RoundedCorners$")
			or line:find("Loading /Users/chrisgrieser/.config//?hammerspoon/init.lua$")
			or line:find("hs%.canvas:delete")
			or line:find("%-%- Done%.$")
			or line:find("wfilter: .* is STILL not registered") -- FIX https://github.com/Hammerspoon/hammerspoon/issues/3462

		if not ignore then
			-- colorize
			local timestamp, msg = line:match("(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d: )(.*)")
			if not msg then msg = line end
			local lmsg = msg:lower()

			local color
			if lmsg:find("^> ") then -- user input
				color = blue(isDark)
			elseif lmsg:find("error") or lmsg:find("fatal") then
				color = red(isDark)
			elseif lmsg:find("warning") or msg:find("stack traceback") or lmsg:find("abort") then
				color = yellow(isDark)
			else
				color = base(isDark)
			end

			if timestamp then
				msg = msg:gsub("^%s*", "")
				local coloredLine = hs.styledtext.new(msg, { color = color, font = baseFont })
				local time = hs.styledtext.new(timestamp, { color = grey(isDark), font = baseFont })
				cons.printStyledtext(time, coloredLine)
			else
				local coloredLine = hs.styledtext.new(msg, { color = color, font = baseFont })
				cons.printStyledtext(coloredLine)
			end
		end
	end
end

-- clean up console as soon as it is opened
M.wf_hsConsole = wf.new("Hammerspoon")
	:subscribe(wf.windowFocused, function() u.runWithDelays(0.2, cleanupConsole) end)

M.aw_hsConsole = aw.new(function(appName, eventType)
	if eventType == aw.activated and appName == "Hammerspoon" then
		u.runWithDelays(0.2, cleanupConsole)
	end
end):start()

--------------------------------------------------------------------------------

-- app-hotkeys
u.appHotkey("Hammerspoon", "cmd", "q", hs.closeConsole) -- prevent accidental quitting
u.appHotkey("Hammerspoon", "cmd", "k", hs.console.clearConsole)
u.appHotkey("Hammerspoon", { "cmd", "shift" }, "c", function()
	local consoleHistory = cons.getHistory()
	if not consoleHistory then return end
	local lastcommand = consoleHistory[#consoleHistory]
	hs.pasteboard.setContents(lastcommand)
	u.notify(('Copied: "%s"'):format(lastcommand))
end)

--------------------------------------------------------------------------------
-- Separator the logs every day at midnight
M.timer_dailyConsoleSeparator = hs.timer
	.doAt("00:00", "01d", function()
		local date = os.date("%a, %d. %b")
		-- stylua: ignore
		print(("\n----------------------------- %s ---------------------------------\n"):format(date))
	end, true)
	:start()

--------------------------------------------------------------------------------

---@param toMode "dark"|"light"
function M.setConsoleColors(toMode)
	local isDark = toMode == "dark"
	cons.outputBackgroundColor(base(not isDark))
	cons.consolePrintColor(base(isDark))
	cons.consoleCommandColor(blue(isDark))
	cons.darkMode(isDark)
end

-- initialize
M.setConsoleColors(u.isDarkMode() and "dark" or "light")

--------------------------------------------------------------------------------
return M
