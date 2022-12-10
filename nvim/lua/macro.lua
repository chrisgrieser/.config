require("utils")
local trace = vim.log.levels.TRACE
local keymap = vim.keymap.set
local fn = vim.fn
local macroRegs, keys
local activeSlot
local M = {}
--------------------------------------------------------------------------------

local function stopRecording()
	cmd.normal ("q")
	local justRecorded = vim.v.event.regcontents
	keymap("n", keys.toggleRecording, startRecording)
	vim.notify(" Recorded [" .. activeSlot .. "]: \n " .. justRecorded .. " ", trace)
end

function startRecording()
	cmd.normal {"q" .. activeSlot, bang = true}
	keymap("n", keys.toggleRecording, stopRecording)
	vim.notify(" Recording to [" .. activeSlot .. "]… ", trace)
end

---changes the active macroSlot & adapts keymaps for it
local function switchMacroSlot()
	if not (activeSlot) then -- first run
		activeSlot = macroRegs[1]
	else
		activeSlot = activeSlot == macroRegs[1] and macroRegs[2] or macroRegs[1]
		vim.notify(" Now using macro slot [" .. activeSlot .. "] ", trace)
	end
	keymap("n", keys.playRecording, "@" .. activeSlot)
	keymap("n", keys.toggleRecording, startRecording)
end

---edit the current macroSlot
local function editMacro()
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
	keys = config.keymaps
	switchMacroSlot() -- initialize first slot & keymaps
	keymap("n", "<C-0>", switchMacroSlot)
	keymap("n", "c0", editMacro)

end

--------------------------------------------------------------------------------

---returns Recording-Status for status line plugins (e.g., used with cmdheight=0)
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
