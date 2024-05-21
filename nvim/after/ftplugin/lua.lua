-- habits from writing too much in other languages
local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end

abbr("//", "--")
abbr("const", "local")
abbr("fi", "end")
abbr("!=", "~=")
abbr("!==", "~=")
abbr("===", "==")

--------------------------------------------------------------------------------

-- Put to EoL in cmdline
vim.keymap.set("n", "<leader>r", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local toEol = vim.trim(line:sub(col + 1))
	return ":lua = " .. toEol
end, { buffer = true, expr = true, desc = " Put to EoL in cmdline" })

vim.keymap.set("x", "<leader>r", function()
	require("config.utils").leaveVisualMode()
	local pos = vim.region(0, "'<", "'>", "v", true)
	local row = vim.tbl_keys(pos)[1]
	local start, stop = unpack(vim.tbl_values(pos)[1])
	local sel = vim.api.nvim_buf_get_text(0, row, start, row, stop, {})[1]
	return ":lua = " .. sel
end, { buffer = true, expr = true, desc = " Put Selection in cmdline" })
