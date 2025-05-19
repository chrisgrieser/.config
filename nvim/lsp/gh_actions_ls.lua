-- PENDING https://github.com/neovim/nvim-lspconfig/pull/3857
--------------------------------------------------------------------------------

return {
	cmd = { "gh-actions-language-server", "--stdio" },
	filetypes = { "yaml" },

	-- `root_dir` ensures that does not attach to all yaml files
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
	workspace_required = false,

	init_options = {}, -- needs to be present https://github.com/neovim/nvim-lspconfig/pull/3713#issuecomment-2857394868

	capabilities = {
		workspace = {
			didChangeWorkspaceFolders = {
				dynamicRegistration = true,
			},
		},
	},
}
