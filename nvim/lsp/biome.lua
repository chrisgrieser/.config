---@type vim.lsp.Config
return {
	-- Do not require a `package.json` like in nvim-lspconfig default.
	root_markers = { "biome.json", "biome.jsonc" },
	root_dir = false, ---@diagnostic disable-line: assign-type-mismatch

	workspace_required = false, -- to use biome's json formatter outside js_projects
}
