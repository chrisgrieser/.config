-- DOCS https://luals.github.io/wiki/settings/
--------------------------------------------------------------------------------

local emmyluaInUse = false -- CONFIG

return {
	settings = {
		Lua = {
			completion = {
				enable = not emmyluaInUse,
				callSnippet = "Disable", -- signature help more useful here
				keywordSnippet = "Replace",
				showWord = "Disable", -- already done by completion plugin
				workspaceWord = false, -- already done by completion plugin
				postfix = ".", -- useful for `table.insert` and the like
			},
			diagnostics = {
				disable = {
					-- formatter already handles that
					"trailing-space",
					-- don't dim content of unused functions
					-- (no loss of diagnostic, `unused-local` still informs about these functions)
					"unused-function",
				},
			},
			hint = { -- inlay hints
				enable = not emmyluaInUse,
				setType = true,
				arrayIndex = "Disable", -- too noisy
				semicolon = "Disable", -- mostly wrong on invalid code
			},
			format = {
				enable = false, -- using `stylua` instead
			},
			-- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
			-- workspace = { checkThirdParty = "Disable" },
		},
	},
	on_attach = function(client)
		if emmyluaInUse then -- disable redundant LSP functionalities
			client.server_capabilities.renameProvider = false
			client.server_capabilities.referencesProvider = false
		end
	end,
}
