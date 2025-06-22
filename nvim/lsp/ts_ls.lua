-- DOCS https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
--------------------------------------------------------------------------------

local config = {
	settings = {
		-- "Cannot re-declare block-scoped variable" -> not useful for single-file-JXA
		-- (biome works only on single-file and so already checks for unintended re-declarations.)
		diagnostics = { ignoredCodes = { 2451 } },

		typescript = {
			inlayHints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
			},
			-- even with formatting disabled still relevant for `organizeImports` code-action
			format = { convertTabsToSpaces = false },
		},

		-- enable checking javascript without a `jsconfig.json` https://www.typescriptlang.org/tsconfig
		implicitProjectConfiguration = { checkJs = true, target = "ES2022" },
	},
	on_attach = function(client)
		-- disable formatting in favor of `biome`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}

config.settings.javascript = config.settings.typescript

--------------------------------------------------------------------------------
return config
