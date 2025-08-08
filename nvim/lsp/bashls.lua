-- DOCS https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = { "sh", "bash", "zsh" }, -- force it to work in zsh as well
	settings = {
		bashIde = {
			shfmt = { spaceRedirects = true },
			includeAllWorkspaceSymbols = false, -- prevents var-renaming affecting other files
			globPattern = "**/*@(.sh|.bash|.zsh)",
			shellcheckArguments = "--shell=bash",
		},
	},
	root_markers = {
		"info.plist", -- Alfred workflows
		".zshrc",
		".git", -- last, so lowest priority
	},
}
