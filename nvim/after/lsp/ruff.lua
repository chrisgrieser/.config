-- DOCS https://docs.astral.sh/ruff/editors/settings/
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	init_options = {
		settings = {
			organizeImports = false, -- if "I" ruleset is added, already included in "fixAll"
			codeAction = { disableRuleComment = { enable = false } }, -- using nvim-rulebook instead
		},
	},
}
