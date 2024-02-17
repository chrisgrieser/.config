local u = require("config.utils")
--------------------------------------------------------------------------------

-- fix my habits
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")
u.ftAbbr("delay", "sleep")
u.ftAbbr("const", "local")

-- FIX some shell-filetypes override makeprg
vim.opt_local.makeprg = "make --silent --warn-undefined-variables"

-- explain shell command
vim.keymap.set({"n", "x"}, "<localleader>e", function()
	local site = "https://explainshell.com/explain?cmd="
	local text = vim.api.nvim_get_current_line()
	if vim.fn.mode():find("[Vv]") then
		u.normal('"zy')
		text = vim.fn.getreg("z")
	end
	vim.fn.system { "open", site .. text }
end, { desc = " Explain Shell Command", buffer = true })
