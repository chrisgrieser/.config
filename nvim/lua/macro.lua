require("utils")
local trace = vim.log.levels.TRACE
local fn = vim.fn
local macroRegs
local activeSlot
local M = {}
--------------------------------------------------------------------------------

-- start/stop recording macro into the current slot
function M.toggleRecording()
	local isRecording = fn.reg_recording() ~= ""
	if isRecording then
		cmd.normal{"q", bang = true}
		print(vim.v.event)
		fn.setreg(activeSlot, fn.getreg(activeSlot):sub(1, -2)) -- remove last character
		local justRecorded = fn.getreg(activeSlot)
		vim.notify(" Recorded [" .. activeSlot .. "]: \n " .. justRecorded .. " ", trace)
	else
		cmd.normal {"q" .. activeSlot, bang = true}
		vim.notify(" Recording to [" .. activeSlot .. "]… ", trace)
	end
end

---play the macro recorded in current slot
function M.playRecording()
	cmd.normal{"@"..activeSlot, bang = true}
end

---changes the active slot
function M.switchMacroSlot()
	if not (activeSlot) then -- first run
		activeSlot = macroRegs[1]
	else
		activeSlot = activeSlot == macroRegs[1] and macroRegs[2] or macroRegs[1]
		vim.notify(" Now using macro slot [" .. activeSlot .. "] ", trace)
	end
end

---edit the current slot
function M.editMacro()
	local macro = fn.getreg(activeSlot)
	local inputConfig = {
		prompt = "Edit Macro [" .. activeSlot .. "]: ",
		default = macro,
	}
	vim.ui.input(inputConfig, function(editedMacro)
		if not (editedMacro) then return end -- cancellation
		fn.setreg(activeSlot, editedMacro)
		vim.notify(" Edited Macro [" .. activeSlot .. "]\n " .. editedMacro, trace)
	end)
end

--------------------------------------------------------------------------------

---Setup Macro Plugin
---@param config table
function M.setup(config)
	macroRegs = config.slots
	M.switchMacroSlot() -- initialize first slot & keymaps
end

--------------------------------------------------------------------------------

---returns recording status for status line plugins (e.g., used with cmdheight=0)
---@return string
function M.recordingStatus()
	if fn.reg_recording() == "" then return "" end
	return " RECORDING [" .. activeSlot .. "]"
end

---returns active slot for status line plugins
---@return string
function M.displayActiveSlot()
	if fn.reg_recording() == "" then return "" end
	return " RECORDING [" .. activeSlot .. "]"
end

--------------------------------------------------------------------------------

return M
