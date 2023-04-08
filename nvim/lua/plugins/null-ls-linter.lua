-- INFO these require null-ls name, not mason name: https://github.com/jayp0521/mason-null-ls.nvim#available-null-ls-sources
-- INFO linters also need to be added as source below
local lintersAndFormatters = {
	"yamllint", -- only for diagnostics, not for formatting
	"prettier", -- js/ts/yaml
	"shellcheck", -- needed for bash-lsp
	"shfmt", -- shell
	"markdownlint",
	"cbfmt", -- use other linters to format codeblocks in markdown
	"black", -- python formatter
	"vale", -- natural language
	"codespell", -- superset of `misspell`, therefore only using codespell
	"selene", -- lua
	"stylua", -- lua
	"stylelint", -- not its plugins though… https://github.com/williamboman/mason.nvim/issues/695
	-- eslint not available: https://github.com/williamboman/mason.nvim/issues/697
}
--------------------------------------------------------------------------------
-- INFO
-- eslint, stylua, selene and prettier use project-specific config files
-- the other linters use a global config file
--------------------------------------------------------------------------------
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
local function nullSources()
	local builtins = require("null-ls").builtins

	return {
		-- GLOBAL
		builtins.diagnostics.codespell.with {
			disabled_filetypes = { "css", "bib" }, -- base64-encoded fonts cause a lot of errors
			-- can't use `--skip`, since it null-ls reads from stdin and not from file
			args = { "--ignore-words", LinterConfig .. "/codespell-ignore.txt", "-" },
		},
		builtins.formatting.codespell.with {
			disabled_filetypes = { "css", "bib" },
			extra_args = { "--ignore-words", LinterConfig .. "/codespell-ignore.txt" },
		},
		builtins.formatting.trim_newlines, -- trim trailing whitespace & newlines
		builtins.formatting.trim_whitespace.with {
			disabled_filetypes = { "markdown" }, -- do not remove spaces due to two-space-rule
		},

		-- PYTHON
		builtins.formatting.black,

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
		-- INFO when no prettierrc can be found, will use prettiers default
		-- config, which includes setting everything to spaces…
		builtins.formatting.prettier.with {
			disabled_filetypes = { "css", "markdown" }, -- using different linters for them
			condition = function(utils) return utils.root_has_file { "selene.toml" } end,
		},

		-- CSS
		builtins.formatting.stylelint.with {
			-- using config without ordering, since automatic re-ordering can be
			-- confusing. Config with stylelint-order is only run on build.
			extra_args = { "--config", LinterConfig .. "/stylelintrc-formatting.yml" },
		},
		builtins.diagnostics.stylelint.with { -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			filetypes = { "css" },
			extra_args = {
				"--quiet", -- only errors, no warnings
				"--config",
				LinterConfig .. "/stylelintrc.yml",
			},
		},

		-- LUA
		builtins.formatting.stylua,
		builtins.diagnostics.selene,

		-- YAML
		builtins.diagnostics.yamllint.with {
			extra_args = { "--config-file", LinterConfig .. "/yamllint.yaml" },
		},

		-- MARKDOWN & PROSE
		builtins.diagnostics.vale.with {
			extra_args = { "--config", LinterConfig .. "/vale/vale.ini" },
		},
		builtins.formatting.cbfmt.with { -- code blocks
			extra_args = { "--config", LinterConfig .. "/cbfmt.toml" },
		},
		builtins.formatting.markdownlint.with {
			extra_args = { "--config", LinterConfig .. "/markdownlintrc" },
		},
		builtins.diagnostics.markdownlint.with {
			-- disabling rules that are autofixed already
			extra_args = {
				"--disable",
				"trailing-spaces",
				"no-multiple-blanks",
				"--config",
				LinterConfig .. "/markdownlintrc",
			},
		},
		builtins.completion.spell.with { -- vim's built-in spell-suggestions
			filetypes = { "markdown", "text", "gitcommit" },
		},
	}
end
--------------------------------------------------------------------------------

return {
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim", "jayp0521/mason-null-ls.nvim" },
		config = function()
			require("null-ls").setup {
				border = BorderStyle,
				-- `.project-root` also used for projects.nvim
				root_dir = require("null-ls.utils").root_pattern(".project-root", ".git", "selene.toml"),
				sources = nullSources(),
			}
		end,
	},
	{

		"jayp0521/mason-null-ls.nvim",
		lazy = true,
		opts = { ensure_installed = lintersAndFormatters },
	},
}
