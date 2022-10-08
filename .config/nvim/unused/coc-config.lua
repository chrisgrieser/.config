require("utils")
--------------------------------------------------------------------------------

-- by default in ~.config, where it gets included in the dotfiles git repo,
-- unecessarily bloating it (badly affecting git sync & dotfiles backups)
g.coc_data_home = "~/.local/share/nvim/coc/"

-- https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#implemented-coc-extensions
g.coc_global_extensions = {
	"coc-css",
	"coc-yaml",
	"coc-tsserver", -- ts and js
	"coc-json",
	"coc-emoji",
	"coc-snippets",
	"coc-sumneko-lua", -- better than coc-lua, since it includes folke/lua-dev.nvim
}

--------------------------------------------------------------------------------

opt.backup = false -- Some servers have issues with backup files, see #649.
opt.writebackup = false
opt.updatetime = 300 -- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
opt.signcolumn = "yes:1"

--------------------------------------------------------------------------------
-- KEYMAPS

-- Navigation
keymap("n", "gd", "<Plug>(coc-definition)", {silent = true})
keymap("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
keymap("n", "gD", "<Plug>(coc-references)", {silent = true})

-- [H]over Info
function _G.show_docs()
	local cw = vim.fn.expand('<cword>') ---@diagnostic disable-line: missing-parameter
	if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
		vim.api.nvim_command('h ' .. cw)
	elseif vim.api.nvim_eval('coc#rpc#ready()') then
		vim.fn.CocActionAsync('doHover')
	else
		vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
	end
end
keymap("n", "<leader>h", function () show_docs() end, {silent = true, nowait = true})

-- Error Navigation & Actions
local opts = {silent = true, nowait = true}
keymap("n", "<leader>f", "<Plug>(coc-fix-current)", opts)
keymap("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
keymap("n", "<leader>a", "<Plug>(coc-codeaction-cursor)", opts)

-- LSP Rename
keymap("n", "<leader>R", "<Plug>(coc-rename)")

--------------------------------------------------------------------------------

-- AUTOCOMPLETION
-- Use tab for trigger completion with characters ahead and navigate.
-- NOTE: There's always complete item selected by default, you may want to enable
-- no select by `"suggest.noselect": true` in your configuration file.
local opts = {silent = true, expr = true, noremap = true, replace_keycodes = false} ---@diagnostic disable-line: redefined-local

function _G.check_back_space()
	local col = vim.fn.col('.') - 1
	return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ---@diagnostic disable-line: undefined-field
end

keymap("i", "<TAB>", [[coc#pum#visible() ? coc#pum#next(1) : "<TAB>"]], opts)
keymap("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
keymap("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "<CR>"]], opts)
keymap("i", "<Esc>", [[coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"]], opts)

-- coc-snippets
g.coc_snippet_next = '<Tab>'

--------------------------------------------------------------------------------

-- for scroll float windows/popups
local opts = {silent = true, nowait = true, expr = true} ---@diagnostic disable-line: redefined-local
keymap("n", "<S-Down>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<S-Down>"', opts)
keymap("n", "<S-Up>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<S-Up>"', opts)
keymap("i", "<S-Down>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keymap("i", "<S-Up>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keymap("v", "<S-Down>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<S-Down>"', opts)
keymap("v", "<S-Up>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<S-Up>"', opts)

--------------------------------------------------------------------------------

-- Autocmds
augroup("CocGroup", {})
autocmd("User", { -- Update signature help on jump placeholder.
	group = "CocGroup",
	pattern = "CocJumpPlaceholder",
	command = "call CocActionAsync('showSignatureHelp')",
	desc = "Update signature help on jump placeholder"
})
autocmd("FileType", { -- Setup formatexpr specified filetype(s).
	group = "CocGroup",
	pattern = "typescript,json",
	command = "setl formatexpr=CocAction('formatSelected')",
	desc = "Setup formatexpr specified filetype(s)."
})
autocmd("CursorHold", { -- Highlight the symbol and its references when holding the cursor.
	group = "CocGroup",
	command = "silent call CocActionAsync('highlight')",
	desc = "Highlight symbol under cursor on CursorHold"
})


