-- python standard
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4

-- formatters prescribe comments being separated by two spaces
vim.opt_local.listchars:append { multispace = " " }
vim.opt_local.formatoptions:append("r") -- `<CR>` in insert mode

--------------------------------------------------------------------------------
-- VIRTUAL ENVIRONMENT

-- set virtual environment for other plugins to use, if it exists
vim.defer_fn(function()
	local venv = (vim.uv.cwd() or "") .. "/.venv"
	if vim.uv.fs_stat(venv) then vim.env.VIRTUAL_ENV = venv end
end, 1)

--------------------------------------------------------------------------------
-- fix habits
local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end

abbr("true", "True")
abbr("false", "False")
abbr("//", "#")
abbr("--", "#")
abbr("null", "None")
abbr("nil", "None")
abbr("none", "None")
abbr("trim", "strip")
