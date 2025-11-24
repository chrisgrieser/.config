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
			markdown = {
				IgnoreLinkTitle = true,
			},
			linters = {
				-- disable buggy rules
				SentenceCapitalization = false, -- https://github.com/Automattic/harper/issues/1056
				UnclosedQuotes = false, -- https://github.com/Automattic/harper/issues/1573
				-- CommaFixes = false, -- https://github.com/Automattic/harper/issues/1097

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
	root_dir = function(bufnr, on_dir)
		if require("config.utils").isObsidianOrNotesOrIcloud(bufnr) then return end
		local rootMarkers = { ".git" }
		on_dir(vim.fs.root(bufnr, rootMarkers))
	end,
	on_attach = function(_client, bufnr)
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
