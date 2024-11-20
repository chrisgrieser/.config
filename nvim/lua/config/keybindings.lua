local keymap = require("config.utils").uniqueKeymap
local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1).source:sub(2)
local desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile)
keymap("n", "<D-,>", function() vim.cmd.edit(pathOfThisFile) end, { desc = desc })

-- `cmd-q` remapped to `ZZ` via Karabiner, PENDING https://github.com/neovide/neovide/issues/2558
keymap("n", "ZZ", "<cmd>wqall!<CR>", { desc = " Quit" })

keymap("n", "<leader>pd", function()
	local packagesDir = vim.fn.stdpath("data") ---@cast packagesDir string
	vim.ui.open(packagesDir)
end, { desc = "󰝰 Open packages directory" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- j/k should on wrapped lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- HJKL behaves like hjkl, but bigger distance
-- (not mapping in op-pending, since using custom textobjects for most of those)
keymap({ "n", "x" }, "H", "0^", { desc = "1st char" }) -- scroll fully to the left
keymap("o", "H", "^", { desc = "1st char" })
keymap({ "n", "x" }, "L", "$zv", { desc = "last char" }) -- zv: unfold under cursor
keymap({ "n", "x" }, "J", "6gj", { desc = "6j" })
keymap({ "n", "x" }, "K", "6gk", { desc = "6k" })

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = " Search in sel" })

-- Goto matching parenthesis (`remap` -> use builtin `MatchIt` plugin)
keymap("n", "gm", "%", { desc = "Goto Match", remap = true })

-- Diagnostics
keymap("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next diagnostic" })
keymap("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous diagnostic" })

keymap(
	"n",
	"gs",
	function() require("personal-plugins.magnet").jump() end,
	{ desc = "󰍇 Magnet" }
)

-- Close all top-level folds
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = "󰘖 Close toplevel folds" })

--------------------------------------------------------------------------------
-- EDITING

-- Undo
keymap("n", "U", "<C-r>")
keymap(
	"n",
	"<leader>ur",
	function() vim.cmd.later(vim.o.undolevels) end,
	{ desc = "󰛒 Redo All" }
)
keymap("n", "<leader>uu", ":earlier ", { desc = "󰜊 Undo to earlier" })

-- Duplicate
keymap(
	"n",
	"ww",
	function() require("personal-plugins.misc").smartLineDuplicate() end,
	{ desc = "󰇋 Duplicate line" }
)

-- Toggles
keymap("n", "~", "v~", { desc = "󰬴 Toggle char case (w/o moving)" })
keymap(
	"n",
	"<",
	function() require("personal-plugins.misc").toggleWordCasing() end,
	{ desc = "󰬴 Toggle word case" }
)

keymap(
	"n",
	">",
	function() require("personal-plugins.misc").camelSnakeToggle() end,
	{ desc = "󰬴 Toggle camel & snake case" }
)

-- Increment/Decrement, or toggle true/false
keymap(
	{ "n", "x" },
	"+",
	function() return require("personal-plugins.misc").toggleOrIncrement() end,
	{ desc = "󰐖 Increment/Toggle", expr = true }
)
keymap({ "n", "x" }, "ü", "<C-x>", { desc = "󰍵 Decrement" })

-- Delete trailing character
keymap("n", "X", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub("%S%s*$", "")
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = "󱎘 Delete char at EoL" })

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
keymap("n", "m", "J", { desc = "󰗈 Merge line up" })
keymap("n", "M", '"zdd"zpkJ', { desc = "󰗈 Merge line down" })

-- Append to EoL
local trailChars = { ",", "\\", "{", ")", ";", "." }
for _, key in pairs(trailChars) do
	local pad = key == "\\" and " " or ""
	keymap("n", "<leader>" .. key, ("mzA%s%s<Esc>`z"):format(pad, key))
end

--------------------------------------------------------------------------------

-- SURROUND
keymap("n", '"', [[bi"<Esc>ea"<Esc>]], { desc = ' " Surround cword' })
keymap("n", "'", [[bi'<Esc>ea'<Esc>]], { desc = " ' Surround cword" })
keymap("n", "(", [[bi(<Esc>ea)<Esc>]], { desc = "󰅲 Surround cword" })
keymap("n", "[", [[bi[<Esc>ea]<Esc>]], { desc = "󰅪 Surround cword", nowait = true })
keymap("n", "{", [[bi{<Esc>ea}<Esc>]], { desc = " Surround cword" })
keymap("n", "<D-e>", [[bi`<Esc>ea`<Esc>]], { desc = " Inline code cword" })
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline code selection" })
keymap("i", "<D-e>", "``<Left>", { desc = " Inline code" })

keymap("i", "<D-t>", "${}<Left>", { desc = "${} Template string" })

--------------------------------------------------------------------------------
-- TEXTOBJECTS

local textobjRemaps = {
	{ "c", "}", "", "curly" }, -- [c]urly brace
	{ "r", "]", "󰅪", "rectangular" }, -- [r]ectangular bracket
	{ "m", "W", "󰬞", "WORD" }, -- [m]assive word
	{ "q", '"', "", "double" }, -- [q]uote
	{ "z", "'", "", "single" }, -- [z]ingle quote
	{ "e", "`", "", "backtick" }, -- t[e]mplate string / inline cod[e]
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
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move selection up", silent = true })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move selection down", silent = true })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<left>", [["zxhh"zpgvhoho]], { desc = "⬅ Move selection left" })

--------------------------------------------------------------------------------

-- LSP
keymap({ "n", "i", "v" }, "<D-g>", vim.lsp.buf.signature_help, { desc = "󰏪 LSP signature" })
keymap({ "n", "x" }, "<D-s>", function()
	local formattingLsps = #vim.lsp.get_clients { method = "textDocument/formatting", bufnr = 0 }
	if formattingLsps > 0 then
		vim.lsp.buf.format()
	else
		-- remove unneeded whitespace
		vim.cmd([[% substitute_\s\+$__e]]) -- trailing spaces
		vim.cmd([[% substitute _\(\n\n\)\n\+_\1_e]]) -- duplicate blank lines
		vim.cmd([[silent! /^\%(\n*.\)\@!/,$ delete]]) -- blanks at end of file
	end
end, { desc = "󰒕 Save & Format" })

--------------------------------------------------------------------------------
-- LSP
keymap({ "n", "x" }, "<leader>cc", vim.lsp.buf.code_action, { desc = "󰒕 Code action" })
keymap({ "n", "x" }, "<leader>hh", vim.lsp.buf.hover, { desc = "󰒕 LSP Hover" })

keymap("n", "<leader>ol", function()
	vim.notify("Restarting…", nil, { title = "LSP", icon = "󰒕" })
	vim.cmd.LspRestart()
end, { desc = "󰒕 :LspRestart" })

--------------------------------------------------------------------------------

-- INSERT MODE
keymap("n", "i", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return [["_cc]] end
	return "i"
end, { expr = true, desc = "indented i on empty line" })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated `V` selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts visual block" })

-- TERMINAL MODE
-- (also relevant for REPLs such as iron.nvim)
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc (terminal mode)" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste (terminal mode)" })

-- COMMAND MODE
keymap("c", "<D-v>", "<C-r>+", { desc = " Paste" })
keymap("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { expr = true, desc = "<BS> does not leave cmdline" })

--------------------------------------------------------------------------------

-- CMDLINE
-- EVAL (better than `:lua = `, since using `vim.notify`)
vim.api.nvim_create_user_command("Eval", function(ctx)
	local output = vim.fn.luaeval(ctx.args)
	vim.notify(
		vim.inspect(output),
		vim.log.levels.DEBUG,
		{ title = "Eval", icon = "󰜎", ft = "lua" }
	)
end, { desc = "Eval cmdline", nargs = "+" })
keymap("n", "<leader>ee", ":Eval ", { desc = "󰜎 Eval" })
-- Copy last command
keymap("n", "<leader>ec", function()
	local lastCommand = vim.fn.getreg(":"):gsub("^Eval ", "")
	vim.fn.setreg("+", lastCommand)
	vim.notify(lastCommand, nil, { title = "Copied", icon = "󰅍" })
end, { desc = "󰓗 Copy last command" })

--------------------------------------------------------------------------------
-- RUN

keymap("n", "<leader>er", function()
	vim.cmd.update()
	local hasShebang = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]:find("^#!")

	if vim.bo.filetype == "lua" then
		vim.cmd.source()
	elseif hasShebang then
		vim.cmd("! chmod +x %")
		vim.cmd("! %")
	else
		vim.notify("File has no shebang.", vim.log.levels.WARN, { title = "Run", icon = "󰜎" })
	end
end, { desc = "󰜎 Run file" })

--------------------------------------------------------------------------------
-- WINDOWS
keymap({ "n", "x", "i" }, "<C-CR>", "<C-w>w", { desc = " Next window" })
keymap({ "n", "x" }, "<C-v>", "<cmd>vertical leftabove split<CR>", { desc = " Vertical split" })
keymap({ "n", "x" }, "<C-s>", "<cmd>horizontal split<CR>", { desc = " Horizontal split" })

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

vim.api.nvim_create_autocmd("WinScrolled", {
	desc = "User: Exit snippet on scroll",
	callback = function(ctx)
		local scrollWinId = tonumber(ctx.match) -- SIC ctx.match returns id as string
		local mainWinId = 1000
		if scrollWinId == mainWinId then vim.snippet.stop() end
	end,
})

--------------------------------------------------------------------------------

-- BUFFERS & FILES
keymap(
	{ "n", "x" },
	"<CR>",
	function() require("personal-plugins.alt-alt").gotoAltFile() end,
	{ desc = "󰽙 Goto Alt-File" }
)
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: restore default behavior of `<CR>` for qf buffers.",
	pattern = "qf",
	callback = function() bkeymap("n", "<CR>", "<CR>") end,
})

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
	function() require("personal-plugins.misc").nextFileInFolder("Next") end,
	{ desc = "󰖽 Next file in folder" }
)
keymap(
	{ "n", "x" },
	"<S-M-CR>",
	function() require("personal-plugins.misc").nextFileInFolder("Prev") end,
	{ desc = "󰖿 Prev file in folder" }
)

-- close window or buffer
keymap({ "n", "x", "i" }, "<D-w>", function()
	local winClosed = pcall(vim.cmd.close)
	if not winClosed then require("personal-plugins.alt-alt").closeBuffer() end
end, { desc = "󰽙 Close window/buffer" })

keymap({ "n", "x", "i" }, "<D-N>", function()
	local extensions = { "sh", "json", "mjs", "md", "py" }
	vim.ui.select(extensions, { prompt = " Scratch file", kind = "plain" }, function(ext)
		if not ext then return end
		local filepath = vim.fs.normalize("~/Desktop/scratchpad." .. ext)
		vim.cmd.edit(filepath)
		vim.cmd.write(filepath)
	end)
end, { desc = " Create scratchpad file" })

--------------------------------------------------------------------------------

-- MAC-SPECIFIC FUNCTIONS
keymap({ "n", "x", "i" }, "<D-l>", function()
	if jit.os ~= "OSX" then return end
	vim.system { "open", "-R", vim.api.nvim_buf_get_name(0) }
end, { desc = "󰀶 Reveal in Finder" })

keymap(
	{ "n", "x", "i" },
	"<D-L>",
	function() require("personal-plugins.misc").openAlfredPref() end,
	{ desc = "󰮤 Reveal in Alfred" }
)

--------------------------------------------------------------------------------
-- MULTI-CURSOR REPLACEMENT

keymap("n", "<D-j>", '*N"_cgn', { desc = "󰆿 Multi-edit cword" })

keymap("x", "<D-j>", function()
	local chunks = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
	local selection = vim.iter(chunks)
		:map(function(chunk) return vim.fn.escape(chunk, [[/\]]) end)
		:join("\\n")
	vim.fn.setreg("/", "\\V" .. selection)
	return '<Esc>"_cgn'
end, { desc = "󰆿 Multi-edit selection", expr = true })

--------------------------------------------------------------------------------
-- MACROS

local register = "r"
local toggleKey = "0"
keymap(
	"n",
	toggleKey,
	function() require("personal-plugins.misc").startOrStopRecording(toggleKey, register) end,
	{ desc = "󰕧 Start/stop recording" }
)
keymap("n", "9", "@" .. register, { desc = "󰕧 Play recording" })
-- `remap` since using nvim builtin mapping
keymap("x", "9", "Q", { desc = "󰕧 Play recording on each line", remap = true })

--------------------------------------------------------------------------------
-- CLIPBOARD

-- sticky yank operations
local cursorPreYank
keymap({ "n", "x" }, "y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y"
end, { desc = "Sticky yank", expr = true })
keymap("n", "Y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y$"
end, { desc = "󰅍 Sticky yank", expr = true, unique = false })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Sticky yank",
	callback = function()
		if vim.v.event.regname == "z" then return end -- used as temp register for keymaps
		if vim.v.event.operator == "y" then vim.api.nvim_win_set_cursor(0, cursorPreYank) end
	end,
})

-- keep the register clean
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = " Paste w/o switching with register" })
keymap("n", "dd", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return '"_dd' end
	return "dd"
end, { expr = true, desc = "dd" })

-- pasting
keymap("n", "P", function()
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local reg = vim.fn.getreg("+")
	vim.api.nvim_set_current_line(curLine .. " " .. reg)
end, { desc = " Sticky paste at EoL" })

keymap("i", "<D-v>", function()
	local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n") -- remove indentation if multi-line
	vim.fn.setreg("+", reg, "v")
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

keymap("n", "<D-v>", "p", { desc = " Paste" }) -- for compatibility with macOS clipboard managers

--------------------------------------------------------------------------------
-- INSPECT

keymap("n", "<leader>ih", vim.cmd.Inspect, { desc = " Highlights under cursor" })
keymap("n", "<leader>it", vim.cmd.InspectTree, { desc = " :InspectTree" })
keymap("n", "<leader>il", vim.cmd.LspInfo, { desc = "󰒕 :LspInfo" })

keymap(
	"n",
	"<leader>ib",
	function() require("personal-plugins.misc").bufferInfo() end,
	{ desc = "󰽙 Buffer info" }
)

--------------------------------------------------------------------------------
-- REFACTORING

keymap("n", "<leader>ff", vim.lsp.buf.rename, { desc = "󰒕 LSP var rename" })
keymap("n", "<leader>fd", ":global //d<Left><Left>", { desc = " Delete matching lines" })

---@param use "spaces"|"tabs"
local function retabber(use)
	vim.bo.expandtab = use == "spaces"
	vim.bo.shiftwidth = 2
	vim.bo.tabstop = 3
	vim.cmd.retab { bang = true }
	vim.notify("Now using " .. use)
end
keymap("n", "<leader>f<Tab>", function() retabber("tabs") end, { desc = "󰌒 Use tabs" })
keymap("n", "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use spaces" })

keymap("n", "<leader>fq", function()
	local line = vim.api.nvim_get_current_line()
	local updatedLine = line:gsub("[\"']", function(q) return (q == [["]] and [[']] or [["]]) end)
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = " Switch quotes in line" })

keymap("n", "<leader>fy", function()
	-- cannot use `:g // y` because it yanks lines one after the other
	vim.ui.input({ prompt = "󰅍 yank lines matching:" }, function(input)
		if not input then return end
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local matchLines = vim.tbl_filter(function(l) return l:find(input, 1, true) end, lines)
		vim.fn.setreg("+", table.concat(matchLines, "\n"))
		vim.notify(("%d lines"):format(#matchLines), nil, { title = "Copied", icon = "󰅍" })
	end)
end, { desc = "󰅍 Matching lines" })

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
	function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 3 or 0 end,
	{ desc = "󰈉 Conceal" }
)
