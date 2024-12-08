local map = require("config.utils").uniqueKeymap
local pp = "personal-plugins."
--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1, "S").source:sub(2)
local desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile)
map("n", "<D-,>", function() vim.cmd.edit(pathOfThisFile) end, { desc = desc })

-- `cmd-q` remapped to `ZZ` via Karabiner, PENDING https://github.com/neovide/neovide/issues/2558
map("n", "ZZ", function() vim.cmd.wqall { bang = true } end, { desc = " Quit" })

local pluginDir = vim.fn.stdpath("data") --[[@as string]]
map("n", "<leader>pd", function() vim.ui.open(pluginDir) end, { desc = "󰝰 Plugin dir" })
map("n", "<leader>pv", function() vim.ui.open(vim.o.viewdir) end, { desc = "󰝰 View dir" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- j/k should on wrapped lines
map({ "n", "x" }, "j", "gj")
map({ "n", "x" }, "k", "gk")

-- HJKL behaves like hjkl, but bigger distance
-- (not mapping in op-pending, since using custom textobjects for most of those)
map({ "n", "x" }, "H", "0^", { desc = "󰲠 char" }) -- scroll fully to the left
map("o", "H", "^", { desc = "󰲠 char" })
map({ "n", "x" }, "L", "$zv", { desc = "󰰍 char" }) -- zv: unfold under cursor
map({ "n", "x" }, "J", "6gj", { desc = "6j" })
map({ "n", "x" }, "K", "6gk", { desc = "6k" })

-- Jump history
map("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
map("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Search
map("n", "-", "/")
map("x", "-", "<Esc>/\\%V", { desc = " Search IN sel" })

-- Goto matching parenthesis (`remap` needed to use builtin `MatchIt` plugin)
map("n", "gm", "%", { desc = "Goto Match", remap = true })

-- Diagnostics
map("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next diagnostic" })
map("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous diagnostic" })

-- Close all top-level folds
map("n", "zz", "<cmd>%foldclose<CR>", { desc = "󰘖 Close toplevel folds" })

map("n", "<D-U>", function()
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
map("n", "u", "<cmd>silent undo<CR>", { desc = "silent undo" })
map("n", "U", "<cmd>silent redo<CR>", { desc = "silent undo" })
map("n", "<leader>ur", function() vim.cmd.later(vim.o.undolevels) end, { desc = "󰛒 Redo all" })
map("n", "<leader>uu", function()
	vim.ui.input({ prompt = "󰜊 Undo to: " }, function(input)
		if not input or input == "" then return end
		vim.cmd.earlier(input)
	end)
end, { desc = "󰜊 Undo to earlier" })

-- Duplicate
-- stylua: ignore
map("n", "ww", function() require("personal-plugins.misc").smartDuplicate() end, { desc = "󰲢 Duplicate line" })

-- Toggles
map("n", "~", "v~", { desc = "󰬴 Toggle char case (w/o moving)" })
-- stylua: ignore
map("n", "<", function() require("personal-plugins.misc").toggleTitleCase() end, { desc = "󰬴 Toggle lower/Title case" })
map("n", ">", "gUiw", { desc = "󰬴 Toggle UPPER case" })

-- Increment/Decrement, or toggle true/false
map(
	{ "n", "x" },
	"+",
	function() return require("personal-plugins.misc").toggleOrIncrement() end,
	{ desc = "󰐖 Increment/toggle", expr = true }
)
map({ "n", "x" }, "ü", "<C-x>", { desc = "󰍵 Decrement" })

-- Delete trailing character
map("n", "X", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub("%S%s*$", "")
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = "󱎘 Delete char at EoL" })

-- Append to EoL
local trailChars = { ",", "\\", "{", ")", ";", "." }
for _, key in pairs(trailChars) do
	local pad = key == "\\" and " " or ""
	map("n", "<leader>" .. key, ("mzA%s%s<Esc>`z"):format(pad, key))
end

-- WHITESPACE & INDENTATION
map("n", "=", "mzO<Esc>`z", { desc = " Blank above" })
map("n", "_", "mzo<Esc>`z", { desc = " Blank below" })

map("n", "<Tab>", ">>", { desc = "󰉶 indent" })
map("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
map("i", "<Tab>", "<C-t>", { desc = "󰉶 indent" })
map("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
map("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })
map("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent" })

-- Spelling (works even with `spell=false`)
map("n", "z.", "1z=", { desc = "󰓆 Fix spelling" })

-- Merging
map("n", "m", "J", { desc = "󰽜 Merge line up" })
map("n", "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down" }) -- `:move` preserves marks

--------------------------------------------------------------------------------
-- SURROUND & ARROW

map("n", '"', 'bi"<Esc>ea"<Esc>', { desc = ' " Surround cword' })
map("n", "'", "bi'<Esc>ea'<Esc>", { desc = " ' Surround cword" })
map("n", "(", "bi(<Esc>ea)<Esc>", { desc = "󰅲 Surround cword" })
map("n", "[", "bi[<Esc>ea]<Esc>", { desc = "󰅪 Surround cword", nowait = true })
map("n", "{", "bi{<Esc>ea}<Esc>", { desc = " Surround cword" })
map("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = " Inline code cword" })
map("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline code selection" })
map("i", "<D-e>", "``<Left>", { desc = " Inline code" })

map("i", "<D-a>", " => ", { desc = "=> Arrow" })

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
	map({ "o", "x" }, "i" .. remap, "i" .. original, { desc = icon .. " inner " .. label })
	map({ "o", "x" }, "a" .. remap, "a" .. original, { desc = icon .. " outer " .. label })
end

-- special remaps
map("o", "J", "2j") -- dd = 1 line, dj = 2 lines, dJ = 3 lines
map("n", "<Space>", '"_ciw', { desc = "󰬞 Change word" })
map("x", "<Space>", '"_c', { desc = "󰒅 Change selection" })
map("n", "<S-Space>", '"_daw', { desc = "󰬞 Delete word" })

--------------------------------------------------------------------------------
-- COMMENTS
-- HACK https://www.reddit.com/r/neovim/comments/1ctc1zd/comment/l4c29rx/
map(
	{ "n", "x" },
	"q",
	function() return require("vim._comment").operator() end,
	{ desc = "󰆈 Comment operator", expr = true }
)
map("n", "qq", "q_", { desc = "󰆈 Comment line", remap = true })
map("o", "u", require("vim._comment").textobject, { desc = "󰆈 Multiline comment" })
map("n", "guu", "guu") -- prevent `omap u` above from overwriting `guu`

-- stylua: ignore start
map("n", "qw", function() require("personal-plugins.comment").commentHr() end, { desc = "󰆈 Horizontal divider" })
map("n", "wq", function() require("personal-plugins.comment").duplicateLineAsComment() end, { desc = "󰆈 Duplicate line as comment" })
map("n", "qf", function() require("personal-plugins.comment").docstring() end, { desc = "󰆈 Function docstring" })
map("n", "Q", function() require("personal-plugins.comment").addComment("eol") end, { desc = "󰆈 Append comment" })
map("n", "qo", function() require("personal-plugins.comment").addComment("below") end, { desc = "󰆈 Comment below" })
map("n", "qO", function() require("personal-plugins.comment").addComment("above") end, { desc = "󰆈 Comment above" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT

map("n", "<Down>", [[<cmd>. move +1<CR>==]], { desc = "󰜮 Move line down" })
map("n", "<Up>", [[<cmd>. move -2<CR>==]], { desc = "󰜷 Move line up" })
map("n", "<Right>", [["zx"zp]], { desc = "➡️ Move char right" })
map("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move char left" })
map("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move selection up" })
map("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move selection down" })
map("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
map("x", "<left>", [["zxhh"zpgvhoho]], { desc = "⬅ Move selection left" })

--------------------------------------------------------------------------------

-- LSP
map({ "n", "i", "v" }, "<D-g>", vim.lsp.buf.signature_help, { desc = "󰏪 LSP signature" })
map({ "n", "x" }, "<leader>cc", vim.lsp.buf.code_action, { desc = "󱐋 Code action" })
map({ "n", "x" }, "<leader>h", vim.lsp.buf.hover, { desc = "󰋽 LSP hover" })
map({ "n", "x" }, "<leader>ol", vim.cmd.LspRestart, { desc = "󰒕 :LspRestart" })

map(
	{ "n", "x" },
	"<D-s>",
	function() require("personal-plugins.misc").formatWithFallback() end,
	{ desc = "󱉯 Save & Format" }
)

--------------------------------------------------------------------------------

-- INSERT MODE
map("n", "i", function()
	if vim.trim(vim.api.nvim_get_current_line()) == "" then return [["_cc]] end
	return "i"
end, { expr = true, desc = "indented i on empty line" })

-- VISUAL MODE
map("x", "V", "j", { desc = "repeated `V` selects more lines" })
map("x", "v", "<C-v>", { desc = "`vv` starts visual block" })

-- TERMINAL MODE
-- (also relevant for REPLs such as iron.nvim)
map("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc" })
map("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste" })

-- COMMAND MODE
map("c", "<D-v>", "<C-r>+", { desc = " Paste" })
map("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { expr = true, desc = "<BS> does not leave cmdline" })

--------------------------------------------------------------------------------
-- INSPECT & EVAL

map("n", "<leader>ip", vim.cmd.Inspect, { desc = " Position at cursor" })
map("n", "<leader>it", vim.cmd.InspectTree, { desc = " TS tree" })
map("n", "<leader>iq", vim.cmd.EditQuery, { desc = " TS query" })
-- stylua: ignore start
map("n", "<leader>il", function() require("personal-plugins.inspect-and-eval").lspCapabilities() end, { desc = "󱈄 LSP capabilities" })
map("n", "<leader>in", function() require("personal-plugins.inspect-and-eval").nodeAtCursor() end, { desc = " Node at cursor" })
map("n", "<leader>ib", function() require("personal-plugins.inspect-and-eval").bufferInfo() end, { desc = "󰽙 Buffer info" })
map({ "n", "x" }, "<leader>ee", function() require("personal-plugins.inspect-and-eval").evalNvimLua() end, { desc = " Eval" })
map("n", "<leader>er", function() require("personal-plugins.inspect-and-eval").runFile() end, { desc = "󰜎 Run file" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- WINDOWS
map({ "n", "x", "i" }, "<C-CR>", function() vim.cmd.wincmd("w") end, { desc = " Cycle windows" })
map({ "n", "x" }, "<C-v>", "<cmd>vertical leftabove split<CR>", { desc = " Vertical split" })
map({ "n", "x" }, "<D-W>", vim.cmd.only, { desc = " Close other windows" })

local delta = 5
map("n", "<C-up>", "<C-w>" .. delta .. "-")
map("n", "<C-down>", "<C-w>" .. delta .. "+")
map("n", "<C-left>", "<C-w>" .. delta .. "<")
map("n", "<C-right>", "<C-w>" .. delta .. ">")

--------------------------------------------------------------------------------

-- SNIPPETS
map({ "n", "i", "s" }, "<D-p>", function()
	if vim.snippet.active() then vim.snippet.jump(1) end
end, { desc = "󰩫 Next placeholder" })

-- exit snippet, see https://github.com/neovim/neovim/issues/26449#issuecomment-1845293096
map({ "i", "s" }, "<Esc>", function()
	vim.snippet.stop()
	return "<Esc>"
end, { desc = "󰩫 Exit snippet", expr = true })

--------------------------------------------------------------------------------

-- BUFFERS & FILES
do
	map(
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

map("n", "<D-r>", vim.cmd.edit, { desc = "󰽙 Reload buffer" })
map("n", "<BS>", vim.cmd.bprevious, { desc = "󰽙 Prev buffer" })
map("n", "<S-BS>", vim.cmd.bnext, { desc = "󰽙 Next buffer" })

-- stylua: ignore start
map({ "n", "x" }, "<D-CR>", function() require("personal-plugins.misc").gotoMostChangedFile() end, { desc = "󰊢 Goto most changed file" })
map({ "n", "x" }, "<M-CR>", function() require("personal-plugins.misc").nextFileInFolder("next") end, { desc = "󰖽 Next file in folder" })
map({ "n", "x" }, "<S-M-CR>", function() require("personal-plugins.misc").nextFileInFolder("prev") end, { desc = "󰖿 Prev file in folder" })
-- stylua: ignore end

-- close window or buffer
map({ "n", "x", "i" }, "<D-w>", function()
	local winClosed = pcall(vim.cmd.close)
	if not winClosed then require("personal-plugins.alt-alt").closeBuffer() end
end, { desc = "󰽙 Close window/buffer" })

map({ "n", "x" }, "<leader>es", function()
	local location = vim.fn.stdpath("config") .. "/debug"
	vim.fn.mkdir(location, "p")
	local currentExt = vim.fn.expand("%:e")
	local path = location .. "/scratch." .. currentExt
	vim.cmd.edit(path)
	vim.cmd.write(path)
end, { desc = " Scratch file" })

--------------------------------------------------------------------------------

-- MAC-SPECIFIC FUNCTIONS
map({ "n", "x", "i" }, "<D-l>", function()
	if jit.os ~= "OSX" then return end
	vim.system { "open", "-R", vim.api.nvim_buf_get_name(0) }
end, { desc = "󰀶 Reveal in macOS Finder" })

map(
	{ "n", "x", "i" },
	"<D-L>",
	function() require("personal-plugins.misc").openAlfredPref() end,
	{ desc = "󰮤 Reveal in Alfred" }
)

--------------------------------------------------------------------------------
-- MACROS

local register = "r"
local toggleKey = "0"
map(
	"n",
	toggleKey,
	function() require("personal-plugins.misc").startOrStopRecording(toggleKey, register) end,
	{ desc = "󰑊 Start/stop recording" }
)
map("n", "9", "@" .. register, { desc = " Play recording" })

--------------------------------------------------------------------------------
-- REFACTORING

map("n", "<leader>ff", vim.lsp.buf.rename, { desc = "󰑕 LSP rename" })
map("n", "<leader>fd", ":global //d<Left><Left>", { desc = " Delete matching lines" })

map(
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
map("n", "<leader>f<Tab>", function() retabber("tabs") end, { desc = "󰌒 Use tabs" })
map("n", "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use spaces" })

map("n", "<leader>fq", function()
	local line = vim.api.nvim_get_current_line()
	local updatedLine = line:gsub("[\"']", function(q) return (q == [["]] and [[']] or [["]]) end)
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = " Switch quotes in line" })

map(
	"i",
	"<D-t>",
	function() require("personal-plugins.auto-template-str").insertTemplateStr() end,
	{ desc = "󰅳 Insert template string" }
)

map("n", "<leader>fm", '*N"_cgn', { desc = "󰆿 Multi-edit cword" })
map("x", "<leader>fm", function()
	local chunks = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = "v" })
	local selection = vim.iter(chunks)
		:map(function(chunk) return vim.fn.escape(chunk, [[/\]]) end)
		:join("\\n")
	vim.fn.setreg("/", "\\V" .. selection)
	return '<Esc>"_cgn'
end, { desc = "󰆿 Multi-edit selection", expr = true })

--------------------------------------------------------------------------------
-- OPTION TOGGLING

map("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line numbers" })
map("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })

map("n", "<leader>od", function()
	local isEnabled = vim.diagnostic.is_enabled { bufnr = 0 }
	vim.diagnostic.enable(not isEnabled, { bufnr = 0 })
end, { desc = " Diagnostics" })

map(
	"n",
	"<leader>oc",
	function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0 end,
	{ desc = "󰈉 Conceal" }
)

--------------------------------------------------------------------------------
