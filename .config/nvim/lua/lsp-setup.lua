require("utils")
--------------------------------------------------------------------------------

g.coc_global_extensions = {
	"coc-lua"
}

--------------------------------------------------------------------------------

opt.backup = false -- Some servers have issues with backup files, see #649.
opt.writebackup = false
opt.updatetime = 300 -- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
opt.signcolumn = "auto:1" -- hide signcolumn when no issue

local keyset = vim.keymap.set

-- Auto complete
function _G.check_back_space()
	local col = vim.fn.col('.') - 1
	return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

--------------------------------------------------------------------------------
-- KEYMAPS

-- Navigation
keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
keyset("n", "gD", "<Plug>(coc-references)", {silent = true})

-- [H]over Info
function _G.show_docs()
	local cw = vim.fn.expand('<cword>')
	if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
		vim.api.nvim_command('h ' .. cw)
	elseif vim.api.nvim_eval('coc#rpc#ready()') then
		vim.fn.CocActionAsync('doHover')
	else
		vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
	end
end
keyset("n", "<leader>h", '<CMD>lua _G.show_docs()<CR>', {silent = true})

-- Error Navigation & Actions
local opts = {silent = true, nowait = true}
keyset("n", "<leader>f", "<Plug>(coc-fix-current)", {silent = true, nowait = true})
keyset("n", "ge", "<Plug>(coc-diagnostic-next)", {silent = true, nowait = true})
keyset("n", "gE", "<Plug>(coc-diagnostic-prev)", {silent = true, nowait = true})
-- Applying codeAction to the selected region. Example: `<leader>aap` for current paragraph
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

--------------------------------------------------------------------------------

-- PASSIVE AUTOCOMPLETION
-- Use tab for trigger completion with characters ahead and navigate.
-- NOTE: There's always complete item selected by default, you may want to enable
-- no select by `"suggest.noselect": true` in your configuration file.
local opts = {silent = true, noremap = true, expr = true}
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice.
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

--------------------------------------------------------------------------------

-- PASSIVE IMPROVEMENTS

-- Update signature help on jump placeholder.
vim.api.nvim_create_autocmd("User", {
	group = "CocGroup",
	pattern = "CocJumpPlaceholder",
	command = "call CocActionAsync('showSignatureHelp')",
	desc = "Update signature help on jump placeholder"
})

-- Setup formatexpr specified filetype(s).
vim.api.nvim_create_autocmd("FileType", {
	group = "CocGroup",
	pattern = "typescript,json",
	command = "setl formatexpr=CocAction('formatSelected')",
	desc = "Setup formatexpr specified filetype(s)."
})


-- Highlight the symbol and its references when holding the cursor.
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
	group = "CocGroup",
	command = "silent call CocActionAsync('highlight')",
	desc = "Highlight symbol under cursor on CursorHold"
})


