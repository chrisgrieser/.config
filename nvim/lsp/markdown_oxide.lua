-- DOCS url
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	-- leave out `.git` to not attach to non-note repos due to https://github.com/Feel-ix-343/markdown-oxide/issues/323
	root_markers = { ".obsidian", ".moxide.toml" },
	workspace_required = true,
}
