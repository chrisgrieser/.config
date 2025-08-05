-- DOCS https://luals.github.io/wiki/settings/
--------------------------------------------------------------------------------

return {
	on_attach = function(client)
		-- disable formatting in favor of `stylua`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	settings = {
		Lua = {
			completion = {
				callSnippet = "Disable", -- signature help more useful here
				keywordSnippet = "Replace",
				showWord = "Disable", -- already done by completion plugin
				workspaceWord = false, -- already done by completion plugin
				postfix = ".", -- useful for `table.insert` and the like
				enable = not vim.g.useEmmylua,
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
			hint = { -- inlay hints
				enable = not vim.g.useEmmylua,
				setType = true,
				arrayIndex = "Disable", -- too noisy
				semicolon = "Disable", -- mostly wrong on invalid code
			},
		},
	},
}
