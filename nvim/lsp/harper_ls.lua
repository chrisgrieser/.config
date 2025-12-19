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
				vim.env.HOME .. "/writing-vault/**", -- reports pandoc citations as spelling errors, etc.
				vim.g.notesDir .. "/**", -- too much German
			},

			diagnosticSeverity = "hint",
			userDictPath = vim.o.spellfile, -- share it with vim's spellcheck
			markdown = { IgnoreLinkTitle = true },
			isolateEnglish = true, -- experimental; in mixed-language doc only check English
			dialect = "American",
			linters = {
				UseTitleCase = false, -- prefer sentence case headings
				SentenceCapitalization = false, -- buggy: https://github.com/Automattic/harper/issues/1056
				UnclosedQuotes = false, -- buggy: https://github.com/Automattic/harper/issues/1573
			},
		},
	},
	on_attach = function(_client, bufnr)
		vim.keymap.set("n", "zg", function()
			vim.lsp.buf.code_action {
				filter = function(a)
					return a.command == "HarperAddToWSDict" or a.command == "HarperAddToUserDict"
				end,
				apply = true,
			}
		end, { desc = "󰓆 Add word to spellfile", buffer = bufnr })
	end,
}
