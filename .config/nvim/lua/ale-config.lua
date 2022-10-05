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

keymap("n", "<leader>f","<Plug>(ale_fix)") -- fix single instance
keymap("n", "<leader>L","<Plug>(ale_lint)") -- line current file

keymap("n", "gl","<Plug>(ale_next_wrap)")
keymap("n", "gL","<Plug>(ale_previous_wrap)")

