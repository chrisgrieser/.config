-- DOCS https://ltex-plus.github.io/ltex-plus/settings.html
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = { "markdown" },
	settings = {
		ltex = {
			language = "auto", -- also per-file via yaml header: `lang: de-DE` https://ltex-plus.github.io/ltex-plus/advanced-usage.html#set-language-in-markdown-with-yaml-front-matter
			diagnosticSeverity = { default = "warning" },
			disabledRules = {
				["en"] = {
					"MORFOLOGIK_RULE_EN_US", -- spellcheck done via Harper instead
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
					"UPPERCASE_SENTENCE_START", -- done via Harper
					"CONSECUTIVE_SPACES", -- done by Harper & rumdl
				},
				["de"] = {
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
