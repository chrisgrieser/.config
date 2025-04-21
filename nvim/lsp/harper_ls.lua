-- DOCS 
-- https://writewithharper.com/docs/integrations/neovim
-- https://writewithharper.com/docs/integrations/language-server#Configuration
--------------------------------------------------------------------------------

return {
	filetypes = { "markdown" }, -- PENDING https://github.com/elijah-potter/harper/issues/228
	settings = {
		["harper-ls"] = {
			diagnosticSeverity = "hint",
			userDictPath = vim.o.spellfile,
			markdown = { IgnoreLinkTitle = true },
			linters = {
				SentenceCapitalization = false, -- false positives: https://github.com/Automattic/harper/issues/1056
			},
			isolateEnglish = true, -- experimental; in mixed-language doc only check English
			dialect = "American",
		},
	},
	on_attach = function(harper, bufnr)
		require("config.utils").detachIfObsidianOrIcloud(harper, bufnr)

		-- Using `harper` to write to the spellfile affectively does the same as
		-- the builtin `zg`, but has the advantage that `harper` is hot-reloaded.
		vim.keymap.set("n", "zg", function()
			vim.lsp.buf.code_action {
				filter = function(a) return a.title:find("^Add .* to the global dictionary%.") ~= nil end,
				apply = true,
			}
		end, { desc = "󰓆 Add word to spellfile", buffer = bufnr })
	end,
}
