-- DOCS https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts
--------------------------------------------------------------------------------

return {
	filetypes = { "bash", "sh", "zsh" }, -- force it to work in zsh as well
	settings = {
		bashIde = {
			shfmt = { spaceRedirects = true },
			includeAllWorkspaceSymbols = true,
			globPattern = "**/*@(.sh|.bash|.zsh)",
			shellcheckArguments = "--shell=bash",
		},
	},
}
