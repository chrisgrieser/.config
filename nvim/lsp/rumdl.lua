-- DOCS https://github.com/rvben/rumdl#configuration
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	root_markers = {
		"rumdl.toml",
		".rumdl.toml",
		"pyproject.toml",
		".markdownlint.yaml",
		".markdownlint.json",
		".git",
	},
}
