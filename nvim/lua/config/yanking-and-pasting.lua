local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------

-- OPTIONS
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Highlighted Yank",
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

-- STICKY YANK
local cursorPreYank
keymap({ "n", "x" }, "y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y"
end, { desc = "Sticky yank", expr = true })
keymap("n", "Y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y$"
end, { desc = "󰅍 Sticky yank", expr = true, unique = false })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Sticky yank",
	callback = function()
		if vim.v.event.regname == "z" then return end -- used as temp register for keymaps
		if vim.v.event.operator == "y" then vim.api.nvim_win_set_cursor(0, cursorPreYank) end
	end,
})

-- KEEP THE REGISTER CLEAN
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = " Paste w/o switching with register" })
keymap("n", "dd", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return '"_dd' end
	return "dd"
end, { expr = true, desc = "dd" })

-- PASTING
keymap("n", "P", function()
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local reg = vim.fn.getreg("+"):gsub("^ *", "")
	vim.api.nvim_set_current_line(curLine .. " " .. reg)
end, { desc = " Sticky paste at EoL" })

keymap("i", "<D-v>", function()
	local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n") -- remove indentation if multi-line
	vim.fn.setreg("+", reg, "v")
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

-- for compatibility with macOS clipboard managers
keymap("n", "<D-v>", "p", { desc = " Paste" })
