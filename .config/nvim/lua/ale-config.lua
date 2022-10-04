require("utils")
--------------------------------------------------------------------------------
g.ale_disable_lsp = 1 -- lsp already via coc

g.ale_cursor_detail = 1 -- open popup instead of echoing the linter msg in the cmdline
g.ale_close_preview_on_insert = 1


 keymap("n", "ga","<Plug>(ale_fix)")
 keymap("n", "ga",":ALEFixSuggest<CR>") -- suggest fixers
