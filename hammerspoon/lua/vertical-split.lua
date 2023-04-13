local u = require("lua.utils")
local wu = require("lua.window-utils")
local frontApp = hs.application.frontmostApplication
--------------------------------------------------------------------------------

local function splitIsActive()
	return (LEFT_SPLIT and RIGHT_SPLIT) ~= nil
end

---activate both apps together,unsplit if one of the two apps are quit.
---Caveat: using an appwatcher seems much more stable then using window
---filters, but comes at the cost of not being able to handle it well if one of
---the two apps have more than one window
local function pairedActivation()
	PairedActivationWatcher = u.aw
		.new(function(appName, eventType)
			local rightApp = RIGHT_SPLIT:application()
			local leftApp = LEFT_SPLIT:application()
			if not leftApp or not rightApp then
				u.notify("2️⃣ Split stopped as app quit")
				VsplitSetLayout("unsplit")
			elseif eventType == u.aw.activated and appName == rightApp:name() then
				LEFT_SPLIT:raise()
			elseif eventType == u.aw.activated and appName == leftApp:name() then
				RIGHT_SPLIT:raise()
			end
		end)
		:start()
end

local function switchSplit()
	if not (splitIsActive()) then
		u.notify("No split active.")
		return
	end

	wu.moveResize(RIGHT_SPLIT, hs.layout.left50)
	wu.moveResize(LEFT_SPLIT, hs.layout.right50)

	local temp = RIGHT_SPLIT
	RIGHT_SPLIT = LEFT_SPLIT
	LEFT_SPLIT = temp
end

---main split function
---(needs to be global, since pairedActivation and VsplitSetLayout call each other)
---@param mode "unsplit"|"split" split will use the secondWin and the current win
---@param secondWin? hs.window required when using mode "split"
function VsplitSetLayout(mode, secondWin)
	-- define split windows
	if mode == "split" then
		LEFT_SPLIT = hs.window.focusedWindow()
		RIGHT_SPLIT = secondWin
	end

	local f1, f2
	if mode == "split" then
		print("2️⃣ Split started")
		pairedActivation()
		f1 = hs.layout.right50
		f2 = hs.layout.left50
	elseif mode == "unsplit" then
		PairedActivationWatcher:stop()
		f1 = wu.pseudoMax
		f2 = wu.pseudoMax
	end

	if RIGHT_SPLIT then
		wu.moveResize(RIGHT_SPLIT, f1)
		RIGHT_SPLIT:raise()
	end
	if LEFT_SPLIT then
		wu.moveResize(LEFT_SPLIT, f2)
		LEFT_SPLIT:raise()
	end

	if mode == "unsplit" then
		PairedActivationWatcher = nil ---@diagnostic disable-line: assign-type-mismatch
		RIGHT_SPLIT = nil
		LEFT_SPLIT = nil ---@diagnostic disable-line: assign-type-mismatch
	end
end

--------------------------------------------------------------------------------

---helper for hs.chooser
---@nodiscard
---@return table|nil list of apps that are running, formatted for hs.chooser
local function runningApps()
	local appsArr = {}
	for _, win in pairs(hs.window:allWindows()) do
		local app = win:application()
		if not app then return end
		local appName = app:name()
		local isExcludedApp = {
			frontApp():name(),
			"SideNotes",
			"CleanShot X",
			"Hammerspoon",
			"Twitter",
			"Alfred",
			"Espanso",
			"Notification Centre",
		}
		if not u.tbl_contains(isExcludedApp, appName) and app:mainWindow() then
			table.insert(appsArr, { text = appName })
		end
	end
	return appsArr
end

---select a second window to pass to vsplitSetLayout()
local function selectSecondWin()
	local apps = runningApps()
	if #apps == 0 then return end
	hs
		.chooser
		.new(function(selection)
			if not selection then return end
			local app = u.app(selection.text)
			if not app then
				u.notify(selection.text .. " has already closed. Aborting split.")
				return
			end
			local secondWin = app:mainWindow()
			VsplitSetLayout("split", secondWin)
		end)
		:choices(apps)
		:rows(#apps - 2) -- for whatever reason, the rows parameter is off by 3?
		:width(30)
		:placeholderText("Split " .. frontApp():name() .. " with…")
		:show()
end

--------------------------------------------------------------------------------
-- HOTKEYS

u.hotkey(u.hyper, "V", function()
	if splitIsActive() then
		VsplitSetLayout("unsplit")
		u.notify("2️⃣ Split stopped manually.")
	else
		selectSecondWin()
	end
end)

u.hotkey(u.hyper, "X", switchSplit)
