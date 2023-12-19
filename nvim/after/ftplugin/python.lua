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

-- cmd+d: Docstring
-- simplified version of neogen.nvim
vim.keymap.set("n", "<D-d>", function()
	vim.cmd.TSTextobjectGotoPreviousStart("@function.outer")
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local indent = vim.api.nvim_get_current_line():match("^%s*") .. (" "):rep(4)
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. ('"'):rep(6) })
	vim.api.nvim_win_set_cursor(0, { ln + 1, #indent + 3 })
	vim.cmd.startinsert()
end, { desc = " Function Docstring", buffer = true })

--------------------------------------------------------------------------------
-- VIRTUAL ENVIRONMENT

-- set virtual environment for other plugins to use
vim.defer_fn(function()
	local venv = vim.loop.cwd() .. "/.venv" -- cwd set by projects.nvim
	if not vim.loop.fs_stat(venv) then return end
	vim.env.VIRTUAL_ENV = venv
	if not vim.env.VIRTUAL_ENV then return end
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
