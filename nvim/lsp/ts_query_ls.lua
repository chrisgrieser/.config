---@type vim.lsp.Config
return {
	-- FIX for https://github.com/ribru17/ts_query_ls/issues/233
	settings = {
		parser_install_directories = { require("nvim-treesitter.config").get_install_dir("") .. "/parser" },
	},
}
