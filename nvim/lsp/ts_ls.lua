-- DOCS https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
--------------------------------------------------------------------------------

---@type vim.lsp.Config
local config = {
	init_options = {
		preferences = {
			importModuleSpecifierPreference = "non-relative",
		},
	},
	handlers = {
		["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
			if result.diagnostics == nil then return end

			-- ignore some tsserver diagnostics
			local idx = 1
			while idx <= #result.diagnostics do
				local entry = result.diagnostics[idx]

				local formatter = require("format-ts-errors")[entry.code]
				entry.message = formatter and formatter(entry.message) or entry.message

				-- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
				if entry.code == 80001 then
					-- { message = "File is a CommonJS module; it may be converted to an ES module.", }
					table.remove(result.diagnostics, idx)
				else
					idx = idx + 1
				end
			end

			vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
		end,
	},
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

		-- quick access to code action
		vim.keymap.set("n", "<leader>rt", function()
			vim.lsp.buf.code_action {
				filter = function(act) return act.title == "Convert to template string" end,
				apply = true,
			}
		end, { desc = " Template string code action", buffer = bufnr })

		-- skip the "Move to file" code action
		vim.keymap.set("n", "<leader>ca", function()
			vim.lsp.buf.code_action {
				filter = function(act) return act.kind ~= "refactor.move" end,
			}
		end, { desc = " Code action", buffer = bufnr })
	end,
}

config.settings.javascript = config.settings.typescript

--------------------------------------------------------------------------------
return config
