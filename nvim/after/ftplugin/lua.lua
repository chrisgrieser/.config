-- habits from writing too much in other languages
local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end

abbr("//", "--")
abbr("const", "local")
abbr("fi", "end")
abbr("!=", "~=")
abbr("!==", "~=")
abbr("===", "==")

--------------------------------------------------------------------------------

-- Run current line
vim.keymap.set("n", "R", function()
	local line = vim.trim(vim.api.nvim_get_current_line())
	return ":lua = " .. line
end, { buffer = true, expr = true, desc = " Run Current Line" })
