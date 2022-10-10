-- nvim-lint
require('lint').linters_by_ft = {
	sh = { 'shellcheck' },
	zsh = { 'shellcheck' },
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

-- shellcheck: force zsh linting
local shellcheckArgs = require("lint.linters.shellcheck").args
table.insert(shellcheckArgs, 1, "bash")
table.insert(shellcheckArgs, 1, "--shell")
table.insert(shellcheckArgs, 1, "--external-sources")

-- -- stylelint: surpress warnings
-- local stylelintArgs = require("lint.linters.stylelint").args
-- table.insert(stylelintArgs, 1, "--quiet")

-- -- eslint: use config
-- local eslintArgs = require("lint.linters.eslint").args
-- table.insert(eslintArgs, "--config")
-- table.insert(eslintArgs, '"$HOME/dotfiles/linter rclines/.eslintrc.json"')

