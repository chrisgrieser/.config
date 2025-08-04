-- DOCS https://github.com/mattn/efm-langserver#configuration-for-neovim-builtin-lsp-with-nvim-lspconfig
--------------------------------------------------------------------------------

local efmConfig = {
	lua = {
		{
			formatCommand = "stylua --search-parent-directories --stdin-filepath='${INPUT}' --respect-ignores -",
			formatStdin = true,
			rootMarkers = { "stylua.toml", ".stylua.toml" },
		},
	},
	markdown = {
		{ -- HACK use `cat` due to https://github.com/mattn/efm-langserver/issues/258
			formatCommand = "markdown-toc --indent=$'\t' -i '${INPUT}' && cat '${INPUT}'",
			formatStdin = false,
			rootMarkers = { ".git" },
		},
		{ -- HACK use `cat` due to https://github.com/mattn/efm-langserver/issues/258
			formatCommand = "markdownlint --fix '${INPUT}' && cat '${INPUT}'",
			formatStdin = false,
			rootMarkers = { ".markdownlint.yaml" },
		},
		{
			lintSource = "markdownlint",
			lintCommand = "markdownlint --stdin",
			lintStdin = true, -- caveat: linting from stdin does not support `.markdownlintignore`
			lintIgnoreExitCode = true,
			lintSeverity = vim.diagnostic.severity.INFO,
			lintFormats = { "%f:%l:%c MD%n/%m", "%f:%l MD%n/%m" },
			rootMarkers = { ".markdownlint.yaml" },
		},
	},
	zsh = {
		-- HACK use efm to force shellcheck to work with zsh files via `--shell=bash`,
		-- since doing so with bash-lsp does not work
		-- PENDING https://github.com/bash-lsp/bash-language-server/issues/1064
		{
			lintSource = "shellcheck",
			rootMarkers = { ".git" },
			lintCommand = "shellcheck --format=gcc --external-sources --shell=bash -",
			lintStdin = true,
			lintFormats = {
				"-:%l:%c: %trror: %m [SC%n]",
				"-:%l:%c: %tarning: %m [SC%n]",
				"-:%l:%c: %tote: %m [SC%n]",
			},
		},
	},
}

return {
	workspace_required = true,
	init_options = { documentFormatting = true },

	filetypes = vim.tbl_keys(efmConfig),
	settings = { languages = efmConfig },

	root_markers = vim.iter(vim.tbl_values(efmConfig))
		:flatten()
		:map(function(tool) return tool.rootMarkers end)
		:flatten()
		:totable(),

	-- cleanup useless empty folder `efm` creates on startup
	on_attach = function() os.remove(vim.fs.normalize("~/.config/efm-langserver")) end,
}
