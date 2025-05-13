-- DOCS
--------------------------------------------------------------------------------

return {
	cmd = { "gh-actions-language-server", "--stdio" },

	-- `root_dir` ensures that LSP only attaches to GitHub Actions yaml files
	filetypes = { "yaml" },
	root_dir = function (bufnr, on_dir)
		local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
		if not vim.endswith(parent, "/.github/workflows") then return end
		on_dir(parent)
	end,

	init_options = { sessionToken = "" }, -- FIX https://github.com/neovim/nvim-lspconfig/pull/3713#issuecomment-2799955353
	capabilities = {
		workspace = {
			didChangeWorkspaceFolders = {
				dynamicRegistration = true,
			},
		},
	},
}
