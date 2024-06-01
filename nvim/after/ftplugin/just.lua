-- standard defined by used by `just --fmt`
vim.defer_fn(function()
	vim.opt_local.tabstop = 4
	vim.opt_local.shiftwidth = 4
	vim.opt_local.expandtab = true
end, 1)
