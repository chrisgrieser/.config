-- DOCS https://docs.astral.sh/ruff/editors/settings/
--------------------------------------------------------------------------------

return {
	init_options = {
		settings = {
			organizeImports = false, -- if "I" ruleset is added, already included in "fixAll"
			codeAction = { disableRuleComment = { enable = false } }, -- using nvim-rulebook instead
		},
	},
	-- disable in favor of `basedpyright`'s hover info
	on_attach = function(ruff) ruff.server_capabilities.hoverProvider = false end,
}
