local u = require("config.utils")
local abbr = require("config.utils").bufAbbrev
--------------------------------------------------------------------------------

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
-- ABBREVIATIONS
abbr("true", "True")
abbr("false", "False")
abbr("//", "#")
abbr("--", "#")
abbr("null", "None")
abbr("nil", "None")
abbr("none", "None")
abbr("trim", "strip")

--------------------------------------------------------------------------------

-- open the next regex at https://regex101.com/
u.bufKeymap("n", "g/", function()
	u.normal('"zyi"vi"') -- yank & reselect inside quotes

	local flagInLine = vim.api.nvim_get_current_line():match("re%.([MIDSUA])")
	local data = {
		regex = vim.fn.getreg("z"),
		flags = flagInLine and "g" .. flagInLine:gsub("D", "S"):lower() or "g",
		substitution = "", -- TODO
		delimiter = '"',
		flavor = "python",
		testString = "",
	}

	require("rip-substitute.open-at-regex101").open(data)
end, { desc = " Open in regex101" })
