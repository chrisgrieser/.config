-- standard used by `just --fmt`
vim.defer_fn(function() vim.opt_local.expandtab = true end, 1)

--------------------------------------------------------------------------------

require("config.utils").bufKeymap("n", "<leader>ll", function()
	local out = vim.system({ "just", "--evaluate" }):wait().stdout or "Error"
	vim.notify(vim.trim(out), nil, { title = "just --evaluate", ft = "just", icon = "󱁤" })
end, { desc = "󰖷 just --evaluate" })
