require("utils")
--------------------------------------------------------------------------------

local lintersAndFormatters = {
	"eslint_d",
	"markdownlint",
	"shellcheck",
	"yamllint",
	"proselint",
	-- stylelint not available?
}
-- INFO: linters also need to be added as source below

--------------------------------------------------------------------------------
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md

local null_ls = require("null-ls")

local forceZshForShellcheck = {
	extra_filetypes = {"zsh"},
	extra_args = {"--shell=bash"},
}

null_ls.setup{
	sources = {
		null_ls.builtins.code_actions.gitsigns, -- gitsings.nvim plugin, e.g. hunk previews

		-- `bashls` and `diagnosticls` both do not work for zsh shellcheck; `efm` depends on go
		null_ls.builtins.diagnostics.shellcheck.with(forceZshForShellcheck),
		null_ls.builtins.code_actions.shellcheck.with(forceZshForShellcheck),
		null_ls.builtins.diagnostics.zsh, -- basic diagnostics via shell -x

		null_ls.builtins.formatting.stylelint.with{
			extra_args = {"--config", fn.expand("~/dotfiles/linter rcfiles/.stylelintrc-formatting.json")},
		},
		null_ls.builtins.diagnostics.stylelint.with{ -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			extra_args = { "--quiet" }, -- only errors, no warnings
		},

		null_ls.builtins.formatting.eslint_d,
		null_ls.builtins.code_actions.eslint_d,
		null_ls.builtins.diagnostics.eslint_d.with{
			-- extra_args = { "--quiet" },
		},

		null_ls.builtins.diagnostics.yamllint.with{
			extra_args = {"--config-file", fn.expand("~/.config/yamllint/config/.yamllint.yaml")},
		},

		null_ls.builtins.code_actions.proselint,
		null_ls.builtins.diagnostics.proselint,
		null_ls.builtins.hover.dictionary, -- vim's builtin dictionary
		null_ls.builtins.diagnostics.markdownlint.with{
			extra_args = {"--disable=trailing-spaces"},
		},
		null_ls.builtins.completion.spell.with{ -- vim's built-in spell-suggestions
			filetypes = { "markdown" },
		},

	},
}

--------------------------------------------------------------------------------
-- mason-null-ls should be loaded after null-ls and mason https://github.com/jayp0521/mason-null-ls.nvim#setup

require("mason-null-ls").setup{
	-- these require the null-ls name, not the mason name: https://github.com/jayp0521/mason-null-ls.nvim#available-null-ls-sources
	ensure_installed = lintersAndFormatters
}
