require("utils")
local null_ls = require("null-ls")
local builtins = null_ls.builtins
--------------------------------------------------------------------------------

-- INFO these require null-ls name, not mason name: https://github.com/jayp0521/mason-null-ls.nvim#available-null-ls-sources
-- INFO linters also need to be added as source below
local lintersAndFormatters = {
	"yamllint",
	"yamlfmt",
	"shellcheck", -- needed for bash-lsp
	"shfmt", -- shell
	"markdownlint",
	"vale", -- natural language
	"selene", -- lua linter
	"codespell", -- common misspellings, autoformatted
	-- stylelint not available: https://github.com/williamboman/mason.nvim/issues/695
	-- eslint not available: https://github.com/williamboman/mason.nvim/issues/697
}

local codeSpellIgnoreFile = os.getenv("HOME") .. "/.config/codespell/codespell-ignore.txt"

--------------------------------------------------------------------------------
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
null_ls.setup {
	sources = {
		-- Global
		builtins.code_actions.gitsigns, -- gitsigns.nvim plugin, e.g. reset hunks
		builtins.diagnostics.codespell.with {-- common misspellings. Far less false positives than with cspell
			disabled_filetypes = {"css"}, -- base64-encoded fonts cause a lot of errors
			args = {"--ignore-words", codeSpellIgnoreFile, "-"}
		},
		builtins.formatting.codespell.with {-- autofix those misspellings
			disabled_filetypes = {"css"},
			extra_args = {"--ignore-words", codeSpellIgnoreFile}
		},

		-- SHELL
		builtins.hover.printenv, -- show value of environment variable on hover command
		builtins.diagnostics.zsh, -- basic diagnostics via shell -x
		builtins.formatting.shfmt,
		-- no diagnostics for shellcheck needed, since handled by bash-lsp
		-- but code actions are needed: https://github.com/bash-lsp/bash-language-server/issues/490
		builtins.code_actions.shellcheck.with {
			extra_filetypes = {"zsh"},
			extra_args = {"--shell=bash"},
		},

		-- CSS
		builtins.formatting.stylelint.with {
			-- using config without ordering, since ordering on save is confusing
			extra_args = {"--config", dotfilesFolder .. "/linter-configs/.stylelintrc-formatting.yml"},
		},
		builtins.diagnostics.stylelint.with {-- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			filetypes = {"css"},
			extra_args = {"--quiet"}, -- only errors, no warnings
		},

		-- Lua
		builtins.diagnostics.selene.with {
			extra_args = {"--config", dotfilesFolder .. "/linter-configs/selene.toml"}
		},

		-- YAML
		builtins.formatting.yamlfmt,
		builtins.diagnostics.yamllint.with {
			extra_args = {"--config-file", dotfilesFolder .. "/yamllint/config/.yamllint.yaml"},
		},

		-- Markdown & Prose
		builtins.diagnostics.vale,
		builtins.diagnostics.markdownlint.with {
			-- fixed via formatting command already
			extra_args = {"--disable", "trailing-spaces", "no-multiple-blanks"},
		},
		builtins.hover.dictionary, -- vim's builtin dictionary
		builtins.formatting.markdownlint,
		builtins.completion.spell.with {-- vim's built-in spell-suggestions
			filetypes = {"markdown", "text", "DressingInput"},
		},

	},
}

--------------------------------------------------------------------------------
-- mason-null-ls should be loaded after null-ls and mason
-- https://github.com/jayp0521/mason-null-ls.nvim#setup

require("mason-null-ls").setup {
	ensure_installed = lintersAndFormatters,
}
