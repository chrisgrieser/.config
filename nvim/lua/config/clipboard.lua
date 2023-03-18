require("config.utils")
local g = vim.g
--------------------------------------------------------------------------------

-- keep the register clean
Keymap("n", "x", '"_x')
Keymap({ "n", "x" }, "c", '"_c')
Keymap("n", "cc", '"_cc')
Keymap("n", "C", '"_C')
Keymap("x", "p", "P", { desc = "paste without switching register" })

-- do not clutter the register if blank line is deleted
Keymap("n", "dd", function()
	local isBlankLine = Fn.getline("."):find("^%s*$") ---@diagnostic disable-line: param-type-mismatch, undefined-field
	local expr = isBlankLine and '"_dd' or "dd"
	return expr
end, { expr = true })

--------------------------------------------------------------------------------
-- Yanky
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "paste (Yanky)" })
vim.keymap.set("n", "P", "<Plug>(YankyCycleForward)", { desc = "Cycle Yankring" })

-- stylua: ignore
vim.keymap.set("n", "<leader>y", require("telescope").extensions.yank_history.yank_history, { desc = "Yank History" })
--------------------------------------------------------------------------------

-- paste charwise reg as linewise & vice versa
Keymap("n", "gp", function()
	local reg = "+"
	local regContent = Fn.getreg(reg)
	local isLinewise = Fn.getregtype(reg) == "V"

	local targetRegType
	if isLinewise then
		targetRegType = "v"
		regContent = regContent:gsub("^%s*", ""):gsub("%s*$", "")
	else
		targetRegType = "V"
	end

	Fn.setreg(reg, regContent, targetRegType) ---@diagnostic disable-line: param-type-mismatch
	Normal('"' .. reg .. "p") -- for whatever reason, not naming a register does not work here
	if targetRegType == "V" then Normal("==") end
end, { desc = "paste differently" })

--------------------------------------------------------------------------------

-- yanking without moving the cursor
Autocmd({ "CursorMoved", "VimEnter" }, {
	callback = function() vim.g.cursorPreYank = GetCursor(0) end,
})

-- - sticky yanking (without moving the cursor)
-- - highlighted yank
Autocmd("TextYankPost", {
	callback = function()
		-- highlighted yank
		vim.highlight.on_yank { timeout = 1500 }

		if Fn.reg_recording() ~= "" or Fn.reg_executing() ~= "" then return end

		-- sticky cursor
		if vim.v.event.operator == "y" then SetCursor(0, g.cursorPreYank) end
	end,
})
