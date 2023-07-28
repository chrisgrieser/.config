-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
--------------------------------------------------------------------------------

local linterConfig = require("config.utils").linterConfigFolder
local lintersAndFormatters = {
	"yamllint", -- only for diagnostics, not for formatting
	"shellcheck", -- needed for bash-lsp
	"shfmt", -- shell
	"markdownlint",
	"cbfmt", -- use other linters to format codeblocks in markdown
	"black", -- python formatter
	"vale", -- natural language
	"codespell", -- superset of `misspell`, therefore only using codespell
	"selene", -- lua
	"stylua", -- lua
	"prettier", -- only used for yaml and html https://github.com/mikefarah/yq/issues/515
	"rome", -- also an LSP; the lsp does diagnostics, the CLI via null-ls does formatting
	-- stylelint included in mason, but not its plugins, which then cannot be found https://github.com/williamboman/mason.nvim/issues/695
}

--------------------------------------------------------------------------------
local function nullSources()
	local builtins = require("null-ls").builtins

	return {
		-- GLOBAL
		builtins.diagnostics.codespell.with {
			disabled_filetypes = { "css", "bib" }, -- base64-encoded fonts cause a lot of errors
			-- can't use `--skip`, since it null-ls reads from stdin and not from file
			args = { "--ignore-words", linterConfig .. "/codespell-ignore.txt", "-" },
		},
		builtins.formatting.codespell.with {
			disabled_filetypes = { "css", "bib" },
			extra_args = { "--ignore-words", linterConfig .. "/codespell-ignore.txt" },
		},
		builtins.formatting.trim_newlines, -- trim trailing whitespace & newlines
		builtins.formatting.trim_whitespace.with {
			disabled_filetypes = { "markdown" }, -- do not remove spaces due to two-space-rule
		},

		-- PYTHON
		builtins.formatting.black,

		-- SHELL
		builtins.formatting.shfmt,

		-- force shellcheck to work with zsh
		-- builtins.diagnostics.shellcheck,
		builtins.code_actions.shellcheck,

		-- builtins.diagnostics.shellcheck.with {
		-- 	extra_filetypes = { "zsh" },
		-- 	extra_args = { "--shell=bash" },
		-- },
		-- builtins.code_actions.shellcheck.with {
		-- 	extra_filetypes = { "zsh" },
		-- 	extra_args = { "--shell=bash" },
		-- },

		-- force shellcheck to work with zsh
		builtins.diagnostics.shellcheck.with {
			extra_filetypes = { "zsh" },
			extra_args = { "--shell=bash" },
		},
		builtins.code_actions.shellcheck.with {
			extra_filetypes = { "zsh" },
			extra_args = { "--shell=bash" },
		},


		-- JS/TS/JSON
		builtins.formatting.rome, -- not available via LSP yet

		-- CSS
		builtins.formatting.stylelint.with {
			-- using config without ordering, since automatic re-ordering can be
			-- confusing. Config with stylelint-order is only run on build.
			extra_args = { "--config", linterConfig .. "/stylelintrc-formatting.yml" },
			timeout = 15000, -- longer timeout for large css files
		},
		builtins.diagnostics.stylelint.with { -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			extra_args = {
				"--quiet", -- only errors, no warnings
				"--config",
				linterConfig .. "/stylelintrc.yml",
			},
		},

		-- LUA
		builtins.formatting.stylua,
		builtins.diagnostics.selene.with {
			-- INFO not dynamically determining config file, since that breaks
			-- selene when switching workspaces
			extra_args = { "--config", linterConfig .. "/selene.toml" },
		},

		-- PRETTIER: YAML/HTML
		-- INFO use only for yaml/html, since rome handles the rest
		builtins.formatting.prettier.with {
			filetypes = { "yaml", "html" },
		},

		-- YAML
		builtins.diagnostics.yamllint.with {
			extra_args = { "--config-file", linterConfig .. "/yamllint.yaml" },
		},

		-- MARKDOWN & PROSE
		builtins.diagnostics.vale.with {
			extra_args = { "--config", linterConfig .. "/vale/vale.ini" },
		},
		builtins.formatting.cbfmt.with { -- code blocks
			extra_args = { "--config", linterConfig .. "/cbfmt.toml" },
		},
		builtins.formatting.markdownlint.with {
			extra_args = { "--config", linterConfig .. "/markdownlintrc" },
		},
		builtins.diagnostics.markdownlint.with {
			-- disabling rules that are autofixed already
			-- stylua: ignore
			extra_args = { "--config", linterConfig .. "/markdownlintrc" },
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
				border = require("config.utils").borderStyle,
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
