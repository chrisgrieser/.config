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
-- add venv-indicator to lualine
if not vim.g.venv_lualine_added then
	vim.g.venv_lualine_added = true -- prevent adding it multiple times
	u.addToLuaLine("tabline", "lualine_a", function()
		-- GUARD python ft, pyright attached, has custom python_path
		if vim.bo.ft ~= "python" then return "" end
		local pyright = vim.lsp.get_active_clients({ name = "pyright" })[1]
		if not pyright then return "" end
		local pythonPath = pyright.config.settings.python.pythonPath
		if not pythonPath then return "" end

		local venv = vim.fs.basename(vim.fs.dirname(vim.fs.dirname(pythonPath)))
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
