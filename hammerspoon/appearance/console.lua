local M = {} -- persist from garbage collector

local u = require("meta.utils")
local cons = hs.console
local wf = hs.window.filter
local aw = hs.application.watcher

_G.i = hs.inspect -- `i` for easiert inspect in the console
--------------------------------------------------------------------------------

-- CONFIG
-- CONSOLE APPEARANCE
local baseFont = { name = "JetBrainsMonoNL NF", size = 22 }

local function red(isDark)
	if isDark then return { red = 1, green = 0, blue = 0 } end
	return { red = 0.7, green = 0, blue = 0 }
end
local function yellow(isDark)
	if isDark then return { red = 1, green = 1, blue = 0 } end
	return { red = 0.7, green = 0.5, blue = 0 }
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

--------------------------------------------------------------------------------

-- CONSOLE SETTINGS
cons.titleVisibility("hidden")
cons.toolbar(nil)
cons.consoleFont(baseFont)
hs.consoleOnTop(true) -- buggy?

-- suppress unnecessary log messages
hs.hotkey.setLogLevel(0) ---@diagnostic disable-line: undefined-field https://github.com/Hammerspoon/hammerspoon/issues/3491
hs.application.enableSpotlightForNameSearches(false)

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
			or line:find("Loading .*/init.lua$")
			or line:find("hs%.canvas:delete")
			or line:find("%-%- Done%.$")
			or line:find("wfilter: .* is STILL not registered") -- FIX https://github.com/Hammerspoon/hammerspoon/issues/3462

		-- colorize timestamp & error levels
		if not ignore then
			local timestamp, msg = line:match("(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d: )(.*)")
			if not msg then msg = line end -- msg without timestamp
			msg = msg
				:gsub("^%s-%d%d:%d%d:%d%d:? ", "") -- remove duplicate timestamp
				:gsub("^%s*", "")

			local color
			local lmsg = msg:lower()
			if msg:find("^> ") then -- user input
				color = blue(isDark)
			elseif lmsg:find("error") or lmsg:find("fatal") then
				color = red(isDark)
			elseif lmsg:find("warning") or msg:find("stack traceback") or lmsg:find("abort") then
				color = yellow(isDark)
			else
				color = base(isDark)
			end

			local coloredLine = hs.styledtext.new(msg, { color = color, font = baseFont })
			if timestamp then
				local time = hs.styledtext.new(timestamp, { color = grey(isDark), font = baseFont })
				cons.printStyledtext(time, coloredLine)
			else
				cons.printStyledtext(coloredLine)
			end
		end
	end
end

-- clean up console as soon as it is opened
M.wf_hsConsole = wf.new("Hammerspoon")
	:subscribe(wf.windowFocused, function() u.defer(0.2, cleanupConsole) end)

M.aw_hsConsole = aw.new(function(appName, eventType)
	if eventType == aw.activated and appName == "Hammerspoon" then u.defer(0.2, cleanupConsole) end
end):start()

--------------------------------------------------------------------------------

-- app-hotkeys
u.appHotkey("Hammerspoon", { "cmd" }, "q", hs.closeConsole) -- prevent accidental quitting
u.appHotkey("Hammerspoon", { "cmd" }, "k", hs.console.clearConsole)

--------------------------------------------------------------------------------
-- Insert a separator the logs every day at midnight
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
