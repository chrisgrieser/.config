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
-- INFO extra undo points prevent vim abbreviations w/ those characters from
-- working, so space should not be added here
local undopointChars = { ".", ",", ";", '"' }
for _, char in pairs(undopointChars) do
	keymap("i", char, char .. "<C-g>u", { desc = "extra undopoint for " .. char })
end

--------------------------------------------------------------------------------

-- GUI
opt.guifont = "JetBrainsMonoNL Nerd Font:h26" -- https://www.programmingfonts.org/#oxygen
opt.guicursor = {
	"n-sm:block",
	"i-ci-c-ve:ver25",
	"r-cr-o-v:hor10",
	"a:blinkwait200-blinkoff500-blinkon700",
}

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
opt.spell = false -- off, since using vale+null-ls for the lsp-integration
opt.spelllang = "en_us" -- but used for spellsuggestions

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

-- column for `gm`
local gmColumn = math.floor(fn.winwidth("%") / 2) ---@diagnostic disable-line: param-type-mismatch
opt.colorcolumn = { "+1", gmColumn } -- relative to textwidth

-- status bar & cmdline
opt.history = 400 -- reduce noise for command history search
opt.cmdheight = 0

-- Character groups
vim.opt.iskeyword:append("-") -- don't treat "-" as word boundary, e.g. for kebab-case

opt.nrformats:append("unsigned") -- make <C-a>/<C-x> ignore negative numbers
opt.nrformats:remove { "bin", "hex" } -- remove edge case ambiguity

-- Timeouts
opt.updatetime = 250 -- also affects current symbol highlight (treesitter-refactor) and currentline lsp-hints

--------------------------------------------------------------------------------

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.smartindent = true

-- invisible chars
opt.list = true
opt.listchars = {
	tab = "  ", -- needs two chars
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

-- to be used with an indent-detection plugin, so the listchars are also changed
-- accordingly
autocmd("BufReadPost", {
	callback = function()
		local usesSpaces = bo.expandtab
		if usesSpaces then
			opt_local.listchars = {
				tab = " >",
				multispace = "·",
			}
		else
			opt_local.listchars = {
				tab = "  ",
				multispace = "·",
				leadmultispace = "·",
				lead = "·",
			}
		end
	end,
})

--------------------------------------------------------------------------------
-- Auto-Saving & Auto-read on change
autocmd({ "BufWinLeave", "BufLeave", "QuitPre", "FocusLost", "InsertLeave" }, {
	pattern = "?*", -- pattern required for some events
	callback = function()
		if not bo.readonly and expand("%") ~= "" and bo.buftype == "" and bo.filetype ~= "gitcommit" then
			cmd.update(expand("%:p"))
		end
	end,
})

-- Auto-read on external change. Requires `checktime` to actually check for it
opt.autoread = true

--------------------------------------------------------------------------------

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's
-- overwritten by the ftplugins having the `o` option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
autocmd("FileType", {
	callback = function() opt_local.formatoptions:remove("o") end,
})

--------------------------------------------------------------------------------
-- FOLDING

-- fold settings required for UFO
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldminlines = 1 -- restrict folding amount for batch-folding commands like zM
-- opt.foldmethod = "indent" -- if not using UFO for folding

--------------------------------------------------------------------------------

-- Remember folds and cursor
local function remember(mode)
	local ignoredFts = {
		"DressingInput",
		"DressingSelect",
		"TelescopePrompt",
		"gitcommit",
		"toggleterm",
		"harpoon",
		"help",
		"qf",
	}
	if vim.tbl_contains(ignoredFts, bo.filetype) or bo.buftype ~= "" or not bo.modifiable then
		return
	end
	if mode == "save" then
		cmd.mkview(1)
	else
		cmd([[silent! loadview 1]]) -- silent to avoid error for files w/o view (e.g. after creation)
	end
end
autocmd("BufWinLeave", {
	pattern = "?*", -- pattern required, otherwise does not trigger
	callback = function() remember("save") end,
})
autocmd("BufWinEnter", {
	pattern = "?*",
	callback = function() remember("load") end,
})

--------------------------------------------------------------------------------
-- DIAGNOSTICS

local function diagnosticFormat(diagnostic, mode)
	local msg = diagnostic.message:gsub("^%s*", ""):gsub("%s*$", "")
	local source = diagnostic.source and diagnostic.source:gsub("%.$", "") or ""
	local code = tostring(diagnostic.code)

	-- stylelint and already includes the code in the message, codespell has no code
	local out
	if source == "stylelint" or source == "codespell" then
		out = msg
	else
		out = msg .. " (" .. code .. ")"
	end

	-- append source to float
	if diagnostic.source and mode == "float" then out = out .. " [" .. source .. "]" end

	return out
end

vim.diagnostic.config {
	virtual_text = {
		format = function(diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
		severity = { min = vim.diagnostic.severity.WARN },
	},
	float = {
		focusable = true,
		border = BorderStyle,
		max_width = 60,
		header = "", -- remove "Diagnostics:" heading
		format = function(diagnostic) return diagnosticFormat(diagnostic, "float") end,
	},
}

--------------------------------------------------------------------------------

-- Skeletons (Templates)
-- apply templates for any filetype named `./templates/skeleton.{ft}`
local skeletonDir = fn.stdpath("config") .. "/templates"
local filetypeList =
	fn.system([[ls "]] .. skeletonDir .. [[/skeleton."* | xargs basename | cut -d. -f2]])
local ftWithSkeletons = vim.split(filetypeList, "\n", {})

for _, ft in pairs(ftWithSkeletons) do
	if ft == "" then break end
	local readCmd = "keepalt 0r " .. skeletonDir .. "/skeleton." .. ft .. " | normal! G"

	autocmd("BufNewFile", {
		pattern = "*." .. ft,
		command = readCmd,
	})

	-- BufReadPost + empty file as additional condition to also auto-insert
	-- skeletons when empty files were created by other apps
	autocmd("BufReadPost", {
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
	"json",
	"lua",
	"javascript",
	"js=javascript",
	"bash",
	"sh=bash",
}
