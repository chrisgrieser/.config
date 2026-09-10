-- DOCS https://ewhauser.github.io/shuck/docs/configuration/
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = {
		-- 'yaml', -- for Github Actions, currently buggy though
		'bash',
		'sh',
		'zsh',
	},
	root_markers = {
		"info.plist", -- add Alfred workflows
		".shuck.toml",
		".git",
	},
}
