---@type vim.lsp.Config
return {
	init_options = {
		-- use the custom directory set in the treesitter config
		parser_install_directories = {
			require("nvim-treesitter.config").get_install_dir("") .. "/parser",
		},
	},
}
