local bo = vim.bo
local u = require("config.utils")
--------------------------------------------------------------------------------

-- python standard
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4

-- python inline comments are separated by two spaces via `black`, so multispace
-- only adds noise when displaying the dots for them
vim.opt_local.listchars:append { multispace = " " }

--------------------------------------------------------------------------------
-- VIRTUAL ENVIRONMENT

-- set virtual environment for other plugins to use
vim.defer_fn(function()
	-- local venv = vim.loop.cwd() .. "/.venv" -- cwd set by projects.nvim
	-- if not vim.loop.fs_stat(venv) then return end
	-- vim.env.VIRTUAL_ENV = venv
	vim.g.python3_host_prog = vim.env.VIRTUAL_ENV .. "/bin/python"
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
