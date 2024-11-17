-- standard used by `just --fmt`
vim.defer_fn(function()
	vim.opt_local.tabstop = 4
	vim.opt_local.shiftwidth = 4
	vim.opt_local.expandtab = true
end, 1)

vim.bo.commentstring = "# %s"

--------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>ll", function()
	local out = vim.system({ "just", "--evaluate" }):wait().stdout or "Error"
	vim.notify(vim.trim(out), nil, { title = "just --evaluate", ft = "just", icon = "󱁤" })
end, { desc = "󰖷 just --evaluate", buffer = true })
