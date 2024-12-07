local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1, "S").source:sub(2)
local desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile)
keymap("n", "<D-,>", function() vim.cmd.edit(pathOfThisFile) end, { desc = desc })

-- `cmd-q` remapped to `ZZ` via Karabiner, PENDING https://github.com/neovide/neovide/issues/2558
keymap("n", "ZZ", function() vim.cmd.wqall { bang = true } end, { desc = " Quit" })

keymap(
	"n",
	"<leader>pd",
	function() vim.ui.open(vim.fn.stdpath("data")) end, ---@diagnostic disable-line: param-type-mismatch
	{ desc = "󰝰 Plugin directory" }
)

keymap(
	"n",
	"<leader>pv",
	function() vim.ui.open(vim.o.viewdir) end,
	{ desc = "󰝰 View directory" }
)

--------------------------------------------------------------------------------
-- NAVIGATION

-- j/k should on wrapped lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- HJKL behaves like hjkl, but bigger distance
-- (not mapping in op-pending, since using custom textobjects for most of those)
keymap({ "n", "x" }, "H", "0^", { desc = "󰲠 char" }) -- scroll fully to the left
keymap("o", "H", "^", { desc = "󰲠 char" })
keymap({ "n", "x" }, "L", "$zv", { desc = " char" }) -- zv: unfold under cursor
keymap({ "n", "x" }, "J", "6gj", { desc = "6j" })
keymap({ "n", "x" }, "K", "6gk", { desc = "6k" })

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = " Search IN sel" })

-- Goto matching parenthesis (`remap` needed to use builtin `MatchIt` plugin)
keymap("n", "gm", "%", { desc = "Goto Match", remap = true })

-- Diagnostics
keymap("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next diagnostic" })
keymap("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous diagnostic" })

-- Close all top-level folds
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = "󰘖 Close toplevel folds" })

keymap("n", "<D-U>", function()
	local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local url = text:match("%l%l%l-://[^%s)]+")
	if url then
		vim.ui.open(url)
	else
		vim.notify("No URL found in file.", vim.log.levels.WARN)
	end
end, { desc = " Open first URL in file" })

--------------------------------------------------------------------------------
-- EDITING

-- Undo
keymap("n", "u", "<cmd>silent undo<CR>zv", { desc = "silent u" })
keymap("n", "U", "<C-r>")
keymap(
	"n",
	"<leader>ur",
	function() vim.cmd.later(vim.o.undolevels) end,
	{ desc = "󰛒 Redo all" }
)
keymap("n", "<leader>uu", function()
	vim.ui.input({ prompt = "󰜊 Undo to: " }, function(input)
		if not input or input == "" then return end
		vim.cmd.earlier(input)
	end)
end, { desc = "󰜊 Undo to earlier" })

-- Duplicate
keymap(
	"n",
	"ww",
	function() require("personal-plugins.misc").smartLineDuplicate() end,
	{ desc = "󰲢 Duplicate line" }
)

-- Toggles
keymap("n", "~", "v~", { desc = "󰬴 Toggle char case (w/o moving)" })
keymap(
	"n",
	"<",
	function() require("personal-plugins.misc").toggleLowercaseTitleCase() end,
	{ desc = "󰬴 Toggle lower/Title case" }
)
keymap("n", ">", "gUiw", { desc = "󰬴 Toggle UPPER case" })

-- Increment/Decrement, or toggle true/false
keymap(
	{ "n", "x" },
	"+",
	function() return require("personal-plugins.misc").toggleOrIncrement() end,
	{ desc = "󰐖 Increment/toggle", expr = true }
)
keymap({ "n", "x" }, "ü", "<C-x>", { desc = "󰍵 Decrement" })

-- Delete trailing character
keymap("n", "X", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub("%S%s*$", "")
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = "󱎘 Delete char at EoL" })

-- Append to EoL
local trailChars = { ",", "\\", "{", ")", ";", "." }
for _, key in pairs(trailChars) do
	local pad = key == "\\" and " " or ""
	keymap("n", "<leader>" .. key, ("mzA%s%s<Esc>`z"):format(pad, key))
end

-- WHITESPACE & INDENTATION
keymap("n", "=", "mzO<Esc>`z", { desc = " Blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = " Blank below" })

keymap("n", "<Tab>", ">>", { desc = "󰉶 indent" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
keymap("i", "<Tab>", "<C-t>", { desc = "󰉶 indent" })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent" })

-- Spelling (works even with `spell=false`)
keymap("n", "z.", "1z=", { desc = "󰓆 Fix spelling" })

-- Merging
keymap("n", "m", "J", { desc = "󰽜 Merge line up" })
keymap("n", "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down" }) -- `:move` preserves marks

--------------------------------------------------------------------------------
-- SURROUND & ARROW

keymap("n", '"', 'bi"<Esc>ea"<Esc>', { desc = ' " Surround cword' })
keymap("n", "'", "bi'<Esc>ea'<Esc>", { desc = " ' Surround cword" })
keymap("n", "(", "bi(<Esc>ea)<Esc>", { desc = "󰅲 Surround cword" })
keymap("n", "[", "bi[<Esc>ea]<Esc>", { desc = "󰅪 Surround cword", nowait = true })
keymap("n", "{", "bi{<Esc>ea}<Esc>", { desc = " Surround cword" })
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = " Inline code cword" })
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline code selection" })
keymap("i", "<D-e>", "``<Left>", { desc = " Inline code" })

keymap("i", "<D-a>", " => ", { desc = "=> Arrow" })

--------------------------------------------------------------------------------
-- TEXTOBJECTS

local textobjRemaps = {
	{ "c", "}", "", "curly" }, -- [c]urly brace
	{ "r", "]", "󰅪", "rectangular" }, -- [r]ectangular bracket
	{ "m", "W", "󰬞", "WORD" }, -- [m]assive word
	{ "q", '"', "", "double" }, -- [q]uote
	{ "z", "'", "", "single" }, -- [z]ingle quote
	{ "e", "`", "", "backtick" }, -- t[e]mplate string / inline cod[e]
}
for _, value in pairs(textobjRemaps) do
	local remap, original, icon, label = unpack(value)
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = icon .. " inner " .. label })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = icon .. " outer " .. label })
end

-- special remaps
keymap("o", "J", "2j") -- dd = 1 line, dj = 2 lines, dJ = 3 lines
keymap("n", "<Space>", '"_ciw', { desc = "󰬞 Change word" })
keymap("x", "<Space>", '"_c', { desc = "󰒅 Change selection" })
keymap("n", "<S-Space>", '"_daw', { desc = "󰬞 Delete word" })

--------------------------------------------------------------------------------
-- COMMENTS
-- HACK https://www.reddit.com/r/neovim/comments/1ctc1zd/comment/l4c29rx/
keymap(
	{ "n", "x" },
	"q",
	function() return require("vim._comment").operator() end,
	{ desc = "󰆈 Comment operator", expr = true }
)
keymap("n", "qq", "q_", { desc = "󰆈 Comment line", remap = true })
keymap("o", "u", require("vim._comment").textobject, { desc = "󰆈 Multiline comment" })
keymap("n", "guu", "guu") -- prevent `omap u` above from overwriting `guu`

-- stylua: ignore start
keymap("n", "qw", function() require("personal-plugins.comment").commentHr() end, { desc = "󰆈 Horizontal divider" })
keymap("n", "wq", function() require("personal-plugins.comment").duplicateLineAsComment() end, { desc = "󰆈 Duplicate line as comment" })
keymap("n", "qf", function() require("personal-plugins.comment").docstring() end, { desc = "󰆈 Function docstring" })
keymap("n", "Q", function() require("personal-plugins.comment").addComment("eol") end, { desc = "󰆈 Append comment" })
keymap("n", "qo", function() require("personal-plugins.comment").addComment("below") end, { desc = "󰆈 Comment below" })
keymap("n", "qO", function() require("personal-plugins.comment").addComment("above") end, { desc = "󰆈 Comment above" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT

keymap("n", "<Down>", [[<cmd>. move +1<CR>==]], { desc = "󰜮 Move line down" })
keymap("n", "<Up>", [[<cmd>. move -2<CR>==]], { desc = "󰜷 Move line up" })
keymap("n", "<Right>", [["zx"zp]], { desc = "➡️ Move char right" })
keymap("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move char left" })
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move selection up" })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move selection down" })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<left>", [["zxhh"zpgvhoho]], { desc = "⬅ Move selection left" })

--------------------------------------------------------------------------------

-- LSP
keymap({ "n", "i", "v" }, "<D-g>", vim.lsp.buf.signature_help, { desc = "󰏪 LSP signature" })
keymap({ "n", "x" }, "<leader>cc", vim.lsp.buf.code_action, { desc = "󱐋 Code action" })
keymap({ "n", "x" }, "<leader>h", vim.lsp.buf.hover, { desc = "󰋽 LSP hover" })
keymap({ "n", "x" }, "<leader>ol", vim.cmd.LspRestart, { desc = "󰒕 :LspRestart" })

keymap(
	{ "n", "x" },
	"<D-s>",
	function() require("personal-plugins.misc").formatWithFallback() end,
	{ desc = "󱉯 Save & Format" }
)

--------------------------------------------------------------------------------

-- INSERT MODE
keymap("n", "i", function()
	if vim.trim(vim.api.nvim_get_current_line()) == "" then return [["_cc]] end
	return "i"
end, { expr = true, desc = "indented i on empty line" })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated `V` selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts visual block" })

-- TERMINAL MODE
-- (also relevant for REPLs such as iron.nvim)
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste" })

-- COMMAND MODE
keymap("c", "<D-v>", "<C-r>+", { desc = " Paste" })
keymap("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { expr = true, desc = "<BS> does not leave cmdline" })

--------------------------------------------------------------------------------
-- INSPECT & EVAL

keymap("n", "<leader>ip", vim.cmd.Inspect, { desc = " Cursor position" })
keymap("n", "<leader>it", vim.cmd.InspectTree, { desc = " TS tree" })
keymap("n", "<leader>iq", vim.cmd.EditQuery, { desc = " TS query" })
keymap(
	"n",
	"<leader>il",
	function() require("personal-plugins.inspect-and-eval").lspCapabilities() end,
	{ desc = "󱈄 LSP capabilities" }
)
keymap(
	"n",
	"<leader>in",
	function() require("personal-plugins.inspect-and-eval").nodeUnderCursor() end,
	{ desc = " Cursor node" }
)
keymap(
	"n",
	"<leader>ib",
	function() require("personal-plugins.inspect-and-eval").bufferInfo() end,
	{ desc = "󰽙 Buffer info" }
)
keymap(
	{ "n", "x" },
	"<leader>ee",
	function() require("personal-plugins.inspect-and-eval").evalNvimLua() end,
	{ desc = " Eval" }
)
keymap(
	"n",
	"<leader>er",
	function() require("personal-plugins.inspect-and-eval").runFile() end,
	{ desc = "󰜎 Run file" }
)

--------------------------------------------------------------------------------
-- WINDOWS
keymap(
	{ "n", "x", "i" },
	"<C-CR>",
	function() vim.cmd.wincmd("w") end,
	{ desc = " Cycle windows" }
)
keymap({ "n", "x" }, "<C-v>", "<cmd>vertical leftabove split<CR>", { desc = " Vertical split" })
keymap({ "n", "x" }, "<D-W>", vim.cmd.only, { desc = " Close other windows" })

local delta = 5
keymap("n", "<C-up>", "<C-w>" .. delta .. "-")
keymap("n", "<C-down>", "<C-w>" .. delta .. "+")
keymap("n", "<C-left>", "<C-w>" .. delta .. "<")
keymap("n", "<C-right>", "<C-w>" .. delta .. ">")

--------------------------------------------------------------------------------

-- SNIPPETS
keymap({ "n", "i", "s" }, "<D-p>", function()
	if vim.snippet.active() then vim.snippet.jump(1) end
end, { desc = "󰩫 Next placeholder" })

-- exit snippet, see https://github.com/neovim/neovim/issues/26449#issuecomment-1845293096
keymap({ "i", "s" }, "<Esc>", function()
	vim.snippet.stop()
	return "<Esc>"
end, { desc = "󰩫 Exit snippet", expr = true })

--------------------------------------------------------------------------------

-- BUFFERS & FILES
do
	keymap(
		{ "n", "x" },
		"<CR>",
		function() require("personal-plugins.alt-alt").gotoAltFile() end,
		{ desc = "󰬈 Goto alt-file" }
	)
	vim.api.nvim_create_autocmd("FileType", {
		desc = "User: restore default behavior of `<CR>` for quickfix buffers.",
		pattern = "qf",
		callback = function(ctx) vim.keymap.set("n", "<CR>", "<CR>", { buffer = ctx.buf }) end,
	})
end

keymap("n", "<D-r>", vim.cmd.edit, { desc = "󰽙 Reload buffer" })
keymap("n", "<BS>", vim.cmd.bprevious, { desc = "󰽙 Prev buffer" })
keymap("n", "<S-BS>", vim.cmd.bnext, { desc = "󰽙 Next buffer" })

keymap(
	{ "n", "x" },
	"<D-CR>",
	function() require("personal-plugins.misc").gotoMostChangedFile() end,
	{ desc = "󰊢 Goto most changed file" }
)
keymap(
	{ "n", "x" },
	"<M-CR>",
	function() require("personal-plugins.misc").nextFileInFolder("next") end,
	{ desc = "󰖽 Next file in folder" }
)
keymap(
	{ "n", "x" },
	"<S-M-CR>",
	function() require("personal-plugins.misc").nextFileInFolder("prev") end,
	{ desc = "󰖿 Prev file in folder" }
)

-- close window or buffer
keymap({ "n", "x", "i" }, "<D-w>", function()
	local winClosed = pcall(vim.cmd.close)
	if not winClosed then require("personal-plugins.alt-alt").closeBuffer() end
end, { desc = "󰽙 Close window/buffer" })

keymap({ "n", "x" }, "<leader>es", function()
	local location = vim.fn.stdpath("config") .. "/debug"
	vim.fn.mkdir(location, "p")
	local currentExt = vim.fn.expand("%:e")
	local path = location .. "/scratch." .. currentExt
	vim.cmd.edit(path)
	vim.cmd.write(path)
end, { desc = " Scratch file" })

--------------------------------------------------------------------------------

-- MAC-SPECIFIC FUNCTIONS
keymap({ "n", "x", "i" }, "<D-l>", function()
	if jit.os ~= "OSX" then return end
	vim.system { "open", "-R", vim.api.nvim_buf_get_name(0) }
end, { desc = "󰀶 Reveal in macOS Finder" })

keymap(
	{ "n", "x", "i" },
	"<D-L>",
	function() require("personal-plugins.misc").openAlfredPref() end,
	{ desc = "󰮤 Reveal in Alfred" }
)

--------------------------------------------------------------------------------
-- MACROS

local register = "r"
local toggleKey = "0"
keymap(
	"n",
	toggleKey,
	function() require("personal-plugins.misc").startOrStopRecording(toggleKey, register) end,
	{ desc = "󰑊 Start/stop recording" }
)
keymap("n", "9", "@" .. register, { desc = " Play recording" })

--------------------------------------------------------------------------------
-- REFACTORING

keymap("n", "<leader>ff", vim.lsp.buf.rename, { desc = "󰑕 LSP rename" })
keymap("n", "<leader>fd", ":global //d<Left><Left>", { desc = " Delete matching lines" })

keymap(
	"n",
	"<leader>fc",
	function() require("personal-plugins.misc").camelSnakeLspRename() end,
	{ desc = "󰑕 LSP rename: camel/snake" }
)

---@param use "spaces"|"tabs"
local function retabber(use)
	vim.bo.expandtab = use == "spaces"
	vim.bo.shiftwidth = 2
	vim.bo.tabstop = 3
	vim.cmd.retab { bang = true }
	vim.notify("Now using " .. use, nil, { title = ":retab", icon = "󰌒" })
end
keymap("n", "<leader>f<Tab>", function() retabber("tabs") end, { desc = "󰌒 Use tabs" })
keymap("n", "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use spaces" })

keymap("n", "<leader>fq", function()
	local line = vim.api.nvim_get_current_line()
	local updatedLine = line:gsub("[\"']", function(q) return (q == [["]] and [[']] or [["]]) end)
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = " Switch quotes in line" })

keymap(
	"i",
	"<D-t>",
	function() require("personal-plugins.auto-template-str").insertTemplateStr() end,
	{ desc = "󰅳 Insert template string" }
)

keymap("n", "<leader>fm", '*N"_cgn', { desc = "󰆿 Multi-edit cword" })
keymap("x", "<leader>fm", function()
	local chunks = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = "v" })
	local selection = vim.iter(chunks)
		:map(function(chunk) return vim.fn.escape(chunk, [[/\]]) end)
		:join("\\n")
	vim.fn.setreg("/", "\\V" .. selection)
	return '<Esc>"_cgn'
end, { desc = "󰆿 Multi-edit selection", expr = true })

--------------------------------------------------------------------------------
-- OPTION TOGGLING

keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line numbers" })
keymap("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })

keymap("n", "<leader>od", function()
	local isEnabled = vim.diagnostic.is_enabled { bufnr = 0 }
	vim.diagnostic.enable(not isEnabled, { bufnr = 0 })
end, { desc = " Diagnostics" })

keymap(
	"n",
	"<leader>oc",
	function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0 end,
	{ desc = "󰈉 Conceal" }
)

--------------------------------------------------------------------------------
