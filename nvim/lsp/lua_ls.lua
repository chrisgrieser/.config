-- DOCS https://luals.github.io/wiki/settings/
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	settings = {
		Lua = {
			format = {
				enable = false, -- disable formatting in favor of `stylua`
			},
			completion = {
				callSnippet = "Disable", -- signature help more useful
				keywordSnippet = "Replace",
				showWord = "Disable", -- already done by completion plugin
				workspaceWord = false, -- already done by completion plugin
				postfix = ".", -- useful for `table.insert` and the like
			},
			diagnostics = {
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
			codeLens = {
				enable = true, -- requires `vim.lsp.codelens.refresh` autocmd
			},
			hint = { -- inlay hints
				enable = true,
				setType = true,
				arrayIndex = "Disable", -- too noisy
				semicolon = "Disable",
			},
		},
	},
}
