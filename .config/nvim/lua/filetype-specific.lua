require("utils")

-- close helper windows with q
autocmd( "FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo" },
	command = [[nnoremap <buffer><silent> q :close<CR>]]
})

-- use spaces for YAML and JSON
autocmd( "FileType", {
	pattern = { "yml", "yaml", "json"},
	command = [[
		set tabstop = 2
		set softtabstop = 2
		set shiftwidth = 2
		set expandtab
	]]
})

-- comments for jsonc
autocmd( "FileType", {
	pattern = {"json"},
	command = [[ syntax match Comment +\/\/.\+$+ ]]
})

-----

-- types of hr
g.hrComment = "---"
keymap("n", "=", ":call setline('.', '"..g.hrComment.."')<CR>", {buffer = true, silent = true})

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
	callback = function() g.hrComment = "────────────────────────────────────────────────────────────────────────────────" end
})

autocmd( "FileType", {
	pattern = {"css"},
	callback = function() g.hrComment = "/* ───────────────────────────────────────────────── */\n/* << XXX\n──────────────────────────────────────────────────── */" end
})






