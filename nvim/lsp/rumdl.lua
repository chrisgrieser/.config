-- DOCS https://github.com/rvben/rumdl#global-configuration
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	root_markers = { -- https://github.com/rvben/rumdl#configuration-discovery
		"rumdl.toml",
		".rumdl.toml",
		"pyproject.toml",
		".markdownlint.yaml",
		".markdownlint.json",
		".git",
	},
}
