require("utils")
--------------------------------------------------------------------------------

-- General
autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo" },
	command = [[nnoremap <buffer><silent> q :close<CR>]]
})

--------------------------------------------------------------------------------
-- BINDINGS

-- Markdown
keymap("n", "<CR>", 'A') -- So double return keeps markdown list syntax
keymap("n", "<leader>x", 'mz^lllrx`z') -- check markdown tasks
keymap("n", ",1", ":GenTocGFM<CR>") --markdown toc

-- CSS
keymap("n", "<leader>v", '^Ellct;') -- change [v]alue key (also works for JSON, actually)
keymap("n", "<leader>d", 'mzlEF.yEEp`z') -- [d]ouble class under cursor
keymap("n", "<leader>D", 'lF.d/[.\\s]<CR>') -- [D]uplicate Class under cursor
keymap("n", "gS", function() telescope.current_buffer_fuzzy_find{default_text='< ', prompt_prefix='🪧'} end) -- Navigation Markers

-- JS
keymap("n", "<leader>t", 'ysiw}i$<Esc>f}') -- make template string variable, requires vim.surround

--------------------------------------------------------------------------------

-- Build System
g.buildCommand = ""
keymap("n", "<leader>b", function()
	if g.buildCommand == "" then
		print("No build command set.")
	else
		os.execute(g.buildCommand)
	end
end)

autocmd( "FileType", {
	pattern = {"json", "js", "ts"},
	callback = function() g.hrComment = "//──────────────────────────────────────────────────────────────────────────────" end
})

--------------------------------------------------------------------------------

-- Skeletons (Templates)
augroup("Templates", {})
autocmd("BufNewFile", {
	group = "Templates",
	pattern = "*.js",
	command = "0r ~/.config/.nvim/templates/skeleton.js",
})
autocmd("BufNewFile", {
	group = "Templates",
	pattern = "*.applescript",
	command = "0r ~/.config/.nvim/templates/skeleton.applescript",
})
autocmd("BufNewFile", {
	group = "Templates",
	pattern = "*.sh",
	command = "0r ~/.config/nvim/templates/skeleton.sh",
})

--------------------------------------------------------------------------------

-- [H]orizontal Ruler
g.hrComment = ""
keymap("n", "gh", function()
	if g.hrComment == "" then
		print("No hr for this filetype defined.")
	else
		fn.setline('.', g.hrComment)
	end
end)

autocmd( "FileType", {
	pattern = {"json", "js", "ts"},
	callback = function() g.hrComment = "//──────────────────────────────────────────────────────────────────────────────" end
})
autocmd( "FileType", {
	pattern = {"sh", "zsh", "yaml", "yml"},
	callback = function() g.hrComment = "#───────────────────────────────────────────────────────────────────────────────" end
})
autocmd( "FileType", {
	pattern = {"lua", "applescript"},
	callback = function() g.hrComment = "--------------------------------------------------------------------------------" end
})
autocmd( "FileType", {
	pattern = {"md"},
	callback = function() g.hrComment = "---" end
})
autocmd( "FileType", {
	pattern = {"css"},
	callback = function() g.hrComment = "/* ───────────────────────────────────────────────── */\n/* << XXX\n──────────────────────────────────────────────────── */" end
})






