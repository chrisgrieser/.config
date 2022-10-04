require("utils")
--------------------------------------------------------------------------------
g.ale_disable_lsp = 1 -- lsp already via coc

g.ale_cursor_detail = 1 -- open popup instead of echoing the linter msg in the cmdline
g.ale_close_preview_on_insert = 1
g.ale_detail_to_floating_preview = 1

g.ale_use_global_executables = 1 -- | can be set to `1` in your vimrc file to make

--------------------------------------------------------------------------------

g.ale_linters = {
	javascript = {"eslint"},
	typescript = {"eslint"},
	css = {"stylelint"},
	markdown = {"markdownlint"},
	python = {"markdownlint"},
	zsh = {"shellcheck"}
}

--------------------------------------------------------------------------------

keymap("n", "<leader>f","<Plug>(ale_fix)") -- fix single instance
keymap("n", "<leader>L","<Plug>(ale_lint)") -- line current file

keymap("n", "gl","<Plug>(ale_next_wrap)")
keymap("n", "gL","<Plug>(ale_previous_wrap)")
