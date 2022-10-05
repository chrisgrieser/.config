require("utils")
--------------------------------------------------------------------------------
-- ALE + COC
g.ale_disable_lsp = 1

-- INFO: setting for redirecting coc output to ALE in "coc-settings.json"
-- https://github.com/dense-analysis/ale#5iii-how-can-i-use-ale-and-cocnvim-together
--------------------------------------------------------------------------------
g.ale_cursor_detail = 0 -- open popup instead msg
g.ale_detail_to_floating_preview = 0 -- bottom panel
g.ale_virtualtext_cursor = 1
g.ale_use_global_executables = 1 -- globally installed listers

g.ale_warn_about_trailing_whitespace = 0 -- not needed, since linted already

g.ale_echo_msg_format = '[%linter%] %code: %%s'

g.ale_linters_ignore = {lua = {'selene'}} -- https://github.com/dense-analysis/ale/issues/4329
--------------------------------------------------------------------------------

-- force shellcheck to also lint zsh files
g.ale_sh_shellcheck_options = '-x'
g.ale_sh_shell_default_exclusions = ''

-- force shellcheck to be used in zsh files
g.ale_sh_shellcheck_dialect = 'bash'
g.ale_sh_shell_default_shell = 'zsh'
g.ale_linters = { zsh = {'shellcheck', 'shell'} }

--------------------------------------------------------------------------------
g.ale_javascript_eslint_options = '--quiet' -- ignore warnings

--------------------------------------------------------------------------------

-- keybindingss
keymap("n", "<leader>f","<Plug>(ale_fix)") -- fix single instance
keymap("n", "<leader>L","<Plug>(ale_lint)") -- line current file

keymap("n", "gl","<Plug>(ale_next_wrap)")
keymap("n", "gL","<Plug>(ale_previous_wrap)")
--------------------------------------------------------------------------------

-- linter-specific config from SublimeLinter
--[[
// this ensures that markdownlint's rc is found. also no ~ is needed
// trailing spaces and single trailing new line disabled as Sublime already does take care of that
"markdownlint": {
	"args": ["--config", "/.markdownlintrc", "--disable=no-trailing-spaces", "--disable=single-trailing-newline"]
},
"stylelint": {
	"filter_errors": "warning: ",
},
"yamllint": {
	"args": ["--config-file", "/.config/yamllint/config/.yamllint.yaml"]
},
"eslint": {
	// "filter_errors": "warning: ",
},
// https://scriptingosx.com/2019/08/shellcheck-and-zsh/
"shellcheck": {
	"args": ["--shell=bash"]
},
]]
--------------------------------------------------------------------------------

