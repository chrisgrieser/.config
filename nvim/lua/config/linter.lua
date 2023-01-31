require("config.utils")
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
	"black", -- python formatter
	"vale", -- natural language
	"codespell", -- natural language (common misspellings, autoformatted)
	"selene", -- lua
	"stylua", -- lua
	"prettier", -- only for TS and JS
	-- stylelint not available: https://github.com/williamboman/mason.nvim/issues/695
	-- eslint not available: https://github.com/williamboman/mason.nvim/issues/697
}

--------------------------------------------------------------------------------
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md

null_ls.setup {
	sources = {
		-- GLOBAL
		builtins.diagnostics.codespell.with { -- common misspellings. Far less false positives than with cspell
			disabled_filetypes = { "css", "bib" }, -- base64-encoded fonts cause a lot of errors
			-- can't use `--skip`, since it null-ls reads from stdin and not a file
			args = { "--ignore-words", linterConfig .. "/codespell-ignore.txt", "-" },
		},
		builtins.formatting.codespell.with { -- autofix those misspellings
			disabled_filetypes = { "css", "bib" },
			extra_args = { "--ignore-words", linterConfig .. "/codespell-ignore.txt" },
		},
		builtins.formatting.trim_newlines, -- trim trailing whitespace & newlines
		builtins.formatting.trim_whitespace.with {
			disabled_filetypes = { "markdown" }, -- do not remove spaces due to two-space-rule
		},

		-- PYTHON
		builtins.formatting.black.with {
			-- stylua: ignore
			args = { "--config", linterConfig .. "/black.toml", "--stdin-filename", "$FILENAME", "--quiet", "-" },
		},

		-- SHELL
		builtins.diagnostics.zsh, -- basic diagnostics via shell -x
		builtins.formatting.shfmt,
		builtins.diagnostics.shellcheck.with {
			extra_filetypes = { "zsh" },
			extra_args = { "--shell=bash" },
		},
		builtins.code_actions.shellcheck.with {
			extra_filetypes = { "zsh" },
			extra_args = { "--shell=bash" },
		},

		-- JS/TS
		builtins.formatting.prettier.with {
			filetypes = { "javascript", "typescript" }, -- do format markdown, css, and so on
			extra_args = { "--config", linterConfig .. "/.prettierrc.yml" },
		},

		-- CSS
		builtins.formatting.stylelint.with {
			-- using config without ordering, since ordering on save is confusing
			extra_args = { "--config", linterConfig .. "/.stylelintrc-formatting.yml" },
		},
		builtins.diagnostics.stylelint.with { -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			filetypes = { "css" },
			extra_args = {
				"--quiet", -- only errors, no warnings
				"--config",
				linterConfig .. "/.stylelintrc.yml",
			},
		},

		-- LUA
		builtins.formatting.stylua.with {
			extra_args = { "--config-path", linterConfig .. "/.stylua.toml" },
		},
		builtins.diagnostics.selene.with {
			extra_args = { "--config", linterConfig .. "/selene.toml" },
		},

		-- YAML
		builtins.formatting.yamlfmt,
		builtins.diagnostics.yamllint.with {
			extra_args = { "--config-file", linterConfig .. "/.yamllint.yaml" },
		},

		-- MARKDOWN & PROSE
		builtins.diagnostics.vale.with {
			extra_args = { "--config", linterConfig .. "/vale/.vale.ini" },
		},
		builtins.formatting.markdownlint.with {
			extra_args = { "--config", linterConfig .. "/.markdownlintrc" },
		},
		builtins.diagnostics.markdownlint.with {
			-- disabling rules that are autofixed already
			extra_args = {
				"--disable",
				"trailing-spaces",
				"no-multiple-blanks",
				"--config",
				linterConfig .. "/.markdownlintrc",
			},
		},
		builtins.hover.dictionary, -- vim's builtin dictionary
		builtins.completion.spell.with { -- vim's built-in spell-suggestions
			filetypes = { "markdown", "text", "gitcommit" },
		},
	},
}

--------------------------------------------------------------------------------
-- mason-null-ls should be loaded after null-ls and mason
-- https://github.com/jayp0521/mason-null-ls.nvim#setup

require("mason-null-ls").setup {
	ensure_installed = lintersAndFormatters,
}
