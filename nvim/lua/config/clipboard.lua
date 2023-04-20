local autocmd = vim.api.nvim_create_autocmd
local fn = vim.fn
local g = vim.g
local keymap = vim.keymap.set
local u = require("config.utils")

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
keymap("n", "p", "<Plug>(YankyPutAfter)", { desc = "Paste (Yanky)" })
keymap("n", "P", "<Plug>(YankyCycleForward)", { desc = "Cycle Yankring" })
keymap(
	"n",
	"<leader>y",
	function() require("telescope").extensions.yank_history.yank_history() end,
	{ desc = "Yank History" }
)
--------------------------------------------------------------------------------

-- paste charwise reg as linewise & vice versa
keymap("n", "zp", function()
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
	u.normal('"' .. reg .. "p") -- for whatever reason, not naming a register does not work here
	if targetRegType == "V" then u.normal("==") end
end, { desc = "paste differently" })

--------------------------------------------------------------------------------

-- yanking without moving the cursor
autocmd({ "CursorMoved", "VimEnter" }, {
	callback = function() vim.g.cursorPreYank = u.getCursor(0) end,
})

-- - sticky yanking (without moving the cursor)
-- - highlighted yank
autocmd("TextYankPost", {
	callback = function()
		-- highlighted yank
		vim.highlight.on_yank { timeout = 1500 }

		if fn.reg_recording() ~= "" or fn.reg_executing() ~= "" then return end

		-- sticky cursor
		if vim.v.event.operator == "y" then u.setCursor(0, g.cursorPreYank) end
	end,
})
