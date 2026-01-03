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
			isolateEnglish = false, -- https://github.com/Automattic/harper/issues/2383#issuecomment-3706591759
			dialect = "American",
			linters = {
				UseTitleCase = false, -- prefer sentence case headings
				UnclosedQuotes = true, -- PENDING https://github.com/Automattic/harper/issues/1573
			},
		},
	},
	on_attach = function(_client, bufnr)
		local function addToDict(which)
			vim.lsp.buf.code_action {
				filter = function(a) return a.command == ("HarperAddTo%sDict"):format(which) end,
				apply = true,
			}
			vim.notify(("Added to %s dict."):format(which))
		end
		-- stylua: ignore
		vim.keymap.set("n", "zg", function() addToDict("WS") end, { desc = "󰓆 Workspace dict", buffer = bufnr })
		-- stylua: ignore
		vim.keymap.set("n", "zG", function() addToDict("User") end, { desc = "󰓆 User dict", buffer = bufnr })
	end,
}
