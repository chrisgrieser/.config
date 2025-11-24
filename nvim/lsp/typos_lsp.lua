-- DOCS https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	init_options = {
		diagnosticSeverity = "Hint",
		config = vim.fn.stdpath("config") .. "/lsp/typos_lsp_global_config.toml",
	},
	root_dir = function(bufnr, on_dir)
		if require("config.utils").isObsidianOrNotesOrIcloud(bufnr) then return end
		local rootMarkers = { "typos.toml", "_typos.toml", ".typos.toml" }
		on_dir(vim.fs.root(bufnr, rootMarkers))
	end,
}
