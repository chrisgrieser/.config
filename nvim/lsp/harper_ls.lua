-- DOCS
-- https://writewithharper.com/docs/integrations/neovim
-- https://writewithharper.com/docs/integrations/language-server#Configuration
-- https://writewithharper.com/docs/rules
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = { "markdown" }, -- too many false positives elsewhere
	root_dir = function(bufnr, on_dir)
		-- do not load in specific repos (there is no `harperignore` to do this)
		if require("config.utils").isObsidianOrNotesOrIcloud(bufnr) then return end
		local rootMarkers = { ".git" }
		on_dir(vim.fs.root(bufnr, rootMarkers))
	end,
	settings = {
		["harper-ls"] = {
			diagnosticSeverity = "hint",
			userDictPath = vim.o.spellfile,
			markdown = {
				IgnoreLinkTitle = true,
			},
			linters = {
				UseTitleCase = false, -- I prefer sentence case headings

				-- disable buggy rules
				SentenceCapitalization = false, -- https://github.com/Automattic/harper/issues/1056
				UnclosedQuotes = false, -- https://github.com/Automattic/harper/issues/1573

				-- enable extra rules?
				UseGenitive = true,
			},
			isolateEnglish = true, -- experimental; in mixed-language doc only check English
			dialect = "American",
		},
	},
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
