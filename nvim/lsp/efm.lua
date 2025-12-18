-- DOCS
-- https://github.com/mattn/efm-langserver/blob/master/schema.md
-- https://github.com/mattn/efm-langserver#configuration-for-neovim-builtin-lsp-with-nvim-lspconfig
--------------------------------------------------------------------------------

---@type vim.lsp.Config
return {
	filetypes = { "zsh" },
	settings = {
		languages = {
			zsh = {
				-- HACK use efm to force shellcheck to work with zsh files via `--shell=bash`,
				-- since doing so with bash-lsp does not work
				-- PENDING https://github.com/bash-lsp/bash-language-server/issues/1064
				{
					lintSource = "shellcheck",
					lintCommand = "shellcheck --format=gcc --external-sources --shell=bash -",
					lintIgnoreExitCode = true,
					lintStdin = true,
					LintAfterOpen = true, -- not documented, and needs to be enabled: https://github.com/mattn/efm-langserver/pull/277
					lintFormats = {
						"-:%l:%c: %trror: %m [SC%n]",
						"-:%l:%c: %tarning: %m [SC%n]",
						"-:%l:%c: %tote: %m [SC%n]",
					},
				},
			},
		},
	},

	-- cleanup useless empty folder `efm` creates on startup
	on_attach = function() os.remove(vim.env.HOME .. "/.config/efm-langserver") end,
}
