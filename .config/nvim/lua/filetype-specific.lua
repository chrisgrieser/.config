require("utils")
--------------------------------------------------------------------------------

-- General
autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo" },
	command = [[nnoremap <buffer><silent> q :close<CR>]]
})

--------------------------------------------------------------------------------

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






