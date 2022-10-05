require("utils")
--------------------------------------------------------------------------------
-- ALE + COC
g.ale_disable_lsp = 1

-- INFO: setting for redirecting coc output to ALE in "coc-settings.json"
-- https://github.com/dense-analysis/ale#5iii-how-can-i-use-ale-and-cocnvim-together
--------------------------------------------------------------------------------
g.ale_cursor_detail = 0 -- open popup instead msg
g.ale_detail_to_floating_preview = 0 -- bottom panel
g.ale_set_balloons = 1 -- hover

g.ale_use_global_executables = 1 -- globally installed listers

g.ale_echo_msg_format = '[%linter%] %severity% %code: %%s'
g.ale_linters_ignore = {lua = {'selene'}} -- https://github.com/dense-analysis/ale/issues/4329
--------------------------------------------------------------------------------

-- force shellcheck to also lint zsh files
g.ale_sh_shellcheck_options = '-x --shell=bash' -- https://scriptingosx.com/2019/08/shellcheck-and-zsh/
g.ale_linters = {
	zsh = {'shellcheck', 'shell'}
}



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

keymap("n", "<leader>f","<Plug>(ale_fix)") -- fix single instance
keymap("n", "<leader>L","<Plug>(ale_lint)") -- line current file

keymap("n", "gl","<Plug>(ale_next_wrap)")
keymap("n", "gL","<Plug>(ale_previous_wrap)")

