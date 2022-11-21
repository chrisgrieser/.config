require("utils")
local warn = vim.log.levels.WARN
local error = vim.log.levels.ERROR
--------------------------------------------------------------------------------
-- META
g.mapleader = ","

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", qol.copyLastCommand)

-- run [l]ast command [a]gain
keymap("n", "<leader>la", qol.runLastCommandAgain)

-- [e]dit [l]ast command
keymap("n", "<leader>le", ":<Up>")

-- search keymaps
keymap("n", "?", telescope.keymaps)

-- Theme Picker
keymap("n", "<leader>T", telescope.colorscheme)

-- Highlights
keymap("n", "<leader>G", telescope.highlights)

-- Update [P]lugins
keymap("n", "<leader>p", function()
	cmd [[nohl]]
	cmd [[update!]]
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	local packer = require("packer")
	packer.startup(require("plugin-list").PluginList)
	packer.snapshot("snapshot_" .. os.date("!%Y-%m-%d_%H-%M-%S"))
	packer.sync()
	cmd [[MasonUpdateAll]]
	-- remove oldest snapshot when more than 20
	local snapshotPath = fn.stdpath("config") .. "/packer-snapshots"
	os.execute([[cd ']] .. snapshotPath .. [[' ; ls -t | tail -n +20 | tr '\n' '\0' | xargs -0 rm]])
end)
keymap("n", "<leader>P", ":PackerStatus<CR>")

-- write all before quitting
keymap("n", "ZZ", ":wqall!<CR>")

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({"n", "x"}, "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap("o", "H", "^")
keymap({"n", "x", "o"}, "L", "$")
keymap({"x", "o"}, "J", "7j")
keymap({"n", "x", "o"}, "K", "7k")

keymap("n", "j", function() qol.overscroll("j") end, {silent = true})
keymap("n", "J", function() qol.overscroll("7j") end, {silent = true})
keymap({"n", "x"}, "G", "Gzz")

-- Sections
keymap("", "[", "{", {nowait = true}) -- slightly easier to press
keymap("", "]", "}", {nowait = true})

-- Jump History
keymap("n", "<C-h>", "<C-o>") -- Back
keymap("n", "<C-l>", "<C-i>") -- Forward
keymap("n", "<C-o>", telescope.jumplist)

-- Hunks
keymap("n", "gh", ":Gitsigns next_hunk<CR>")
keymap("n", "gH", ":Gitsigns prev_hunk<CR>")

-- Leap
keymap("n", "ö", "<Plug>(leap-forward-to)")
keymap("n", "Ö", "<Plug>(leap-backwards-to)")

-- Search
keymap({"n", "x", "o"}, "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("n", "<Esc>", ":lua require('notify').dismiss()<CR>:nohl<CR>:echo<CR>lh", {silent = true}) -- clear highlights & shortmessage, lh clears hover window
keymap({"n", "x", "o"}, "+", "*") -- no more modifier key on German Keyboard

-- URLs
keymap("n", "gü", "/http.*<CR>:nohl<CR>") -- goto next
keymap("n", "gÜ", "?http.*<CR>:nohl<CR>") -- goto prev

-- Marks
keymap("", "m", "`") -- Goto Mark (changing this also requires adapting `dq` and `cq` mappings)
keymap("", "ä", "m") -- Set Mark
keymap("", "<C-m>", ":delmarks a-z<CR><C-e><C-y>") -- clear local marks, scrolling to update marks in scrollbar

-- CLIPBOARD
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')
keymap("n", "gp", qol.pasteDifferently) -- paste charwise reg as linewise & vice versa

-- yanking without moving the cursor
-- visual https://stackoverflow.com/a/3806683#comment10788861_3806683
-- normal https://www.reddit.com/r/vim/comments/ekgy47/comment/fddnfl3/
keymap("x", "y", "ygv<Esc>")
augroup("yankKeepCursor", {})
autocmd({"CursorMoved", "VimEnter"}, {
	group = "yankKeepCursor",
	callback = function() g.cursorPreYankPos = fn.getpos(".") end,
})
autocmd("TextYankPost", {
	group = "yankKeepCursor",
	callback = function()
		if vim.v.event.operator == "y" then
			fn.setpos(".", g.cursorPreYankPos)
		end
	end
})

--------------------------------------------------------------------------------
-- TEXTOBJECTS

keymap("n", "C", '"_C')
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<C-M-Space>", '"_daw') -- wordaround, since <S-Space> not fully supported, requires karabiner remapping it
keymap("x", "<Space>", '"_c')

-- change sub-word
-- (i.e. a simpler version of vim-textobj-variable-segment, not supporting CamelCase)
keymap("n", "<leader><Space>", function()
	opt.iskeyword = opt.iskeyword - {"_", "-"}
	cmd [[normal! "_diw]]
	cmd [[startinsert]] -- :Normal does not allow to end in insert mode
	opt.iskeyword = opt.iskeyword + {"_", "-"}
end)

-- special plugin text objects
keymap({"x", "o"}, "ih", ":Gitsigns select_hunk<CR>", {silent = true})
keymap({"x", "o"}, "ah", ":Gitsigns select_hunk<CR>", {silent = true})

-- map ai to aI in languages where aI is not used anyway
augroup("indentobject", {})
autocmd("BufEnter", {
	group = "indentobject",
	callback = function()
		local ft = bo.filetype
		if not (ft == "yaml" or ft == "python" or ft == "markdown") then
			keymap({"x", "o"}, "ai", "aI", {remap = true, buffer = true})
		end
	end
})

-- treesitter textobjects:
-- af -> a function
-- aC -> a condition
-- q -> comment
-- aa -> an argument

keymap({"o", "x"}, "iq", 'i"') -- double [q]uote
keymap({"o", "x"}, "aq", 'a"')
keymap({"o", "x"}, "iz", "i'") -- single quote (mnemonic: [z]itation)
keymap({"o", "x"}, "az", "a'")
keymap({"o", "x"}, "ir", "i]") -- [r]ectangular brackets
keymap({"o", "x"}, "ar", "a]")
keymap({"o", "x"}, "ic", "i}") -- [c]urly brackets
keymap({"o", "x"}, "ac", "a}")
keymap("o", "r", "}") -- [r]est of the paragraph
keymap("o", "R", "{")

require("nvim-surround").setup {
	aliases = {-- aliases should match the bindings above
		["b"] = ")",
		["c"] = "}",
		["r"] = "]",
		["q"] = '"',
		["z"] = "'",
	},
	move_cursor = false,
	keymaps = {
		visual = "s",
		visual_line = "S",
	},
	surrounds = {
		["f"] = {
			find = function()
				return require("nvim-surround.config").get_selection {motion = "af"}
			end,
			delete = function()
				local ft = bo.filetype
				local patt
				if ft == "lua" then
					patt = "^(.-function.-%b() ?)().-( ?end)()$"
				elseif ft == "js" or ft == "ts" or ft == "bash" or ft == "zsh" then
					patt = "^(.-function.-%b() ?{)().*(})()$"
				else
					vim.notify("No function-surround defined for " .. ft, warn)
					patt = "()()()()"
				end
				return require("nvim-surround.config").get_selections {
					char = "f",
					pattern = patt,
				}
			end,
			add = function()
				local ft = bo.filetype
				if ft == "lua" then
					return {
						{"function ()", "\t"},
						{"", "end"},
					}
				elseif ft == "js" or ft == "ts" or ft == "bash" or ft == "zsh" then
					return {
						{"function () {", "\t"},
						{"", "}"},
					}
				end
				vim.notify("No function-surround defined for " .. ft, warn)
				return {{""}, {""}}
			end,
		},
	}
}

-- fix for ss not working, has to come after nvim-surround's setup
keymap("n", "yss", "ys_", {remap = true})
keymap("n", "dss", "ds_", {remap = true})
keymap("n", "css", "cs_", {remap = true})

--------------------------------------------------------------------------------

-- COMMENTS (mnemonic: [q]uiet text)
require("Comment").setup {
	toggler = {
		line = "qq",
		block = "<Nop>",
	},
	opleader = {
		line = "q",
		block = "<Nop>",
	},
	extra = {
		above = "qO",
		below = "qo",
		eol = "Q",
	},
}

-- effectively creating "q" as comment textobj, can't map directly to q since
-- overlap in visual mode where q can be object and operator. However, this
-- method here also has the advantage of making it possible to preserve cursor
-- position.
-- INFO: Also need to use the remapped "ä", cannot use noremap since "COM" from
-- treesitter textobj is needed 🥴
keymap("n", "dq", "äzdCOM`z", {remap = true}) -- requires remap for treesitter and comments.nvim mappings
keymap("n", "yq", "yCOM", {remap = true}) -- thanks to yank positon saving, doesnt need to be done here
keymap("n", "cq", 'äz"_dCOMxQ', {remap = true}) -- delete & append comment to preserve commentstring

-- TEXTOBJECT FOR ADJACENT COMMENTED LINES
-- = qu for uncommenting
-- big Q also as text object
-- https://github.com/numToStr/Comment.nvim/issues/22#issuecomment-1272569139
local function commented_lines_textobject()
	local U = require("Comment.utils")
	local cl = vim.api.nvim_win_get_cursor(0)[1] -- current line
	local range = {srow = cl, scol = 0, erow = cl, ecol = 0}
	local ctx = {ctype = U.ctype.linewise, range = range}
	local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
	local ll, rr = U.unwrap_cstr(cstr)
	local padding = true
	local is_commented = U.is_commented(ll, rr, padding)
	local line = vim.api.nvim_buf_get_lines(0, cl - 1, cl, false)
	if next(line) == nil or not is_commented(line[1]) then return end
	local rs, re = cl, cl -- range start and end
	repeat
		rs = rs - 1
		line = vim.api.nvim_buf_get_lines(0, rs - 1, rs, false)
	until next(line) == nil or not is_commented(line[1])
	rs = rs + 1
	repeat
		re = re + 1
		line = vim.api.nvim_buf_get_lines(0, re - 1, re, false)
	until next(line) == nil or not is_commented(line[1])
	re = re - 1
	vim.fn.execute("normal! " .. rs .. "GV" .. re .. "G")
end

keymap("o", "u", commented_lines_textobject, {silent = true})
keymap("o", "Q", commented_lines_textobject, {silent = true})

--------------------------------------------------------------------------------

-- MACRO
-- one-off recording (+ q needs remapping due to being mapped to comments)
-- needs temporary remapping, since there is no "recording mode"
g.isRecording = false
augroup("recording", {})
autocmd({"RecordingLeave", "VimEnter"}, {
	group = "recording",
	callback = function()
		keymap("n", "0", "qy") -- not saving in throwaway register z, so the respective keymaps can be used during a macro
		g.isRecording = false -- for status line
		require("lualine").refresh()
	end
})
autocmd("RecordingEnter", {
	group = "recording",
	callback = function()
		keymap("n", "0", "q")
		g.isRecording = true
		require("lualine").refresh()
	end
})
keymap("n", "9", "@y") -- quick replay (don't use counts that high anyway)

-- structured search & replace
keymap({"n", "x"}, "<leader>f", function() require("ssr").open() end) -- wrapped in function for lazy-loading

--------------------------------------------------------------------------------

-- Whitespace Control
keymap("n", "!", "a <Esc>h") -- insert space
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below
keymap("n", "<BS>", function() -- reduce multiple blank lines to exactly one
	if fn.getline(".") == "" then ---@diagnostic disable-line: param-type-mismatch
		cmd [[normal! "_dipO]]
	else
		vim.notify(" Line not empty.", warn) ---@diagnostic disable-line: param-type-mismatch
	end
end)

-- [H]ori[z]ontal Ruler
keymap("n", "zh", qol.hr)

-- Indention
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("x", "<Tab>", ">gv")
keymap("x", "<S-Tab>", "<gv")

keymap({"n", "x"}, "^", "=") -- auto-indent
keymap("n", "^^", "mz=ip`z") -- since indenting paragraph is far more common than indenting a line

--------------------------------------------------------------------------------

-- toggle word between Capital and lower case
keymap("n", "ü", "mzlblgueh~`z")

-- toggle case or switch direction of char (e.g. > to <)
keymap("n", "Ü", qol.reverse)

-- <leader>{char} → Append {char} to end of line
local trailingKeys = {".", ",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}", "|", "/", "\\", "`"}
for _, v in pairs(trailingKeys) do
	keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z")
end
-- Remove last character from line, e.g., a trailing comma
keymap("n", "X", 'mz$"_x`z')

-- Spelling (mnemonic: [z]pe[l]ling)
keymap("n", "zl", telescope.spell_suggest)
keymap("n", "gl", "]s") -- next misspelling
keymap("n", "gL", "[s") -- prev misspelling
keymap("n", "zf", "mz1z=`z") -- auto[f]ix word under cursor (= select 1st suggestion)

-- [S]ubstitute Operator (substitute.nvim)
local substi = require("substitute")
local exchange = require("substitute.exchange")
substi.setup()
keymap("n", "s", substi.operator)
keymap("n", "ss", substi.line)
keymap("n", "S", substi.eol)
keymap("n", "sx", exchange.operator)
keymap("n", "sxx", exchange.line)
keymap("x", "X", exchange.visual)

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", qol.duplicateLine)
keymap("n", "<A-r>", function() qol.duplicateLine {increment = true} end)
keymap("x", "R", qol.duplicateSelection)

-- Undo
keymap({"n", "x"}, "U", "<C-r>") -- redo
keymap("n", "<C-u>", qol.undoDuration)
keymap("n", "<leader>u", ":UndotreeToggle<CR>") -- undo tree
keymap("i", "<C-g>u<Space>", "<Space>") -- extra undo point for every space

-- Logging & Debugging
keymap("n", "<leader>ll", qol.quicklog)
keymap("n", "<leader>lr", qol.removeLog)

-- Sort
keymap({"n", "x"}, "<leader>S", ":sort<CR>")

--------------------------------------------------------------------------------

-- Line & Character Movement
keymap("n", "<Down>", qol.moveLineDown)
keymap("n", "<Up>", qol.moveLineUp)
keymap("x", "<Down>", qol.moveSelectionDown)
keymap("x", "<Up>", qol.moveSelectionUp)
keymap("n", "<Right>", qol.moveCharRight)
keymap("n", "<Left>", qol.moveCharLeft)
keymap("x", "<Right>", qol.moveSelectionRight)
keymap("x", "<Left>", qol.moveSelectionLeft)

-- Merging / Splitting Lines
keymap({"n", "x"}, "M", "J") -- [M]erge line up
keymap({"n", "x"}, "gm", "ddpkJ") -- [m]erge line down

g.splitjoin_split_mapping = "" -- disable default mappings
g.splitjoin_join_mapping = ""
keymap("n", "<leader>s", ":SplitjoinSplit<CR><CR>") -- 2nd <CR> needed for cmdheight=0
keymap("n", "<leader>m", ":SplitjoinJoin<CR><CR>") -- 2nd <CR> needed for cmdheight=0
keymap("n", "|", "a<CR><Esc>k$") -- Split line at cursor

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
keymap("i", "<C-e>", "<Esc>A") -- EoL
keymap("i", "<C-k>", "<Esc>lDi") -- kill line
keymap("i", "<C-a>", "<Esc>I") -- BoL
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-u>", "<C-e><C-u>") -- clear

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("x", "p", "P") -- do not override register when pasting
keymap("x", "P", "p") -- override register when pasting
keymap("x", "V", "j") -- repeatedly pressing "V" selects more lines (indented for Visual Line Mode)
keymap("x", "v", "<C-v>") -- `vv` from normal mode goes to visual block mode

--------------------------------------------------------------------------------
-- WINDOW AND BUFFERS
keymap("", "<C-w>h", ":split #<CR>")
keymap("", "<C-w>v", ":vsplit #<CR>") -- open the alternate file in the split instead of the current file
keymap("", "<C-Right>", ":vertical resize +3<CR>") -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>")
keymap("", "<C-Down>", ":resize +3<CR>")
keymap("", "<C-Up>", ":resize -3<CR>")
keymap("n", "gw", "<C-w><C-w>") -- switch to next split

-- Buffers
keymap("n", "<CR>", ":nohl<CR><C-^>", {silent = true}) -- switch to alt-file
keymap("n", "<C-M-CR>", ":nohl | bnext<CR>", {silent = true}) -- cycle between buffers, <S-CR> supported via karabiner-remapping

--------------------------------------------------------------------------------
-- FILES

-- File switchers
keymap("n", "go", telescope.find_files) -- [o]pen file in parent-directory
keymap("n", "gO", telescope.git_files) -- [o]pen file in git directory
keymap("n", "gr", telescope.oldfiles) -- [r]ecent files
keymap("n", "gb", telescope.buffers) -- open [b]uffer
keymap("n", "gf", telescope.live_grep) -- search in [f]iles
keymap("n", "gR", telescope.resume) -- search in [f]iles

-- File Operations
keymap("", "<C-p>", qol.copyFilepath)
keymap("", "<C-n>", qol.copyFilename)
keymap("", "<leader>x", qol.chmodx)
keymap("", "<C-r>", qol.renameFile)
keymap({"n", "x", "i"}, "<D-n>", qol.createNewFile)
keymap("x", "<leader>X", qol.moveSelectionToNewFile)

-- Git Operations
keymap("n", "<C-g>", function()
	if bo.filetype == "DiffviewFileHistory" then
		cmd("DiffviewClose")
		return
	end
	vim.ui.input({prompt = "Search File History (empty = full history):"}, function(query)
		if not (query) then -- = cancellation
			return
		elseif query == "" then
			cmd("DiffviewFileHistory %")
		else
			cmd("DiffviewFileHistory % -G" .. query)
		end
	end)
end)
keymap("x", "<C-g>", ":DiffviewFileHistory<CR>")

--------------------------------------------------------------------------------

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>")
keymap("n", "<leader>or", ":set relativenumber!<CR>")
keymap("n", "<leader>on", ":set number!<CR>")
keymap("n", "<leader>ow", ":set wrap! <CR>")

--------------------------------------------------------------------------------

-- TERMINAL MODE
keymap("n", "<leader>t", ":10split<CR>:terminal<CR>")
keymap("n", "<leader>g", [[:w<CR>:!acp ""<Left>]]) -- shell function, enabled via .zshenv

--------------------------------------------------------------------------------

-- BUILD SYSTEM
keymap("n", "<leader>r", function()
	cmd [[update!]]
	local filename = fn.expand("%:t")

	if filename == "sketchybarrc" then
		fn.system("brew services restart sketchybar")

	elseif bo.filetype == "markdown" then
		local filepath = fn.expand("%:p")
		local pdfFilename = fn.expand("%:t:r") .. ".pdf"
		fn.system("pandoc '" .. filepath .. "' --output='" .. pdfFilename .. "' --pdf-engine=wkhtmltopdf")
		fn.system("open '" .. pdfFilename .. "'")

	elseif bo.filetype == "lua" then
		local parentFolder = fn.expand("%:p:h")
		if parentFolder:find("nvim") then
			cmd [[write! | source %]]
			if filename:find("plugin%-list") then
				require("packer").compile()
				vim.notify(" Plugins reloaded and re-compiled. ")
			else
				vim.notify(" " .. fn.expand("%") .. " reloaded. ")
			end
		elseif parentFolder:find("hammerspoon") then
			os.execute('open -g "hammerspoon://hs-reload"')
		end

	elseif bo.filetype == "yaml" and fn.getcwd():find(".config/karabiner") then
		os.execute [[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]]

	elseif bo.filetype == "typescript" then
		cmd [[!npm run build]] -- not via fn.system to get the output in the cmdline

	elseif bo.filetype == "applescript" then
		cmd [[AppleScriptRun]]

	else
		vim.notify(" No build system set.", error)

	end
end)

--------------------------------------------------------------------------------

-- q / Esc to close special windows
autocmd("FileType", {
	pattern = specialFiletypes,
	callback = function()
		local opts = {buffer = true, silent = true, nowait = true}
		keymap("n", "<Esc>", ":close<CR>", opts)
		keymap("n", "q", ":close<CR>", opts)
	end
})
