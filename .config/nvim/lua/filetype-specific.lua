require("utils")

-- INFO: Options are mostly set in the after/ftplugins

--------------------------------------------------------------------------------
-- KEYBINDINGS

-- Markdown
keymap("n", "<CR>", 'A') -- So double return keeps markdown list syntax
keymap("n", "<leader>x", 'mz^lllrx`z') -- check markdown tasks
keymap("n", "<leader>1", ":GenTocGFM<CR>") --markdown toc (markdown-toc plugin)
keymap("n", "<leader>-", "mzI- <Esc>`z") -- Add bullet point
keymap("n", "<leader>>", "mzI> <Esc>`z") -- Turn into blockquote

-- CSS / JSON / YAML
keymap("n", "<leader>v", '^Ellct;') -- change [v]alue key

-- CSS
keymap("n", "<leader>d", 'mzlEF.yEEp`z') -- [d]ouble class under cursor
keymap("n", "<leader>D", 'lF.d/[.\\s]<CR>') -- [D]uplicate Class under cursor

-- toggle !important
---@diagnostic disable: undefined-field
keymap("n", "<leader>i", function ()
	local lineContent = fn.getline('.')
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent)
end)

-- JS / TS / Shell
keymap("n", "<leader>t", 'ysiw}i$<Esc>f}') -- make template string variable, requires vim.surround

-- Emmet
autocmd("FileType", {
	pattern = {"css"},
	callback = function ()
		keymap("i", ",,", "<Plug>(emmet-expand-abbr)", {silent = true})
	end
})

-- neovim special windows
autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo", "AppleScriptRunOutput" },
	callback = function ()
		keymap("n", "q", ":close<CR>", {buffer = true, silent = true})
	end
})

-- Emmet
autocmd("FileType", {
	pattern = {"css"},
	callback = function ()
		keymap("i", ",,", "<Plug>(emmet-expand-abbr)", {silent = true})
	end
})

--------------------------------------------------------------------------------

-- Build System
keymap("n", "<leader>r", function()
	cmd[[write]]

	if bo.filetype == "lua" then
		local parentFolder = fn.expand("%:p:h") ---@diagnostic disable-line: missing-parameter
		if not(parentFolder) then return end
		if parentFolder:find("nvim") then
			cmd[[write | source % | echo "Neovim config reloaded."]]
		else
			os.execute('open -g "hammerspoon://hs-reload"')
		end

	elseif bo.filetype == "yaml" then
		os.execute[[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]]

	elseif bo.filetype == "typescript" then
		cmd[[!npm run build]]

	elseif bo.filetype == "applescript" then
		cmd[[:AppleScriptRun]]
	else

		print("No build system set.")
	end
end)

--------------------------------------------------------------------------------

-- Skeletons (Templates)
augroup("Templates", {})
autocmd("BufNewFile", {
	group = "Templates",
	pattern = "*.js",
	command = "0r ~/.config/nvim/templates/skeleton.js",
})
autocmd("BufNewFile", {
	group = "Templates",
	pattern = "*.applescript",
	command = "0r ~/.config/nvim/templates/skeleton.applescript",
})
autocmd("BufNewFile", {
	group = "Templates",
	pattern = "*.sh",
	command = "0r ~/.config/nvim/templates/skeleton.sh",
})

--------------------------------------------------------------------------------

-- [H]orizontal Ruler
keymap("n", "gh", function()
	if not(b.hrComment) then
		print("No hr for this filetype defined.")
	elseif type(b.hrComment) == "table" then
		fn.append('.', b.hrComment) ---@diagnostic disable-line: param-type-mismatch

		local lineNum = api.nvim_win_get_cursor(0)[1] + 2
		local colNum = #b.hrComment[2] + 2
		api.nvim_win_set_cursor(0, {lineNum, colNum})
		cmd[[startinsert]]
	else
		fn.append('.', {b.hrComment, ""})
		cmd[[normal! j]]
	end
end)

augroup("horizontalRuler", {})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"json", "javascript", "typescript"},
	callback = function() b.hrComment = "//──────────────────────────────────────────────────────────────────────────────" end
})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"bash", "zsh", "yaml"},
	callback = function() b.hrComment = "#───────────────────────────────────────────────────────────────────────────────" end
})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"lua", "applescript"},
	callback = function() b.hrComment = "--------------------------------------------------------------------------------" end
})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"markdown"},
	callback = function() b.hrComment = "---" end
})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"css"},
	callback = function() b.hrComment = {
		"/* ───────────────────────────────────────────────── */",
		"/* <<  ",
		"──────────────────────────────────────────────────── */",
		"",
	} end,
})

