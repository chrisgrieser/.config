local efmConfig = {
	lua = {
		{
			formatCommand = "stylua -",
			formatStdin = true,
			rootMarkers = { "stylua.toml", ".stylua.toml" },
		},
	},
	markdown = {
		-- HACK use `cat` due to https://github.com/mattn/efm-langserver/issues/258
		{
			formatCommand = "markdown-toc --indent=4 -i '${INPUT}' && cat '${INPUT}'",
			formatStdin = false,
		},
		{
			formatCommand = "markdownlint --fix '${INPUT}' && cat '${INPUT}'",
			rootMarkers = { ".markdownlint.yaml" },
			formatStdin = false,
		},
	},
	zsh = {
		-- HACK use efm to force shellcheck to work with zsh files via `--shell=bash`,
		-- since doing so with bash-lsp does not work
		-- PENDING https://github.com/bash-lsp/bash-language-server/pull/1133
		{
			lintSource = "shellcheck",
			lintCommand = "shellcheck --format=gcc --external-sources --shell=bash -",
			lintStdin = true,
			lintFormats = {
				"-:%l:%c: %trror: %m [SC%n]",
				"-:%l:%c: %tarning: %m [SC%n]",
				"-:%l:%c: %tote: %m [SC%n]",
			},
		},
	},
	just = {
		{
			formatCommand = 'just --fmt --unstable --justfile="${INPUT}" ; cat "${INPUT}"',
			formatStdin = false,
			rootMarkers = { "Justfile", ".justfile" },
		},
	},
}

local out = vim.iter(vim.tbl_values(efmConfig))
	:flatten()
	:map(function(config) return config.rootMarkers end)
	:flatten()
	:totable()
vim.notify(--[[🖨️]] vim.inspect(out), nil, { ft = "lua", title = "out 🖨️" })
