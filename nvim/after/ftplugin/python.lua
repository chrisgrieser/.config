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
vim.defer_fn(function()
	local venv_python = u.getVenvPython()
	if not venv_python then return end
	vim.env.VIRTUAL_ENV = venv_python
	vim.g.python3_host_prog = venv_python
end, 1)

-- add venv-indicator to lualine
if not vim.g.venv_lualine_added then
	vim.g.venv_lualine_added = true -- prevent adding it multiple times
	u.addToLuaLine("tabline", "lualine_a", function()
		-- GUARD python ft, pyright attached, has custom python_path
		if vim.bo.ft ~= "python" then return "" end
		local venv_python = vim.env.VIRTUAL_ENV
		if not venv_python then return "" end
		local venv = vim.fs.basename(vim.fs.dirname(vim.fs.dirname(venv_python)))
		return "󱥒 " .. venv
	end)
end

--------------------------------------------------------------------------------

-- fix habits
u.ftAbbr("true", "True")
u.ftAbbr("false", "False")
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")
u.ftAbbr("null", "None")
u.ftAbbr("nil", "None")
u.ftAbbr("none", "None")
