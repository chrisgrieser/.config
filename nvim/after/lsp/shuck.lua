-- DOCS https://ewhauser.github.io/shuck/docs/configuration/
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = {
		'yaml', -- add for Github Actions
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
