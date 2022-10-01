require("utils")
--------------------------------------------------------------------------------

-- General
autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo" },
	command = [[nnoremap <buffer><silent> q :close<CR>]]
})

--------------------------------------------------------------------------------

-- Markdown
autocmd("FileType", {
	pattern = {"md"},
	command = [[set wrap<CR>]]
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
g.buildCommand = ""
keymap("n", "<leader>b", function()
	if g.buildCommand == "" then
		print("No build command set.")
	else
		os.execute(g.buildCommand)
	end
end)

autocmd( "FileType", {
	pattern = {"yaml"}, -- karabiner config
	callback = function() g.buildCommand = 'osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"' end
})
autocmd( "FileType", {
	pattern = {"lua"}, -- hammerspoon config
	callback = function() g.buildCommand = 'open "hammerspoon://hs-reload"' end
})
autocmd( "FileType", {
	pattern = {"ts"}, -- typescript build
	callback = function() g.buildCommand = 'npm run build' end
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






