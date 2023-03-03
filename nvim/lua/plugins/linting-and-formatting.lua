-- INFO these require null-ls name, not mason name: https://github.com/jayp0521/mason-null-ls.nvim#available-null-ls-sources
-- INFO linters also need to be added as source below
local lintersAndFormatters = {
	"yamllint",
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

return {
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim", "jayp0521/mason-null-ls.nvim" },
		config = function()
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md

			local builtins = require("null-ls").builtins
			require("null-ls").setup {
				sources = {
					-- GLOBAL
					builtins.diagnostics.codespell.with { -- common misspellings. Far less false positives than with cspell
						disabled_filetypes = { "css", "bib" }, -- base64-encoded fonts cause a lot of errors
						-- can't use `--skip`, since it null-ls reads from stdin and not from file
						args = { "--ignore-words", LinterConfig .. "/codespell-ignore.txt", "-" },
					},
					builtins.formatting.codespell.with { -- autofix those misspellings
						disabled_filetypes = { "css", "bib" },
						extra_args = { "--ignore-words", LinterConfig .. "/codespell-ignore.txt" },
					},
					builtins.formatting.trim_newlines, -- trim trailing whitespace & newlines
					builtins.formatting.trim_whitespace.with {
						disabled_filetypes = { "markdown" }, -- do not remove spaces due to two-space-rule
					},

					-- PYTHON
					builtins.formatting.black.with {
						args = {
							"--config",
							LinterConfig .. "/black.toml",
							"--stdin-filename",
							"$FILENAME",
							"--quiet",
							"-",
						},
					},

					-- SHELL
					builtins.diagnostics.zsh, -- basic diagnostics via shell -x
					builtins.formatting.shfmt,
					-- force shellcheck to work with zsh
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
						filetypes = { "javascript", "typescript", "yaml" }, -- do not format markdown, css, and so on
						extra_args = { "--config", LinterConfig .. "/.prettierrc.yml" },
					},

					-- CSS
					builtins.formatting.stylelint.with {
						-- using config without ordering, since ordering on save is confusing
						extra_args = { "--config", LinterConfig .. "/.stylelintrc-formatting.yml" },
					},
					builtins.diagnostics.stylelint.with { -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
						filetypes = { "css" },
						extra_args = {
							"--quiet", -- only errors, no warnings
							"--config",
							LinterConfig .. "/.stylelintrc.yml",
						},
					},

					-- LUA
					builtins.formatting.stylua.with {
						extra_args = { "--config-path", LinterConfig .. "/.stylua.toml" },
					},
					builtins.diagnostics.selene.with {
						extra_args = { "--config", LinterConfig .. "/selene.toml" },
					},

					-- YAML
					builtins.diagnostics.yamllint.with {
						extra_args = { "--config-file", LinterConfig .. "/.yamllint.yaml" },
					},

					-- MARKDOWN & PROSE
					builtins.diagnostics.vale.with {
						extra_args = { "--config", LinterConfig .. "/vale/.vale.ini" },
					},
					builtins.formatting.markdownlint.with {
						extra_args = { "--config", LinterConfig .. "/.markdownlintrc" },
					},
					builtins.diagnostics.markdownlint.with {
						-- disabling rules that are autofixed already
						extra_args = {
							"--disable",
							"trailing-spaces",
							"no-multiple-blanks",
							"--config",
							LinterConfig .. "/.markdownlintrc",
						},
					},
					builtins.completion.spell.with { -- vim's built-in spell-suggestions
						filetypes = { "markdown", "text", "gitcommit" },
					},
				},
			}
		end,
	},
	{

		"jayp0521/mason-null-ls.nvim",
		lazy = true, -- loaded by null-ls
		config = function()
			-- mason-null-ls should be loaded after null-ls and mason
			-- https://github.com/jayp0521/mason-null-ls.nvim#setup

			require("mason-null-ls").setup {
				ensure_installed = lintersAndFormatters,
			}
		end,
	},
}
