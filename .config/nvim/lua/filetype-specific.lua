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

