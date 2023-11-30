local u = require("config.utils")
--------------------------------------------------------------------------------

-- fix my habits
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")

-- some shell-filetypes override makeprg
vim.opt_local.makeprg = "make --silent --warn-undefined-variables"

vim.keymap.set("n", "<localleader>e", function()
	local line = vim.trim(vim.api.nvim_get_current_line())
	local site = "https://explainshell.com/explain?cmd="
	vim.fn.system { "open", site .. line }
end, { desc = "Explain Shell Command" })
