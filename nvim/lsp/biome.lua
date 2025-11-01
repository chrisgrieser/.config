---@type vim.lsp.Config
return {
	root_markers = {
		-- Do not require a `package.json` like in nvim-lspconfig default.
		"jsconfig.json",
		"tsconfig.json",
		"biome.json",
		"biome.jsonc",
		".obsidian/snippets/*.css",
	},
	root_dir = false, ---@diagnostic disable-line: assign-type-mismatch
}
