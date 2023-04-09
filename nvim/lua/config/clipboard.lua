local g = vim.g
local keymap = vim.keymap.set
local fn = vim.fn
--------------------------------------------------------------------------------

-- keep the register clean
keymap("n", "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "cc", '"_cc')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = "Paste without switching register" })

-- do not clutter the register if blank line is deleted
keymap("n", "dd", function()
	local isBlankLine = fn.getline("."):find("^%s*$") ---@diagnostic disable-line: param-type-mismatch, undefined-field
	local expr = isBlankLine and '"_dd' or "dd"
	return expr
end, { expr = true })

--------------------------------------------------------------------------------
-- Yanky
vim.keymap.set("n", "p", "<Plug>(YankyPutAfter)", { desc = "Paste (Yanky)" })
vim.keymap.set("n", "P", "<Plug>(YankyCycleForward)", { desc = "Cycle Yankring" })
vim.keymap.set(
	"n",
	"<leader>y",
	function() require("telescope").extensions.yank_history.yank_history() end,
	{ desc = "Yank History" }
)
--------------------------------------------------------------------------------

-- paste charwise reg as linewise & vice versa
keymap("n", "gp", function()
	local reg = "+"
	local regContent = fn.getreg(reg)
	local isLinewise = fn.getregtype(reg) == "V"

	local targetRegType
	if isLinewise then
		targetRegType = "v"
		regContent = regContent:gsub("^%s*", ""):gsub("%s*$", "")
	else
		targetRegType = "V"
	end

	fn.setreg(reg, regContent, targetRegType) ---@diagnostic disable-line: param-type-mismatch
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

		if fn.reg_recording() ~= "" or fn.reg_executing() ~= "" then return end

		-- sticky cursor
		if vim.v.event.operator == "y" then SetCursor(0, g.cursorPreYank) end
	end,
})
