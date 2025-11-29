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
			hover = {
				expandAlias = false, -- `@alias`
			},
			type = {
				inferParamType = true, -- unannotated params are inferred instead of `any`
				checkTableShape = true,
			},
			diagnostics = {
				neededFileStatus = {
					["await-in-sync"] = "Any",
					["incomplete-signature-doc"] = "Any",
					["missing-global-doc"] = "Any",
					["missing-local-export-doc"] = "Any",
					["not-yieldable"] = "Any",
				},
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
	on_attach = {

	}
}
