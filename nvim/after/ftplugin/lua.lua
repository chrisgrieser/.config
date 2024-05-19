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
