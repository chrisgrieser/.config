require("utils")
--------------------------------------------------------------------------------

-- General
autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo" },
	-- command = [[nnoremap <buffer><silent> q :close<CR>]]
	callback = function ()
		keymap("n", "q", ":close<CR>", {buffer = true, silent = true})
	end
})

--------------------------------------------------------------------------------

-- Markdown
autocmd("FileType", {
	pattern = {"markdown"},
	callback = function ()
		bo.wrap = false
		bo.textwidth = false
		bo.conceallevel = 2
	end
})

--------------------------------------------------------------------------------
-- KEYBINDINGS

-- Markdown
keymap("n", "<CR>", 'A') -- So double return keeps markdown list syntax
keymap("n", "<leader>x", 'mz^lllrx`z') -- check markdown tasks
keymap("n", "<leader>1", ":GenTocGFM<CR>") --markdown toc
keymap("n", "<leader>-", "mzI- <Esc>`z") -- Add bullet point
keymap("n", "<leader>>", "mzI> <Esc>`z") -- Turn into blockquote

-- CSS / JSON / YAML
keymap("n", "<leader>v", '^Ellct;') -- change [v]alue key
keymap("n", "<leader>d", 'mzlEF.yEEp`z') -- [d]ouble class under cursor
keymap("n", "<leader>D", 'lF.d/[.\\s]<CR>') -- [D]uplicate Class under cursor
keymap("n", "gS", function() telescope.current_buffer_fuzzy_find{default_text='< ', prompt_prefix='🪧'} end) -- Navigation Markers

-- JS / TS / Shell
keymap("n", "<leader>t", 'ysiw}i$<Esc>f}') -- make template string variable, requires vim.surround

--------------------------------------------------------------------------------

-- Build Systems
keymap("n", "<leader>b", function()
	if not(b.buildCommand)then
		print("No build command set.")
	else
		os.execute(b.buildCommand)
	end
end)

autocmd( "FileType", {
	pattern = {"yaml"}, -- karabiner config
	callback = function() b.buildCommand = 'osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"' end
})
autocmd( "FileType", {
	pattern = {"lua"}, -- hammerspoon config
	callback = function() b.buildCommand = 'open "hammerspoon://hs-reload"' end
})
autocmd( "FileType", {
	pattern = {"typescript"}, -- typescript build
	callback = function() b.buildCommand = 'npm run build' end
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
keymap("n", "gh", function()
	if b.hrComment then
		print("No hr for this filetype defined.")
	else
		fn.setline('.', b.hrComment)
	end
end)

autocmd( "FileType", {
	pattern = {"json", "javascript", "typescript"},
	callback = function() b.hrComment = "//──────────────────────────────────────────────────────────────────────────────" end
})
autocmd( "FileType", {
	pattern = {"bash", "zsh", "yaml"},
	callback = function() b.hrComment = "#───────────────────────────────────────────────────────────────────────────────" end
})
autocmd( "FileType", {
	pattern = {"lua", "applescript"},
	callback = function() b.hrComment = "--------------------------------------------------------------------------------" end
})
autocmd( "FileType", {
	pattern = {"markdown"},
	callback = function() b.hrComment = "---" end
})
autocmd( "FileType", {
	pattern = {"css"},
	callback = function() b.hrComment = "/* ───────────────────────────────────────────────── */\n/* << XXX\n──────────────────────────────────────────────────── */" end
})






