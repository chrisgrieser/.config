local u = require("config.utils")
local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1).source:sub(2)
local desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile)
keymap("n", "<D-,>", function() vim.cmd.edit(pathOfThisFile) end, { desc = desc })

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance
-- (not mapping in op-pending, since there are custom textobjects for each LjkJK)
keymap({ "n", "x" }, "H", "0^") -- scroll fully to the left
keymap("o", "H", "^")
keymap({ "n", "x" }, "L", "$zv") -- zv: unfold
keymap({ "n", "x" }, "j", "gj") -- gj to work with wrapped lines as well
keymap({ "n", "x" }, "k", "gk")
keymap({ "n", "x" }, "J", "6gj")
keymap({ "n", "x" }, "K", "6gk")

-- repeat f/t
keymap({ "n", "x" }, "ö", ";")
keymap({ "n", "x" }, "Ö", ",")

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = "Search IN sel" })

-- Diagnostics
keymap("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next Diagnostic" })
keymap("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous Diagnostic" })

-- quickfix
keymap("n", "gq", vim.cmd.cnext, { desc = " Next Quickfix" })
keymap("n", "g1", vim.cmd.cfirst, { desc = " First Quickfix" })
keymap("n", "gQ", vim.cmd.cprevious, { desc = " Prev Quickfix" })
keymap("n", "dQ", function() vim.cmd.cexpr("[]") end, { desc = " Clear Quickfix" })

--------------------------------------------------------------------------------
-- EDITING

-- Undo time, not changes https://vim.fandom.com/wiki/Using_undo_branches
-- (using `earlier 1` instead of `g+` to silence the keymap)
keymap("n", "u", "<cmd>silent earlier 1<CR>zv")
keymap("n", "U", "<cmd>silent later 1<CR>zv")

-- emulate some basic commands from `vim-abolish`
keymap("n", "crt", "mzguiwgUl`z", { desc = "󰬴 Titlecase" })
keymap("n", "cru", "mzgUiw`z", { desc = "󰬴 lowercase" })
keymap("n", "crl", "mzguiw`z", { desc = "󰬴 UPPERCASE" })

keymap("n", "~", '<cmd>lua require("funcs.nano-plugins").betterTilde()<CR>', { desc = "better ~" })

-- Delete trailing character
keymap("n", "X", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub("%s+$", ""):sub(1, -2)
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = "󱎘 Delete char at EoL" })

-- WHITESPACE & INDENTATION
keymap("n", "=", "mzO<Esc>`z", { desc = "  blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "  blank below" })

keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent selection" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent selection" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent line" })
keymap("i", "<Tab>", "<C-t>", { desc = "󰉵 indent line" })

keymap("n", "<Tab>", function()
	if vim.snippet.active { direction = 1 } then
		vim.snippet.jump(1)
	else
		u.normal(">>")
	end
end, { desc = "󰉶 indent / next placeholder" })
keymap("n", "<S-Tab>", function()
	if vim.snippet.active { direction = -1 } then
		vim.snippet.jump(-1)
	else
		u.normal("<<")
	end
end, { desc = "󰉵 outdent line / prev placeholder" })

-- Close all top-level folds
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = "󰘖 Close toplevel folds" })

-- [O]pen new scope / brace
-- (`remap` needed to trigger auto-pairing plugin)
keymap("n", "<D-o>", "a{<CR>", { desc = " Open new scope", remap = true })
keymap("i", "<D-o>", "{<CR>", { desc = " Open new scope", remap = true })

-- Spelling (works even with `spell=false`)
keymap("n", "z.", "1z=", { desc = "󰓆 Fix Spelling" })

-- Merging
keymap({ "n", "x" }, "M", "J", { desc = "󰗈 Merge up" })
keymap({ "n", "x" }, "gm", '"zdd"zpkJ', { desc = "󰗈 Merge down" })

-- Increment/Decrement, or toggle true/false
keymap(
	{ "n", "x" },
	"+",
	function() return require("funcs.nano-plugins").toggleOrIncrement() end,
	{ desc = " Increment/Toggle", expr = true }
)
keymap({ "n", "x" }, "ü", "<C-x>", { desc = " Decrement" })

-- cmd+E: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = " Inline Code" }) -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline Code" })
keymap("i", "<D-e>", "``<Left>", { desc = " Inline Code" })

-- regex
keymap(
	"n",
	"g/",
	function() require("funcs.nano-plugins").openAtRegex101() end,
	{ desc = " Open in regex101" }
)

--------------------------------------------------------------------------------
-- TEXTOBJECTS

-- remapping of builtin text objects to use letters instead of punctuation
for remap, original in pairs(u.textobjRemaps) do
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = "󱡔 inner " .. original })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = "󱡔 outer " .. original })
end

-- special remaps
keymap("o", "J", "2j") -- dd = 1 line, dj = 2 lines, dJ = 3 lines
keymap("n", "<Space>", '"_ciw', { desc = "󱡔 change word" })
keymap("n", "<S-Space>", '"_daw', { desc = "󱡔 delete word" })

--------------------------------------------------------------------------------
-- COMMENTS

-- needs `remap = true`, as those are nvim-keymaps (not vim-keymaps)
keymap("n", "qq", "gcc", { desc = " Comment Line", remap = true })
keymap("o", "u", "gc", { desc = " Comment Text Object", remap = true })
keymap(
	{ "n", "x" },
	"q",
	-- HACK https://www.reddit.com/r/neovim/comments/1ctc1zd/comment/l4c29rx/
	function() return require("vim._comment").operator() end,
	{ desc = " Comment Operator", expr = true }
)

-- stylua: ignore start
keymap("n", "qw", function() require("funcs.comment").commentHr() end, { desc = " Horizontal Divider" })
keymap("n", "wq", function() require("funcs.comment").duplicateLineAsComment() end, { desc = " Duplicate Line as Comment" })
keymap("n", "qf", function() require("funcs.comment").docstring() end, { desc = " Function Docstring" })
keymap("n", "Q", function() require("funcs.comment").addComment("eol") end, { desc = " Append Comment" })
keymap("n", "qo", function() require("funcs.comment").addComment("below") end, { desc = " Comment Below" })
keymap("n", "qO", function() require("funcs.comment").addComment("above") end, { desc = " Comment Above" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT

keymap("n", "<Down>", [[<cmd>. move +1<CR>==]], { desc = "󰜮 Move line down" })
keymap("n", "<Up>", [[<cmd>. move -2<CR>==]], { desc = "󰜷 Move line up" })
keymap("n", "<Right>", [["zx"zp]], { desc = "➡️ Move char right" })
keymap("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move char left" })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move selection down", silent = true })
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move selection up", silent = true })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<left>", [["zxhh"zpgvhoho]], { desc = "⬅ Move selection left" })

--------------------------------------------------------------------------------
-- COMMAND MODE
keymap("c", "<C-u>", "<C-e><C-u>") -- kill whole line
keymap("c", "<D-v>", "<C-r>+", { desc = " Paste" })
keymap("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { desc = "<BS> does not leave cmdline", expr = true })

-- INSERT MODE
keymap({ "i", "c" }, "<C-a>", "<Home>")
keymap({ "i", "c" }, "<C-e>", "<End>")
keymap("n", "i", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return [["_cc]] end
	return "i"
end, { desc = "correctly indented i", expr = true })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts Visual Block" })

--------------------------------------------------------------------------------
-- WINDOWS
keymap({ "n", "x", "i" }, "<C-CR>", "<C-w>w", { desc = " Next Window" })
keymap({ "n", "x" }, "<C-v>", "<cmd>vertical leftabove split<CR>", { desc = " Vertical Split" })
keymap({ "n", "x" }, "<C-s>", "<cmd>horizontal split<CR>", { desc = " Horizontal Split" })

local delta = 5
keymap("n", "<C-up>", "<C-w>" .. delta .. "-")
keymap("n", "<C-down>", "<C-w>" .. delta .. "+")
keymap("n", "<C-left>", "<C-w>" .. delta .. "<")
keymap("n", "<C-right>", "<C-w>" .. delta .. ">")

-- BUFFERS & FILES
keymap("n", "<D-r>", vim.cmd.edit, { desc = "󰽙 Reload Buffer" })
keymap(
	"n",
	"<BS>",
	function() require("funcs.buf-nav").bufferByLastUsed("prev") end,
	{ desc = "󰽙 Prev Buffer" }
)
keymap(
	"n",
	"<S-BS>",
	function() require("funcs.buf-nav").bufferByLastUsed("next") end,
	{ desc = "󰽙 Next Buffer" }
)
keymap(
	{ "n", "x" },
	"<CR>",
	function() require("funcs.buf-nav").gotoAltBuffer() end,
	{ desc = "󰽙 Alt Buffer" }
)

keymap(
	{ "n", "x" },
	"<D-CR>",
	function() require("funcs.git-jumper").gotoChangedFiles() end,
	{ desc = "󰊢 Goto Changed File" }
)

keymap(
	{ "n", "x" },
	"g<CR>",
	function() require("funcs.git-jumper").gotoLastCommittedChangeInFile() end,
	{ desc = "󰊢 Goto last committed change in file" }
)

keymap({ "n", "x", "i" }, "<D-w>", function()
	vim.cmd.update { mods = { silent = true } }
	local winClosed = pcall(vim.cmd.close)
	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	if not winClosed and moreThanOneBuffer then pcall(vim.cmd.bdelete) end
end, { desc = "󰽙 :close / :bdelete" })

keymap({ "n", "x", "i" }, "<D-N>", function()
	vim.ui.input({ prompt = "Scratch File Extension" }, function(ext)
		if not ext then return end
		local filepath = vim.fs.normalize("~/Desktop/scratch." .. ext)
		vim.cmd.edit(filepath)
		vim.cmd.write(filepath)
	end)
end, { desc = "󰽙 Scratch File on Desktop" })

-- mac-specific
keymap(
	{ "n", "x" },
	"<D-l>",
	function() vim.system { "open", "-R", vim.api.nvim_buf_get_name(0) } end,
	{ desc = "󰀶 Reveal in Finder" }
)

keymap(
	{ "n", "x" },
	"<D-L>",
	function() require("funcs.nano-plugins").openAlfredPref() end,
	{ desc = "󰮤 Reveal in Alfred" }
)

--------------------------------------------------------------------------------
-- MULTI-CURSOR REPLACEMENT

keymap("n", "<D-j>", '*N"_cgn', { desc = "󰆿 Multi-Edit" })
-- `remap` because it requires nvim's visual star
keymap("x", "<D-j>", '*N"_cgn', { desc = "󰆿 Multi-Edit", remap = true })

--------------------------------------------------------------------------------
-- MACROS
-- 1. start/stop with just one keypress
-- 2. add notification & sound for recording
local register = "r"
local toggleKey = "0"
keymap("n", toggleKey, function()
	local notRecording = vim.fn.reg_recording() == ""
	if notRecording then
		u.normal("q" .. register)
	else
		u.normal("q")
		local macro = vim.fn.getreg(register):sub(1, -(#toggleKey + 1)) -- as the key itself is recorded
		if macro == "" then return end
		vim.fn.setreg(register, macro)
		u.notify("Recorded", vim.fn.keytrans(macro), "trace")
	end
	local sound = "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/"
		.. (notRecording and "begin_record.caf" or "end_record.caf")
	vim.system { "afplay", sound } -- macOS only
end, { desc = "󰕧 Start/Stop Recording" })

vim.fn.setreg(register, "") -- start with empty register
keymap("n", "9", "@" .. register, { desc = "󰕧 Play Recording" })

--------------------------------------------------------------------------------
-- CLIPBOARD

-- sticky yank operations
local mark = "z" -- where to store cursor position
keymap({ "n", "x" }, "y", "m" .. mark .. "y", { desc = "󰅍 Sticky Yank" })
keymap("n", "Y", "m" .. mark .. "y$", { desc = "󰅍 Sticky Yank", unique = false })

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		-- `z` is used as temporary register for keymaps, thus needs to be ignored
		if vim.v.event.operator == "y" and vim.v.event.regname ~= "z" then
			local preYank = vim.api.nvim_buf_get_mark(0, mark)
			vim.api.nvim_win_set_cursor(0, preYank)
		end
	end,
})

-- keep the register clean
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P") -- paste without switching with register

keymap("n", "dd", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return '"_dd' end
	return "dd"
end, { expr = true, desc = "dd" })

keymap("i", "<D-v>", function()
	local regContent = vim.trim(vim.fn.getreg("+"))
	vim.fn.setreg("+", regContent, "v")
	return "<C-g>u<C-r><C-o>+" -- "<C-g>u" adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

--------------------------------------------------------------------------------
-- QUITTING
keymap({ "n", "x" }, "<MiddleMouse>", vim.cmd.wqall, { desc = ":wqall" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help", "checkhealth" },
	callback = function()
		vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, nowait = true, desc = "Close" })
	end,
})

--------------------------------------------------------------------------------


