require("utils")
local trace = vim.log.levels.TRACE
local keymap = vim.keymap.set
local fn = vim.fn
local macroRegs, macroKeys

local M = {}
--------------------------------------------------------------------------------

---setup Autocommands
---@param toggleKey string
local function setupAutocmds(toggleKey)
	augroup("recording", {})
	autocmd("RecordingLeave", {
		group = "recording",
		callback = function()
			keymap("n", toggleKey, "q" .. g.activeMacroSlot)
			vim.notify(" Recorded " .. g.activeMacroSlot .. ": \n " .. vim.v.event.regcontents.." ", trace)
		end
	})
	autocmd("RecordingEnter", {
		group = "recording",
		callback = function()
			keymap("n", toggleKey, "q")
			vim.notify(" Recording to " .. g.activeMacroSlot .. "… ", trace)
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
	if not(g.activeMacroSlot) then -- first run
		g.activeMacroSlot = macroRegs[1]
	else
		g.activeMacroSlot = g.activeMacroSlot == macroRegs[1] and macroRegs[2] or macroRegs[1]
		vim.notify(" Now using " .. g.activeMacroSlot .. " ", trace)
	end
	keymap("n", macroKeys.playRecording, "@" .. g.activeMacroSlot)
	keymap("n", macroKeys.toggleRecording, "q" .. g.activeMacroSlot)
end

---edit the current macroSlot
function M.editMacro()
	local macro = fn.getreg(g.activeMacroSlot)
	vim.ui.input({prompt = "Edit Macro " .. g.activeMacroSlot .. ": ", default = macro}, function(editedMacro)
		if not (editedMacro) then return end -- cancellation
		fn.setreg(g.activeMacroSlot, editedMacro)
		vim.notify(" Edited Macro " .. g.activeMacroSlot .. "\n " .. editedMacro, trace)
	end)
end

--------------------------------------------------------------------------------

---returns Recording-Status for status line plugins, to be used with cmdheight=0
---@return string
function M.recordingStatus()
	if fn.reg_recording() == "" then return "" end
	return " RECORDING ["..g.activeMacroSlot.."]"
end

--------------------------------------------------------------------------------

return M
