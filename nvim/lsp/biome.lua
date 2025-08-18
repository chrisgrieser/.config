---@type vim.lsp.Config
return {
	-- Do not require a `package.json` like in nvim-lspconfig default.
	-- (needs `root_dir`, since lspconfig default uses it and it overrides `root_markers`)
	root_dir = function(bufnr, on_dir)
		local root_markers = {
			"biome.json",
			"biome.jsonc",
		}

		local projectRoot = vim.fs.root(bufnr, root_markers)
		if projectRoot then on_dir(projectRoot) end
	end,
	workspace_required = false, -- to use biome's json formatter outside js_projects
}
