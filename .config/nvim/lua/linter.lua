require("utils")
--------------------------------------------------------------------------------

local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.diagnostics.stylelint.with{ -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			extra_args = { "--quiet" }, -- only errors, no warnings
		},
		null_ls.builtins.diagnostics.selene.with{
			extra_args = {"config=$HOME/dotfiles/linter rclines/selene.toml"},
		},
		null_ls.builtins.diagnostics.yamllint.with{
			extra_args = {"config=$HOME/.config/yamllint/config/.yamllint.yaml"},
		},
		null_ls.builtins.diagnostics.shellcheck.with{ -- bashls, diagnosticls both do not work for zsh shellcheck; efm depends on go
			extra_filetypes = {"zsh"},
			extra_args = { "--external-sources", "--shell=bash" },
		},
	},
})
-- not using eslint with null_ls, since the lsp for is already works fine 

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

---- nvim-lint
--require('lint').linters_by_ft = {
--	sh = { 'shellcheck' }, -- bashls, diagnosticls both do not work for zsh shellcheck; efm depends on go
--	zsh = { 'shellcheck' },
--	lua = { 'selene' },
--	yaml = { 'yamllint' },
--	css = { 'stylelint' }, -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
--	-- javascript = { 'eslint' }, available via lsp servers already and better integrated there
--	-- typescript = { 'eslint' },
--}

---- when to lint
--augroup("nvimlint", {})
--autocmd({ "BufEnter", "InsertLeave", "TextChanged" }, {
--	callback = function() require("lint").try_lint() end,
--	group = "nvimlint",
--})

----------------------------------------------------------------------------------
---- LINTER-SPECIFIC OPTIONS

---- shellcheck: force zsh linting
--local shellcheckArgs = require("lint.linters.shellcheck").args
--table.insert(shellcheckArgs, 1, "--shell=bash")
--table.insert(shellcheckArgs, 1, "--external-sources")

---- stylelint: surpress warnings
--local stylelintArgs = require("lint.linters.stylelint").args
--table.insert(stylelintArgs, 1, "--quiet")

---- selene: use config
--local seleneArgs = require("lint.linters.selene").args
--table.insert(seleneArgs, "--config")
--table.insert(seleneArgs, '"$HOME/dotfiles/linter rclines/selene.toml"')

---- yamllint: use config
--local yamllintArgs = require("lint.linters.yamllint").args
--table.insert(yamllintArgs, "--config-file")
--table.insert(yamllintArgs, '"$HOME/.config/.yamllint.yaml"')
