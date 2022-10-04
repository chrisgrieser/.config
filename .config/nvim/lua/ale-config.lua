require("utils")
--------------------------------------------------------------------------------
-- ALE + COC

g.ale_disable_lsp = 1 -- lsp already via coc

-- INFO: setting for redirecting coc output to ALE in "coc-settings.json"
-- https://github.com/dense-analysis/ale#5iii-how-can-i-use-ale-and-cocnvim-together
--------------------------------------------------------------------------------
g.ale_cursor_detail = 0 -- open popup instead of echoing the linter msg in the cmdline
g.ale_close_preview_on_insert = 1
g.ale_detail_to_floating_preview = 0

g.ale_use_global_executables = 1 -- | can be set to `1` in your vimrc file to make

--------------------------------------------------------------------------------

g.ale_linters = {
	javascript = {"eslint"},
	typescript = {"eslint"},
	css = {"stylelint"},
	markdown = {"markdownlint"},
	python = {'flake8', 'mypy', 'pylint', 'pyright'},
	zsh = {"shellcheck"}
}

--------------------------------------------------------------------------------

keymap("n", "<leader>f","<Plug>(ale_fix)") -- fix single instance
keymap("n", "<leader>L","<Plug>(ale_lint)") -- line current file

keymap("n", "gl","<Plug>(ale_next_wrap)")
keymap("n", "gL","<Plug>(ale_previous_wrap)")

