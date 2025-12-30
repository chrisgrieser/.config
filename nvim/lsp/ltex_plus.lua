-- DOCS https://ltex-plus.github.io/ltex-plus/settings.html
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = { "markdown" },
	root_dir = function(bufnr, on_dir)
		-- do not load in specific repos (there is no `ltexignore` to do this)
		local pathsToIgnore = {
			vim.env.HOME .. "/Library/Mobile Documents/", -- anything in iCloud
			vim.env.HOME .. "/phd-data-analysis/",
			vim.g.notesDir,
		}
		local filepath = vim.api.nvim_buf_get_name(bufnr)
		local ignore = vim.iter(pathsToIgnore):any(function(p) return vim.startswith(filepath, p) end)
		if ignore then return end

		local rootMarkers = { ".git" }
		on_dir(vim.fs.root(bufnr, rootMarkers))
	end,
	settings = {
		ltex = {
			language = "en-US", -- also file via yaml header like `lang: de-DE` https://ltex-plus.github.io/ltex-plus/advanced-usage.html#set-language-in-markdown-with-yaml-front-matter
			diagnosticSeverity = { default = "warning" },
			disabledRules = {
				["en-US"] = {
					"MORFOLOGIK_RULE_EN_US", -- spellcheck done via Harper instead
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
					"UPPERCASE_SENTENCE_START", -- done via Harper
					"CONSECUTIVE_SPACES", -- done by Harper & rumdl
				},
				["de-DE"] = {
					"GERMAN_SPELLER_RULE", -- too many false positives
					"ABKUERZUNG_LEERZEICHEN", -- not needed
					"TYPOGRAFISCHE_ANFUEHRUNGSZEICHEN", -- don't expect smart quotes
				},
			},
			additionalRules = {
				enablePickyRules = true,
				mothersTongue = "de-DE",
			},
			markdown = {
				nodes = { Link = "dummy" }, -- don't check link text
			},
		},
	},
}
