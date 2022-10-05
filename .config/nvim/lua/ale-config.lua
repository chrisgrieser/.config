require("utils")
--------------------------------------------------------------------------------
-- ALE + COC
g.ale_disable_lsp = 1

-- INFO: setting for redirecting coc output to ALE in "coc-settings.json"
-- https://github.com/dense-analysis/ale#5iii-how-can-i-use-ale-and-cocnvim-together
--------------------------------------------------------------------------------
-- DISPLAY OPTIONS
g.ale_cursor_detail = 0 -- open popup instead of msg
g.ale_echo_msg_format = '[%linter%] %code: %%s' -- add linter so it's clearer from which linter the error comes

g.ale_virtualtext_cursor = 1
g.ale_virtualtext_delay = 200
g.ale_virtualtext_prefix = ' ↞ '
cmd[[highlight ALEVirtualTextError ctermfg=red guifg=red]]
cmd[[highlight ALEVirtualTextWarning ctermfg=yellow guifg=yellow]]
cmd[[highlight ALEVirtualTextInfo ctermfg=blue guifg=blue]]

--------------------------------------------------------------------------------

-- LINTING OPTIONS
g.ale_use_global_executables = 1 -- globally installed listers
g.ale_warn_about_trailing_whitespace = 0 -- not needed, since linted already

-- LINTER-SPECIFIC OPTIONS
-- force shellcheck to be used in zsh files
g.ale_sh_shellcheck_dialect = 'bash' -- https://scriptingosx.com/2019/08/shellcheck-and-zsh/
g.ale_sh_shell_default_shell = 'zsh'
g.ale_linters = { zsh = {'shellcheck', 'shell'} }

-- shell
g.ale_sh_shellcheck_options = '-x'
g.ale_sh_shell_default_exclusions = '' -- rules to be ignored globally

-- markdown
g.ale_markdown_markdownlint_options = "--disable=no-trailing-spaces --disable=single-trailing-newline"

-- js/ts
-- g.ale_javascript_eslint_options = '--quiet' -- ignore warnings

-- css
g.ale_css_stylelint_options = '--quiet'-- ignore warnings

-- lua:
g.ale_linters_ignore = {lua = {'selene'}} -- disable selene since buggy: https://github.com/dense-analysis/ale/issues/4329
g.ale_css_selene_options = ''

--------------------------------------------------------------------------------

-- keybindings
keymap("n", "<leader>f","<Plug>(ale_fix)") -- fix single instance
keymap("n", "<leader>L","<Plug>(ale_lint)") -- line current file

keymap("n", "gl","<Plug>(ale_next_wrap)")
keymap("n", "gL","<Plug>(ale_previous_wrap)")

