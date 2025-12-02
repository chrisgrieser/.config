---Warn when there are conflicting keymaps
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? { desc?: string, unique?: boolean, remap?: boolean, silent?:boolean }
local function keymap(mode, lhs, rhs, opts)
	if not opts then opts = {} end

	-- allow to disable with `unique=false` to overwrite nvim defaults: https://neovim.io/doc/user/vim_diff.html#default-mappings
	if opts.unique == nil then opts.unique = true end

	-- violating `unique=true` throws an error; using `pcall` to still load other mappings
	local success, _ = pcall(vim.keymap.set, mode, lhs, rhs, opts)
	if not success then
		local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
		local msg = ("**Duplicate keymap**\n[[%s]] %s"):format(modes, lhs)
		vim.defer_fn(function() -- defer for notification plugin
			vim.notify(msg, vim.log.levels.WARN, { title = "User keybindings", timeout = false })
		end, 1000)
	end
end

---META-------------------------------------------------------------------------

-- save before quitting (non-unique, since also set by Neovide)
keymap("n", "<D-q>", vim.cmd.wqall, { desc = " Save & quit", unique = false })

-- stylua: ignore
keymap("n", "<leader>pd", function() vim.ui.open(vim.fn.stdpath("data") --[[@as string]]) end, { desc = "󰝰 Local data dir" })
-- stylua: ignore
keymap("n", "<leader>pD", function() vim.ui.open(vim.g.iCloudSync) end, { desc = " Cloud data dir" })

keymap("n", "<D-,>", function()
	local pathOfThisFile = debug.getinfo(1, "S").source:gsub("^@", "")
	vim.cmd.edit(pathOfThisFile)
end, { desc = "󰌌 Edit keybindings" })

keymap(
	{ "n", "x", "i" },
	"<D-C-r>", -- `hyper` gets registered by neovide as `cmd+ctrl` (`D-C`)
	function() require("personal-plugins.misc").restartNeovide() end,
	{ desc = " Save & restart neovide" }
)

-- terminal at cwd
keymap(
	{ "n", "x", "i" },
	"<D-C-t>", -- `hyper` gets registered by neovide as cmd+ctrl
	function()
		assert(jit.os == "OSX", "requires macOS' `osascript`")
		vim.system({ "open", "-a", 'WezTerm' }):wait()
		vim.defer_fn(function()
			local stdin = ("cd -q %q && clear\n"):format(vim.uv.cwd() or "")
			vim.system({ "wezterm", "cli", "send-text", "--no-paste" }, { stdin = stdin })
		end, 400)
	end,
	{ desc = " Open cwd in WezTerm" }
)

---NAVIGATION-------------------------------------------------------------------
-- make j/k on wrapped lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- make HJKL behave like hjkl but bigger with distance
-- (not mapping in op-pending, since using custom textobjects for those keys)
keymap({ "n", "x" }, "H", "0^", { desc = "󰲠 char" }) -- scroll fully to the left
keymap("o", "H", "^", { desc = "󰲠 char" })
keymap({ "n", "x" }, "L", "$", { desc = "󰬓 char", remap = true }) -- remap for `nvim-origami` overload of `$`
keymap({ "n", "x" }, "J", "6gj", { desc = "6j" })
keymap({ "n", "x" }, "K", "6gk", { desc = "6k" })

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = " Search within selection" })

-- [g]oto [m]atching parenthesis (`remap` needed to use builtin `MatchIt` plugin)
keymap("n", "gm", "%", { desc = "󰅪 Goto match", remap = true })

-- Diagnostics
keymap("n", "ge", "]d", { desc = "󰋼 Next diagnostic", remap = true })
keymap("n", "gE", "[d", { desc = "󰋼 Previous diagnostic", remap = true })

-- Open URL in file
-- stylua: ignore
keymap("n", "<D-U>", function() require("personal-plugins.misc").openUrlInBuffer() end, { desc = " Open URL in buffer" })

---MARKS------------------------------------------------------------------------
do
	local marks = require("personal-plugins.marks")

	marks.setup {
		marks = { "A", "B", "C" },
		signs = { hlgroup = "StandingOut", icons = { A = "󰬈", B = "󰬉", C = "󰬊" } },
	}

	local subLeader = "<leader>m"
	if vim.g.whichkeyAddSpec then vim.g.whichkeyAddSpec { subLeader, group = "󰃃 Marks" } end

	keymap("n", subLeader .. "m", marks.cycleMarks, { desc = "󰃀 Cycle marks" })
	keymap("n", subLeader .. "r", marks.deleteAllMarks, { desc = "󰃆 Delete marks" })

	for _, mark in pairs(marks.config.marks) do
		keymap(
			"n",
			subLeader .. mark:lower(),
			function() marks.setUnsetMark(mark) end,
			{ desc = "󰃃 Set " .. mark }
		)
	end
end

---EDITING----------------------------------------------------------------------

-- Undo
keymap("n", "u", "<cmd>silent undo<CR>zv", { desc = "󰜊 Silent undo" })
keymap("n", "U", "<cmd>silent redo<CR>zv", { desc = "󰛒 Silent redo" })
keymap("n", "<leader>uu", ":earlier ", { desc = "󰜊 Undo to earlier" })
-- stylua: ignore
keymap("n", "<leader>ur", function() vim.cmd.later(vim.o.undolevels) end, { desc = "󰛒 Redo all" })

-- Duplicate
-- stylua: ignore
keymap("n", "ww", function() require("personal-plugins.misc").smartDuplicate() end, { desc = "󰲢 Duplicate line" })

-- Toggles
keymap("n", "~", "v~", { desc = "󰬴 Toggle char case (w/o moving)" })

-- stylua: ignore
keymap("n", "<", function() require("personal-plugins.misc").toggleTitleCase() end, { desc = "󰬴 Toggle lower/Title case" })
keymap("n", ">", "gUiw", { desc = "󰬴 Uppercase cword" })

-- toggle common words or increment/decrement numbers
-- stylua: ignore
keymap("n", "+", function() require("personal-plugins.misc").toggleOrIncrement() end, { desc = "󰐖 Increment/toggle" })
keymap("n", "ü", "<C-x>", { desc = "󰍵 Decrement" })

keymap("n", "X", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub(".$", "")
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = "󱎘 Delete char at EoL" })

-- Append to EoL: `<leader>` + `char`
local trailChars = { ",", ")", ";", ".", '"', "'", " \\", " {", "?" }
for _, chars in pairs(trailChars) do
	keymap("n", "<leader>" .. vim.trim(chars), function()
		local updatedLine = vim.api.nvim_get_current_line() .. chars
		vim.api.nvim_set_current_line(updatedLine)
	end)
end

-- Spelling
keymap("n", "z.", "1z=", { desc = "󰓆 Fix spelling" }) -- works even with `spell=false`
keymap("n", "zl", function()
	local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
	suggestions = vim.list_slice(suggestions, 1, 9)
	vim.ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" }, function(selection)
		if not selection then return end
		vim.cmd.normal { '"_ciw' .. selection, bang = true }
	end)
end, { desc = "󰓆 Spell suggestions" })

-- template strings
-- stylua: ignore
keymap("i", "<D-t>", function() require("personal-plugins.auto-template-str").insertTemplateStr() end, { desc = "󰅳 Insert template string" })

-- multi-edit
keymap("n", "<D-j>", '*N"_cgn', { desc = "󰆿 Multi-edit cword" })
keymap("x", "<D-j>", function()
	local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = "v" })[1]
	assert(selection, "No selection.")
	vim.fn.setreg("/", "\\V" .. vim.fn.escape(selection, [[/\]]))
	return '<Esc>"_cgn'
end, { desc = "󰆿 Multi-edit selection", expr = true })

-- Merging
keymap("n", "m", "J", { desc = "󰽜 Merge line up" })
keymap("n", "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down" }) -- `:move` preserves marks

-- Markdown syntax (useful to have in all filetypes for comments)
-- stylua: ignore start
keymap({ "n", "x", "i" }, "<D-e>", function() require("personal-plugins.misc").mdWrap("`") end, { desc = " Inline code" })
keymap({ "n", "x", "i" }, "<D-k>", function() require("personal-plugins.misc").mdWrap("mdlink") end, { desc = " Link" })
keymap({ "n", "x", "i" }, "<D-b>", function() require("personal-plugins.misc").mdWrap("**") end, { desc = " Bold" })
keymap({ "n", "x", "i" }, "<D-i>", function() require("personal-plugins.misc").mdWrap("*") end, { desc = " Italic" })

-- simple surrounds
keymap("n", '"', function() require("personal-plugins.misc").mdWrap('"') end, { desc = ' Surround' })
keymap("n", "(", function() require("personal-plugins.misc").mdWrap("(", ")") end, { desc = "󰅲 Surround" })
keymap("n", "[", function() require("personal-plugins.misc").mdWrap("[", "]") end, { desc = "󰅪 Surround" })
keymap("n", "{", function() require("personal-plugins.misc").mdWrap("{", "}") end, { desc = " Surround" })
-- stylua: ignore end

---WHITESPACE & INDENTATION-----------------------------------------------------
keymap("n", "=", "[<Space>", { desc = " Blank above", remap = true }) -- remap, since nvim default
keymap("n", "_", "]<Space>", { desc = " Blank below", remap = true })

keymap("n", "<Tab>", ">>", { desc = "󰉶 indent" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
keymap("i", "<Tab>", "<C-t>", { desc = "󰉶 indent", unique = false })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent", unique = false })

---QUICKFIX---------------------------------------------------------------------
keymap("n", "gq", "<cmd>silent cnext<CR>zv", { desc = "󰴩 Next quickfix" })
keymap("n", "gQ", "<cmd>silent cprev<CR>zv", { desc = "󰴩 Prev quickfix" })
keymap("n", "<leader>qr", function() vim.cmd.cexpr("[]") end, { desc = "󰚃 Remove qf items" })
keymap("n", "<leader>q1", "<cmd>silent cfirst<CR>zv", { desc = "󰴩 Goto 1st quickfix" })
keymap("n", "<leader>qq", function()
	local quickfixWinOpen = vim.fn.getqflist({ winid = true }).winid ~= 0
	vim.cmd(quickfixWinOpen and "cclose" or "copen")
end, { desc = " Toggle quickfix window" })

---FOLDING----------------------------------------------------------------------
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = " Close toplevel folds" })
keymap("n", "zm", "zM", { desc = " Close all folds" })
keymap("n", "zv", "zv", { desc = "󰘖 Open until cursor visible" }) -- just for which-key
keymap("n", "zr", "zR", { desc = "󰘖 Open all folds" })
-- stylua: ignore
keymap("n", "zf", function() vim.opt.foldlevel = vim.v.count1 end, { desc = " Set fold level to {count}" })

---CLIPBOARD--------------------------------------------------------------------
-- Sticky yank
do
	keymap({ "n", "x" }, "y", function()
		vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
		return "y"
	end, { expr = true })
	keymap("n", "Y", function()
		vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
		return "y$"
	end, { expr = true, unique = false }) -- non-unique, since nvim default

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Sticky yank",
		callback = function()
			if vim.v.event.operator == "y" and vim.v.event.regname == "" and vim.b.cursorPreYank then
				vim.api.nvim_win_set_cursor(0, vim.b.cursorPreYank)
				vim.b.cursorPreYank = nil
			end
		end,
	})
end

-- yankring
do
	-- same as regular `p`, but when undoing the paste and then using `.`, will
	-- paste `"2p`, so `<C-p>..... pastes all recent deletions and `pu.u.u.u.`
	-- cycles through them
	keymap("n", "<D-p>", '"1p', { desc = " Cyclic paste" })

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Yankring",
		callback = function()
			if vim.v.event.operator == "y" then
				for i = 9, 1, -1 do -- Shift all numbered registers.
					vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
				end
			end
		end,
	})
end

-- stylua: ignore
keymap("n", "<leader>yb", function() require("personal-plugins.breadcrumbs").copy() end, { desc = "󰳮 breadcrumbs" })

-- keep the register clean
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P")
keymap("n", "dd", function()
	local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
	return (lineEmpty and '"_dd' or "dd")
end, { expr = true })

-- pasting
keymap("n", "P", function()
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local reg = vim.trim(vim.fn.getreg("+"))
	vim.api.nvim_set_current_line(curLine .. " " .. reg)
end, { desc = " Paste at EoL" })

keymap("i", "<D-v>", function()
	vim.fn.setreg("+", vim.trim(vim.fn.getreg("+"))) -- trim
	if vim.fn.mode() == "R" then return "<C-r>+" end
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste", expr = true })

keymap("n", "<D-v>", "p", { desc = " Paste" }) -- compatibility w/ macOS clipboard managers
keymap("n", "qp", "R<C-r>+<Esc>", { desc = " Paste replacing" })

---TEXTOBJECTS------------------------------------------------------------------
local textobjRemaps = {
	{ "c", "}", "", "curly" }, -------- [c]urly brace
	{ "r", "]", "󰅪", "rectangular" }, -- [r]ectangular bracket
	{ "m", "W", "󰬞", "WORD" }, --------- [m]assive word
	{ "q", '"', "", "double" }, ------- [q]uote
	{ "z", "'", "", "single" }, ------- [z]ingle quote
	{ "e", "`", "", "backtick" }, ----- t[e]mplate string / inline cod[e]
}
for _, value in pairs(textobjRemaps) do
	local remap, original, icon, label = unpack(value)
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = icon .. " inner " .. label })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = icon .. " outer " .. label })
end

keymap("o", "J", "2j") -- `dd` = 1 line, `dj` = 2 lines, `dJ` = 3 lines
keymap("n", "<Space>", '"_ciw', { desc = "󰬞 Change word" })
keymap("x", "<Space>", '"_c', { desc = "󰒅 Change selection" })
keymap("n", "<S-Space>", '"_daw', { desc = "󰬞 Delete word" })

---COMMENTS---------------------------------------------------------------------
-- requires `remap` or method from: https://www.reddit.com/r/neovim/comments/1ctc1zd/comment/l4c29rx/
keymap({ "n", "x" }, "q", "gc", { desc = "󰆈 Comment operator", remap = true })
keymap("n", "qq", "gcc", { desc = "󰆈 Comment line", remap = true })
do
	keymap("o", "u", "gc", { desc = "󰆈 Multiline comment", remap = true })
	keymap("n", "guu", "guu") -- prevent previous mapping from overwriting `guu`
end

-- stylua: ignore start
keymap("n", "qw", function() require("personal-plugins.comment").commentHr() end, { desc = "󰆈 Horizontal divider" })
keymap("n", "qr", function() require("personal-plugins.comment").commentHr("replaceModeLabel") end, { desc = "󰆈 Horizontal divider w/ label" })
keymap("n", "wq", function() require("personal-plugins.comment").duplicateLineAsComment() end, { desc = "󰆈 Duplicate line as comment" })
keymap("n", "qf", function() require("personal-plugins.comment").docstring() end, { desc = "󰆈 Function docstring" })
keymap("n", "Q", function() require("personal-plugins.comment").addComment("eol") end, { desc = "󰆈 Add comment at EoL" })
keymap("n", "qO", function() require("personal-plugins.comment").addComment("above") end, { desc = "󰆈 Add comment above" })
keymap("n", "qo", function() require("personal-plugins.comment").addComment("below") end, { desc = "󰆈 Add comment below" })
keymap("n", "gS", function() require("personal-plugins.comment").gotoCommentHeader() end, { desc = "󰆈 Goto comment header" })
require("personal-plugins.comment").setupReplaceModeHelpersForComments()
-- stylua: ignore end

---LINE & CHARACTER MOVEMENT----------------------------------------------------
keymap("n", "<Down>", "<cmd>. move +1<CR>==", { desc = "󰜮 Move line down" })
keymap("n", "<Up>", "<cmd>. move -2<CR>==", { desc = "󰜷 Move line up" })
keymap("n", "<Right>", [["zx"zp]], { desc = "➡️ Move char right" })
keymap("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move char left" })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move selection down", silent = true })
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move selection up", silent = true })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<left>", [["zxhh"zpgvhoho]], { desc = "⬅ Move selection left" })

---LSP--------------------------------------------------------------------------
keymap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "󱐋 Code action" })

-- stylua: ignore start
keymap({ "n", "x" }, "<leader>h", function() vim.lsp.buf.hover { max_width = 70 } end, { desc = "󰋽 LSP hover" })

keymap("n", "<PageDown>", function() require("personal-plugins.misc").scrollLspOrOtherWin(5) end, { desc = "↓ Scroll other win" })
keymap("n", "<PageUp>", function() require("personal-plugins.misc").scrollLspOrOtherWin(-5) end, { desc = "↑ Scroll other win" })
-- stylua: ignore end

---VARIOUS MODES----------------------------------------------------------------

-- insert mode
keymap("n", "i", function()
	local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
	return lineEmpty and '"_cc' or "i"
end, { expr = true, desc = "indented i on empty line" })

-- visual mode
keymap("x", "V", "j", { desc = "repeated `V` selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts visual block" })

-- terminal mode
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste" })

-- cmdline mode
keymap("c", "<D-v>", function()
	vim.fn.setreg("+", vim.trim(vim.fn.getreg("+"))) -- trim
	return "<C-r>+"
end, { expr = true, desc = " Paste" })

keymap("c", "<D-c>", function()
	local cmdline = vim.fn.getcmdline()
	if cmdline == "" then return vim.notify("Nothing to copy.", vim.log.levels.WARN) end
	vim.fn.setreg("+", cmdline)
	vim.notify(cmdline, nil, { title = "Copied", icon = "󰅍" })
end, { desc = "󰅍 Yank cmdline" })

keymap("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { expr = true, desc = "<BS> does not leave cmdline" })

---INSPECT & EVAL---------------------------------------------------------------
keymap("n", "<leader>ii", vim.cmd.Inspect, { desc = "󱈄 Highlights at cursor" })
keymap("n", "<leader>it", vim.cmd.InspectTree, { desc = " TS Syntax Tree" })
keymap("n", "<leader>iT", "<cmd>checkhealth nvim-treesitter<CR>", { desc = " TS Parsers" })
keymap("n", "<leader>id", function()
	local diag = vim.diagnostic.get_next()
	vim.notify(vim.inspect(diag), nil, { ft = "lua" })
end, { desc = "󰋽 Next diagnostic" })

-- stylua: ignore start
keymap("n", "<leader>iL", function() vim.cmd.edit(vim.lsp.log.get_filename()) end, { desc = "󱂅 LSP log" })
keymap("n", "<leader>ib", function() require("personal-plugins.misc").inspectBuffer() end, { desc = "󰽙 Buffer info" })
-- stylua: ignore end

keymap({ "n", "x" }, "<leader>ee", function()
	local selection = vim.fn.mode() == "n" and ""
		or vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
	return ":lua = " .. selection
end, { expr = true, desc = "󰢱 Eval lua expr" })
keymap("n", "<leader>ey", function()
	local cmd = vim.fn.getreg(":")
	local syntax = vim.startswith(cmd, "lua") and "lua" or "vim"
	local lastExcmd = cmd:gsub("^lua ", ""):gsub("^= ?", "")
	if lastExcmd == "" then return vim.notify("Nothing to copy", vim.log.levels.TRACE) end
	vim.fn.setreg("+", lastExcmd)
	vim.notify(lastExcmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
end, { desc = "󰘳 Yank last ex-cmd" })

---WINDOWS & SPLITS-------------------------------------------------------------
keymap({ "n", "v", "i" }, "<C-CR>", "<C-w>w", { desc = " Cycle windows" })
keymap({ "n", "x" }, "<C-v>", "<cmd>vertical split #<CR>", { desc = " Split altfile" })
keymap({ "n", "x" }, "<D-W>", vim.cmd.only, { desc = " Close other windows" })

keymap("n", "<C-Up>", "<C-w>3-")
keymap("n", "<C-Down>", "<C-w>3+")
keymap("n", "<C-Left>", "<C-w>5<")
keymap("n", "<C-Right>", "<C-w>5>")

---BUFFERS & FILES--------------------------------------------------------------

-- stylua: ignore start
keymap({ "n", "x" }, "<CR>", function() require("personal-plugins.magnet").gotoAltFile() end, { desc = "󰬈 Goto alt-file" })
keymap({ "n", "x" }, "<D-CR>", function() require("personal-plugins.magnet").gotoMostChangedFile() end, { desc = "󰊢 Goto most changed file" })
-- stylua: ignore end

-- close window or buffer
keymap({ "n", "x", "i" }, "<D-w>", function()
	vim.cmd("silent! update")
	local winClosed = pcall(vim.cmd.close) -- fails on last window
	if winClosed then return end

	local bufCount = #vim.fn.getbufinfo { buflisted = 1 }
	if bufCount == 1 then return vim.notify("Only one buffer open.", vim.log.levels.TRACE) end
	vim.cmd.bdelete()
end, { desc = "󰽙 Close window/buffer" })

keymap("n", "<BS>", function()
	if vim.bo.buftype ~= "" then return end -- prevent accidental triggering in special buffers
	vim.cmd.bprevious()
end, { desc = "󰽙 Prev buffer" })
keymap("n", "<S-BS>", vim.cmd.bnext, { desc = "󰽙 Next buffer" })

-- stylua: ignore
keymap({ "n", "x", "i" }, "<D-L>", function() require("personal-plugins.misc").openWorkflowInAlfredPrefs() end, { desc = "󰮤 Reveal in Alfred" })

---MACROS-----------------------------------------------------------------------

do
	local reg = "r"
	local toggleKey = "0"

	vim.fn.setreg(reg, "") -- clear on startup to avoid accidents
	-- stylua: ignore
	keymap("n", toggleKey, function() require("personal-plugins.misc").startOrStopRecording(toggleKey, reg) end, { desc = "󰃽 Start/stop recording" })
	-- stylua: ignore
	keymap("n", "9", function() require("personal-plugins.misc").playRecording(reg) end, { desc = "󰃽 Play recording" })
end

---REFACTORING------------------------------------------------------------------

keymap("n", "<leader>rr", vim.lsp.buf.rename, { desc = "󰑕 LSP rename" })

-- stylua: ignore
keymap("n", "<leader>rc", function() require("personal-plugins.misc").camelSnakeLspRename() end, { desc = "󰑕 LSP rename: camel/snake" })

keymap("n", "<leader>rq", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub("[\"']", { ['"'] = "'", ["'"] = '"' })
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = " Switch quotes in line" })

do
	local function retabber(use)
		vim.bo.expandtab = use == "spaces"
		if use == "spaces" then vim.bo.shiftwidth = 2 end
		vim.cmd.retab { bang = true }
		vim.notify("Now using " .. use, nil, { title = ":retab", icon = "󰌒" })
	end
	keymap("n", "<leader>r<Tab>", function() retabber("tabs") end, { desc = "󰌒 Use tabs" })
	keymap("n", "<leader>r<Space>", function() retabber("spaces") end, { desc = "󱁐 Use spaces" })
end

---OPTION TOGGLING--------------------------------------------------------------

keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line numbers" })
keymap("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })
keymap("n", "<leader>os", "<cmd>set spell!<CR>", { desc = "󰓆 Spellcheck" })

keymap("n", "<leader>od", function()
	local isEnabled = vim.diagnostic.is_enabled { bufnr = 0 }
	vim.diagnostic.enable(not isEnabled, { bufnr = 0 })
end, { desc = "󰋽 Diagnostics" })

keymap("n", "<leader>oH", function()
	local isEnabled = vim.lsp.inlay_hint.is_enabled { bufnr = 0 }
	vim.lsp.inlay_hint.enable(not isEnabled, { bufnr = 0 })
end, { desc = "󰋽 Inlay hints" })

-- stylua: ignore
keymap("n", "<leader>oc", function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0 end, { desc = "󰈉 Conceal" })

keymap("n", "<leader>ol", function()
	local clients = vim.lsp.get_clients { bufnr = 0 }
	local names = vim.tbl_map(function(client) return client.name end, clients)
	local list = "- " .. table.concat(names, "\n- ")
	vim.notify(list, nil, { title = "Restarting LSPs", icon = "󰑓" })
	vim.lsp.enable(names, false)
	vim.lsp.enable(names, true)
end, { desc = "󰑓 LSP Restart" })
