-- standard used by `just --fmt`
vim.schedule(function()
	vim.opt_local.expandtab = true
	vim.opt_local.shiftwidth = 4
end)

--------------------------------------------------------------------------------
local bkeymap = require("config.utils").bufKeymap

bkeymap("n", "<leader>ll", function()
	local out = vim.system({ "just", "--evaluate" }):wait().stdout or "Error"
	vim.notify(vim.trim(out), nil, { title = "just --evaluate", ft = "just", icon = "󱁤" })
end, { desc = "󰖷 just --evaluate" })
