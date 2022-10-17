require("utils")
-- INFO: Options are mostly set in the after/ftplugins

--------------------------------------------------------------------------------
-- KEYBINDINGS

-- Markdown
keymap("n", "<CR>", 'A') -- So double return keeps markdown list syntax
keymap("n", "<leader>x", 'mz^lllrx`z') -- check markdown tasks
keymap("n", "<leader>-", "mzI- <Esc>`z") -- Add bullet point
keymap("n", "<leader>>", "mzI> <Esc>`z") -- Turn into blockquote

-- CSS / JSON / YAML
keymap("n", "<leader>v", '^Ellct;') -- change [v]alue key

-- CSS
keymap("n", "<leader>c", 'mzlEF.yEEp`z') -- double [c]lass under cursor
keymap("n", "<leader>C", 'lF.d/[.\\s]<CR>:nohl<CR>') -- delete class under cursor

-- toggle !important
keymap("n", "<leader>i", function ()
	---@diagnostic disable: undefined-field, param-type-mismatch
	local lineContent = fn.getline('.')
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent)
	---@diagnostic enable: undefined-field, param-type-mismatch
end)

-- Emmet
autocmd("FileType", {
	pattern = {"css"},
	callback = function ()
		keymap("i", ",,", "<Plug>(emmet-expand-abbr)", {silent = true})
	end
})

-- neovim special windows
autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo", "AppleScriptRunOutput", "Outline" },
	callback = function ()
		keymap("n", "q", ":close<CR>", {buffer = true, silent = true, nowait = true})
	end
})

--------------------------------------------------------------------------------

-- Build System
keymap("n", "<leader>r", function()
	cmd[[write]]

	local filename = fn.expand("%:t") ---@diagnostic disable-line: missing-parameter
	if filename == "sketchybarrc" then
		fn.system("brew services restart sketchybar")

	elseif bo.filetype == "lua" then
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
autocmd("BufNewFile", {
	group = "Templates",
	pattern = "*.lua",
	command = "0r ~/.config/nvim/templates/skeleton.lua",
})

--------------------------------------------------------------------------------

-- [H]orizontal Ruler
keymap("n", "gh", function()
	if not(b.hrComment) then
		print("No hr for this filetype defined.")
	elseif bo.filetype == "css" then
		fn.append('.', b.hrComment) ---@diagnostic disable-line: param-type-mismatch

		local lineNum = api.nvim_win_get_cursor(0)[1] + 2
		local colNum = #b.hrComment[2] + 2
		api.nvim_win_set_cursor(0, {lineNum, colNum})
		cmd[[startinsert]]
	else
		fn.append('.', {b.hrComment, ""}) ---@diagnostic disable-line: param-type-mismatch
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
	pattern = {"bash", "zsh", "sh", "yaml"},
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
		"/* << ",
		"──────────────────────────────────────────────────── */",
		"",
		"",
	} end,
})

