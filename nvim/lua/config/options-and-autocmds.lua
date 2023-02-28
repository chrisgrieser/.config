require("config.utils")
--------------------------------------------------------------------------------

-- DIRECTORIES
opt.directory:prepend(VimDataDir .. "swap//")
opt.undodir:prepend(VimDataDir .. "undo//")
opt.viewdir = VimDataDir .. "view"
opt.shadafile = VimDataDir .. "main.shada"

--------------------------------------------------------------------------------
-- Undo
opt.undofile = true -- enable persistent undo history
opt.undolevels = 500 -- less undos saved for quicker loading of undo history

-- extra undopoints (= more fine-grained undos)
-- INFO extra undo points prevent vim abbreviations w/ those characters from working
local undopointChars = { ".", ",", ";", '"' }
for _, char in pairs(undopointChars) do
	keymap("i", char, char .. "<C-g>u", { desc = "extra undopoint for " .. char })
end

-- WARN do not save this file, or codespell will fix all misspellings 🙈
-- INFO using iabbrev instead of luasnip autotriggers for portability
cmd.abclear()
cmd.iabbrev("teh the")
cmd.iabbrev("keybaord keyboard")
cmd.iabbrev("sicne since")
cmd.iabbrev("nto not")
cmd.iabbrev("shwo show")
cmd.iabbrev("retrun return")
cmd.iabbrev("onyl only")

--------------------------------------------------------------------------------

-- GUI
opt.guifont = "JetBrainsMonoNL Nerd Font:h26"
opt.guicursor = {
	"n-sm:block",
	"i-ci-c-ve:ver25",
	"r-cr-o-v:hor10",
	"a:blinkwait200-blinkoff500-blinkon700",
}

-- timeouts
opt.updatetime = 250 -- affects current symbol highlight (treesitter-refactor) and currentline lsp-hints

-- Search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- Quickfix / Locaton List
opt.grepprg = "rg --vimgrep" -- use rg for :grep

-- Popups / Floating Windows
opt.pumheight = 15 -- max number of items in popup menu
opt.pumwidth = 10 -- min width popup menu

-- Spelling
opt.spelllang = "en_us"

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.smartindent = true

-- invisible chars
opt.list = true
opt.listchars = {
	tab = "  ",
	multispace = "·",
	nbsp = "ﮊ",
	lead = "·",
	leadmultispace = "·",
	precedes = "…",
	extends = "…",
}
opt.fillchars = {
	eob = " ", -- no ~ for the eof
	fold = " ", -- no dots for folds
}
opt.showbreak = "↪ " -- precedes wrapped lines

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- For external apps
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = '%{expand("%:p")}'

-- Editor
opt.cursorline = true
opt.scrolloff = 11
opt.sidescrolloff = 13

opt.textwidth = 80
opt.wrap = false
opt.breakindent = false
opt.linebreak = true -- do not break up full words on wrap
opt.signcolumn = "yes:1" -- = gutter
opt.colorcolumn = "+1" -- relative to textwidth

-- status bar & cmdline
opt.history = 400 -- reduce noise for command history search
opt.cmdheight = 0

-- Character groups
vim.opt.iskeyword:append("-") -- don't treat "-" as word boundary, e.g. for kebab-case

opt.nrformats:append("unsigned") -- make <C-a>/<C-x> ignore negative numbers
opt.nrformats:remove { "bin", "hex" } -- remove edge case ambiguity

--------------------------------------------------------------------------------

-- Files & Saving
opt.confirm = true -- ask instead of aborting

augroup("autosave", {})
autocmd({ "BufWinLeave", "BufLeave", "QuitPre", "FocusLost", "InsertLeave" }, {
	group = "autosave",
	pattern = "?*", -- pattern required for some events
	callback = function()
		if not bo.readonly and expand("%") ~= "" and bo.buftype == "" and bo.filetype ~= "gitcommit" then
			cmd.update(expand("%:p"))
		end
	end,
})

-- test
-- emulate autochdir, since the respective option is deprecated
-- augroup("autochdir", {})
-- autocmd("BufWinEnter", {
-- 	group = "autochdir",
-- 	pattern = "?*", -- needed for BufWinEnter to work
-- 	callback = function()
-- 		-- needs to exclude commit filetypes: https://github.com/petertriho/cmp-git/issues/47#issuecomment-1374788422
-- 		local ignoredFT = { "gitcommit", "NeogitCommitMessage", "DiffviewFileHistory", "" }
-- 		if not vim.tbl_contains(ignoredFT, bo.filetype) and (expand("%:p"):find("^/")) then
-- 			cmd.lcd(expand("%:p:h"))
-- 		end
-- 	end,
-- })

-- so autochdir does not interfere with saving of views
opt.viewoptions:remove("curdir")

--------------------------------------------------------------------------------

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
augroup("formatopts", {})
autocmd("FileType", {
	group = "formatopts",
	callback = function()
		if bo.filetype == "markdown" then return end -- not for markdown, for autolist hack (see markdown.lua)
		opt_local.formatoptions:remove("o")
	end,
})

--------------------------------------------------------------------------------
-- FOLDING

-- restrict folding amount for batch-folding commands like zM
opt.foldminlines = 3
opt.foldnestmax = 2

-- if not using UFO for folding
-- opt.foldexpr = "nvim_treesitter#foldexpr()" -- if treesitter folding is used via expr below
-- opt.foldmethod = "expr"
-- opt.foldmethod = "indent"

--------------------------------------------------------------------------------

-- Remember folds and cursor
local function remember(mode)
	local ignoredFts = {
		"DressingInput",
		"DressingSelect",
		"TelescopePrompt",
		"gitcommit",
		"toggleterm",
		"help",
		"qf",
	}
	if vim.tbl_contains(ignoredFts, bo.filetype) or bo.buftype == "nofile" or not bo.modifiable then
		return
	end
	if mode == "save" then
		cmd.mkview(1)
	else
		cmd([[silent! loadview 1]]) -- silent to avoid error for files w/o view (e.g. after creation)
		normal("0^") -- to scroll to the left on start
	end
end
augroup("rememberCursorAndFolds", {})
autocmd("BufWinLeave", {
	group = "rememberCursorAndFolds",
	pattern = "?*", -- pattern required, otherwise does not trigger
	callback = function() remember("save") end,
})
autocmd("BufWinEnter", {
	group = "rememberCursorAndFolds",
	pattern = "?*",
	callback = function() remember("load") end,
})

--------------------------------------------------------------------------------

-- Skeletons (Templates)
-- apply templates for any filetype named `./templates/skeleton.{ft}`
augroup("Templates", {})
local skeletonDir = fn.stdpath("config") .. "/templates"
local filetypeList =
	fn.system([[ls "]] .. skeletonDir .. [[/skeleton."* | xargs basename | cut -d. -f2]])
local ftWithSkeletons = vim.split(filetypeList, "\n", {})

for _, ft in pairs(ftWithSkeletons) do
	if ft == "" then break end
	local readCmd = "keepalt 0r " .. skeletonDir .. "/skeleton." .. ft .. " | normal! G"

	autocmd("BufNewFile", {
		group = "Templates",
		pattern = "*." .. ft,
		command = readCmd,
	})

	-- BufReadPost + empty file as additional condition to also auto-insert
	-- skeletons when empty files were created by other apps
	autocmd("BufReadPost", {
		group = "Templates",
		pattern = "*." .. ft,
		callback = function()
			local curFile = expand("%")
			local fileIsEmpty = fn.getfsize(curFile) < 4 -- to account for linebreak weirdness
			if fileIsEmpty then cmd(readCmd) end
		end,
	})
end

--------------------------------------------------------------------------------

-- syntax highlighting in code blocks
g.markdown_fenced_languages = {
	"css",
	"python",
	"py=python",
	"yaml",
	"yml=yaml",
	"json",
	"lua",
	"javascript",
	"js=javascript",
	"bash",
	"sh=bash",
}
