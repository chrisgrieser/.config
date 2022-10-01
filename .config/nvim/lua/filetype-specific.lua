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
		set tabstop 2
		set softtabstop 2
		set shiftwidth 2
		set expandtab
	]]
})

--------------------------------------------------------------------------------

-- inserts an [h]r approriate for the filetype
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






