-- DOCS https://github.com/mattn/efm-langserver#configuration-for-neovim-builtin-lsp-with-nvim-lspconfig
--------------------------------------------------------------------------------

---@type vim.lsp.Config
local efmConfig = {
	markdown = {
		{
			lintSource = "markdownlint",
			lintCommand = "markdownlint --stdin",
			lintStdin = true, -- caveat: linting from stdin doesn't support `.markdownlintignore`
			lintIgnoreExitCode = true,
			lintFormats = {
				"stdin:%l:%c %trror MD%n/%*[^ ] %m",
				"stdin:%l %trror MD%n/%*[^ ] %m",
				"stdin:%l:%c %tarning MD%n/%*[^ ] %m",
				"stdin:%l %tarning MD%n/%*[^ ] %m",
			},
			-- lower severity (warnings require `default: warning` in markdownlint.yaml)
			lintCategoryMap = { w = "N", e = "I" }, -- warning -> hint, error -> info
			rootMarkers = { ".markdownlint.yaml", ".markdownlint.jsonc" },
			requireMarker = true -- on active when root-marker is found, since too noisy on other people's repos
		},
	},
	zsh = {
		-- HACK use efm to force shellcheck to work with zsh files via `--shell=bash`,
		-- since doing so with bash-lsp does not work
		-- PENDING https://github.com/bash-lsp/bash-language-server/issues/1064
		{
			lintSource = "shellcheck",
			lintCommand = "shellcheck --format=gcc --external-sources --shell=bash -",
			lintIgnoreExitCode = true,
			lintStdin = true,
			lintFormats = {
				"-:%l:%c: %trror: %m [SC%n]",
				"-:%l:%c: %tarning: %m [SC%n]",
				"-:%l:%c: %tote: %m [SC%n]",
			},
			rootMarkers = { ".git" },
		},
	},
}

return {
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
