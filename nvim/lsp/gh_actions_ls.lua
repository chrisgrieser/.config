-- DOCS
--------------------------------------------------------------------------------

return {
	cmd = { "gh-actions-language-server", "--stdio" },

	-- `root_dir` ensures that LSP only attaches to GitHub Actions yaml files
	filetypes = { "yaml" },
	root_dir = function(bufnr, on_dir)
		local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
		if
			vim.endswith(parent, "/.github/workflows")
			or vim.endswith(parent, "/.forgejo/workflows")
			or vim.endswith(parent, "/.gitea/workflows")
		then
			on_dir(parent)
		end
	end,

	init_options = {}, -- need to be present https://github.com/neovim/nvim-lspconfig/pull/3713#issuecomment-2857394868
	capabilities = {
		workspace = {
			didChangeWorkspaceFolders = {
				dynamicRegistration = true,
			},
		},
	},
}
