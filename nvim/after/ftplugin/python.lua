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

local ftAbbr = require("config.utils").ftAbbr
ftAbbr("true", "True")
ftAbbr("false", "False")
ftAbbr("//", "#")
ftAbbr("--", "#")
ftAbbr("null", "None")
ftAbbr("nil", "None")
ftAbbr("none", "None")
ftAbbr("trim", "strip")
