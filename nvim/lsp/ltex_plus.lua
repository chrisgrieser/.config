-- DOCS https://ltex-plus.github.io/ltex-plus/settings.html
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = { "markdown" },
	settings = {
		ltex = {
			language = "en-US", -- can also be set per file via markdown yaml header (e.g. `de-DE`)
			diagnosticSeverity = { default = "warning" },
			disabledRules = {
				["en-US"] = {
					"MORFOLOGIK_RULE_EN_US", -- spellcheck done via Harper instead
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
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
	on_attach = require("config.utils").detachIfObsidianOrIcloud,
}
