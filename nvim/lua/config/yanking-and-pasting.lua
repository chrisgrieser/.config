local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------

-- OPTIONS
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Highlighted Yank",
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

--------------------------------------------------------------------------------
-- STICKY YANK

do
	local cursorBefore
	keymap({ "n", "x" }, "y", function()
		cursorBefore = vim.api.nvim_win_get_cursor(0)
		return "y"
	end, { expr = true })
	keymap("n", "Y", function()
		cursorBefore = vim.api.nvim_win_get_cursor(0)
		return "y$"
	end, { expr = true, unique = false }) -- `unique`, since it's a nvim-builtin

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Sticky yank/delete",
		callback = function()
			if vim.v.event.regname ~= "" or not cursorBefore then return end

			if vim.v.event.operator == "y" then vim.api.nvim_win_set_cursor(0, cursorBefore) end
		end,
	})
end

--------------------------------------------------------------------------------
-- KEEP THE REGISTER CLEAN

keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P")
keymap("n", "dd", function()
	local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
	return (lineEmpty and '"_dd' or "dd")
end, { expr = true })

-- PASTING
keymap("n", "P", function()
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local reg = vim.trim(vim.fn.getreg("+"))
	vim.api.nvim_set_current_line(curLine .. " " .. reg)
end, { desc = " Sticky paste at EoL" })

keymap("i", "<D-v>", function()
	local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n") -- remove indentation if multi-line
	vim.fn.setreg("+", reg, "v")
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

-- for compatibility with macOS clipboard managers
keymap("n", "<D-v>", "p", { desc = " Paste" })
