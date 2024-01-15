local bo = vim.bo
local u = require("config.utils")
--------------------------------------------------------------------------------

-- python standard
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4

--------------------------------------------------------------------------------
-- VIRTUAL ENVIRONMENT

-- set virtual environment for other plugins to use, if it exists
vim.defer_fn(function()
	local venv = (vim.loop.cwd() or "") .. "/.venv"
	if vim.loop.fs_stat(venv) then vim.env.VIRTUAL_ENV = venv end
end, 1)

--------------------------------------------------------------------------------

-- fix habits
u.ftAbbr("true", "True")
u.ftAbbr("false", "False")
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")
u.ftAbbr("null", "None")
u.ftAbbr("nil", "None")
u.ftAbbr("none", "None")
