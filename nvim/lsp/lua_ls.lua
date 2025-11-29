-- DOCS https://luals.github.io/wiki/settings/
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	settings = {
		Lua = {
			format = {
				enable = false, -- disable in favor of `stylua`
			},
			completion = {
				callSnippet = "Disable", -- signature-help more useful
				keywordSnippet = "Replace",
				showWord = "Disable", -- already done by completion plugin
				workspaceWord = false, -- already done by completion plugin
				postfix = ".", -- useful for `table.insert` and the like
			},
			type = {
				inferParamType = true, -- unannotated params are inferred instead of `any`
			},
			diagnostics = {
				groupFileStatus = { ["luadoc"] = "Any" }, -- require stricter annotations
				unusedLocalExclude = { "_*" },
				disable = {
					-- formatter already handles that
					"trailing-space",
					-- don't dim content of unused functions
					-- (no loss of diagnostic, `unused-local` still informs about these functions)
					"unused-function",
				},
				globals = { "vim" }, -- when working on nvim plugins that lack a `.luarc.json`
			},
			codeLens = { -- reference count, `vim.lsp.codelens.refresh`
				enable = true,
			},
			hint = { -- inlay hints, requires `vim.lsp.inlay_hint.enable`
				enable = true,
				setType = true,
				arrayIndex = "Disable", -- too noisy
				semicolon = "Disable",
			},
		},
	},
}
