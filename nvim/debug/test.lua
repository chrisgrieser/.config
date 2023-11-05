-- https://neovim.io/doc/user/lsp.html#vim.lsp.start()
vim.lsp.start {
	name = "ast-grep",
	cmd = { "ast-grep", "lsp" },
	root_dir = vim.fs.dirname(vim.fs.find({ "sgconfig.yml" }, { upward = true })[1]),
}
