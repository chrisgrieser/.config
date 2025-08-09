-- DOCS https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
--------------------------------------------------------------------------------

---@type vim.lsp.Config
local config = {
	init_options = {
		preferences = {
			importModuleSpecifierPreference = "non-relative",
		},
	},
	settings = {
		diagnostics = {
			ignoredCodes = {
				80001, -- "File is a CommonJS module; it may be converted to an ES module."
			},
		},

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
			-- without formatting still relevant for `organizeImports` code-action
			format = { convertTabsToSpaces = false },
		},

		-- enable checking javascript without a `jsconfig.json` https://www.typescriptlang.org/tsconfig
		implicitProjectConfiguration = { checkJs = true, target = "ES2022" },
	},
	on_attach = function(client, bufnr)
		-- disable formatting in favor of `biome`
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false

		local function nmap(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { desc = desc, buffer = bufnr })
		end

		-- quick access to code action
		nmap("<leader>rt", function()
			vim.lsp.buf.code_action {
				filter = function(act) return act.title == "Convert to template string" end,
				apply = true,
			}
		end, " Template string code action")

		-- skip the "Move to file" code action
		nmap("<leader>ca", function()
			vim.lsp.buf.code_action {
				filter = function(act) return act.kind ~= "refactor.move" end,
			}
		end, " Template string code action")

		-- pretty ts error
		nmap(
			"<leader>t",
			function() require("personal-plugins.pretty-ts-error").select() end,
			" Pretty `ts_ls` diagnostic"
		)
	end,
}

config.settings.javascript = config.settings.typescript

--------------------------------------------------------------------------------
return config
