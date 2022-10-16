require("utils")
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
--------------------------------------------------------------------------------

local null_ls = require("null-ls")

local forceZshForShellcheck = {
	extra_filetypes = {"zsh"},
	extra_args = {"--shell=bash"},
}

null_ls.setup{
	sources = {
		null_ls.builtins.diagnostics.stylelint.with{ -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			extra_args = { "--quiet" }, -- only errors, no warnings
		},

		null_ls.builtins.code_actions.eslint,
		null_ls.builtins.diagnostics.eslint.with{
			extra_args = { "--quiet" }, -- only errors, no warnings
		},

		null_ls.builtins.diagnostics.selene.with{
			extra_args = {"--config", fn.expand("~/dotfiles/linter rcfiles/selene.toml")}, -- ~ requires expand
		},
		null_ls.builtins.diagnostics.yamllint.with{
			extra_args = {"--config", fn.expand("~/.config/yamllint/config/.yamllint.yaml")},
		},

		-- `bashls` and `diagnosticls` both do not work for zsh shellcheck; `efm` depends on go
		null_ls.builtins.code_actions.shellcheck.with{forceZshForShellcheck},
		null_ls.builtins.diagnostics.shellcheck.with{forceZshForShellcheck},
	},
}
