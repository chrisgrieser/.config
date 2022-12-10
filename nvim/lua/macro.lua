require("utils")
local trace = vim.log.levels.TRACE
local keymap = vim.keymap.set
local fn = vim.fn
local macroRegs, macroKeys
local activeSlot
local M = {}
--------------------------------------------------------------------------------

---setup Autocommands
---@param toggleKey string
local function setupAutocmds(toggleKey)
	augroup("recording", {})
	autocmd("RecordingLeave", {
		group = "recording",
		callback = function()
			local justRecorded = vim.v.event.regcontents
			keymap("n", toggleKey, "q" .. activeSlot)
			vim.notify(" Recorded " .. activeSlot .. ": \n " .. justRecorded .. " ", trace)
		end
	})
	autocmd("RecordingEnter", {
		group = "recording",
		callback = function()
			keymap("n", toggleKey, "q")
			vim.notify(" Recording to " .. activeSlot .. "… ", trace)
		end,
	})
end

--------------------------------------------------------------------------------

---Setup Macro Plugin
---@param config table
function M.setup(config)
	macroRegs = config.slots
	macroKeys = config.keymaps
	setupAutocmds(config.keymaps.toggleRecording)
	M.switchMacroSlot() -- initialize first slot & keymaps
end

---changes the active macroSlot & adapts keymaps for it
function M.switchMacroSlot()
	if not (activeSlot) then -- first run
		activeSlot = macroRegs[1]
	else
		activeSlot = activeSlot == macroRegs[1] and macroRegs[2] or macroRegs[1]
		vim.notify(" Now using [" .. activeSlot .. "] ", trace)
	end
	keymap("n", macroKeys.playRecording, "@" .. activeSlot)
	keymap("n", macroKeys.toggleRecording, "q" .. activeSlot)
end

---edit the current macroSlot
function M.editMacro()
	local macro = fn.getreg(activeSlot)
	local inputConfig = {
		prompt = "Edit Macro " .. activeSlot .. ": ",
		default = macro,
	}
	vim.ui.input(inputConfig, function(editedMacro)
		if not (editedMacro) then return end -- cancellation
		fn.setreg(activeSlot, editedMacro)
		vim.notify(" Edited Macro [" .. activeSlot .. "]\n " .. editedMacro, trace)
	end)
end

--------------------------------------------------------------------------------

---returns Recording-Status for status line plugins, to be used with cmdheight=0
---@return string
function M.recordingStatus()
	if fn.reg_recording() == "" then return "" end
	return " RECORDING [" .. activeSlot .. "]"
end

function M.displayActiveSlot()
	if fn.reg_recording() == "" then return "" end
	return " RECORDING [" .. activeSlot .. "]"
end

--------------------------------------------------------------------------------

return M
