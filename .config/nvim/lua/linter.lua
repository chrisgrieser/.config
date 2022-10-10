-- nvim-lint
require('lint').linters_by_ft = {
	sh = { 'shellcheck' },
	zsh = { 'shellcheck' },
	yaml = { 'yamllint' },
	lua = { 'selene' },
	-- available via lsp servers already (and better integrated there?)
	-- css = { 'stylelint' },
	-- javascript = { 'eslint' },
	-- typescript = { 'eslint' },
}

-- when to lint
augroup("nvimlint", {})
autocmd({ "BufEnter", "InsertLeave", "TextChanged" }, {
	callback = function() require("lint").try_lint() end,
	group = "nvimlint",
})

--------------------------------------------------------------------------------
-- LINTER-SPECIFIC OPTIONS

-- stylelint: surpress warnings
local stylelintArgs = require("lint.linters.stylelint").args
table.insert(stylelintArgs, 1, "--quiet")

-- selene: use config
local eslintArgs = require("lint.linters.eslint").args
table.insert(eslintArgs, "--config")
table.insert(eslintArgs, '"$HOME/dotfiles/linter rclines/.eslintrc.json"')

-- shellcheck: force zsh linting
local shellcheckArgs = require("lint.linters.shellcheck").args
table.insert(shellcheckArgs, 1, "bash")
table.insert(shellcheckArgs, 1, "--shell")
table.insert(shellcheckArgs, 1, "--external-sources")

-- selene: use config
local seleneArgs = require("lint.linters.selene").args
table.insert(seleneArgs, "--config")
table.insert(seleneArgs, '"$HOME/dotfiles/linter rclines/selene.toml"')

-- fix yamllint config
local yamllintArgs = require("lint.linters.yamllint").args
table.insert(yamllintArgs, "--config-file")
table.insert(yamllintArgs, '"$HOME/.config/.yamllint.yaml"')

