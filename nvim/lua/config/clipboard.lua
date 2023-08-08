local autocmd = vim.api.nvim_create_autocmd
local fn = vim.fn
local g = vim.g
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------

--- macOS bindings (needed for compatibility with automation apps)
keymap({"n", "x"}, "<D-c>", "y", { desc = "copy" }) 
keymap({ "n", "x" }, "<D-v>", "p", { desc = "paste" }) 
keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })

--------------------------------------------------------------------------------

-- keep the register clean
keymap("n", "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = "Paste without switching register" })

-- do not clutter the register if blank line is deleted
keymap("n", "dd", function()
	local isBlankLine = fn.getline("."):find("^%s*$") ---@diagnostic disable-line: param-type-mismatch, undefined-field
	local expr = isBlankLine and '"_dd' or "dd"
	return expr
end, { expr = true })

--------------------------------------------------------------------------------

-- paste charwise reg as linewise & vice versa
keymap("n", "gp", function()
	local regContent = fn.getreg("+")
	local isLinewise = fn.getregtype("+") == "V"

	local targetRegType = "V"
	if isLinewise then
		targetRegType = "v"
		regContent = regContent:gsub("^%s*", ""):gsub("%s*$", "")
	end

	fn.setreg("+", regContent, targetRegType) ---@diagnostic disable-line: param-type-mismatch
	u.normal('"+p')
end, { desc = " Paste differently" })

-- always paste characterwise when in insert mode
keymap("i", "<D-v>", function ()
	local regContent = fn.getreg("+"):gsub("^%s*", ""):gsub("%s*$", "")
	fn.setreg("+", regContent, "v") ---@diagnostic disable-line: param-type-mismatch
	-- "<C-g>u" adds undopoint before the paste
	return "<C-g>u<C-r><C-o>+"
end, { desc = " Paste charwise", expr = true }) 


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
