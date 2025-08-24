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
			diagnosticSeverity = "hint",
			userDictPath = vim.o.spellfile,
			markdown = { IgnoreLinkTitle = true },
			linters = {
				-- disable buggy rules
				SentenceCapitalization = false, -- https://github.com/Automattic/harper/issues/1056
				CommaFixes = false, -- https://github.com/Automattic/harper/issues/1097

				-- enable extra rules?
				UseGenitive = true,
				BoringWords = false,
				LinkingVerbs = false,
				SpelledNumbers = false,
			},
			isolateEnglish = true, -- experimental; in mixed-language doc only check English
			dialect = "American",
		},
	},
	on_attach = function(harper, bufnr)
		require("config.utils").detachIfObsidianOrIcloud(harper, bufnr)

		-- Using `harper` to write to the spell-file effectively does the same as
		-- the builtin `zg`, but has the advantage that `harper` is hot-reloaded.
		vim.keymap.set("n", "zg", function()
			vim.lsp.buf.code_action {
				filter = function(a) return a.title:find("^Add .* to the user dictionary%.") ~= nil end,
				apply = true,
			}
		end, { desc = "󰓆 Add word to spellfile", buffer = bufnr })
	end,
}
