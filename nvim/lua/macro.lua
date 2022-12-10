require("utils")
local trace = vim.log.levels.TRACE
local warn = vim.log.levels.WARN
local fn = vim.fn

local macroRegs, activeSlot, toggleKey
local M = {}
--------------------------------------------------------------------------------

-- start/stop recording macro into the current slot
local function toggleRecording()
	local isRecording = fn.reg_recording() ~= ""
	if isRecording then
		cmd.normal {"q", bang = true}

		-- NOTE the macro key records itself, so it has to be removed from the
		-- register. As this function has to know the variable length of the
		-- LHS key that triggered it, it has to be passed in via .setup()-function
		fn.setreg(activeSlot, fn.getreg(activeSlot):sub(1, -1 * (#toggleKey + 1)))

		local justRecorded = fn.getreg(activeSlot)
		if justRecorded == "" then
			vim.notify(" Recording aborted. ", warn)
		else
			vim.notify(" Recorded [" .. activeSlot .. "]: \n " .. justRecorded .. " ", trace)
		end
	else
		cmd.normal {"q" .. activeSlot, bang = true}
		vim.notify(" Recording to [" .. activeSlot .. "]… ", trace)
	end
end

---Setup Macro Plugin
---@param config table
function M.setup(config)
	macroRegs = config.slots
	activeSlot = macroRegs[1]

	toggleKey = config.toggleKey
	keymap("n", toggleKey, toggleRecording)
end

---play the macro recorded in current slot
function M.playRecording()
	cmd.normal {"@" .. activeSlot, bang = true}
end

--------------------------------------------------------------------------------

---changes the active slot
function M.switchMacroSlot()
	activeSlot = activeSlot == macroRegs[1] and macroRegs[2] or macroRegs[1]
	local currentMacro = fn.getreg(activeSlot)
	local msg = " Now using macro slot [" .. activeSlot .. "]. "
	if currentMacro ~= "" then msg = msg + " Currently recorded macro: \n " .. currentMacro end
	vim.notify(msg, trace)
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

---returns recording status for status line plugins (e.g., used with cmdheight=0)
---@return string
function M.recordingStatus()
	if fn.reg_recording() == "" then return "" end
	return " 雷REC [" .. activeSlot .. "]"
end

---returns active slot for status line plugins
---@return string
function M.displayActiveSlot()
	return "  RECORDING [" .. activeSlot .. "]"
end

--------------------------------------------------------------------------------

return M
