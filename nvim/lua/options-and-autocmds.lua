require("utils")
--------------------------------------------------------------------------------

-- DIRECTORIES
opt.directory:prepend(vimDataDir .. "swap//")
opt.undodir:prepend(vimDataDir .. "undo//")
opt.viewdir = vimDataDir .. "view"
opt.shadafile = vimDataDir .. "main.shada"

opt.undofile = true -- enable persistent undo history
--------------------------------------------------------------------------------

-- timeouts
opt.timeoutlen = 1200 -- for awaiting keystrokes when there is no `nowait`
opt.updatetime = 250 -- affects current symbol highlight (treesitter-refactor) and currentline lsp-hints

-- Search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- Popups / Floating Windows
opt.pumheight = 15 -- max number of items in popup menu
opt.pumwidth = 10 -- min width popup menu
opt.winblend = 2 -- % transparency

-- Spelling
opt.spell = false
opt.spelllang = "en_us"

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.smartindent = true
opt.list = true

-- modifying behavior of some keymaps
opt.virtualedit = "block" -- select whitespace for proper rectangles in visual block mode

-- invisible chars
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
	eob = " ", -- no ~ for the eof, no dots for folds
	fold = " ", -- no dots for folds
}
opt.showbreak = "↪ " -- precedes wrapped lines

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Window Managers/espanso: set title
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = "%{expand(\"%:p\")} [%{mode()}]"

-- Editor
opt.cursorline = true
opt.scrolloff = 12
opt.sidescrolloff = 20
opt.textwidth = 80
opt.wrap = false
opt.breakindent = false
opt.linebreak = true -- do not break up full words
opt.colorcolumn = {"+1", "+20"} -- relative to textwidth
opt.signcolumn = "yes:1" -- = gutter
opt.backspace = {"start", "eol"} -- restrict insert mode backspace behavior

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
augroup("formatopts", {})
autocmd("FileType", {
	group = "formatopts",
	callback = function()
		if not (bo.filetype == "markdown") then -- not for markdown, for autolist hack (see markdown.lua)
			bo.formatoptions = bo.formatoptions:gsub("o", "")
		end
	end
})

-- Character groups
opt.iskeyword:append("-") -- don't treat "-" as word boundary, useful e.g. for kebab-case-variables
-- opt.nrformats = "alpha" -- <C-a> and <C-x> also work on letters

--------------------------------------------------------------------------------

-- FILES & SAVING
opt.autochdir = true -- always current directory
opt.confirm = true -- ask instead of aborting

augroup("autosave", {})
autocmd({"BufWinLeave", "QuitPre", "FocusLost", "InsertLeave"}, {
	group = "autosave",
	pattern = "?*",
	callback = function()
		-- safety net to not save file in wrong folder when autochdir is not reliable
		local curFile = fn.expand("%:p")
		cmd.update(curFile)
	end
})

augroup("Mini-Lint", {})
autocmd("BufWritePre", {
	group = "Mini-Lint",
	callback = function()
		local prevCursor = api.nvim_win_get_cursor(0)
		if bo.filetype ~= "markdown" then -- to preserve spaces from the two-space-rule, and trailing spaces on sentences
			cmd [[%s/\s\+$//e]] -- trim trailing whitespaces
		end
		cmd [[silent! %s#\($\n\s*\)\+\%$##]] -- trim extra blanks at eof https://stackoverflow.com/a/7496112
		api.nvim_win_set_cursor(0, prevCursor)
	end
})

--------------------------------------------------------------------------------

-- status bar & cmdline
opt.history = 250 -- reduce noise for command history search
opt.cmdheight = 0

--------------------------------------------------------------------------------
-- FOLDING
local ufo = require("ufo")
local foldIcon = "  "
ufo.setup {
	provider_selector = function(bufnr, filetype, buftype) ---@diagnostic disable-line: unused-local
		return {"treesitter", "indent"} -- Use Treesitter as fold provider
	end,
	open_fold_hl_timeout = 0,
	fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
		-- https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
		local newVirtText = {}
		local suffix = foldIcon .. " " .. tostring(endLnum - lnum)
		local sufWidth = vim.fn.strdisplaywidth(suffix)
		local targetWidth = width - sufWidth
		local curWidth = 0
		for _, chunk in ipairs(virtText) do
			local chunkText = chunk[1]
			local chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if targetWidth > curWidth + chunkWidth then
				table.insert(newVirtText, chunk)
			else
				chunkText = truncate(chunkText, targetWidth - curWidth)
				local hlGroup = chunk[2]
				table.insert(newVirtText, {chunkText, hlGroup})
				chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if curWidth + chunkWidth < targetWidth then
					suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
				end
				break
			end
			curWidth = curWidth + chunkWidth
		end
		table.insert(newVirtText, {suffix, "MoreMsg"})
		return newVirtText
	end,
}

keymap("n", "zR", ufo.openAllFolds) -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
keymap("n", "zM", ufo.closeAllFolds)

-- fold settings required for UFO
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99

-- if not using UFO for folding
-- opt.foldexpr = "nvim_treesitter#foldexpr()" -- if treesitter folding is used via expr below
-- opt.foldmethod = "expr"
-- opt.foldmethod = "indent"
-- opt.foldnestmax = 2
-- opt.foldminlines = 2

--------------------------------------------------------------------------------

-- Remember folds and cursor
augroup("rememberCursorAndFolds", {})
autocmd("BufWinLeave", {
	group = "rememberCursorAndFolds",
	pattern = "?*",
	command = "silent! mkview"
})
autocmd("BufWinEnter", {
	group = "rememberCursorAndFolds",
	pattern = "?*",
	callback = function()
		local ignoredFts = {
			"DressingSelect",
			"cybu",
		}
		if vim.tbl_contains(ignoredFts, bo.filetype) then return end
		cmd [[silent! loadview]]
		cmd.normal {"zH", bang = true} -- zH to also scroll to the left
	end
})

--------------------------------------------------------------------------------

-- Skeletons (Templates)
-- apply templates for any filetype named `./templates/skeleton.{ft}`
augroup("Templates", {})
local skeletionPath = fn.stdpath("config") .. "/templates"
local filetypeList = fn.system([[ls "]] .. skeletionPath .. [[/skeleton."* | xargs basename | cut -d. -f2]])
local ftWithSkeletons = split(filetypeList, "\n")
for _, ft in pairs(ftWithSkeletons) do
	if ft == "" then break end
	local readCmd = "keepalt 0r $HOME/.config/nvim/templates/skeleton." .. ft .. " | normal! G"

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
			local curFile = fn.expand("%")
			local fileIsEmpty = fn.getfsize(curFile) < 4 -- to account for linebreak weirdness
			if fileIsEmpty then cmd(readCmd) end
		end
	})
end
