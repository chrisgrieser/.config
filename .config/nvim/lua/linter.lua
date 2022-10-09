-- nvim-lint
require('lint').linters_by_ft = {
  sh = { 'shellcheck' },
  zsh = { 'shellcheck' },
  css = { 'stylelint' },
  js = { 'eslint' },
  ts = { 'eslint' },
  yaml = { 'yamllint' },
  markdown = { 'markdownlint' },
  lua = { 'selene' },
}

-- when to lint
augroup("nvimlint", {})
autocmd({ "BufEnter", "InsertLeave", "TextChanged" }, {
	callback = function() require("lint").try_lint() end,
	group = "nvimlint",
})

--------------------------------------------------------------------------------
-- LINTER-SPECIFIC OPTIONS

-- surpress warnings
local stylelintArgs = require("lint.linters.stylelint").args
table.insert(stylelintArgs, 1, "--quiet")

-- fix yamllint config
local yamllintArgs = require("lint.linters.yamllint").args
table.insert(yamllintArgs, "--config-file")
table.insert(yamllintArgs, '"$HOME/.config/.yamllint.yaml"')

-- force zsh linting
local shellcheckArgs = require("lint.linters.shellcheck").args
table.insert(shellcheckArgs, 1, "bash")
table.insert(shellcheckArgs, 1, "--shell")

-- selene
local seleneArgs = require("lint.linters.selene").args
table.insert(seleneArgs, "--config")
table.insert(seleneArgs, '"/Users/chrisgrieser/dotfiles/linter rclines/selene.toml"')

