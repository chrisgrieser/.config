-- DOCS
-- https://writewithharper.com/docs/integrations/neovim
-- https://writewithharper.com/docs/integrations/language-server#Configuration
-- https://writewithharper.com/docs/rules
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = { "markdown" }, -- too many false positives elsewhere
	settings = {
		["harper-ls"] = {
			excludePatterns = { -- PENDING https://github.com/Automattic/harper/issues/2339
				vim.env.HOME .. "/Library/Mobile Documents/**", -- anything in iCloud
				vim.env.HOME .. "/phd-data-analysis/**",
			},

			diagnosticSeverity = "hint",
			userDictPath = vim.o.spellfile, -- share it with vim's spellcheck
			markdown = { IgnoreLinkTitle = true },
			isolateEnglish = true, -- experimental; in mixed-language doc only check English
			dialect = "American",
			linters = {
				UseTitleCase = false, -- I prefer sentence case headings

				-- disable buggy rules
				SentenceCapitalization = false, -- https://github.com/Automattic/harper/issues/1056
				UnclosedQuotes = false, -- https://github.com/Automattic/harper/issues/1573

				-- enable extra rules
				UseGenitive = true,
			},
		},
	},
	on_attach = function(_client, bufnr)
		vim.keymap.set("n", "zg", function()
			vim.lsp.buf.code_action {
				filter = function(a) return a.command == "HarperAddToWSDict" end,
				apply = true,
			}
		end, { desc = "󰓆 Add word to workspace dict", buffer = bufnr })
		vim.keymap.set("n", "zG", function()
			vim.lsp.buf.code_action {
				filter = function(a) return a.command == "HarperAddToUserDict" end,
				apply = true,
			}
		end, { desc = "󰓆 Add word to user dict", buffer = bufnr })
	end,
}
