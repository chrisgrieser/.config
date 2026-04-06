---META-------------------------------------------------------------------------
-- save before quitting (non-unique, since also set by Neovide)
Keymap { "<D-q>", vim.cmd.wqall, desc = " Save & quit", unique = false }

Keymap {
	"<D-C-t>", -- `hyper` gets registered by Neovide as `cmd+ctrl` (`<D-C-`)
	function() require("personal-plugins.misc").openCwdInTerminal() end,
	desc = " Open cwd in Terminal",
	mode = { "n", "x", "i" },
}

Keymap {
	"<D-,>",
	function()
		local pathOfThisLuaFile = debug.getinfo(1, "S").source:gsub("^@", "")
		vim.cmd.edit(pathOfThisLuaFile)
	end,
	desc = "󰌌 Edit keybindings",
}

Keymap {
	"<leader>pd",
	function() vim.ui.open(vim.fn.stdpath("data")) end,
	desc = "󰝰 Local data dir",
}

---NAVIGATION-------------------------------------------------------------------
-- make mappings work on wrapped lines as well
Keymap { "j", "gj", mode = { "n", "x" } }
Keymap { "k", "gk", mode = { "n", "x" } }

-- make HJKL behave like hjkl but with bigger distance
Keymap { "J", "6gj", mode = { "n", "x" } }
Keymap { "K", "6gk", mode = { "n", "x" } }

-- Jump history
Keymap { "<C-h>", "<C-o>", desc = "󱋿 Jump back" }
Keymap { "<C-l>", "<C-i>", desc = "󱋿 Jump forward", unique = false }

-- Search
Keymap { "-", "/" }
Keymap { "-", "<Esc>/\\%V", mode = "x", desc = " Search within selection" }

-- Diagnostics
Keymap { "ge", "]d", desc = "󰋽 Next diagnostic", remap = true }
Keymap { "gE", "[d", desc = "󰋽 Previous diagnostic", remap = true }

-- [g]oto [m]atching parenthesis (`remap` needed to use builtin `MatchIt` plugin)
Keymap { "gm", "%", desc = "󰅪 Goto match", remap = true }

-- Open URL in file
Keymap {
	"<D-U>",
	function()
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		for _, line in ipairs(lines) do
			local url = line:match("%l+://[^%s%)%]}\"'`>]+")
			if url then return vim.ui.open(url) end
		end
		vim.notify("No URL found in file.", vim.log.levels.WARN)
	end,
	desc = " Open URL in buffer",
}

---MARKS------------------------------------------------------------------------
do
	local marks = require("personal-plugins.marks")

	marks.loadSigns()
	if vim.g.whichkeyAddSpec then vim.g.whichkeyAddSpec { "<leader>m", group = "󰃀 Marks" } end

	Keymap { "<leader>mm", marks.cycleMarks, desc = "󰃀 Cycle marks" }
	Keymap { "<leader>ma", marks.setUnsetA, desc = "󰃅 Set A" }
	Keymap { "<leader>mb", marks.setUnsetB, desc = "󰃅 Set B" }
end

---EDITING----------------------------------------------------------------------

-- Undo
Keymap { "u", "<cmd>silent undo<CR>zv", desc = "󰜊 Silent undo" }
Keymap { "U", "<cmd>silent redo<CR>zv", desc = "󰛒 Silent redo" }
Keymap { "<leader>uu", ":earlier ", desc = "󰜊 Undo to earlier" }
Keymap { "<leader>ur", function() vim.cmd.later(vim.o.undolevels) end, desc = "󰛒 Redo all" }

Keymap {
	"<leader>ut",
	function()
		if not package.loaded["undotree"] then
			vim.cmd.packadd("nvim.undotree")
			vim.api.nvim_create_autocmd("FileType", {
				desc = "User: undotree settings",
				pattern = "nvim-undotree",
				callback = function(ctx) Keymap { "q", vim.cmd.close, buf = ctx.buf, nowait = true } end,
			})
		end
		require("undotree").open()
	end,
	desc = "󰋚 Undo tree",
}

-- Duplicate
Keymap {
	"ww",
	function() require("personal-plugins.misc").smartDuplicate() end,
	desc = "󰲢 Duplicate line",
	unique = false, -- not unique to overwrite mapping from mini.operators
}

-- stylua: ignore
Keymap { "<", function() require("personal-plugins.misc").toggleTitleCase() end, desc = "󰬴 Toggle lower/Title case" }
Keymap { ">", "gUiw", desc = "󰬴 Uppercase cword" }

-- Toggles
-- stylua: ignore
Keymap { "+", function() require("personal-plugins.misc").toggleOrIncrement() end, desc = "󰐖 Increment/toggle" }
Keymap { "ü", "<C-x>", desc = "󰍵 Decrement" }
Keymap { "~", "v~", desc = "󰬴 Toggle char case (w/o moving)" }

Keymap {
	"X",
	function()
		local updatedLine = vim.api.nvim_get_current_line():sub(1, -2)
		vim.api.nvim_set_current_line(updatedLine)
	end,
	desc = "󱎘 Delete char at EoL",
}

-- Append to EoL: `<leader>` + `char`
local trailChars = { ",", ")", ";", ".", '"', "'", " \\", " {", "?" }
for _, chars in pairs(trailChars) do
	Keymap {
		"<leader>" .. vim.trim(chars),
		function()
			local updatedLine = vim.api.nvim_get_current_line() .. chars
			vim.api.nvim_set_current_line(updatedLine)
		end,
	}
end

-- Spelling
Keymap { "z.", "1z=", desc = "󰓆 Fix spelling" } -- works even with `spell=false`
Keymap {
	"zl",
	function()
		local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
		suggestions = vim.list_slice(suggestions, 1, 9)
		vim.ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" }, function(selection)
			if not selection then return end
			vim.cmd.normal { '"_ciw' .. selection, bang = true }
		end)
	end,
	desc = "󰓆 Spell suggestions",
}

-- Template strings
Keymap {
	"<D-t>",
	function() require("personal-plugins.auto-template-str").insertTemplateStr() end,
	mode = "i",
	desc = "󰅳 Insert template string",
}

-- Edits repeatable via `.`
Keymap { "<D-j>", '*N"_cgn', desc = "󰆿 Repeatable edit (cword)" }
Keymap {
	"<D-j>",
	function()
		assert(vim.fn.mode() == "v", "Only visual (character) mode.")
		local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
		vim.fn.setreg("/", "\\V" .. vim.fn.escape(selection, [[/\]]))
		return '<Esc>"_cgn'
	end,
	mode = "x",
	desc = "󰆿 Repeatable edit (selection)",
	expr = true,
}

-- Merge lines
Keymap { "m", "J", desc = "󰽜 Merge line up" }
Keymap { "M", "<cmd>. move +1<CR>kJ", desc = "󰽜 Merge line down" } -- `:move` preserves marks

-- Markdown inline comments (useful to have in all filetypes for comments)
Keymap {
	"<D-e>",
	function() require("personal-plugins.md-qol").wrap("`") end,
	mode = { "n", "x", "i" },
	desc = " Inline code",
}

-- Simple surrounds
-- stylua: ignore start
Keymap { '"', function() require("personal-plugins.md-qol").wrap('"') end, desc = " Surround" }
Keymap { "'", function() require("personal-plugins.md-qol").wrap("'") end, desc = " Surround" }
Keymap { "(", function() require("personal-plugins.md-qol").wrap("(", ")") end, desc = "󰅲 Surround" }
Keymap { "[", function() require("personal-plugins.md-qol").wrap("[", "]") end, nowait = true, desc = "󰅪 Surround" }
Keymap { "{", function() require("personal-plugins.md-qol").wrap("{", "}") end, desc = " Surround" }
-- stylua: ignore end

---AI REWRITE-------------------------------------------------------------------
do
	if vim.g.whichkeyAddSpec then vim.g.whichkeyAddSpec { "<leader>a", group = "󰚩 AI" } end
	-- stylua: ignore start
	Keymap{ "<leader>aa", function() require("personal-plugins.ai-rewrite").task() end, mode = { "n", "x" }, desc = "󰘎 Prompt" }
	Keymap{ "<leader>as", function() require("personal-plugins.ai-rewrite").task("simplify") end, mode = { "n", "x" }, desc = "󰚩 Simplify" }
	Keymap{ "<leader>af", function() require("personal-plugins.ai-rewrite").task("fix") end, mode = { "n", "x" }, desc = "󰚩 Fix" }
	Keymap{ "<leader>ac", function() require("personal-plugins.ai-rewrite").task("complete") end, mode = { "n", "x" }, desc = "󰚩 Complete" }
	-- stylua: ignore end
end

---WHITESPACE & INDENTATION-----------------------------------------------------
Keymap { "=", "[<Space>", desc = " Blank above", remap = true } -- remap, since nvim default
Keymap { "_", "]<Space>", desc = " Blank below", remap = true }

Keymap { "<Tab>", ">>", desc = "󰉶 indent" }
Keymap { "<Tab>", ">gv", mode = "x", desc = "󰉶 indent" }
Keymap { "<Tab>", "<C-t>", mode = "i", desc = "󰉶 indent", unique = false }
Keymap { "<S-Tab>", "<<", desc = "󰉵 outdent" }
Keymap { "<S-Tab>", "<gv", mode = "x", desc = "󰉵 outdent" }
Keymap { "<S-Tab>", "<C-d>", mode = "i", desc = "󰉵 outdent", unique = false }

---QUICKFIX---------------------------------------------------------------------
Keymap { "gq", "<cmd>silent cnext<CR>zv", desc = "󰴩 Next quickfix" }
Keymap { "gQ", "<cmd>silent cprev<CR>zv", desc = "󰴩 Prev quickfix" }
Keymap { "<leader>qr", function() vim.cmd.cexpr("[]") end, desc = "󰚃 Remove qf items" }
Keymap { "<leader>q1", "<cmd>silent cfirst<CR>zv", desc = "󰴩 Goto 1st quickfix" }
Keymap {
	"<leader>qq",
	function()
		local quickfixWinOpen = vim.fn.getqflist({ winid = true }).winid ~= 0
		vim.cmd(quickfixWinOpen and "cclose" or "copen")
	end,
	desc = " Toggle quickfix window",
}

---FOLDING----------------------------------------------------------------------
Keymap { "zz", "<cmd>%foldclose<CR>", desc = " Close toplevel folds" }
Keymap { "zm", "zM", desc = " Close all folds" }
Keymap { "zv", "zv", desc = "󰘖 Open until cursor visible" } -- just for which-key
Keymap { "zr", "zR", desc = "󰘖 Open all folds" }
Keymap {
	"zf",
	function() vim.opt.foldlevel = vim.v.count1 end,
	desc = " Set fold level to {count}",
}

---YANKING----------------------------------------------------------------------

do -- STICKY YANK
	Keymap {
		"y",
		function()
			vim.b.preYankCursor = vim.api.nvim_win_get_cursor(0)
			return "y"
		end,
		expr = true,
		mode = { "n", "x" },
	}
	Keymap {
		"Y",
		function()
			vim.b.preYankCursor = vim.api.nvim_win_get_cursor(0)
			return "y$"
		end,
		expr = true,
		unique = false, -- since nvim default
	}

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Sticky yank",
		callback = function()
			if vim.v.event.operator == "y" and vim.b.preYankCursor then
				vim.api.nvim_win_set_cursor(0, vim.b.preYankCursor)
				vim.b.preYankCursor = nil
			end
		end,
	})
end

do -- YANKRING
	-- When undoing the paste and then using `.`, will paste `"2p`, thus `<D-p>...`
	-- pastes all recent things and `<D-p>u.u.u.u.`, cycles through them
	Keymap { "<D-p>", '"1p', desc = " Paste from yankring" }

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Yankring",
		callback = function()
			if vim.v.event.operator ~= "y" then return end
			for i = 9, 1, -1 do -- shift all numbered registers
				vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
			end
		end,
	})
end

-- keep the register clean
Keymap { "x", '"_x', mode = { "n", "x" } }
Keymap { "c", '"_c', mode = { "n", "x" } }
Keymap { "C", '"_C' }
Keymap { "p", "P", mode = "x" }
Keymap {
	"dd",
	function() -- `dd` should not put empty lines into the register
		local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
		return (lineEmpty and '"_dd' or "dd")
	end,
	expr = true,
}

---PASTING----------------------------------------------------------------------
Keymap {
	"P",
	function()
		local reg = "+"
		require("personal-plugins.md-qol").addTitleToUrlIfMarkdown(reg)
		local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
		local clipb = vim.trim(vim.fn.getreg(reg))
		vim.api.nvim_set_current_line(curLine .. " " .. clipb)
	end,
	desc = " Paste at EoL",
}

-- insert mode paste
-- 1. trim if register
-- 2. add undopoint before the paste
-- 3. skip auto-indent
Keymap {
	"<D-v>",
	function()
		local reg = "+"
		vim.fn.setreg(reg, vim.trim(vim.fn.getreg(reg))) -- trim
		if vim.fn.mode() == "R" then return "<C-r>" .. reg end
		require("personal-plugins.md-qol").addTitleToUrlIfMarkdown(reg)
		return "<C-g>u<C-r><C-o>" .. reg -- `<C-g>u` adds undopoint before, `<C-r><C-o>` skips auto-indent
	end,
	mode = "i",
	desc = " Paste",
	expr = true,
}

-- default paste
Keymap { "p", "]p", desc = " Paste & indent" }

-- compatibility w/ macOS clipboard managers; remap to inherit changes to `p`
Keymap { "<D-v>", "p", desc = " Paste", remap = true }

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
	Keymap { "i" .. remap, "i" .. original, mode = { "o", "x" }, desc = icon .. " inner " .. label }
	Keymap { "a" .. remap, "a" .. original, mode = { "o", "x" }, desc = icon .. " outer " .. label }
end

Keymap { "J", "2j", mode = "o" } -- `dd` = 1 line, `dj` = 2 lines, `dJ` = 3 lines
Keymap { "<Space>", '"_ciw', desc = "󰬞 Change word" }
Keymap { "<Space>", '"_c', mode = "x", desc = "󰒅 Change selection" }
Keymap { "<S-Space>", '"_daw', desc = "󰬞 Delete word" }

---COMMENTS---------------------------------------------------------------------
-- requires `remap` or method from: https://www.reddit.com/r/neovim/comments/1ctc1zd/comment/l4c29rx/
Keymap { "q", "gc", mode = { "n", "x" }, desc = "󰆈 Comment operator", remap = true }
Keymap { "qq", "gcc", desc = "󰆈 Comment line", remap = true }
do
	Keymap { "u", "gc", mode = "o", desc = "󰆈 Multiline comment", remap = true }
	Keymap { "guu", "guu" } -- prevent previous keymap from overwriting `guu` (lowercase line)
end

do
	local com = require("personal-plugins.comment")
	Keymap { "qw", com.commentHr, desc = "󰆈 Divider" }
	Keymap { "qr", function() com.commentHr("replaceMode") end, desc = "󰆈 Divider + label" }
	Keymap { "wq", com.duplicateLineAsComment, desc = "󰆈 Duplicate line as comment" }
	Keymap { "Q", function() com.addComment("eol") end, desc = "󰆈 Add comment at EoL" }
	Keymap { "qO", function() com.addComment("above") end, desc = "󰆈 Add comment above" }
	Keymap { "qo", function() com.addComment("below") end, desc = "󰆈 Add comment below" }
	com.setupReplaceModeHelpersForComments()
end

---LINE & CHARACTER MOVEMENT----------------------------------------------------
Keymap { "<Down>", "<cmd>. move +1<CR>==", desc = "󰜮 Move line down" }
Keymap { "<Up>", "<cmd>. move -2<CR>==", desc = "󰜷 Move line up" }
Keymap { "<Right>", [["zx"zp]], desc = "➡️ Move char right" }
Keymap { "<Left>", [["zdh"zph]], desc = "⬅ Move char left" }
Keymap {
	"<Down>",
	[[:move '>+1<CR>gv=gv]],
	mode = "x",
	desc = "󰜮 Move selection down",
	silent = true,
}
Keymap {
	"<Up>",
	[[:move '<-2<CR>gv=gv]],
	mode = "x",
	desc = "󰜷 Move selection up",
	silent = true,
}
Keymap { "<Right>", [["zx"zpgvlolo]], mode = "x", desc = "➡️ Move selection right" }
Keymap { "<left>", [["zxhh"zpgvhoho]], mode = "x", desc = "⬅ Move selection left" }

---LSP--------------------------------------------------------------------------
Keymap { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "x" }, desc = "󱐋 Code action" }

Keymap {
	"<leader>h",
	function() vim.lsp.buf.hover { max_width = 80 } end,
	mode = { "n", "x" },
	desc = "󰋽 LSP hover",
}

Keymap {
	"<PageDown>",
	function() require("personal-plugins.misc").scrollLspOrOtherWin(5) end,
	desc = "↓ Scroll other win",
}
Keymap {
	"<PageUp>",
	function() require("personal-plugins.misc").scrollLspOrOtherWin(-5) end,
	desc = "↑ Scroll other win",
}

---VARIOUS MODES----------------------------------------------------------------

-- insert mode
Keymap {
	"i",
	function()
		local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
		return lineEmpty and '"_cc' or "i"
	end,
	expr = true,
	desc = "indented i on empty line",
}

-- visual mode
Keymap { "V", "j", mode = "x", desc = "repeated `V` selects more lines" }
Keymap { "v", "<C-v>", mode = "x", desc = "`vv` starts visual block" }

-- terminal mode
Keymap { "<C-CR>", [[<C-\><C-n><C-w>w]], mode = "t", desc = " Goto next window" }
Keymap { "<Esc>", [[<C-\><C-n>]], mode = "t", desc = " Esc" }
Keymap { "<D-v>", [[<C-\><C-n>pi]], mode = "t", desc = " Paste" }

-- cmdline mode
Keymap {
	"<D-v>",
	function()
		vim.fn.setreg("+", vim.trim(vim.fn.getreg("+")))
		return "<C-r>+"
	end,
	mode = "c",
	expr = true,
	desc = " Paste",
}

Keymap {
	"<D-c>",
	function()
		local cmdline = vim.fn.getcmdline()
		if cmdline == "" then return vim.notify("Nothing to copy.", vim.log.levels.WARN) end
		vim.fn.setreg("+", cmdline)
		vim.notify(cmdline, nil, { title = "Copied", icon = "󰅍" })
	end,
	mode = "c",
	desc = "󰅍 Yank cmdline",
}

Keymap {
	"<BS>",
	function()
		if vim.fn.getcmdline() ~= "" then return "<BS>" end
	end,
	expr = true,
	mode = "c",
	desc = "disable <BS> when cmdline is empty",
}

Keymap { "<C-a>", "<C-b>", mode = "c", desc = "Goto start of cmdline" }
Keymap { "<D-Left>", "<C-b>", mode = "c", desc = "Goto start of cmdline" }
Keymap { "<D-Right>", "<C-e>", mode = "c", desc = "Goto end of cmdline" }

---INSPECT & EVAL---------------------------------------------------------------
Keymap { "<leader>ii", vim.cmd.Inspect, desc = "󱈄 Inspect at cursor" }
Keymap { "<leader>it", vim.cmd.InspectTree, desc = " TS syntax tree" }

Keymap {
	"<leader>ia",
	function() require("personal-plugins.misc").inspectNodeAncestors() end,
	desc = " Node ancestors",
}
Keymap {
	"<leader>iL",
	function() vim.cmd.edit(vim.lsp.log.get_filename()) end,
	desc = "󱂅 LSP log",
}
Keymap {
	"<leader>ib",
	function() require("personal-plugins.misc").inspectBuffer() end,
	desc = "󰽙 Buffer info",
}
Keymap {
	"<leader>i+",
	function() require("personal-plugins.misc").sumOfAllNumbersInBuf() end,
	mode = { "n", "x" },
	desc = "∑ Sum of numbers in buffer",
}

Keymap {
	"<leader>id",
	function()
		local diag = vim.diagnostic.get_next()
		vim.notify(vim.inspect(diag), nil, { ft = "lua" })
	end,
}

Keymap {
	"<leader>ee",
	function()
		local selection = vim.fn.mode() == "n" and ""
			or vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
		return ":lua = " .. selection
	end,
	expr = true,
	mode = { "n", "x" },
	desc = "󰢱 Eval lua expr",
}

Keymap {
	"<leader>ey",
	function()
		local cmd = vim.trim(vim.fn.getreg(":"))
		local lastExcmd = cmd:gsub("^lua ", ""):gsub("^= ?", "")
		if lastExcmd == "" then return vim.notify("Nothing to copy", vim.log.levels.TRACE) end
		local syntax = vim.startswith(cmd, "lua") and "lua" or "vim"
		vim.notify(lastExcmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
		vim.fn.setreg("+", lastExcmd)
	end,
	desc = " Yank last ex-cmd",
}

---WINDOWS & SPLITS-------------------------------------------------------------
Keymap { "<C-CR>", "<C-w>w", mode = { "n", "v", "i" }, desc = " Cycle windows" }
Keymap { "<C-v>", "<cmd>vertical split #<CR>", mode = { "n", "x", "i" }, desc = " Split altfile" }
Keymap { "<D-W>", vim.cmd.only, mode = { "n", "x", "i" }, desc = " Close other windows" }

Keymap { "<C-Up>", "<C-w>3-", mode = { "n", "v", "i" } }
Keymap { "<C-Down>", "<C-w>3+", mode = { "n", "v", "i" } }
Keymap { "<C-Left>", "<C-w>5<", mode = { "n", "v", "i" } }
Keymap { "<C-Right>", "<C-w>5>", mode = { "n", "v", "i" } }

---BUFFERS & FILES--------------------------------------------------------------

-- stylua: ignore start
Keymap{"<CR>", function() require("personal-plugins.magnet").gotoAltFile() end,  mode = { "n", "x" }, desc = "󰬈 Goto alt-file" }
Keymap{"<D-CR>", function() require("personal-plugins.magnet").gotoMostChangedFile() end,  mode = { "n", "x" }, desc = "󰊢 Goto most changed file" }
-- stylua: ignore end

Keymap {
	"<D-w>",
	function()
		vim.cmd("silent! update")
		local winClosed = pcall(vim.cmd.close) -- fails on last window
		if winClosed then return end
		local bufCount = #vim.fn.getbufinfo { buflisted = 1 }
		if bufCount == 1 then return vim.notify("Only one buffer open.", vim.log.levels.TRACE) end
		vim.cmd.bdelete()
	end,
	mode = { "n", "x", "i" },
	desc = "󰽙 Close window/buffer",
}

Keymap {
	"<BS>",
	function()
		if vim.bo.buftype ~= "" then return end -- prevent accidental triggering in special buffers
		vim.cmd.bprevious()
	end,
	desc = "󰽙 Prev buffer",
}
Keymap { "<S-BS>", vim.cmd.bnext, desc = "󰽙 Next buffer" }

Keymap {
	"<D-L>",
	function() require("personal-plugins.misc").openWorkflowInAlfredPrefs() end,
	mode = { "n", "x", "i" },
	desc = "󰮤 Reveal in Alfred",
}

---MACROS-----------------------------------------------------------------------
do
	local reg = "r"
	local toggleKey = "0"

	vim.fn.setreg(reg, "") -- clear on startup to avoid accidents
	-- stylua: ignore
	Keymap{toggleKey, function() require("personal-plugins.misc").startOrStopRecording(toggleKey, reg) end,  desc = "󰃽 Start/stop recording" }
	-- stylua: ignore
	Keymap{"9", function() require("personal-plugins.misc").playRecording(reg) end,  desc = "󰃽 Play recording" }
end

---REFACTORING------------------------------------------------------------------
Keymap { "<leader>rr", vim.lsp.buf.rename, desc = "󰑕 LSP rename" }
Keymap {
	"<leader>rq",
	function()
		local updatedLine =
			vim.api.nvim_get_current_line():gsub("[\"']", { ['"'] = "'", ["'"] = '"' })
		vim.api.nvim_set_current_line(updatedLine)
	end,
	desc = " Switch quotes in line",
}
Keymap {
	"<leader>rc",
	function() require("personal-plugins.misc").camelSnakeLspRename() end,
	desc = "󰑕 LSP rename: camel/snake",
}

---OPTION TOGGLING--------------------------------------------------------------
Keymap { "<leader>on", "<cmd>set number!<CR>", desc = " Line numbers" }
Keymap { "<leader>ow", "<cmd>set wrap!<CR>", desc = "󰖶 Wrap" }

Keymap {
	"<leader>od",
	function()
		local isEnabled = vim.diagnostic.is_enabled { bufnr = 0 }
		vim.diagnostic.enable(not isEnabled, { bufnr = 0 })
	end,
	desc = "󰋽 Diagnostics",
}

Keymap {
	"<leader>or",
	function()
		local isEnabled = vim.lsp.codelens.is_enabled { bufnr = 0 }
		vim.lsp.codelens.enable(not isEnabled, { bufnr = 0 })
	end,
	desc = "󰈿 References (CodeLens)",
}

Keymap {
	"<leader>oc",
	function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0 end,
	desc = "󰈉 Conceal",
}

Keymap {
	"<leader>ol",
	function()
		vim.cmd.lsp("restart")
		vim.notify("Restarting LSPs", vim.log.levels.DEBUG)
	end,
	desc = "󰑓 LSP restart",
}

--------------------------------------------------------------------------------
