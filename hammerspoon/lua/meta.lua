require("lua.utils")
local cons = hs.console
--------------------------------------------------------------------------------

---filter console entries, removing logging for enabling/disabling hotkeys,
---useless layout info or warnings, or info on extension loading.
-- HACK to fix https://www.reddit.com/r/hammerspoon/comments/11ao9ui/how_to_suppress_logging_for_hshotkeyenable/
function CleanupConsole()
	local consoleOutput = tostring(hs.console.getConsole())
	local out = ""
	local layoutLinesCount = 0

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
			out = out .. line .. "\n"

		-- skip multiline-log messages from applying a layout without a window open
		elseif layoutLinesCount > 3 then
			layoutLinesCount = 0
		elseif layoutInfo or layoutLinesCount > 0 then
			layoutLinesCount = layoutLinesCount + 1
		end
	end

	-- emphasize errors and warnings, remove double time-stamps
	out = out:gsub("%d%d:%d%d:%d%d ERROR: ", "🔴 ERROR") 
	out = out:gsub("%d%d:%d%d:%d%d %*%* Warning: ", "⚠️ WARN") 

	hs.console.setConsole(out)
end

-- `hammerspoon://hs-reload` for reloading via Build System
local reloadIndicator = "/tmp/hs-is-reloading"
UriScheme("hs-reload", function()
	hs.execute("touch " .. reloadIndicator)
	hs.reload()
	-- INFO will also run the systemStart function due to reload
end)

function SystemStart()
	-- do not git sync on reload to prevent commit spam when updating hammerspoon
	-- config regularly
	local _, isReloading = hs.execute("[[ -e " .. reloadIndicator .. " ]]")
	if isReloading then
		print("\n----------------------------- 🔨 HAMMERSPOON RELOAD ---------------------------------\n")
		CleanupConsole()

		os.remove(reloadIndicator)
		-- use neovim automation to display the notification in neovim
		hs.execute([[echo 'vim.notify("✅ Hammerspoon reloaded.")' > /tmp/nvim-automation]])
		return
	else
		Notify("Finished loading.")
		HoleCover()
		PeripheryBatteryCheck("notify")
		QuitFinderIfNoWindow()
		SyncAllGitRepos("notify")
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
